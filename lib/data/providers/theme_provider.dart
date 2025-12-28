import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

/// Provider for managing app theme
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    try {
      final storage = StorageService.instance;
      _themeMode = storage.isDarkMode() ? ThemeMode.dark : ThemeMode.light;
      _locale = Locale(storage.getLanguage());
      notifyListeners();
    } catch (e) {
      // Storage not initialized yet, use defaults
    }
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await StorageService.instance.setDarkMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await StorageService.instance.setDarkMode(mode == ThemeMode.dark);
    notifyListeners();
  }

  /// Set locale
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await StorageService.instance.setLanguage(locale.languageCode);
    notifyListeners();
  }

  /// Get list of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ru'),
    Locale('es'),
  ];

  /// Get language name from locale
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode;
    }
  }
}
