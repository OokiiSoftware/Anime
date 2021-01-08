import 'dart:ui';
import 'package:anime/auxiliar/import.dart';

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
  static Color get text => darkModeOn ? OkiColors.textDark : OkiColors.textLight;
  static Color textInvert([double alfa = 1]) => OkiColors.textInvert(alfa, isDark: darkModeOn);
  static Color get textError => OkiColors.textError;
  static Color get background => OkiColors.background(isDark: darkModeOn);
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

  static refesh(BuildContext context) async {
    Brightness brightness = getBrilho(Config.theme);
    await DynamicTheme.of(context).setBrightness(brightness);
  }
}
