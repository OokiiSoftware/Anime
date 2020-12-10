import 'package:anime/auxiliar/import.dart';
import 'package:anime/pages/import.dart';
import 'package:anime/res/import.dart';

void main() => runApp(Main());

class Main extends StatefulWidget {
  @override
  MyState createState() => MyState();
}
class MyState extends State<Main> {
  static const String TAG = 'Main';

  bool _isIniciado = false;
  bool _mostrarLog = false;

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
          home: _getBody,
          builder: (c, widget) => Scaffold(
              key: Log.scaffKey,
              body: widget
          ),
        );
      },
    );
  }

  void init() async {
    loadTheme();

    _checkInitTimeout();
    await Aplication.init();
    await FirebaseOki.init();

    //region OfflineData pode ter uma lista offline, se tiver a lista a inicializacão é mais rapida
    bool onlineDataBaixados = false;
    if (OnlineData.data.isEmpty) {
      await OnlineData.baixarLista();
      onlineDataBaixados = true;
    }
    //endregion

    setState(() {
      _mostrarLog = false;
      _isIniciado = RunTime.isOnline = true;
    });
    if (!onlineDataBaixados)
      await OnlineData.baixarLista();
  }

  Future _checkInitTimeout() async {
    await Future.delayed(Duration(seconds: 10));
    if (!mounted) return;
    if (!_isIniciado) {
      setState(() {
        _mostrarLog = true;
      });
    }
    await Future.delayed(Duration(seconds: 5));
    if (!mounted) return;
    setState(() {
      _isIniciado = true;
    });
  }

  Widget get _getBody {
    if (!_isIniciado)
      return SplashScreen(mostrarLog: _mostrarLog);
    else if (!FirebaseOki.isLogado)
      return LoginPage();
    else
      return MainPage();
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
