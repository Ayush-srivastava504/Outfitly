import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/wardrobe_enums.dart';

enum Units { metric, imperial }

@immutable
class AppPrefs {
  const AppPrefs({
    this.onboardingDone = false,
    this.themeMode = ThemeMode.system,
    this.preferredStyles = const {},
    this.preferredColors = const {},
    this.preferredCategories = const {},
    this.units = Units.metric,
    this.lastWeather = Weather.mild,
    this.backupNudgeDismissed = false,
  });

  final bool onboardingDone;
  final ThemeMode themeMode;
  final Set<ClothingStyle> preferredStyles;
  final Set<String> preferredColors;
  final Set<ClothingCategory> preferredCategories;
  final Units units;
  final Weather lastWeather;
  final bool backupNudgeDismissed;

  AppPrefs copyWith({
    bool? onboardingDone,
    ThemeMode? themeMode,
    Set<ClothingStyle>? preferredStyles,
    Set<String>? preferredColors,
    Set<ClothingCategory>? preferredCategories,
    Units? units,
    Weather? lastWeather,
    bool? backupNudgeDismissed,
  }) => AppPrefs(
    onboardingDone: onboardingDone ?? this.onboardingDone,
    themeMode: themeMode ?? this.themeMode,
    preferredStyles: preferredStyles ?? this.preferredStyles,
    preferredColors: preferredColors ?? this.preferredColors,
    preferredCategories: preferredCategories ?? this.preferredCategories,
    units: units ?? this.units,
    lastWeather: lastWeather ?? this.lastWeather,
    backupNudgeDismissed: backupNudgeDismissed ?? this.backupNudgeDismissed,
  );

  static AppPrefs read(SharedPreferences sp) => AppPrefs(
    onboardingDone: sp.getBool('onboardingDone') ?? false,
    themeMode: ThemeMode.values.firstWhere((m) => m.name == sp.getString('themeMode'), orElse: () => ThemeMode.system),
    preferredStyles: (sp.getStringList('preferredStyles') ?? []).map(ClothingStyle.tryParse).whereType<ClothingStyle>().toSet(),
    preferredColors: (sp.getStringList('preferredColors') ?? []).toSet(),
    preferredCategories: (sp.getStringList('preferredCategories') ?? [])
        .map((n) => ClothingCategory.values.where((c) => c.name == n).firstOrNull)
        .whereType<ClothingCategory>()
        .toSet(),
    units: sp.getString('units') == 'imperial' ? Units.imperial : Units.metric,
    lastWeather: Weather.values.firstWhere((w) => w.name == sp.getString('lastWeather'), orElse: () => Weather.mild),
    backupNudgeDismissed: sp.getBool('backupNudgeDismissed') ?? false,
  );

  Future<void> write(SharedPreferences sp) async {
    await sp.setBool('onboardingDone', onboardingDone);
    await sp.setString('themeMode', themeMode.name);
    await sp.setStringList('preferredStyles', preferredStyles.map((e) => e.name).toList());
    await sp.setStringList('preferredColors', preferredColors.toList());
    await sp.setStringList('preferredCategories', preferredCategories.map((e) => e.name).toList());
    await sp.setString('units', units.name);
    await sp.setString('lastWeather', lastWeather.name);
    await sp.setBool('backupNudgeDismissed', backupNudgeDismissed);
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('overridden in main'));

class AppPrefsNotifier extends Notifier<AppPrefs> {
  @override
  AppPrefs build() => AppPrefs.read(ref.read(sharedPrefsProvider));

  Future<void> update(AppPrefs Function(AppPrefs) change) async {
    state = change(state);
    await state.write(ref.read(sharedPrefsProvider));
  }
}

final appPrefsProvider = NotifierProvider<AppPrefsNotifier, AppPrefs>(AppPrefsNotifier.new);
