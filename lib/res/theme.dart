import 'dart:ui';
import 'package:anime/auxiliar/import.dart';

class OkiColors {
  static Color primaryLight = Colors.orangeAccent;
  static Color primaryDark = Colors.deepOrange;
  static Color primary = Colors.orange;
  static Color accent = Colors.blue;
  static Color text = Colors.white;
  static Color textInvert(double alfa) => Color.fromRGBO(0, 0, 0, alfa);
  static Color textError = Colors.red;
  static Color background = Colors.white;
  static Color tint = Colors.white;
}

class OkiThemeMode {
  static const sistema = 'Sistema';
  static const claro = 'Claro';
  static const escuro = 'Escuro';
}

class OkiTheme {
  static bool darkModeOn = false;

  static Color get primaryLight => OkiColors.primaryLight;
  static Color get primaryDark => OkiColors.primaryDark;
  static Color get primary => OkiColors.primary;
  static Color get accent => OkiColors.accent;
  static Color get text => OkiColors.text;
  static Color textInvert([double alfa = 1]) => OkiColors.textInvert(alfa);
  static Color get textError => OkiColors.textError;
  static Color get background => OkiColors.background;
  static Color get tint => OkiColors.tint;

  static Brightness getBrilho(String theme) {
    Brightness brightness;
    if (theme == OkiThemeMode.sistema)
      brightness = SchedulerBinding.instance.window.platformBrightness;
    else if (theme == OkiThemeMode.claro)
      brightness = Brightness.light;
    else
      brightness = Brightness.dark;
    return brightness;
  }
}
