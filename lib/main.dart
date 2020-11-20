import 'package:anime/auxiliar/logs.dart';
import 'package:anime/pages/MainPage.dart';
import 'package:anime/res/strings.dart';
import 'package:anime/res/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  static const String TAG = 'Main';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: MyResources.APP_NAME,
      theme: ThemeData(
        primaryColorLight: MyTheme.primaryLight(),
        primaryColorDark: MyTheme.primaryDark(),
        primaryColor: MyTheme.primary(),
        accentColor: MyTheme.accent(),
        primaryIconTheme: IconThemeData(color: MyTheme.tint()),
        tabBarTheme: TabBarTheme(
          labelColor: MyTheme.tint(),
          unselectedLabelColor: MyTheme.tint()
        ),
        backgroundColor: MyTheme.background(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: 14),
        ),
      ),
      home: MainPage(),
      builder: (a, widget) => Scaffold(
        key: Log.scaffKey,
          body: widget
      ),
    );
  }
}