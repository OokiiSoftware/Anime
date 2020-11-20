import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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

class MyTheme {
  static Color primaryLight() => MyColors.primaryLight;
  static Color primaryDark() => MyColors.primaryDark;
  static Color primary() => MyColors.primary;
  static Color accent() => MyColors.accent;
  static Color text() => MyColors.text;
  static Color textInvert([double alfa = 1]) => MyColors.textInvert(alfa);
  static Color textError() => MyColors.textError;
  static Color background() => MyColors.background;
  static Color tint() => MyColors.tint;
}
