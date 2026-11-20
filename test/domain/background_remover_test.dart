import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:outfitly/domain/services/background_remover.dart';

Uint8List image(int w, int h, List<int> Function(int x, int y) color) {
  final out = Uint8List(w * h * 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final c = color(x, y);
      final i = (y * w + x) * 4;
      out[i] = c[0];
      out[i + 1] = c[1];
      out[i + 2] = c[2];
      out[i + 3] = 255;
    }
  }
  return out;
}

int alphaAt(Uint8List rgba, int w, int x, int y) => rgba[(y * w + x) * 4 + 3];

void main() {
  const remover = FloodFillBackgroundRemover(feather: 0);

  test('removes a plain white background and keeps the garment', () {
    // Navy "shirt" rectangle on white.
    final px = image(60, 60, (x, y) => (x >= 15 && x < 45 && y >= 10 && y < 50) ? [25, 35, 80] : [248, 248, 248]);
    final out = remover.remove(px, 60, 60)!;
    expect(alphaAt(out, 60, 2, 2), 0, reason: 'corner background removed');
    expect(alphaAt(out, 60, 30, 30), 255, reason: 'garment kept');
  });

  test('keeps enclosed background-coloured areas (e.g. a white logo inside the shirt)', () {
    final px = image(60, 60, (x, y) {
      final inShirt = x >= 10 && x < 50 && y >= 10 && y < 50;
      final logo = x >= 25 && x < 35 && y >= 25 && y < 35;
      if (logo) return [248, 248, 248];
      return inShirt ? [200, 30, 40] : [248, 248, 248];
    });
    final out = remover.remove(px, 60, 60)!;
    expect(alphaAt(out, 60, 30, 30), 255, reason: 'logo is enclosed, not connected to the border');
    expect(alphaAt(out, 60, 1, 1), 0);
  });

  test('gives up on busy backgrounds instead of producing garbage', () {
    final px = image(40, 40, (x, y) => [(x * 37) % 256, (y * 53) % 256, ((x + y) * 29) % 256]);
    expect(remover.remove(px, 40, 40), isNull);
  });

  test('gives up when the photo is a single flat colour', () {
    final px = image(30, 30, (_, _) => [120, 120, 120]);
    expect(remover.remove(px, 30, 30), isNull);
  });

  test('feathering softens the edge', () {
    const soft = FloodFillBackgroundRemover(feather: 2);
    final px = image(60, 60, (x, y) => (x >= 15 && x < 45 && y >= 10 && y < 50) ? [25, 35, 80] : [248, 248, 248]);
    final out = soft.remove(px, 60, 60)!;
    final edge = alphaAt(out, 60, 15, 30);
    expect(edge, inExclusiveRange(0, 255));
    expect(alphaAt(out, 60, 30, 30), 255);
  });
}
