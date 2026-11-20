/// Perceptual difference hash (dHash) for spotting near-duplicate photos.
class DuplicateDetector {
  const DuplicateDetector({this.threshold = 6});

  /// Maximum Hamming distance still considered "looks similar".
  final int threshold;

  /// [luma] is a 9x8 grayscale image (72 values, row-major). Returns a 16-char hex hash.
  String hash(List<int> luma) {
    if (luma.length != 72) {
      throw ArgumentError.value(luma.length, 'luma', 'Expected 72 values (9x8)');
    }
    var bits = BigInt.zero;
    for (var y = 0; y < 8; y++) {
      for (var x = 0; x < 8; x++) {
        bits = bits << 1;
        if (luma[y * 9 + x] < luma[y * 9 + x + 1]) bits = bits | BigInt.one;
      }
    }
    return bits.toRadixString(16).padLeft(16, '0');
  }

  int distance(String a, String b) {
    var x = BigInt.parse(a, radix: 16) ^ BigInt.parse(b, radix: 16);
    var count = 0;
    while (x > BigInt.zero) {
      if (x & BigInt.one == BigInt.one) count++;
      x = x >> 1;
    }
    return count;
  }

  bool isSimilar(String a, String b) => distance(a, b) <= threshold;
}
