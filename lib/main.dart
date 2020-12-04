import 'package:anime/auxiliar/logs.dart';
import 'package:anime/auxiliar/preferences.dart';
import 'package:anime/pages/MainPage.dart';
import 'package:anime/res/strings.dart';
import 'package:anime/res/theme.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(Main());

class Main extends StatefulWidget {
  @override
  MyState createState() => MyState();
}
class MyState extends State<Main> {
  static const String TAG = 'Main';

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: setTheme,
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: MyResources.APP_NAME,
          theme: theme,
          home: MainPage(),
          builder: (c, widget) => Scaffold(
              key: Log.scaffKey,
              body: widget
          ),
        );
      },
    );
  }

  void init() async {
    // await GlobalData.init();
    loadTheme();
  }

  ThemeData setTheme(Brightness brightness) {
    bool darkModeOn = brightness == Brightness.dark;
    MyTheme.darkModeOn = darkModeOn;

    return ThemeData(
      brightness: brightness,
      // primaryColorLight: MyTheme.primaryLight,
      // primaryColorDark: MyTheme.primaryDark,
      primaryColor: MyTheme.primary,
      accentColor: MyTheme.accent,
      primaryIconTheme: IconThemeData(color: MyTheme.tint),
      tabBarTheme: TabBarTheme(
          labelColor: MyTheme.tint,
          unselectedLabelColor: MyTheme.tint
      ),
      tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
              color: MyTheme.primary
          )
      ),
      backgroundColor: MyTheme.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        bodyText2: TextStyle(fontSize: 14),
      ),
    );
  }

  void loadTheme() async {
    Preferences.instance = await SharedPreferences.getInstance();
    var savedTheme = Preferences.getString(PreferencesKey.THEME, padrao: Arrays.thema[0]);

    Brightness brightness = MyTheme.getBrilho(savedTheme);
    setTheme(brightness);
  }
}