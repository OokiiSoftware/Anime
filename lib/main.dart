import 'package:anime/auxiliar/import.dart';
import 'package:anime/res/import.dart';
import 'package:anime/pages/MainPage.dart';

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
          title: AppResources.APP_NAME,
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
    OkiTheme.darkModeOn = darkModeOn;

    return ThemeData(
      brightness: brightness,
      // primaryColorLight: MyTheme.primaryLight,
      // primaryColorDark: MyTheme.primaryDark,
      primaryColor: OkiTheme.primary,
      accentColor: OkiTheme.accent,
      primaryIconTheme: IconThemeData(color: OkiTheme.tint),
      tabBarTheme: TabBarTheme(
          labelColor: OkiTheme.tint,
          unselectedLabelColor: OkiTheme.tint
      ),
      tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
              color: OkiTheme.primary
          )
      ),
      backgroundColor: OkiTheme.background,
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

    Brightness brightness = OkiTheme.getBrilho(savedTheme);
    setTheme(brightness);
  }
}