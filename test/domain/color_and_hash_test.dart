import 'package:flutter_test/flutter_test.dart';
import 'package:outfitly/domain/services/color_analyzer.dart';
import 'package:outfitly/domain/services/duplicate_detector.dart';
import 'package:outfitly/domain/wardrobe_enums.dart';

List<int> solidWithCenter(int w, int h, List<int> bg, List<int> fg) {
  final out = <int>[];
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final inCenter = x > w * 0.2 && x < w * 0.8 && y > h * 0.2 && y < h * 0.8;
      out.addAll([...(inCenter ? fg : bg), 255]);
    }
  }
  return out;
}

void main() {
  group('ColorAnalyzer', () {
    const a = ColorAnalyzer();

    test('ignores a white photo background and finds the garment colour', () {
      final px = solidWithCenter(48, 48, [250, 250, 250], [25, 35, 80]);
      expect(a.analyze(px, 48, 48).named.name, 'Navy');
    });

    test('a white garment on white still resolves to white', () {
      final px = solidWithCenter(48, 48, [250, 250, 250], [245, 245, 245]);
      expect(a.analyze(px, 48, 48).named.name, 'White');
    });

    test('red on a dark background', () {
      final px = solidWithCenter(48, 48, [30, 30, 30], [205, 30, 35]);
      expect(a.analyze(px, 48, 48).named.name, 'Red');
    });

    test('hsl and hue distance helpers', () {
      expect(toHsl(255, 0, 0).h, closeTo(0, 0.01));
      expect(toHsl(0, 0, 255).h, closeTo(240, 0.01));
      expect(hueDistance(350, 10), 20);
      expect(parseHex('#C2643C'), (r: 0xC2, g: 0x64, b: 0x3C));
    });
  });

  group('DuplicateDetector', () {
    const d = DuplicateDetector();
    final gradient = [
      for (var y = 0; y < 8; y++)
        for (var x = 0; x < 9; x++) x * 20 + y,
    ];

    test('identical images hash identically', () {
      expect(d.hash(gradient), d.hash(List.of(gradient)));
      expect(d.distance(d.hash(gradient), d.hash(gradient)), 0);
    });

    test('small brightness change is still similar; reversed image is not', () {
      final brighter = gradient.map((v) => v + 10).toList();
      expect(d.isSimilar(d.hash(gradient), d.hash(brighter)), isTrue);
      final reversed = [
        for (var y = 0; y < 8; y++)
          for (var x = 0; x < 9; x++) (8 - x) * 20 + y,
      ];
      expect(d.isSimilar(d.hash(gradient), d.hash(reversed)), isFalse);
    });

    test('rejects wrong input size', () {
      expect(() => d.hash([1, 2, 3]), throwsArgumentError);
    });
  });

  group('bitmasks', () {
    test('untagged items match anything', () {
      expect(maskMatches(0, Season.winter.bit), isTrue);
      expect(maskMatches(Season.summer.bit, Season.winter.bit), isFalse);
      expect(maskMatches(Season.summer.bit | Season.winter.bit, Season.winter.bit), isTrue);
      expect(seasonsOf(maskOf([Season.spring.bit, Season.autumn.bit])), [Season.spring, Season.autumn]);
    });
  });
}
