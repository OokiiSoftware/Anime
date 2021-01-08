import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
import 'package:anime/sub_pages/import.dart';
import '../auxiliar/config.dart';
import 'anime_page.dart';
import 'config_page.dart';
import 'info_page.dart';
import 'login_page.dart';

BannerAd myBanner;

void onMenuItemSelected(BuildContext context, String value) async {
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
        Log.d('MainPage', 'loadAdMob', "BannerAd event is $event");
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
}

class MainPage extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}
class _MyState extends State<MainPage> with SingleTickerProviderStateMixin {

  //region Variaveis
  // static const String TAG = 'MainPage';

  TabController _tabController;
  String _currentTitle = Titles.main_page[0];

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
    _loadAdMob();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis

    bool _isOnline = RunTime.isOnline;
    bool isListMode = Config.itemListMode.isListMode;

    var tintColor = _isOnline ? OkiTheme.tint : OkiTheme.textError;
    List<Widget> tabs = [
      Tooltip(message: Titles.main_page[0], child: Tab(icon: Icon(Icons.list, color: tintColor))),
      Tooltip(message: Titles.main_page[1], child: Tab(icon: Icon(Icons.favorite, color: tintColor))),
      Tooltip(message: Titles.main_page[2], child: Tab(icon: Icon(Icons.offline_pin, color: tintColor))),
      Tooltip(message: Titles.main_page[3], child: Tab(icon: Icon(Icons.online_prediction, color: tintColor))),
    ];

    var tabViews = [
      AnimesFragment(context, ListType.assistindo),
      AnimesFragment(context, ListType.favoritos),
      AnimesFragment(context, ListType.concluidos),
      OnlineFragment(context),
    ];

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
                  OkiTheme.refesh(this.context);

                  setState(() {
                    isListMode = Config.itemListMode.isListMode;
                  });
                },
              ),
            PopupMenuButton<String> (
              itemBuilder: (context) {
                return Arrays.menuMain.map((e) => PopupMenuItem(child: Text(e), value: e)).toList();
              },
              onSelected: _onMenuItemSelected,
            ),
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

  void _init() {
    if (_tabController == null) {
      int initIndex = Config.currentTabInMainPage;
      if (initIndex == 3) initIndex = 2;
      _tabController = TabController(length: 4, initialIndex: initIndex, vsync: this);
      _tabController.addListener(_onPageChanged);
    }
    _onPageChanged();
    // _mostrarDicas();
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

  void _onPageChanged() {
    int index = _tabController.index;
    String quantAnimes = '';
    final user = FirebaseOki.userOki;
    switch(index) {
      case ListType.assistindoValue:
        quantAnimes = user.getAnimeLenght(ListType.assistindo).toString();
        break;
      case ListType.favoritosValue:
        quantAnimes = user.getAnimeLenght(ListType.favoritos).toString();
        break;
      case ListType.concluidosValue:
        quantAnimes = user.getAnimeLenght(ListType.concluidos).toString();
        break;
    }
    setState(() {
      _currentTitle = Titles.main_page[index] + (quantAnimes.isEmpty ? '' : ' ($quantAnimes)');
    });
    Config.currentTabInMainPage = index;
  }

  void _mostrarDicas() async {
    bool mostreiEssaDica = Preferences.getBool(PreferencesKey.PAGE_MAIN_DICA_FILTROS);

    if (mostreiEssaDica) return;

    await Future.delayed(Duration(milliseconds: 500));

    Preferences.setBool(PreferencesKey.PAGE_MAIN_DICA_FILTROS, true);

    var title = 'Novos filtros';
    var content = Text("Veja na guia 'Online'");
    DialogBox.dialogOK(context, title: title, content: [content]);
  }

  //endregion

}

class MainPage2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<MainPage2> with SingleTickerProviderStateMixin {

  //region Variaveis
  static const int NAO_LANCADOS_PAGE_INDEX = 4;

  String title = Titles.main_page[0];
  int currentListTypeValue;

  AssistindoFrament assistindoFragment;
  FavoritosFrament favoritosFragment;
  ConcluidosFrament concluidosFragment;
  OnlineFragment onlineFragment;
  NaoLancadosFrament naoLancadosFragment;
  //endregion

  //region overrides

  @override
  void dispose() {
    super.dispose();
    myBanner?.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
    _loadAdMob();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis
    bool _isOnline = RunTime.isOnline;
    bool isListMode = Config.itemListMode.isListMode;

    var tintColor = _isOnline ? OkiTheme.tint : OkiTheme.textError;

    var draewrHeaderTextColor = Colors.white;
    var draewrTextColor = OkiTheme.text;
    var draewrIconColor = OkiTheme.text;
    var draewrTextStyle = TextStyle(color: draewrTextColor);
    //endregion

    Widget temp;
    switch(currentListTypeValue) {
      case ListType.assistindoValue:
        temp = AssistindoFrament(context);
        break;
      case ListType.favoritosValue:
        temp = FavoritosFrament(context);
        break;
      case ListType.concluidosValue:
        temp = ConcluidosFrament(context);
        break;
      case ListType.onlineValue:
        temp = OnlineFragment(context);
        break;
      case NAO_LANCADOS_PAGE_INDEX:
        temp = NaoLancadosFrament(context);
        break;
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(title, style: Styles.titleText),
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
                isListMode = Config.itemListMode.isListMode;
                setState(() {});
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      if (OkiTheme.darkModeOn)...[
                        Colors.grey[900],
                        Colors.grey[850]
                      ] else...[
                        OkiTheme.primary,
                        OkiTheme.primaryLight,
                      ]
                    ]
                ),
              ),
              child: Container(
                child: Column(
                  children: [
                    //Icone / Foto
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 70,
                        height: 70,
                        child: Image.asset(MyIcons.ic_launcher),
                      ),
                    ),
                    Spacer(),
                    // Nome
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppResources.APP_NAME,
                        style: TextStyle(
                          color: draewrHeaderTextColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // Email
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppResources.app_email,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.list, color: draewrIconColor),
              title: Text(Titles.main_page[0], style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                _setPage(ListType.assistindo);
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: draewrIconColor),
              title: Text(Titles.main_page[1], style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                _setPage(ListType.favoritos);
              },
            ),
            ListTile(
              leading: Icon(Icons.offline_pin, color: draewrIconColor),
              title: Text(Titles.main_page[2], style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                _setPage(ListType.concluidos);
              },
            ),
            ListTile(
              leading: Icon(Icons.online_prediction, color: draewrIconColor),
              title: Text(Titles.main_page[3], style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                _setPage(ListType.online);
              },
            ),
            ListTile(
              leading: Icon(Icons.online_prediction, color: draewrIconColor),
              title: Text(Menus.NAO_LANCADOS, style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                _setPage(ListType(NAO_LANCADOS_PAGE_INDEX));
              },
            ),

            //Sobre
            ListTile(
              leading: Icon(Icons.info, color: draewrIconColor),
              title: Text(MenuMain.sobre, style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                onMenuItemSelected(context, MenuMain.sobre);
              },
            ),
            //Loguot
            ListTile(
              leading: Icon(Icons.remove_circle, color: draewrIconColor),
              title: Text(MenuMain.logout, style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                onMenuItemSelected(context, MenuMain.logout);
              },
            ),
            Divider(color: draewrIconColor),
            // Config
            ListTile(
              leading: Icon(Icons.settings, color: draewrIconColor),
              title: Text(MenuMain.config, style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                onMenuItemSelected(context, MenuMain.config);
              },
            ),
          ],
        ),
      ),
      body: temp,
    );
  }

  //endregion

  //region Metodos

  void _init() {
    int initIndex = Config.currentTabInMainPage;
    if (initIndex == 3) initIndex = 2;

    _setPage(ListType(initIndex));
  }

  Widget get getBody {
    switch(currentListTypeValue) {
      case ListType.assistindoValue:
        if (assistindoFragment == null)
          assistindoFragment = AssistindoFrament(context);
        return assistindoFragment;

      case ListType.favoritosValue:
        if (favoritosFragment == null)
          favoritosFragment = FavoritosFrament(context);
        return favoritosFragment;

      case ListType.concluidosValue:
        if (concluidosFragment == null)
          concluidosFragment = ConcluidosFrament(context);
        return concluidosFragment;

      case ListType.onlineValue:
        if (onlineFragment == null)
          onlineFragment = OnlineFragment(context);
        return onlineFragment;

      case 4:
        if (naoLancadosFragment == null)
          naoLancadosFragment = NaoLancadosFrament(context);
        return naoLancadosFragment;
    }
    return null;
  }

  void _setPage(ListType page) {
    currentListTypeValue = page.value;
    title = Titles.main_page[page.value];
    setState(() {});
  }

  void _closeDrawer(BuildContext context) {
    Navigator.pop(context);
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
      return _msgSemResultados(context);
    }
    return listView(listResults);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _setQueryValues();
    if (listResults.length == 0 && query.length > 0) {
      return _msgSemResultados(context);
    }

    return listView(listResults);
  }

  Widget _msgSemResultados(context) => ListTile(
    title: Text(MyTexts.SEM_RESULTADOS),
    subtitle: Text(MyTexts.SUJESTAO_ON_SEM_RESULTADOS),
    onTap: () async {
      await Navigate.to(context, GenerosFragment());
      if (RunTime.updatePesquisaMainPage) {
        sugestoes.clear();
        _setQueryValues();
        sugestoes.addAll(OnlineData.dataAnimes);
        context.setState(() {});
      }
    },
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
            trailing: Layouts.markerAnime(item, user),
            onTap: () => _onItemTap(context, item));
      },
      itemCount: list.length,
    );
  }

  void _setQueryValues() {
    listResults.clear();
    listResults.addAll(query.isEmpty ? [] :
    sugestoes.where((x) =>
    (x.nome.toLowerCase().contains(query.toLowerCase())) ||
        (x.nome2 != null && x.nome2.toLowerCase().contains(query.toLowerCase()))
    ).toList());
  }

  void _onItemTap(BuildContext context, Anime item) async {
    var collection = OnlineData.getAsync(item.idPai);
    if (collection != null) {
      int init = collection.itemsToList.indexOf(item);
      await Navigate.to(context, AnimePage(anime: collection, listType: ListType.online, inicialItem: init));
    }
  }
}