import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auxiliar/import.dart';
import 'manager/import.dart';
import 'pages/import.dart';
import 'res/import.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: OkiColors.primary,
    ),
  );
  runApp(Main());
}

class Main extends StatefulWidget {
  @override
  _State createState() => _State();
}
class _State extends State<Main> {

  //region variaveis

  // ignore: unused_field
  static const String _TAG = 'Main';

  bool _mostrarLog = false;

  bool _isIniciado = false;
  bool _hasError = false;
  String _errorText;

  ThemeMode _themeMode = ThemeMode.system;

  //endregion

  //region overrides

  @override
  void dispose() {
    super.dispose();
    ThemeManager.i.removeModeChangeListener(_onThemeModeChanged);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(OkiColors.primary),
        )
    );
    final appBarTheme = AppBarTheme(
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.white,
      ),
    );
    final tabBarTheme = TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppResources.APP_NAME,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: OkiColors.primary,
        appBarTheme: appBarTheme,
        tabBarTheme: tabBarTheme,
        elevatedButtonTheme: buttonStyle,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: OkiColors.primary,
        appBarTheme: appBarTheme,
        tabBarTheme: tabBarTheme,
        elevatedButtonTheme: buttonStyle,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: _themeMode,
      home: _body(),
      builder: (c, widget) => Scaffold(
          key: Log.scaffKey,
          body: widget
      ),
    );
  }

  Widget _body() {
    if (_hasError)
      return _errorBuilder();
    if (!_isIniciado)
      return SplashScreen(mostrarLog: _mostrarLog);
    if (SettingsManager.i.useNewLayout)
      return MainPage2();

    return MainPage();
  }

  //endregion

  void init() async {
    ThemeManager.i.addModeChangeListener(_onThemeModeChanged);
    SettingsManager.i.addLayoutListener((value) {
      setState(() {});
    });
    if (!await AplicationManager.i.init(onError: _onError)) {
      return;
    }

    _mostrarLog = false;
    _isIniciado = true;
    setState(() {});
  }

  Widget _errorBuilder() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ocorreu um erro ao iniciar o app'),
            if (_errorText != null)
              Text(_errorText),
          ],
        ),
      ),
    );
  }

  void _onError(e) {
    setState(() {
      _errorText = e.toString();
      _hasError = true;
    });
  }

  void _onThemeModeChanged(ThemeMode value) {
    setState(() {
      _themeMode = value;
    });
  }

}
