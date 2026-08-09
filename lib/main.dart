import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'core/cyber_design_system.dart';
import 'l10n/app_localizations.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'services/localization_service.dart';
import 'services/theme_preference_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.instance.initializePersistence();
  await ThemePreferenceService.instance.load();
  runApp(const CyberUApp());
}

class CyberUApp extends StatelessWidget {
  const CyberUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemePreferenceService.instance.currentThemeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LocalizationService.instance.currentLocale,
          builder: (context, localeCode, child) {
            final bool isSupported = AppLocalizations.supportedLocales.any(
              (locale) => locale.languageCode == localeCode,
            );
            return MaterialApp(
              title: 'Cyber Uday',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: isSupported ? Locale(localeCode) : const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) =>
                  CyberAmbientPointer(child: child ?? const SizedBox.shrink()),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
