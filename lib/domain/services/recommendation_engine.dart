import 'dart:math' as math;

import '../wardrobe_enums.dart';
import 'color_analyzer.dart';

/// Minimal, storage-independent view of a clothing item used by the engine.
class RecoItem {
  const RecoItem({
    required this.id,
    required this.name,
    required this.category,
    required this.colorHex,
    required this.colorName,
    this.seasons = 0,
    this.occasions = 0,
    this.style,
    this.isFavorite = false,
    this.wearCount = 0,
    this.lastWorn,
  });

  final String id;
  final String name;
  final ClothingCategory category;
  final String colorHex;
  final String colorName;
  final int seasons;
  final int occasions;
  final ClothingStyle? style;
  final bool isFavorite;
  final int wearCount;
  final DateTime? lastWorn;

  bool get isNeutral {
    final named = kNamedColors.where((c) => c.name == colorName);
    if (named.isNotEmpty && named.first.neutral) return true;
    final rgb = parseHex(colorHex);
    final hsl = toHsl(rgb.r, rgb.g, rgb.b);
    return hsl.s < 0.18 || hsl.l < 0.12 || hsl.l > 0.92;
  }

  double get hue {
    final rgb = parseHex(colorHex);
    return toHsl(rgb.r, rgb.g, rgb.b).h;
  }
}

class RecoContext {
  const RecoContext({
    required this.today,
    required this.weather,
    this.occasion,
    this.season,
    this.preferredColors = const {},
    this.preferredStyles = const {},
    this.recentCombos = const {},
  });

  final DateTime today;
  final Weather weather;
  final Occasion? occasion;
  final Season? season;
  final Set<String> preferredColors;
  final Set<ClothingStyle> preferredStyles;

  /// Combination key (sorted item ids joined by '|') → date last worn.
  final Map<String, DateTime> recentCombos;
}

class Suggestion {
  const Suggestion(this.items, this.score, this.reasons);
  final List<RecoItem> items;
  final double score;
  final List<String> reasons;

  String get key => comboKey(items.map((e) => e.id));
}

String comboKey(Iterable<String> ids) => (ids.toList()..sort()).join('|');

sealed class RecoResult {
  const RecoResult();
}

class Suggestions extends RecoResult {
  const Suggestions(this.list);
  final List<Suggestion> list;
}

class InsufficientWardrobe extends RecoResult {
  const InsufficientWardrobe(this.missing);

  /// Human-readable description of what to add, e.g. ["a top and a bottom, or a dress"].
  final List<String> missing;
}

/// Tunable weights; exposed for tests.
class RecoWeights {
  const RecoWeights({
    this.allNeutral = 1.0,
    this.accentWithNeutrals = 1.5,
    this.analogous = 1.2,
    this.complementary = 1.0,
    this.clash = -0.8,
    this.tooManyColors = -1.2,
    this.styleCoherent = 1.0,
    this.styleClash = -1.2,
    this.preferredColor = 0.5,
    this.preferredStyle = 0.5,
    this.favorite = 0.4,
    this.occasionTagged = 0.4,
    this.seasonTagged = 0.3,
    this.wornRecently = -1.5,
    this.comboRepeat = -2.5,
    this.underused = 0.3,
    this.diversityPenalty = 1.2,
  });

  final double allNeutral, accentWithNeutrals, analogous, complementary, clash, tooManyColors;
  final double styleCoherent, styleClash, preferredColor, preferredStyle, favorite;
  final double occasionTagged, seasonTagged, wornRecently, comboRepeat, underused, diversityPenalty;
}

/// Deterministic, explainable, on-device outfit recommender.
class RecommendationEngine {
  const RecommendationEngine({this.weights = const RecoWeights(), this.perSlot = 12});

  final RecoWeights weights;
  final int perSlot;

  RecoResult suggest(List<RecoItem> wardrobe, RecoContext ctx, {int count = 5}) {
    final seasonMask = ctx.season?.bit ?? ctx.weather.seasonMask;
    final occasionBit = ctx.occasion?.bit ?? 0;

    bool fits(RecoItem i) => maskMatches(i.seasons, seasonMask) && maskMatches(i.occasions, occasionBit);

    List<RecoItem> slot(ClothingCategory c) {
      final list = wardrobe.where((i) => i.category == c && fits(i)).toList()
        ..sort((a, b) {
          if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
          final la = a.lastWorn?.millisecondsSinceEpoch ?? 0, lb = b.lastWorn?.millisecondsSinceEpoch ?? 0;
          if (la != lb) return la.compareTo(lb);
          return a.id.compareTo(b.id);
        });
      return list.take(perSlot).toList();
    }

    final tops = slot(ClothingCategory.tops);
    final bottoms = slot(ClothingCategory.bottoms);
    final dresses = slot(ClothingCategory.dresses);
    final shoes = slot(ClothingCategory.shoes);
    final outer = slot(ClothingCategory.outerwear);

    final canSeparates = tops.isNotEmpty && bottoms.isNotEmpty;
    if (!canSeparates && dresses.isEmpty) {
      final missing = <String>[];
      if (tops.isEmpty && bottoms.isEmpty) {
        missing.add('a top and a bottom, or a dress');
      } else if (tops.isEmpty) {
        missing.add('a top (or a dress)');
      } else {
        missing.add('a bottom (or a dress)');
      }
      return InsufficientWardrobe(missing);
    }

    final wornCounts = wardrobe.map((e) => e.wearCount).toList()..sort();
    final median = wornCounts.isEmpty ? 0 : wornCounts[wornCounts.length ~/ 2];

    final bases = <List<RecoItem>>[
      if (canSeparates)
        for (final t in tops)
          for (final b in bottoms) [t, b],
      for (final d in dresses) [d],
    ];

    final scored = <Suggestion>[];
    for (final base in bases) {
      final shoeOptions = shoes.isEmpty ? <RecoItem?>[null] : shoes.cast<RecoItem?>();
      for (final s in shoeOptions) {
        var items = [...base, ?s];
        if (ctx.weather.wantsLayer && outer.isNotEmpty) {
          // Pick the best-harmonising layer rather than multiplying combinations.
          RecoItem? bestLayer;
          var bestScore = -double.infinity;
          for (final o in outer.take(5)) {
            final sc = _score([...items, o], ctx, median).$1;
            if (sc > bestScore) {
              bestScore = sc;
              bestLayer = o;
            }
          }
          items = [...items, bestLayer!];
        }
        final (score, reasons) = _score(items, ctx, median);
        final finalReasons = [...reasons];
        if (ctx.weather.wantsLayer && outer.isEmpty) {
          finalReasons.add('It\'s ${ctx.weather.label.toLowerCase()}. Add outerwear to your wardrobe for layered suggestions');
        }
        scored.add(Suggestion(items, score, finalReasons));
      }
    }

    scored.sort((a, b) {
      final c = b.score.compareTo(a.score);
      return c != 0 ? c : a.key.compareTo(b.key);
    });

    // Maximal-marginal-relevance selection for variety.
    final chosen = <Suggestion>[];
    final pool = [...scored];
    while (chosen.length < count && pool.isNotEmpty) {
      Suggestion? best;
      var bestVal = -double.infinity;
      for (final cand in pool.take(200)) {
        var overlap = 0;
        for (final c in chosen) {
          overlap = math.max(overlap, cand.items.where((i) => c.items.any((j) => j.id == i.id)).length);
        }
        final val = cand.score - weights.diversityPenalty * overlap;
        if (val > bestVal) {
          bestVal = val;
          best = cand;
        }
      }
      chosen.add(best!);
      pool.remove(best);
    }
    return Suggestions(chosen);
  }

  /// Returns (score, top reasons). Public for unit tests via [scoreItems].
  (double, List<String>) scoreItems(List<RecoItem> items, RecoContext ctx) {
    final counts = items.map((e) => e.wearCount).toList()..sort();
    return _score(items, ctx, counts.isEmpty ? 0 : counts[counts.length ~/ 2]);
  }

  (double, List<String>) _score(List<RecoItem> items, RecoContext ctx, int median) {
    final w = weights;
    final parts = <(double, String)>[];

    // Colour harmony.
    final accents = items.where((i) => !i.isNeutral).toList();
    if (accents.isEmpty) {
      parts.add((w.allNeutral, 'An easy all-neutral palette (${_colorList(items)})'));
    } else if (accents.length == 1) {
      parts.add((w.accentWithNeutrals, '${accents.first.colorName} stands out against neutral pieces'));
    } else if (accents.length == 2) {
      final d = hueDistance(accents[0].hue, accents[1].hue);
      if (d < 40) {
        parts.add((w.analogous, '${accents[0].colorName} and ${accents[1].colorName} are close, harmonious tones'));
      } else if (d >= 150) {
        parts.add((w.complementary, '${accents[0].colorName} and ${accents[1].colorName} are bold complementary colours'));
      } else {
        parts.add((w.clash, 'Colours may clash'));
      }
    } else {
      final distinct = accents.map((e) => e.colorName).toSet();
      if (distinct.length >= 3) parts.add((w.tooManyColors, 'Many competing colours'));
    }

    // Style coherence.
    final styles = items.map((e) => e.style).whereType<ClothingStyle>().toList();
    if (styles.length >= 2 && styles.toSet().length == 1) {
      parts.add((w.styleCoherent, 'Consistent ${styles.first.label.toLowerCase()} style'));
    }
    if (styles.any((s) => s.isDressy) && styles.contains(ClothingStyle.sporty)) {
      parts.add((w.styleClash, 'Mixes dressy and sporty pieces'));
    }

    // Preferences.
    final prefColor = items.where((i) => ctx.preferredColors.contains(i.colorName)).length;
    if (prefColor > 0) parts.add((w.preferredColor * prefColor, 'Uses your favourite colours'));
    final prefStyle = items.where((i) => i.style != null && ctx.preferredStyles.contains(i.style)).length;
    if (prefStyle > 0) parts.add((w.preferredStyle * prefStyle, 'Matches your preferred style'));

    final favs = items.where((i) => i.isFavorite).toList();
    if (favs.isNotEmpty) {
      parts.add((w.favorite * favs.length, favs.length == 1 ? 'Includes your favourite ${favs.first.name}' : 'Includes ${favs.length} favourites'));
    }

    if (ctx.occasion != null) {
      final tagged = items.where((i) => maskHas(i.occasions, ctx.occasion!.bit)).length;
      if (tagged > 0) parts.add((w.occasionTagged * tagged, 'Suits ${ctx.occasion!.label.toLowerCase()}'));
    }
    final seasonBits = ctx.season?.bit ?? ctx.weather.seasonMask;
    final seasonTagged = items.where((i) => i.seasons != 0 && i.seasons & seasonBits != 0).length;
    if (seasonTagged > 0) parts.add((w.seasonTagged * seasonTagged, 'Right for ${ctx.weather.label.toLowerCase()} weather'));

    // Freshness.
    for (final i in items) {
      if (i.lastWorn != null) {
        final days = _daysBetween(i.lastWorn!, ctx.today);
        if (days >= 0 && days < 3) parts.add((w.wornRecently, 'You wore the ${i.name} recently'));
      }
    }
    final key = comboKey(items.map((e) => e.id));
    final lastCombo = ctx.recentCombos[key];
    if (lastCombo != null && _daysBetween(lastCombo, ctx.today) < 14) {
      parts.add((w.comboRepeat, 'You wore this exact outfit in the last two weeks'));
    }

    // Rotation: nudge under-used items.
    final underused = items.where((i) => i.wearCount < median || i.wearCount == 0).toList();
    if (underused.isNotEmpty) {
      final stale = underused.firstWhere((i) => i.lastWorn != null, orElse: () => underused.first);
      final msg = stale.lastWorn == null
          ? 'Gives your ${stale.name} its first outing'
          : 'You haven\'t worn the ${stale.name} in ${_daysBetween(stale.lastWorn!, ctx.today)} days';
      parts.add((w.underused * underused.length, msg));
    }

    final score = parts.fold<double>(0, (a, p) => a + p.$1);
    final positives = parts.where((p) => p.$1 > 0).toList()..sort((a, b) => b.$1.compareTo(a.$1));
    final negatives = parts.where((p) => p.$1 < 0).map((p) => 'Heads-up: ${p.$2}');
    return (score, [...positives.take(3).map((p) => p.$2), ...negatives.take(1)]);
  }

  static String _colorList(List<RecoItem> items) => items.map((e) => e.colorName.toLowerCase()).toSet().join(', ');

  static int _daysBetween(DateTime a, DateTime b) => DateTime(b.year, b.month, b.day).difference(DateTime(a.year, a.month, a.day)).inDays;
}
