import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _locale = 'en'; // 'en', 'mr', 'hi'

  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocale(String languageCode) {
    _locale = languageCode;
    notifyListeners();
  }

  // Lightweight translation dictionary
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'feed': 'Feed',
      'map': 'Map',
      'funds': 'Fundraisers',
      'polls': 'Polls',
      'profile': 'Profile',
      'report_issue': 'Report an Issue',
    },
    'mr': {
      'feed': 'फीड',
      'map': 'नकाशा',
      'funds': 'निधी संकलन',
      'polls': 'मतदान',
      'profile': 'प्रोफाईल',
      'report_issue': 'समस्या नोंदवा',
    },
    'hi': {
      'feed': 'फ़ीड',
      'map': 'नक्शा',
      'funds': 'धन उगाहने',
      'polls': 'मतदान',
      'profile': 'प्रोफ़ाइल',
      'report_issue': 'समस्या दर्ज करें',
    }
  };

  String t(String key) {
    return _translations[_locale]?[key] ?? key;
  }
}