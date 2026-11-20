import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/prefs/app_prefs.dart';
import '../../domain/wardrobe_enums.dart';
import '../../shared/widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;
  final _styles = <ClothingStyle>{};
  final _colors = <String>{};
  final _categories = <ClothingCategory>{...ClothingCategory.values};
  Units _units = Units.metric;

  static const _intro = [
    (
      Icons.checkroom,
      'Your wardrobe, in your pocket',
      'Photograph your clothes once and see everything you own at a glance — organised, searchable and private.',
    ),
    (
      Icons.auto_awesome,
      'Outfits that make sense',
      'Combine pieces into looks, and get daily suggestions that consider weather, occasion, colour harmony and what you wore recently.',
    ),
    (
      Icons.calendar_month,
      'Plan and track',
      'Schedule outfits on a calendar and discover what you really wear. Everything stays on your device — no account needed.',
    ),
  ];

  Future<void> _finish({bool skipped = false}) async {
    await ref
        .read(appPrefsProvider.notifier)
        .update(
          (p) => p.copyWith(
            onboardingDone: true,
            preferredStyles: skipped ? p.preferredStyles : _styles,
            preferredColors: skipped ? p.preferredColors : _colors,
            preferredCategories: skipped ? p.preferredCategories : _categories,
            units: skipped ? p.units : _units,
          ),
        );
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final last = _index == _intro.length;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => _finish(skipped: true), child: const Text('Skip')),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  for (final (icon, title, body) in _intro)
                    LayoutBuilder(
                      builder: (context, c) {
                        final art = (c.maxHeight * 0.38).clamp(72.0, 180.0);
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: c.maxHeight),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 520),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: art,
                                      height: art,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [t.colorScheme.primary.withValues(alpha: 0.25), t.colorScheme.primary.withValues(alpha: 0.05)],
                                        ),
                                      ),
                                      child: Icon(icon, size: art * 0.47, color: t.colorScheme.primary),
                                    ),
                                    SizedBox(height: art < 120 ? 16 : 40),
                                    Text(title, style: t.textTheme.headlineMedium, textAlign: TextAlign.center),
                                    const SizedBox(height: 16),
                                    Text(
                                      body,
                                      style: t.textTheme.bodyLarge?.copyWith(color: t.colorScheme.onSurfaceVariant),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  _preferences(t),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  for (var i = 0; i <= _intro.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _index ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index ? t.colorScheme.primary : t.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const SizedBox(width: 16),
                  const Spacer(),
                  // Flexible + scale-down keeps the button inside the row even with very large system fonts.
                  Flexible(
                    flex: 6,
                    child: FilledButton(
                      onPressed: last ? _finish : () => _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic),
                      child: FittedBox(fit: BoxFit.scaleDown, child: Text(last ? 'Get started' : 'Next', maxLines: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preferences(ThemeData t) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    children: [
      Text('Make it yours', style: t.textTheme.headlineMedium),
      const SizedBox(height: 6),
      Text(
        'Optional — this helps suggestions fit your taste. You can change it later.',
        style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 24),
      Text('Styles you like', style: t.textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final s in ClothingStyle.values)
            FilterChip(label: Text(s.label), selected: _styles.contains(s), onSelected: (v) => setState(() => v ? _styles.add(s) : _styles.remove(s))),
        ],
      ),
      const SizedBox(height: 20),
      Text('Favourite colours', style: t.textTheme.titleMedium),
      const SizedBox(height: 10),
      ColorPickerChips(
        selected: null,
        multi: true,
        selectedSet: _colors,
        onSelected: (c) => setState(() => _colors.contains(c.name) ? _colors.remove(c.name) : _colors.add(c.name)),
      ),
      const SizedBox(height: 20),
      Text('Categories you wear', style: t.textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final c in ClothingCategory.values)
            FilterChip(
              label: Text(c.label),
              selected: _categories.contains(c),
              onSelected: (v) => setState(() => v ? _categories.add(c) : _categories.remove(c)),
            ),
        ],
      ),
      const SizedBox(height: 20),
      Text('Measurement units', style: t.textTheme.titleMedium),
      const SizedBox(height: 8),
      SegmentedButton<Units>(
        segments: const [
          ButtonSegment(value: Units.metric, label: Text('Metric (cm)')),
          ButtonSegment(value: Units.imperial, label: Text('Imperial (in)')),
        ],
        selected: {_units},
        onSelectionChanged: (s) => setState(() => _units = s.first),
      ),
      const SizedBox(height: 24),
    ],
  );
}
