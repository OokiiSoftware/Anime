import 'package:anime/auxiliar/aplication.dart';
import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/auxiliar/logs.dart';
import 'package:anime/auxiliar/online_data.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/model/config.dart';
import 'package:anime/model/user_oki.dart';
import 'package:anime/pages/anime_page.dart';
import 'package:anime/pages/config_page.dart';
import 'package:anime/pages/login_page.dart';
import 'package:anime/res/resources.dart';
import 'package:anime/res/strings.dart';
import 'package:anime/res/theme.dart';
import 'package:anime/sub_pages/animes_fragment.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  MyPageState createState() => MyPageState();
}
class MyPageState extends State<MainPage> with SingleTickerProviderStateMixin {

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

    if (!_isIniciado) return Layouts.splashScreen(mostrarLog: _mostrarLog);

    var tintColor = _isOnline ? MyTheme.tint : MyTheme.textError;

    final List<Widget> tabs = [
      Tooltip(message: Titles.main_page[0], child: Tab(icon: Icon(Icons.list, color: tintColor))),
      Tooltip(message: Titles.main_page[1], child: Tab(icon: Icon(Icons.favorite, color: tintColor))),
      Tooltip(message: Titles.main_page[2], child: Tab(icon: Icon(Icons.offline_pin, color: tintColor))),
      Tooltip(message: Titles.main_page[3], child: Tab(icon: Icon(Icons.online_prediction, color: tintColor))),
    ];

    final user = FirebaseOki.user;
    final assistindoFragment = AnimesFragment(context, user.assistindoList, ListType.assistindo);
    final favoritosFragment = AnimesFragment(context, user.favoritosList, ListType.favoritos);
    final concluidosFragment = AnimesFragment(context, user.concluidosList, ListType.concluidos);
    final onlineFragment = AnimesFragment(context, OnlineData.dataList, ListType.online);

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
            IconButton(
              tooltip: 'Configurações',
              icon: Icon(Icons.settings, color: tintColor),
              onPressed: () {
                Navigate.to(context, ConfigPage());
              },
            ),
            Padding(padding: EdgeInsets.only(right: 10))
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
    if (OnlineData.data.length == 0) {
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
      _isIniciado = _isOnline = OnlineData.isOnline = true;
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

  void _onPageChanged(int index) {
    String quantAnimes = '';
    final user = FirebaseOki.user;
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
          Log.d(TAG, 'testAdMob', "BannerAd event is $event");
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
    primaryColor: MyTheme.primary,
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
      return ListTile(
        title: Text('Sem resultados'),
        subtitle: Text('Tente selecionar alguns generos na guia \'Online\''),
      );
    }

    return listView(listResults);
  }

  ListView listView(List<Anime> list) {
    UserOki user = FirebaseOki.user;
    return ListView.builder(
      padding: Layouts.adsPadding(10),
      itemBuilder: (context, index) {
        Anime item = list[index];
        return Layouts.anime(
            item,
            list: ListType.online,
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