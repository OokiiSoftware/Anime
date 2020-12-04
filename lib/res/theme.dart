import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class MyColors {
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

class ThemeMode {
  static const sistema = 'Sistema';
  static const claro = 'Claro';
  static const escuro = 'Escuro';
}

class MyTheme {
  static bool darkModeOn = false;

  static Color get primaryLight => MyColors.primaryLight;
  static Color get primaryDark => MyColors.primaryDark;
  static Color get primary => MyColors.primary;
  static Color get accent => MyColors.accent;
  static Color get text => MyColors.text;
  static Color textInvert([double alfa = 1]) => MyColors.textInvert(alfa);
  static Color get textError => MyColors.textError;
  static Color get background => MyColors.background;
  static Color get tint => MyColors.tint;

  static Brightness getBrilho(String theme) {
    Brightness brightness;
    if (theme == ThemeMode.sistema)
      brightness = SchedulerBinding.instance.window.platformBrightness;
    else if (theme == ThemeMode.claro)
      brightness = Brightness.light;
    else
      brightness = Brightness.dark;
    return brightness;
  }
}
