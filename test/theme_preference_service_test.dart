import 'package:cyberuday/services/theme_preference_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test(
    'theme preference persists the selected application appearance',
    () async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final ThemePreferenceService service = ThemePreferenceService(
        preferences: preferences,
      );

      await service.save(ThemeMode.light);

      expect(await service.load(), ThemeMode.light);
      expect(service.currentThemeMode.value, ThemeMode.light);
    },
  );
}
