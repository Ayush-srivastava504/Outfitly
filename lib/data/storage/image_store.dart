import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../domain/services/color_analyzer.dart';
import '../../domain/services/duplicate_detector.dart';

class StoredImage {
  const StoredImage({required this.imagePath, required this.thumbPath, required this.colorHex, required this.colorName, required this.phash});
  final String imagePath; // relative
  final String thumbPath; // relative
  final String colorHex;
  final String colorName;
  final String phash;
}

/// Pixel analysis of an encoded image, run off the UI thread.
class ImageAnalysis {
  const ImageAnalysis(this.thumbJpg, this.colorHex, this.colorName, this.phash);
  final Uint8List thumbJpg;
  final String colorHex;
  final String colorName;
  final String phash;
}

ImageAnalysis analyzeImageBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Unsupported or corrupt image');
  final oriented = img.bakeOrientation(decoded);
  final thumb = img.copyResize(oriented, width: oriented.width >= oriented.height ? 400 : null, height: oriented.height > oriented.width ? 400 : null);
  final thumbJpg = img.encodeJpg(thumb, quality: 80);

  final small = img.copyResize(oriented, width: 48, height: 48);
  final rgba = small.convert(numChannels: 4).getBytes(order: img.ChannelOrder.rgba);
  final color = const ColorAnalyzer().analyze(rgba, 48, 48);

  final tiny = img.grayscale(img.copyResize(oriented, width: 9, height: 8));
  final luma = <int>[for (final px in tiny) px.r.toInt()];
  final hash = const DuplicateDetector().hash(luma);
  return ImageAnalysis(thumbJpg, color.hex, color.named.name, hash);
}

/// Saves compressed images + thumbnails under the app documents directory.
class ImageStore {
  ImageStore(this.rootDir);

  final String rootDir;
  static const _uuid = Uuid();

  String resolve(String relative) => p.join(rootDir, relative);

  Future<StoredImage> importImage(String sourcePath) async {
    final id = _uuid.v4();
    final imagesDir = Directory(p.join(rootDir, 'images'));
    final thumbsDir = Directory(p.join(rootDir, 'thumbs'));
    await imagesDir.create(recursive: true);
    await thumbsDir.create(recursive: true);

    final relImage = p.join('images', '$id.jpg');
    final relThumb = p.join('thumbs', '$id.jpg');

    Uint8List? full;
    try {
      // Native downscale + EXIF rotation; fast for 12MP camera shots.
      full = await FlutterImageCompress.compressWithFile(sourcePath, minWidth: 1600, minHeight: 1600, quality: 82);
    } catch (_) {
      full = null;
    }
    full ??= await File(sourcePath).readAsBytes();

    final analysis = await compute(analyzeImageBytes, full);
    await File(resolve(relImage)).writeAsBytes(full, flush: true);
    await File(resolve(relThumb)).writeAsBytes(analysis.thumbJpg, flush: true);

    return StoredImage(imagePath: relImage, thumbPath: relThumb, colorHex: analysis.colorHex, colorName: analysis.colorName, phash: analysis.phash);
  }

  Future<void> deleteFiles(Iterable<String> relativePaths) async {
    for (final r in relativePaths) {
      final f = File(resolve(r));
      if (await f.exists()) await f.delete();
    }
  }
}
