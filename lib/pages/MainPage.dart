import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
import 'package:anime/sub_pages/import.dart';
import '../auxiliar/config.dart';
import 'anime_page.dart';
import 'config_page.dart';
import 'info_page.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}
class _MyState extends State<MainPage> with SingleTickerProviderStateMixin {

  //region Variaveis

  static const String TAG = 'MainPage';

  bool _isIniciado = false;
  bool _isOnline = false;
  bool _mostrarLog = false;

  TabController _tabController;
  String _currentTitle = Titles.main_page[0];

  BannerAd myBanner;

  //endregion

  //region overrides

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
    myBanner?.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis

    bool isListMode = Config.itemListMode.isListMode;

    if (!_isIniciado) return SplashScreen(mostrarLog: _mostrarLog);

    var tintColor = _isOnline ? OkiTheme.tint : OkiTheme.textError;

    final List<Widget> tabs = [
      Tooltip(message: Titles.main_page[0], child: Tab(icon: Icon(Icons.list, color: tintColor))),
      Tooltip(message: Titles.main_page[1], child: Tab(icon: Icon(Icons.favorite, color: tintColor))),
      Tooltip(message: Titles.main_page[2], child: Tab(icon: Icon(Icons.offline_pin, color: tintColor))),
      Tooltip(message: Titles.main_page[3], child: Tab(icon: Icon(Icons.online_prediction, color: tintColor))),
    ];

    final assistindoFragment = AnimesFragment(context, ListType.assistindo);
    final favoritosFragment = AnimesFragment(context, ListType.favoritos);
    final concluidosFragment = AnimesFragment(context, ListType.concluidos);
    final onlineFragment = AnimesFragment(context, ListType.online);

    final List<Widget> tabViews = [assistindoFragment, favoritosFragment, concluidosFragment, onlineFragment];

    if (_tabController == null) {
      _tabController = TabController(length: tabs.length, initialIndex: 0, vsync: this);
      _tabController.addListener(() => _onPageChanged(_tabController.index));
    }

    if (!_isOnline) Config.itemListMode = ListMode.list;

    //endregion

    return Scaffold(
        appBar: AppBar(
          title: Text(_currentTitle, style: Styles.titleText),
          bottom: TabBar(
            controller: _tabController,
            tabs: tabs,
          ),
          actions: [
            IconButton(
              tooltip: 'Pesquisar',
              icon: Icon(Icons.search, color: tintColor),
              onPressed: () {
                showSearch(context: context, delegate: DataSearch());
              },
            ),
            if (_isOnline)
              IconButton(
                tooltip: 'Modo de Visualização',
                icon: Icon(isListMode? Icons.list : Icons.view_module),
                onPressed: () {
                  if (isListMode) Config.itemListMode = ListMode.grid;
                  else Config.itemListMode = ListMode.list;

                  setState(() {
                    isListMode = Config.itemListMode.isListMode;
                  });
                },
              ),
            // IconButton(
            //   tooltip: 'Configurações',
            //   icon: Icon(Icons.settings, color: tintColor),
            //   onPressed: () {
            //     Navigate.to(context, ConfigPage());
            //   },
            // ),
            PopupMenuButton<String> (
              itemBuilder: (context) {
                return Arrays.menuMain.map((e) => PopupMenuItem(child: Text(e), value: e)).toList();
              },
              onSelected: _onMenuItemSelected,
            ),
            // Padding(padding: EdgeInsets.only(right: 10))
          ],
        ),
        body: TabBarView(
            controller: _tabController,
            children: tabViews
        )
    );
  }

  //endregion

  //region Metodos

  void _init() async {
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

    if (!FirebaseOki.isLogado) {
      Navigate.toReplacement(context, LoginPage());
      return;
    }

    setState(() {
      _mostrarLog = false;
      _isIniciado = _isOnline = RunTime.isOnline = true;
    });
    if (!onlineDataBaixados)
      await OnlineData.baixarLista();
    _loadAdMob();
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

  void _onMenuItemSelected(String value) async {
    switch(value) {
      case MenuMain.config:
        Navigate.to(context, ConfigPage());
        break;
      case MenuMain.sobre:
        Navigate.to(context, InfoPage());
        break;
      case MenuMain.logout:
        await FirebaseOki.finalize();
        Navigate.toReplacement(context, LoginPage());
        break;
    }
  }

  void _onPageChanged(int index) {
    String quantAnimes = '';
    final user = FirebaseOki.userOki;
    switch(index) {
      case ListType.assistindoValue:
        quantAnimes = user.assistindo.length.toString();
        break;
      case ListType.favoritosValue:
        quantAnimes = user.favoritos.length.toString();
        break;
      case ListType.concluidosValue:
        quantAnimes = user.concluidos.length.toString();
        break;
    }
    setState(() {
      _currentTitle = Titles.main_page[index] + (quantAnimes.isEmpty ? '' : ' ($quantAnimes)');
    });
  }

  void _loadAdMob() async {
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      // keywords: <String>['flutterio', 'Anime'],
      // contentUrl: 'https://flutter.io',
      childDirected: false,
      testDevices: <String>[], // Android emulators are considered test devices
    );

    myBanner?.dispose();
    myBanner = BannerAd(
        adUnitId: /*BannerAd.testAdUnitId,*/'ca-app-pub-8585143969698496/1877059427',
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          Log.d(TAG, 'loadAdMob', "BannerAd event is $event");
          switch(event) {
            case MobileAdEvent.loaded:
              RunTime.mostrandoAds = true;
              break;
            default:
              RunTime.mostrandoAds = false;
          }
        }
    );
    if (await myBanner.load())
      await myBanner.show();

    // InterstitialAd myInterstitial = InterstitialAd(
    //   adUnitId: 'ca-app-pub-8585143969698496/1877059427',
    //   targetingInfo: targetingInfo,
    // );
    // myInterstitial.listener = (MobileAdEvent event) {
    //   // print("BannerAd event is $event");
    //   if (event == MobileAdEvent.loaded) {
    //     // myBanner.show();
    //     // myInterstitial.dispose();
    //   }
    // };
  }

  //endregion

}

class DataSearch extends SearchDelegate<String> {

  final sugestoes = OnlineData.dataAnimes;
  final List<Anime> listResults = [];

  @override
  String get searchFieldLabel => Strings.PESQUISAR;

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeData(
    brightness: Brightness.dark,
    primaryColor: OkiTheme.primary,
  );

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: Icon(Icons.clear), onPressed: () {query = '';})];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation
      ),
      onPressed: () => close(context, null)
  );

  @override
  Widget buildResults(BuildContext context) {
    if (listResults.length == 0) {
      return _msgSemResultados;
    }
    return listView(listResults);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    listResults.clear();
    listResults.addAll(query.isEmpty ? [] :
    sugestoes.where((x) =>
        (x.nome.toLowerCase().contains(query.toLowerCase())) ||
        (x.nome2 != null && x.nome2.toLowerCase().contains(query.toLowerCase()))
    ).toList());

    if (listResults.length == 0 && query.length > 0) {
      return _msgSemResultados;
    }

    return listView(listResults);
  }

  Widget get _msgSemResultados => ListTile(
    title: Text('Sem resultados'),
    subtitle: Text('Tente selecionar alguns generos na guia \'Online\''),
  );

  ListView listView(List<Anime> list) {
    UserOki user = FirebaseOki.userOki;
    return ListView.builder(
      padding: Layouts.adsPadding(10),
      itemBuilder: (context, index) {
        Anime item = list[index];
        return AnimeItemLayout(
            item,
            listType: ListType.online,
            showSeconfName: true,
            trailing: Layouts.teste2(item, user),
            onTap: () => _onItemTap(context, item));
      },
      itemCount: list.length,
    );
  }

  void _onItemTap(BuildContext context, Anime item) async {
      await Navigate.to(context, AnimePage(ListType.online, anime: item));
  }

}