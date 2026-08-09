import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferenceService {
  ThemePreferenceService({SharedPreferences? preferences})
    : _preferences = preferences;

  static final ThemePreferenceService instance = ThemePreferenceService();

  static const String preferenceKey = 'cyber_uday.theme_mode';

  final SharedPreferences? _preferences;
  final ValueNotifier<ThemeMode> currentThemeMode = ValueNotifier<ThemeMode>(
    ThemeMode.dark,
  );

  Future<SharedPreferences> get _store async =>
      _preferences ?? await SharedPreferences.getInstance();

  Future<ThemeMode> load() async {
    final String? value = (await _store).getString(preferenceKey);
    final ThemeMode mode = _fromStorage(value) ?? ThemeMode.dark;
    currentThemeMode.value = mode;
    return mode;
  }

  Future<void> save(ThemeMode mode) async {
    await (await _store).setString(preferenceKey, mode.name);
    currentThemeMode.value = mode;
  }

  ThemeMode? _fromStorage(String? value) {
    for (final ThemeMode mode in ThemeMode.values) {
      if (mode.name == value) return mode;
    }
    return null;
  }
}
