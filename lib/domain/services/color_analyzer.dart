import 'dart:math' as math;

/// A named reference color.
class NamedColor {
  const NamedColor(this.name, this.r, this.g, this.b, {this.neutral = false});
  final String name;
  final int r, g, b;
  final bool neutral;

  String get hex => '#${_h(r)}${_h(g)}${_h(b)}';
  static String _h(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
}

const List<NamedColor> kNamedColors = [
  NamedColor('Black', 20, 20, 22, neutral: true),
  NamedColor('Charcoal', 64, 66, 72, neutral: true),
  NamedColor('Gray', 140, 140, 145, neutral: true),
  NamedColor('White', 245, 245, 245, neutral: true),
  NamedColor('Cream', 240, 230, 205, neutral: true),
  NamedColor('Beige', 215, 195, 160, neutral: true),
  NamedColor('Khaki', 175, 160, 115, neutral: true),
  NamedColor('Brown', 110, 70, 40, neutral: true),
  NamedColor('Camel', 190, 140, 85, neutral: true),
  NamedColor('Navy', 25, 35, 80, neutral: true),
  NamedColor('Denim', 70, 100, 145, neutral: true),
  NamedColor('Olive', 105, 110, 50, neutral: true),
  NamedColor('Red', 200, 35, 40),
  NamedColor('Burgundy', 115, 25, 40),
  NamedColor('Pink', 240, 150, 180),
  NamedColor('Orange', 240, 130, 40),
  NamedColor('Yellow', 240, 210, 60),
  NamedColor('Mustard', 200, 160, 40),
  NamedColor('Green', 50, 145, 70),
  NamedColor('Teal', 30, 125, 130),
  NamedColor('Sky Blue', 130, 190, 230),
  NamedColor('Blue', 40, 90, 200),
  NamedColor('Purple', 115, 60, 160),
  NamedColor('Lavender', 190, 170, 220),
];

NamedColor namedColorByName(String name) => kNamedColors.firstWhere((c) => c.name == name, orElse: () => kNamedColors.first);

/// Perceptual-ish RGB distance ("redmean" approximation).
double colorDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
  final rm = (r1 + r2) / 2;
  final dr = r1 - r2, dg = g1 - g2, db = b1 - b2;
  return math.sqrt((2 + rm / 256) * dr * dr + 4 * dg * dg + (2 + (255 - rm) / 256) * db * db);
}

NamedColor nearestNamedColor(int r, int g, int b) {
  NamedColor best = kNamedColors.first;
  var bestD = double.infinity;
  for (final c in kNamedColors) {
    final d = colorDistance(r, g, b, c.r, c.g, c.b);
    if (d < bestD) {
      bestD = d;
      best = c;
    }
  }
  return best;
}

({int r, int g, int b}) parseHex(String hex) {
  final v = int.parse(hex.replaceFirst('#', ''), radix: 16);
  return (r: (v >> 16) & 0xFF, g: (v >> 8) & 0xFF, b: v & 0xFF);
}

/// Hue in degrees 0..360, saturation and lightness 0..1.
({double h, double s, double l}) toHsl(int r, int g, int b) {
  final rf = r / 255, gf = g / 255, bf = b / 255;
  final mx = math.max(rf, math.max(gf, bf)), mn = math.min(rf, math.min(gf, bf));
  final l = (mx + mn) / 2;
  if (mx == mn) return (h: 0, s: 0, l: l);
  final d = mx - mn;
  final s = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn);
  double h;
  if (mx == rf) {
    h = ((gf - bf) / d) % 6;
  } else if (mx == gf) {
    h = (bf - rf) / d + 2;
  } else {
    h = (rf - gf) / d + 4;
  }
  h *= 60;
  if (h < 0) h += 360;
  return (h: h, s: s, l: l);
}

double hueDistance(double a, double b) {
  final d = (a - b).abs() % 360;
  return d > 180 ? 360 - d : d;
}

/// Result of analysing an image's pixels.
class ColorAnalysis {
  const ColorAnalysis(this.hex, this.named);
  final String hex;
  final NamedColor named;
}

/// Finds the dominant garment colour from raw RGBA pixels.
///
/// The background is estimated from the image border and pixels close to it are
/// ignored (unless that removes almost everything), then k-means (k=3) picks the
/// largest cluster.
class ColorAnalyzer {
  const ColorAnalyzer();

  ColorAnalysis analyze(List<int> rgba, int width, int height) {
    assert(rgba.length >= width * height * 4);
    final pixels = <List<int>>[];
    for (var i = 0; i < width * height; i++) {
      final a = rgba[i * 4 + 3];
      if (a < 128) continue;
      pixels.add([rgba[i * 4], rgba[i * 4 + 1], rgba[i * 4 + 2]]);
    }
    if (pixels.isEmpty) {
      final c = kNamedColors.first;
      return ColorAnalysis(c.hex, c);
    }

    // Background estimate: mean of border pixels.
    var br = 0, bg = 0, bb = 0, bn = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (x != 0 && y != 0 && x != width - 1 && y != height - 1) continue;
        final i = (y * width + x) * 4;
        br += rgba[i];
        bg += rgba[i + 1];
        bb += rgba[i + 2];
        bn++;
      }
    }
    br ~/= bn;
    bg ~/= bn;
    bb ~/= bn;
    var foreground = pixels.where((p) => colorDistance(p[0], p[1], p[2], br, bg, bb) > 60).toList();
    if (foreground.length < pixels.length * 0.1) foreground = pixels;

    final centroid = _kMeansLargest(foreground, 3);
    final named = nearestNamedColor(centroid[0], centroid[1], centroid[2]);
    final hex = '#${centroid.map((v) => v.toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';
    return ColorAnalysis(hex, named);
  }

  List<int> _kMeansLargest(List<List<int>> pts, int k) {
    k = math.min(k, pts.length);
    // Deterministic init: evenly spaced samples.
    final centers = List.generate(k, (i) => List<double>.from(pts[(i * pts.length) ~/ k].map((e) => e.toDouble())));
    final assign = List.filled(pts.length, 0);
    for (var iter = 0; iter < 10; iter++) {
      for (var i = 0; i < pts.length; i++) {
        var best = 0;
        var bestD = double.infinity;
        for (var c = 0; c < k; c++) {
          final dr = pts[i][0] - centers[c][0], dg = pts[i][1] - centers[c][1], db = pts[i][2] - centers[c][2];
          final d = dr * dr + dg * dg + db * db;
          if (d < bestD) {
            bestD = d;
            best = c;
          }
        }
        assign[i] = best;
      }
      final sums = List.generate(k, (_) => [0.0, 0.0, 0.0, 0.0]);
      for (var i = 0; i < pts.length; i++) {
        final s = sums[assign[i]];
        s[0] += pts[i][0];
        s[1] += pts[i][1];
        s[2] += pts[i][2];
        s[3] += 1;
      }
      for (var c = 0; c < k; c++) {
        if (sums[c][3] > 0) {
          centers[c] = [sums[c][0] / sums[c][3], sums[c][1] / sums[c][3], sums[c][2] / sums[c][3]];
        }
      }
    }
    final counts = List.filled(k, 0);
    for (final a in assign) {
      counts[a]++;
    }
    var largest = 0;
    for (var c = 1; c < k; c++) {
      if (counts[c] > counts[largest]) largest = c;
    }
    return centers[largest].map((v) => v.round().clamp(0, 255)).toList();
  }
}
