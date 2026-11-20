import 'package:flutter_test/flutter_test.dart';
import 'package:outfitly/domain/services/recommendation_engine.dart';
import 'package:outfitly/domain/wardrobe_enums.dart';

RecoItem item(
  String id,
  ClothingCategory c,
  String colorName,
  String hex, {
  int seasons = 0,
  int occasions = 0,
  ClothingStyle? style,
  bool fav = false,
  int worn = 0,
  DateTime? lastWorn,
}) => RecoItem(
  id: id,
  name: id,
  category: c,
  colorHex: hex,
  colorName: colorName,
  seasons: seasons,
  occasions: occasions,
  style: style,
  isFavorite: fav,
  wearCount: worn,
  lastWorn: lastWorn,
);

void main() {
  const engine = RecommendationEngine();
  final today = DateTime(2026, 11, 19);
  RecoContext ctx({Weather w = Weather.mild, Occasion? o, Map<String, DateTime> combos = const {}}) =>
      RecoContext(today: today, weather: w, occasion: o, recentCombos: combos);

  final navyTop = item('navyTop', ClothingCategory.tops, 'Navy', '#192350');
  final whiteTop = item('whiteTop', ClothingCategory.tops, 'White', '#F5F5F5');
  final redTop = item('redTop', ClothingCategory.tops, 'Red', '#C82328');
  final beigeChinos = item('beigeChinos', ClothingCategory.bottoms, 'Beige', '#D7C3A0');
  final jeans = item('jeans', ClothingCategory.bottoms, 'Denim', '#466491');
  final sneakers = item('sneakers', ClothingCategory.shoes, 'White', '#F5F5F5');
  final coat = item('coat', ClothingCategory.outerwear, 'Camel', '#BE8C55');
  final dress = item('dress', ClothingCategory.dresses, 'Green', '#329146');

  test('reports what is missing when no complete outfit is possible', () {
    final r = engine.suggest([navyTop, sneakers], ctx());
    expect(r, isA<InsufficientWardrobe>());
    expect((r as InsufficientWardrobe).missing.single, contains('bottom'));
    expect(engine.suggest([], ctx()), isA<InsufficientWardrobe>());
  });

  test('builds separates and dress outfits, with shoes when available', () {
    final r = engine.suggest([navyTop, beigeChinos, sneakers, dress], ctx()) as Suggestions;
    expect(r.list, hasLength(2));
    for (final s in r.list) {
      expect(s.items.map((e) => e.id), contains('sneakers'));
      expect(s.reasons, isNotEmpty);
    }
    expect(r.list.any((s) => s.items.any((i) => i.id == 'dress')), isTrue);
  });

  test('never suggests items outside the wardrobe and never duplicates a suggestion', () {
    final wardrobe = [navyTop, whiteTop, redTop, beigeChinos, jeans, sneakers];
    final r = engine.suggest(wardrobe, ctx(), count: 5) as Suggestions;
    final ids = wardrobe.map((e) => e.id).toSet();
    for (final s in r.list) {
      expect(s.items.every((i) => ids.contains(i.id)), isTrue);
    }
    expect(r.list.map((s) => s.key).toSet(), hasLength(r.list.length));
  });

  test('adds outerwear in cold weather and explains when none exists', () {
    final cold = engine.suggest([navyTop, beigeChinos, coat], ctx(w: Weather.cold)) as Suggestions;
    expect(cold.list.first.items.map((e) => e.id), contains('coat'));

    final noCoat = engine.suggest([navyTop, beigeChinos], ctx(w: Weather.cold)) as Suggestions;
    expect(noCoat.list.first.reasons.join(), contains('outerwear'));

    final warm = engine.suggest([navyTop, beigeChinos, coat], ctx(w: Weather.warm)) as Suggestions;
    expect(warm.list.first.items.map((e) => e.id), isNot(contains('coat')));
  });

  test('filters by season tags but treats untagged items as all-season', () {
    final summerOnly = item('linen', ClothingCategory.tops, 'White', '#F5F5F5', seasons: Season.summer.bit);
    final r = engine.suggest([summerOnly, beigeChinos], ctx(w: Weather.cold));
    expect(r, isA<InsufficientWardrobe>());
    final hot = engine.suggest([summerOnly, beigeChinos], ctx(w: Weather.hot));
    expect(hot, isA<Suggestions>());
  });

  test('respects occasion tags', () {
    final gymTee = item('gym', ClothingCategory.tops, 'Gray', '#8C8C91', occasions: Occasion.sport.bit);
    final r = engine.suggest([gymTee, beigeChinos], ctx(o: Occasion.formal));
    expect(r, isA<InsufficientWardrobe>());
  });

  test('penalises recently worn items and repeated combinations', () {
    final wornYesterday = item('navyTop', ClothingCategory.tops, 'Navy', '#192350', lastWorn: today.subtract(const Duration(days: 1)));
    final fresh = engine.scoreItems([navyTop, beigeChinos], ctx()).$1;
    final stale = engine.scoreItems([wornYesterday, beigeChinos], ctx()).$1;
    expect(stale, lessThan(fresh));

    final key = comboKey(['navyTop', 'beigeChinos']);
    final repeated = engine.scoreItems([navyTop, beigeChinos], ctx(combos: {key: today.subtract(const Duration(days: 3))})).$1;
    expect(repeated, lessThan(fresh));
  });

  test('colour harmony: neutrals + one accent beats three clashing accents', () {
    final pink = item('pink', ClothingCategory.bottoms, 'Pink', '#F096B4');
    final yellowShoes = item('yshoes', ClothingCategory.shoes, 'Yellow', '#F0D23C');
    final harmonious = engine.scoreItems([redTop, beigeChinos, sneakers], ctx()).$1;
    final clashing = engine.scoreItems([redTop, pink, yellowShoes], ctx()).$1;
    expect(harmonious, greaterThan(clashing));
  });

  test('style clash between dressy and sporty is penalised', () {
    final blazer = item('b', ClothingCategory.tops, 'Navy', '#192350', style: ClothingStyle.elegant);
    final trackPants = item('t', ClothingCategory.bottoms, 'Black', '#141416', style: ClothingStyle.sporty);
    final tailored = item('c', ClothingCategory.bottoms, 'Black', '#141416', style: ClothingStyle.elegant);
    expect(engine.scoreItems([blazer, tailored], ctx()).$1, greaterThan(engine.scoreItems([blazer, trackPants], ctx()).$1));
  });

  test('is deterministic', () {
    final w = [navyTop, whiteTop, redTop, beigeChinos, jeans, sneakers, coat];
    final a = (engine.suggest(w, ctx()) as Suggestions).list.map((s) => s.key).toList();
    final b = (engine.suggest(w, ctx()) as Suggestions).list.map((s) => s.key).toList();
    expect(a, b);
  });

  test('diversity: top suggestions are not all built around the same piece', () {
    final w = [navyTop, whiteTop, redTop, beigeChinos, jeans, sneakers];
    final list = (engine.suggest(w, ctx(), count: 3) as Suggestions).list;
    final tops = list.map((s) => s.items.firstWhere((i) => i.category == ClothingCategory.tops).id).toSet();
    expect(tops.length, greaterThan(1));
  });
}
