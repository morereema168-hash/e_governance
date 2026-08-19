import 'package:flutter/material.dart';
// Add this import so the file can see AppLocalizations:
import '../l10n/app_localizations.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  // Store as a Locale object so it plugs directly into MaterialApp
  Locale _locale = const Locale('en'); 

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocale(String languageCode) {
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
}

// ── LOCALIZATION SHORTCUT ──
extension LocalizationShortcut on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this)!;
}