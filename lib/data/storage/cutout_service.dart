import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../domain/services/background_remover.dart';
import '../db/app_database.dart';
import 'image_store.dart';

/// Removes a photo's background. Implementations must never throw for "can't do it" — return null.
abstract class BackgroundRemovalEngine {
  /// Returns PNG bytes with a transparent background, or null.
  Future<Uint8List?> removeBackground(String imagePath);
}

/// Google ML Kit Subject Segmentation: on-device, free. The model is delivered by Google Play
/// services (declared in AndroidManifest so it downloads at install time).
class MlKitBackgroundRemoval implements BackgroundRemovalEngine {
  @override
  Future<Uint8List?> removeBackground(String imagePath) async {
    if (!Platform.isAndroid) return null;
    final segmenter = SubjectSegmenter(
      options: SubjectSegmenterOptions(
        enableForegroundBitmap: true,
        enableForegroundConfidenceMask: false,
        enableMultipleSubjects: SubjectResultOptions(enableConfidenceMask: false, enableSubjectBitmap: false),
      ),
    );
    try {
      final result = await segmenter.processImage(InputImage.fromFilePath(imagePath));
      final png = result.foregroundBitmap;
      if (png == null || png.isEmpty) return null;
      return await compute(_trimTransparent, png);
    } catch (e) {
      debugPrint('ML Kit segmentation unavailable: $e');
      return null;
    } finally {
      await segmenter.close();
    }
  }
}

/// Pure-Dart fallback for plain backgrounds; also used in tests.
class FloodFillBackgroundRemoval implements BackgroundRemovalEngine {
  const FloodFillBackgroundRemoval();

  @override
  Future<Uint8List?> removeBackground(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return compute(_floodFill, bytes);
  }
}

Uint8List? _floodFill(Uint8List encoded) {
  final decoded = img.decodeImage(encoded);
  if (decoded == null) return null;
  final oriented = img.bakeOrientation(decoded);
  // Work at ≤700px for speed; the cut-out is only shown on the avatar.
  final small = oriented.width > 700 || oriented.height > 700
      ? img.copyResize(oriented, width: oriented.width >= oriented.height ? 700 : null, height: oriented.height > oriented.width ? 700 : null)
      : oriented;
  final rgba = small.convert(numChannels: 4);
  final out = const FloodFillBackgroundRemover().remove(rgba.getBytes(order: img.ChannelOrder.rgba), rgba.width, rgba.height);
  if (out == null) return null;
  final result = img.Image.fromBytes(width: rgba.width, height: rgba.height, bytes: out.buffer, numChannels: 4, order: img.ChannelOrder.rgba);
  return _trimTransparent(img.encodePng(result));
}

/// Crops fully transparent margins so the garment fills its layer box on the avatar.
Uint8List _trimTransparent(Uint8List png) {
  final im = img.decodePng(png);
  if (im == null) return png;
  final withAlpha = im.numChannels == 4 ? im : im.convert(numChannels: 4);
  var minX = withAlpha.width, minY = withAlpha.height, maxX = -1, maxY = -1;
  for (final px in withAlpha) {
    if (px.a > 12) {
      if (px.x < minX) minX = px.x;
      if (px.x > maxX) maxX = px.x;
      if (px.y < minY) minY = px.y;
      if (px.y > maxY) maxY = px.y;
    }
  }
  if (maxX < 0) return png;
  final cropped = img.copyCrop(withAlpha, x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1);
  final scaled = cropped.width > 900 || cropped.height > 900
      ? img.copyResize(cropped, width: cropped.width >= cropped.height ? 900 : null, height: cropped.height > cropped.width ? 900 : null)
      : cropped;
  return img.encodePng(scaled, level: 6);
}

/// Creates and caches a background-removed PNG per item (ML Kit first, flood-fill fallback).
class CutoutService {
  CutoutService(this.db, this.images, {List<BackgroundRemovalEngine>? engines})
    : engines = engines ?? [MlKitBackgroundRemoval(), const FloodFillBackgroundRemoval()];

  final AppDatabase db;
  final ImageStore images;
  final List<BackgroundRemovalEngine> engines;

  /// Returns the updated item (with [ClothingItem.cutoutPath] set) or the unchanged item if no engine succeeded.
  Future<ClothingItem?> ensureCutout(ClothingItem item, {bool force = false}) async {
    if (item.cutoutPath != null && !force && await File(images.resolve(item.cutoutPath!)).exists()) return item;
    final source = images.resolve(item.imagePath);
    if (!await File(source).exists()) return item;

    Uint8List? png;
    for (final e in engines) {
      png = await e.removeBackground(source);
      if (png != null) break;
    }
    if (png == null) return item;

    // New filename per generation → no stale image-cache hits; old file removed.
    final rel = p.join('cutouts', '${item.id}_${DateTime.now().millisecondsSinceEpoch}.png');
    final file = File(images.resolve(rel));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(png, flush: true);
    await (db.update(db.clothingItems)..where((t) => t.id.equals(item.id))).write(ClothingItemsCompanion(cutoutPath: Value(rel)));
    if (item.cutoutPath != null && item.cutoutPath != rel) await images.deleteFiles([item.cutoutPath!]);
    return (db.select(db.clothingItems)..where((t) => t.id.equals(item.id))).getSingleOrNull();
  }
}
