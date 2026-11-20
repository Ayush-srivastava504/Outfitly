import 'dart:collection';
import 'dart:typed_data';

import 'color_analyzer.dart';

/// Offline fallback background removal for product-style photos (garment on a plain background).
///
/// The background colour is estimated from the image border, then a flood fill from every border
/// pixel clears connected pixels that are close to it. Enclosed areas inside the garment are kept,
/// and alpha is feathered at the edge for a softer cut-out. Works without ML Kit / Play services.
class FloodFillBackgroundRemover {
  const FloodFillBackgroundRemover({this.tolerance = 48, this.feather = 2});

  /// Max colour distance (redmean) from the background estimate still treated as background.
  final double tolerance;

  /// Edge softening radius in pixels.
  final int feather;

  /// [rgba] is width*height*4 bytes. Returns a new RGBA buffer with the background made transparent,
  /// or null when the photo doesn't look like a plain background (nothing sensible to remove).
  Uint8List? remove(Uint8List rgba, int width, int height) {
    final n = width * height;
    if (rgba.length < n * 4 || n == 0) return null;

    // Background estimate: per-channel median of border pixels (robust to a garment touching the edge).
    final rs = <int>[], gs = <int>[], bs = <int>[];
    void sample(int x, int y) {
      final i = (y * width + x) * 4;
      rs.add(rgba[i]);
      gs.add(rgba[i + 1]);
      bs.add(rgba[i + 2]);
    }

    for (var x = 0; x < width; x++) {
      sample(x, 0);
      sample(x, height - 1);
    }
    for (var y = 1; y < height - 1; y++) {
      sample(0, y);
      sample(width - 1, y);
    }
    int median(List<int> v) => (v..sort())[v.length ~/ 2];
    final br = median(rs), bg = median(gs), bb = median(bs);

    bool isBg(int p) {
      final i = p * 4;
      return colorDistance(rgba[i], rgba[i + 1], rgba[i + 2], br, bg, bb) <= tolerance;
    }

    // Busy background check: if most of the border isn't close to the estimate, give up.
    var borderMatches = 0;
    for (var k = 0; k < rs.length; k++) {
      if (colorDistance(rs[k], gs[k], bs[k], br, bg, bb) <= tolerance) borderMatches++;
    }
    if (borderMatches < rs.length * 0.6) return null;

    final removed = Uint8List(n); // 1 = background
    final queue = Queue<int>();
    void seed(int p) {
      if (removed[p] == 0 && isBg(p)) {
        removed[p] = 1;
        queue.add(p);
      }
    }

    for (var x = 0; x < width; x++) {
      seed(x);
      seed((height - 1) * width + x);
    }
    for (var y = 0; y < height; y++) {
      seed(y * width);
      seed(y * width + width - 1);
    }
    while (queue.isNotEmpty) {
      final p = queue.removeFirst();
      final x = p % width, y = p ~/ width;
      if (x > 0) seed(p - 1);
      if (x < width - 1) seed(p + 1);
      if (y > 0) seed(p - width);
      if (y < height - 1) seed(p + width);
    }

    var kept = 0;
    for (var p = 0; p < n; p++) {
      if (removed[p] == 0) kept++;
    }
    // Nothing (or almost everything) removed → not a usable cut-out.
    if (kept < n * 0.03 || kept > n * 0.97) return null;

    final out = Uint8List.fromList(rgba);
    for (var p = 0; p < n; p++) {
      if (removed[p] == 1) {
        out[p * 4 + 3] = 0;
        continue;
      }
      if (feather <= 0) continue;
      // Feather: reduce alpha near removed pixels.
      final x = p % width, y = p ~/ width;
      var near = 0, total = 0;
      for (var dy = -feather; dy <= feather; dy++) {
        for (var dx = -feather; dx <= feather; dx++) {
          final nx = x + dx, ny = y + dy;
          if (nx < 0 || ny < 0 || nx >= width || ny >= height) continue;
          total++;
          if (removed[ny * width + nx] == 1) near++;
        }
      }
      if (near > 0) {
        final a = out[p * 4 + 3];
        out[p * 4 + 3] = (a * (1 - near / total * 0.8)).round();
      }
    }
    return out;
  }
}
