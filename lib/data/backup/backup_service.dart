import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../db/app_database.dart';

class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

class RestoreSummary {
  const RestoreSummary(this.items, this.outfits, this.calendarEntries);
  final int items, outfits, calendarEntries;
}

/// Local, serverless backup: one ZIP containing `outfitly.json` plus the image files.
class BackupService {
  BackupService(this.db, this.rootDir);

  final AppDatabase db;
  final String rootDir;

  static const formatVersion = 1;
  static const manifestName = 'outfitly.json';

  Future<Uint8List> export() async {
    final items = await db.select(db.clothingItems).get();
    final outfits = await db.select(db.outfits).get();
    final outfitItems = await db.select(db.outfitItems).get();
    final calendar = await db.select(db.calendarEntries).get();
    final wear = await db.select(db.wearLogs).get();

    final manifest = {
      'app': 'outfitly',
      'formatVersion': formatVersion,
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'clothingItems': items.map((e) => e.toJson()).toList(),
      'outfits': outfits.map((e) => e.toJson()).toList(),
      'outfitItems': outfitItems.map((e) => e.toJson()).toList(),
      'calendarEntries': calendar.map((e) => e.toJson()).toList(),
      'wearLogs': wear.map((e) => e.toJson()).toList(),
    };

    final archive = Archive()..addFile(ArchiveFile.string(manifestName, jsonEncode(manifest)));
    for (final i in items) {
      for (final rel in [i.imagePath, i.thumbPath, ?i.cutoutPath]) {
        final f = File(p.join(rootDir, rel));
        if (await f.exists()) {
          archive.addFile(ArchiveFile.bytes(p.posix.joinAll(p.split(rel)), await f.readAsBytes()));
        }
      }
    }
    return ZipEncoder().encodeBytes(archive);
  }

  /// Replaces all local data with the backup. Validates everything before touching the database.
  Future<RestoreSummary> restore(Uint8List zipBytes) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      throw BackupException('This file is not a valid Outfitly backup (unreadable ZIP).');
    }
    final manifestFile = archive.findFile(manifestName);
    if (manifestFile == null) throw BackupException('Backup is missing $manifestName.');

    final Map<String, dynamic> m;
    try {
      m = jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException('Backup data is corrupt.');
    }
    if (m['app'] != 'outfitly') throw BackupException('This backup was not created by Outfitly.');
    final v = m['formatVersion'];
    if (v is! int || v > formatVersion) {
      throw BackupException('This backup was made by a newer version of Outfitly. Please update the app first.');
    }

    List<T> parse<T>(String key, T Function(Map<String, dynamic>) f) {
      final raw = m[key];
      if (raw is! List) throw BackupException('Backup is missing "$key".');
      try {
        return raw.map((e) => f(e as Map<String, dynamic>)).toList();
      } catch (_) {
        throw BackupException('Backup section "$key" is corrupt.');
      }
    }

    final items = parse('clothingItems', ClothingItem.fromJson);
    final outfits = parse('outfits', Outfit.fromJson);
    final outfitItems = parse('outfitItems', OutfitItem.fromJson);
    final calendar = parse('calendarEntries', CalendarEntry.fromJson);
    final wear = parse('wearLogs', WearLog.fromJson);

    // Write image files first; DB swap happens only once files are in place.
    final referenced = <String>{};
    for (final i in items) {
      for (final rel in [i.imagePath, i.thumbPath, ?i.cutoutPath]) {
        referenced.add(p.normalize(rel));
        final entry = archive.findFile(p.posix.joinAll(p.split(rel)));
        if (entry == null) continue; // Item survives without its photo; UI shows a placeholder.
        final dest = File(p.join(rootDir, rel));
        if (!p.isWithin(rootDir, dest.path)) throw BackupException('Backup contains an unsafe file path.');
        await dest.parent.create(recursive: true);
        await dest.writeAsBytes(entry.content, flush: true);
      }
    }

    await db.transaction(() async {
      await db.delete(db.wearLogs).go();
      await db.delete(db.calendarEntries).go();
      await db.delete(db.outfitItems).go();
      await db.delete(db.outfits).go();
      await db.delete(db.recentViews).go();
      await db.delete(db.clothingItems).go();
      await db.batch((b) {
        b.insertAll(db.clothingItems, items);
        b.insertAll(db.outfits, outfits);
        b.insertAll(db.outfitItems, outfitItems);
        b.insertAll(db.calendarEntries, calendar);
        b.insertAll(db.wearLogs, wear);
      });
    });

    // Remove orphaned image files from the previous wardrobe.
    for (final dir in ['images', 'thumbs', 'cutouts']) {
      final d = Directory(p.join(rootDir, dir));
      if (!await d.exists()) continue;
      await for (final f in d.list()) {
        if (f is File && !referenced.contains(p.normalize(p.relative(f.path, from: rootDir)))) {
          await f.delete();
        }
      }
    }
    return RestoreSummary(items.length, outfits.length, calendar.length);
  }

  /// Deletes every row and image. Used by Settings → Clear data.
  Future<void> wipe() async {
    await db.transaction(() async {
      await db.delete(db.wearLogs).go();
      await db.delete(db.calendarEntries).go();
      await db.delete(db.outfitItems).go();
      await db.delete(db.outfits).go();
      await db.delete(db.recentViews).go();
      await db.delete(db.clothingItems).go();
    });
    for (final dir in ['images', 'thumbs', 'cutouts']) {
      final d = Directory(p.join(rootDir, dir));
      if (await d.exists()) await d.delete(recursive: true);
    }
  }
}
