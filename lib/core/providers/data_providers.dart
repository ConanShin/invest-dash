import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local/database.dart';
import '../../data/repository/asset_repository.dart';

part 'data_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  // This will be overridden in main.dart
  throw UnimplementedError();
}

@riverpod
AssetRepository assetRepository(Ref ref) {
  return AssetRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Future<List<dynamic>> owners(Ref ref) async {
  // Using dynamic to avoid build_runner type resolution issues with generated drift classes
  return ref.watch(assetRepositoryProvider).getAllOwners();
}

@riverpod
class ThemeModeController extends _$ThemeModeController {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final index = prefs.getInt(_themeKey);
    return index != null ? ThemeMode.values[index] : ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_themeKey, mode.index);
  }
}

@riverpod
class WeatherSetting extends _$WeatherSetting {
  static const _weatherKey = 'show_weather';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_weatherKey) ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_weatherKey, value);
  }
}
