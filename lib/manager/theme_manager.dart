import 'package:flutter/material.dart';
import '../auxiliar/import.dart';
import 'import.dart';

class OkiColors {
  static int cor(bool darkModeOn) => darkModeOn ? 0 : 255;

  static const Color primaryLight = Colors.orangeAccent;
  static const Color primaryDark = Colors.deepOrangeAccent;
  static const Color primary = Colors.orange;
  static const Color accent = Colors.deepOrange;
  static const Color textDark = Colors.white;
  static const Color textLight = Colors.black;
  static Color textInvert(double alfa, {bool isDark = false}) => Color.fromRGBO(cor(isDark), cor(isDark), cor(isDark), alfa);
  static const Color textError = Colors.red;
  static Color background({bool isDark = false}) => isDark ? Colors.black87 : Colors.white;
  static const Color tint = Colors.white;
}

class ThemeManager {
  static const _TAG = 'ThemeManager';
  static const String _THEME_KEY = '_THEME_KEY';

  static ThemeManager i = ThemeManager();

  final List<Function(ThemeMode)> _onModeChangedListener = [];

  final List<String> modesList = ['System', 'Light', 'Dark'];

  String get themeModeString {
    switch(themeMode) {
      case ThemeMode.system:
        return modesList[0];
      case ThemeMode.light:
        return modesList[1];
      case ThemeMode.dark:
        return modesList[2];
      default:
        return modesList[0];
    }
  }

  Color get disabledTextColor {
    return (brightness == Brightness.dark) ? Colors.white54 : Colors.black54;
  }

  bool get isDarkMode => brightness == Brightness.dark;

  ThemeMode themeMode;
  Brightness get brightness => MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;

  ThemeMode themeModeFromString(String value) {
    switch(value) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      case 'System':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  void addModeChangeListener(Function(ThemeMode) value) {
    if (!_onModeChangedListener.contains(value))
      _onModeChangedListener.add(value);
  }
  void removeModeChangeListener(Function(ThemeMode) value) {
    _onModeChangedListener.remove(value);
  }

  void setThemeMode(String value) {
    themeMode = themeModeFromString(value);
    _onModeChangedListener.forEach((value) {
      value.call(themeMode);
    });
    _saveThemeMode(value);
  }

  void _saveThemeMode(String value) {
    Preferences.pref.setString(_THEME_KEY, value);
  }

  void load() {
    String theme = Preferences.pref.getString(_THEME_KEY);
    setThemeMode(theme);
    Log.d(_TAG, 'load', 'OK');
  }
}