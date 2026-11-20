/// Pure-Dart wardrobe vocabulary shared by every layer.
library;

enum ClothingCategory {
  tops('Tops'),
  bottoms('Bottoms'),
  dresses('Dresses'),
  outerwear('Outerwear'),
  shoes('Shoes'),
  accessories('Accessories'),
  bags('Bags');

  const ClothingCategory(this.label);
  final String label;

  static ClothingCategory parse(String name) => ClothingCategory.values.firstWhere((c) => c.name == name, orElse: () => ClothingCategory.tops);
}

/// Bit flags: stored as an int so filters are a single comparison.
enum Season {
  spring('Spring', 1),
  summer('Summer', 2),
  autumn('Autumn', 4),
  winter('Winter', 8);

  const Season(this.label, this.bit);
  final String label;
  final int bit;
}

enum Occasion {
  casual('Casual', 1),
  work('Work', 2),
  formal('Formal', 4),
  party('Party', 8),
  sport('Sport', 16),
  date('Date', 32),
  travel('Travel', 64);

  const Occasion(this.label, this.bit);
  final String label;
  final int bit;
}

enum ClothingStyle {
  casual('Casual'),
  classic('Classic'),
  minimal('Minimal'),
  streetwear('Streetwear'),
  sporty('Sporty'),
  elegant('Elegant'),
  bohemian('Bohemian');

  const ClothingStyle(this.label);
  final String label;

  static ClothingStyle? tryParse(String? name) {
    if (name == null) return null;
    for (final s in ClothingStyle.values) {
      if (s.name == name) return s;
    }
    return null;
  }

  bool get isDressy => this == classic || this == elegant;
}

enum Weather {
  cold('Cold', '❄️'),
  mild('Mild', '⛅'),
  warm('Warm', '🌤️'),
  hot('Hot', '☀️'),
  rainy('Rainy', '🌧️');

  const Weather(this.label, this.emoji);
  final String label;
  final String emoji;

  /// Seasons whose clothes suit this weather.
  int get seasonMask => switch (this) {
    Weather.cold => Season.winter.bit | Season.autumn.bit,
    Weather.mild => Season.spring.bit | Season.autumn.bit,
    Weather.warm => Season.spring.bit | Season.summer.bit,
    Weather.hot => Season.summer.bit,
    Weather.rainy => Season.spring.bit | Season.autumn.bit | Season.winter.bit,
  };

  bool get wantsLayer => this == Weather.cold || this == Weather.rainy;
}

/// Bitmask helpers.
int maskOf(Iterable<int> bits) => bits.fold(0, (a, b) => a | b);
bool maskHas(int mask, int bit) => mask & bit != 0;

/// An item with no tags (mask 0) is treated as suitable for everything.
bool maskMatches(int itemMask, int wanted) => itemMask == 0 || wanted == 0 || itemMask & wanted != 0;

List<Season> seasonsOf(int mask) => Season.values.where((s) => maskHas(mask, s.bit)).toList();
List<Occasion> occasionsOf(int mask) => Occasion.values.where((o) => maskHas(mask, o.bit)).toList();

Season seasonForDate(DateTime d) {
  // Northern-hemisphere default; the user picks the season explicitly on the suggestion screen.
  final m = d.month;
  if (m >= 3 && m <= 5) return Season.spring;
  if (m >= 6 && m <= 8) return Season.summer;
  if (m >= 9 && m <= 11) return Season.autumn;
  return Season.winter;
}
