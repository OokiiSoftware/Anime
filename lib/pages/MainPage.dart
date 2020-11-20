import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/model/config.dart';
import 'package:anime/model/user.dart';
import 'package:anime/pages/anime_page.dart';
import 'package:anime/pages/login_page.dart';
import 'package:anime/pages/info_page.dart';
import 'package:anime/res/my_icons.dart';
import 'package:anime/res/resources.dart';
import 'package:anime/res/strings.dart';
import 'package:anime/res/theme.dart';
import 'package:anime/sub_pages/animes_fragment.dart';
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
  String _currentTitle = MyTitles.main_page[0];

  //endregion

  //region overrides

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis

    bool isListMode = ItemListMode(Config.itemListMode).isListMode;

    if (!_isIniciado) return _splashScreen();

    var tintColor = _isOnline ? MyTheme.tint() : MyTheme.textError();

    final List<Widget> tabs = [
      Tooltip(message: MyTitles.main_page[0], child: Tab(icon: Icon(Icons.list, color: tintColor))),
      Tooltip(message: MyTitles.main_page[1], child: Tab(icon: Icon(Icons.favorite, color: tintColor))),
      Tooltip(message: MyTitles.main_page[2], child: Tab(icon: Icon(Icons.offline_pin, color: tintColor))),
      Tooltip(message: MyTitles.main_page[3], child: Tab(icon: Icon(Icons.online_prediction, color: tintColor))),
    ];

    final user = Firebase.user;
    final assistindoFragment = AnimesFragment(context, user.assistindoList, ListType(ListType.assistindo));
    final favoritosFragment = AnimesFragment(context, user.favoritosList, ListType(ListType.favoritos));
    final concluidosFragment = AnimesFragment(context, user.concluidosList, ListType(ListType.concluidos));
    final onlineFragment = AnimesFragment(context, OnlineData.dataList, ListType(ListType.online));

    final List<Widget> tabViews = [assistindoFragment, favoritosFragment, concluidosFragment, onlineFragment];

    if (_tabController == null) {
      _tabController = TabController(length: tabs.length, initialIndex: 0, vsync: this);
      _tabController.addListener(() => _onPageChanged(_tabController.index));
    }

    if (!_isOnline) Config.itemListMode = ItemListMode.list;

    //endregion

    return _isIniciado ? Scaffold(
        appBar: AppBar(
          title: Text(_currentTitle, style: MyStyles.titleText),
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
                  if (isListMode) Config.itemListMode = ItemListMode.grid;
                  else Config.itemListMode = ItemListMode.list;
                  Config.save();
                  setState(() {
                    isListMode = ItemListMode(Config.itemListMode).isListMode;
                  });
                },
              ),
            IconButton(
              tooltip: 'Informações',
              icon: Icon(Icons.info, color: tintColor),
              onPressed: () {
                Navigate.to(context, InfoPage());
              },
            ),
            Padding(padding: EdgeInsets.only(right: 10))
          ],
        ),
        body: TabBarView(
            controller: _tabController,
            children: tabViews
        )
    ) :
    _splashScreen();
  }

  //endregion

  //region Metodos

  void _init() async {
    _checkInit();
    await GlobalData.init();
    await Firebase.init();

    if (!Firebase.isLogado) {
      Navigate.toReplacement(context, LoginPage());
      return;
    }

    _mostrarLog = false;
    setState(() {
      _isIniciado = _isOnline = OnlineData.isOnline = true;
    });
  }

  Widget _splashScreen() {
    var padding = Padding(padding: EdgeInsets.only(top: 10));
    return Scaffold(
      backgroundColor: MyTheme.primary(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(MyIcons.ic_launcher, width: 200),
            padding,
            Text(MyResources.APP_NAME, style: TextStyle(fontSize: 30, color: MyTheme.text())),
            if (_mostrarLog)...[
              padding,
              Text('Parece que sua conexão está sem Chakra\nIniciando modo Offline', style: TextStyle(color: MyTheme.text())),
              LinearProgressIndicator(backgroundColor: MyTheme.primary())
            ],
          ],
        ),
      ),
    );
  }

  Future _checkInit() async {
    await Future.delayed(Duration(seconds: 10));
    if (!_isIniciado) {
      setState(() {
        _mostrarLog = true;
      });
    }
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      _isIniciado = true;
    });
//    await Future.delayed(Duration(seconds: 60));
//    _init();
  }

  void _onPageChanged(int index) {
    String quantAnimes = '';
    final user = Firebase.user;
    switch(index) {
      case ListType.assistindo:
        quantAnimes = user.assistindo.length.toString();
        break;
      case ListType.favoritos:
        quantAnimes = user.favoritos.length.toString();
        break;
      case ListType.concluidos:
        quantAnimes = user.concluidos.length.toString();
        break;
    }
    setState(() {
      _currentTitle = MyTitles.main_page[index] + (quantAnimes.isEmpty ? '' : ' ($quantAnimes)');
    });
  }

  //endregion

}

class DataSearch extends SearchDelegate<String> {

  final sugestoes = OnlineData.dataAnimes;

  @override
  String get searchFieldLabel => MyStrings.PESQUISAR;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () {query = '';})];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    ), onPressed: () {
      close(context, null);
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    Navigator.pop(context);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Anime> list = query.isEmpty ? [] :
    sugestoes.where((x) =>
        (x.nome.toLowerCase().contains(query.toLowerCase())) ||
        (x.nome2 != null && x.nome2.toLowerCase().contains(query.toLowerCase()))
    ).toList();
    User user = Firebase.user;
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemBuilder: (context, index) {
      Anime item = list[index];
      return MyLayouts.anime(
          item,
          list: ListType(ListType.online),
          showSeconfName: true,
          trailing: MyLayouts.teste2(item, user),
          onTap: () => _onItemTap(context, item));
    },
      itemCount: list.length,
    );
  }

  void _onItemTap(BuildContext context, Anime item) async {
      await Navigate.to(context, AnimePage(ListType(ListType.online), anime: item));
  }

}