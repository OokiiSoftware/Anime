import 'package:flutter/material.dart';
import '../auxiliar/import.dart';
import '../manager/import.dart';
import '../model/import.dart';
import '../res/import.dart';
import 'import.dart';

//region common

const _PAGE_INDEX_KEY = '_PAGE_INDEX_KEY';

AnimesManager get _animes => AnimesManager.i;
SettingsManager get _settings => SettingsManager.i;

String get _filtro => _settings.filtro;

void _onMenuItemSelected(BuildContext context, String value) async {
  switch(value) {
    case MenuMain.config:
      Navigate.to(context, ConfigPage());
      break;
    case MenuMain.sobre:
    Navigate.to(context, InfoPage());
      break;
    case MenuMain.logout:
    // await FirebaseManager.i.finalize();
    // Navigate.toReplacement(context, LoginPage());
      break;
  }
}

void _onFiltroClick(BuildContext context) async {
  var title = Titles.ALTERAR_FILTRO;
  var controller = TextEditingController();
  controller.text = _settings.filtro;
  var content = [
    OkiTextField(
      controller: controller,
      hint: 'Ex: 2021',
    ),
    Card(
      child: ListTile(
        title: Text('Ver exemplos de filtros'),
        dense: true,
        onTap: () {
          var title = 'Exemplos de Filtros';
          var content = [
            Text('A (Uma letra)'),
            Text('An (Várias letras)'),
            Text('A-Z (Listar de A a Z)'),
            Text('A,Ba,C.. (Listar A,Ba,C..)'),
            Text('VAZIO ou # (Listar tudo)'),
            Text('2021 (Lançados em 2021)'),
            Text('0000 (Animes não lançados)'),
          ];
          DialogBox(context: context, title: title, content: content).ok();
        },
      ),
    ),
    Card(
      child: ListTile(
        title: Text('Alterar os Generos'),
        dense: true,
        onTap: () {
          Navigate.to(context, GenerosPage());
        },
      ),
    ),
  ];

  var result = await DialogBox(
    context: context,
    title: title,
    content: content,
  ).cancelOK();

  if (result.isPositive) {
    var text = controller.text.trim().replaceAll(' ', '');
    if (text.isEmpty) text = '#';
    _settings.filtro = text;
  }
}

void _loadInitIndex() {
  if (_pageIndex == null) {
    _pageIndex = Preferences.pref.getInt(_PAGE_INDEX_KEY, padrao: _ALL_INDEX);
  }
}
void _saveIndex(int index) {
  Preferences.pref.setInt(_PAGE_INDEX_KEY, index);
}

const int _FAV_INDEX = 0;
const int _ALL_INDEX = 1;
const int _NAO_INDEX = 2;

int _pageIndex;
bool _inProgress = false;

//endregion

class MainPage2 extends StatefulWidget {
  @override
  _State createState() => _State();
}
class _State extends State<MainPage2> with SingleTickerProviderStateMixin {


  //region overrides

  @override
  void dispose() {
    super.dispose();
    _settings.removeListModeListener(_onListModeChanged);
    _settings.removeGenerosListener(_onGenerosChanged);
    _settings.removeFiltroListener(_onFiltroChanged);
    AdMobManager.i.dispose();
  }

  @override
  void initState() {
    super.initState();
    _settings.addListModeListener(_onListModeChanged);
    _settings.addGenerosListener(_onGenerosChanged);
    _settings.addFiltroListener(_onFiltroChanged);
    _loadInitIndex();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    Anime anime = _getAnime();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppResources.APP_NAME),
        actions: [
          IconButton(
            tooltip: 'Pesquisar',
            icon: Icon(Icons.search,),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          ), // Pesquisa

          IconButton(
            tooltip: 'Visualização',
            icon: Icon(_settings.listMode.isList ? Icons.list : Icons.view_module_sharp),
            onPressed: () {
              if (_settings.listMode.isList)
                _settings.listMode = AnimeListMode.grid;
              else
                _settings.listMode = AnimeListMode.list;
              setState(() {});
            },
          ), // Visualização
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
                      if (ThemeManager.i.isDarkMode)...[
                        Colors.grey[900],
                        Colors.grey[850]
                      ] else...[
                        OkiColors.primary,
                        OkiColors.primaryLight,
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
                        child: Image.asset(MyIcons.ic_launcher_adaptive),
                      ),
                    ),
                    Spacer(),
                    // Nome
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppResources.APP_NAME,
                        style: TextStyle(
                          color: Colors.white,
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
              leading: Icon(Icons.favorite),
              title: Text(Titles.main_page[0]),
              onTap: () {
                _closeDrawer(context);
                _setPage(_FAV_INDEX);
              },
            ), // Favoritos
            ListTile(
              leading: Icon(Icons.online_prediction,),
              title: Text(Titles.main_page[1],),
              onTap: () {
                _closeDrawer(context);
                _setPage(_ALL_INDEX);
              },
            ), // Online
            ListTile(
              leading: Icon(Icons.online_prediction),
              title: Text(Menus.NAO_LANCADOS),
              onTap: () {
                _closeDrawer(context);
                _setPage(_NAO_INDEX);
              },
            ), // Não lançados

            ListTile(
              leading: Icon(Icons.info,),
              title: Text(MenuMain.sobre,),
              onTap: () {
                _closeDrawer(context);
                _onMenuItemSelected(context, MenuMain.sobre);
              },
            ), // Sobre

            ListTile(
              leading: Icon(Icons.remove_circle,),
              title: Text(MenuMain.logout,),
              onTap: () {
                _closeDrawer(context);
                _onMenuItemSelected(context, MenuMain.logout);
              },
            ), // Loguot
            Divider(),

            ListTile(
              leading: Icon(Icons.settings,),
              title: Text(MenuMain.config,),
              onTap: () {
                _closeDrawer(context);
                _onMenuItemSelected(context, MenuMain.config);
              },
            ), // Config
          ],
        ),
      ),
      body: AnimePage(
        anime: anime,
        showAppBar: false,
        isRoot: true,
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator () :
      (_pageIndex == _ALL_INDEX) ?
      FloatingActionButton(
        tooltip: 'Filtro',
        child: Text(_settings.filtro.toUpperCase()),
        onPressed: () => _onFiltroClick(context),
      ) : null,
    );
  }

  Anime _getAnime() {
    switch(_pageIndex) {
      case _FAV_INDEX:
        return _animes.getFavoritos();
        break;
      case _NAO_INDEX:
        return _animes.getList(filtro: '0000');
        break;
      default:
        return _animes.getList(filtro: _filtro,);
    }
  }

  //endregion

  //region Metodos

  void _init() async {
    if (!_animes.sincronizado) {
      _setInProgess(true);
      await _animes.sincronizar();
      _setInProgess(false);
    }
  }

  void _onFiltroChanged(String filtro) {
    setState(() {});
  }
  void _onGenerosChanged(List<String> generos) {
    setState(() {});
  }
  void _onListModeChanged(AnimeListMode listMode) {
    setState(() {});
  }

  void _setPage(int index) {
    _pageIndex = index;
    _saveIndex(index);
    setState(() {});
  }

  void _closeDrawer(BuildContext context) {
    Navigator.pop(context);
  }

  void _setInProgess(bool b) {
    _inProgress = b;
    if (mounted)
      setState(() {});
  }

  //endregion

}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State2();
}
class _State2 extends State<MainPage> with SingleTickerProviderStateMixin {

  //region Variaveis

  TabController _controller;

  //endregion

  //region overrides

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
    _settings.removeListModeListener(_onListModeChanged);
    _settings.removeGenerosListener(_onGenerosChanged);
    _settings.removeFiltroListener(_onFiltroChanged);
    AdMobManager.i.dispose();
  }

  @override
  void initState() {
    _loadInitIndex();
    if (_pageIndex >= 2)
      _pageIndex = 1;
    super.initState();
    _controller = TabController(length: 2, initialIndex: _pageIndex, vsync: this);
    _controller.addListener(_onPageChanged);

    _settings.addListModeListener(_onListModeChanged);
    _settings.addGenerosListener(_onGenerosChanged);
    _settings.addFiltroListener(_onFiltroChanged);

    _init();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis

    var title = Titles.main_page[_pageIndex];

    List<Widget> tabs = [
      Tooltip(message: Titles.main_page[0], child: Tab(icon: Icon(Icons.favorite))),
      Tooltip(message: Titles.main_page[1], child: Tab(icon: Icon(Icons.online_prediction))),
      // Tooltip(message: Titles.main_page[2], child: Tab(icon: Icon(Icons.offline_pin,))),
      // Tooltip(message: Titles.main_page[3], child: Tab(icon: Icon(Icons.online_prediction,))),
    ];

    var tabViews = [
      AnimePage(
        anime: _animes.getFavoritos(),
        showAppBar: false,
        isRoot: true,
      ),
      AnimePage(
        anime: _animes.getList(filtro: _filtro),
        showAppBar: false,
        isRoot: true,
      ),
    ];

    //endregion

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: TabBar(
          controller: _controller,
          tabs: tabs,
        ),
        actions: [
          IconButton(
            tooltip: 'Pesquisar',
            icon: Icon(Icons.search,),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          ), // Pesquisa

          IconButton(
            tooltip: 'Visualização',
            icon: Icon(_settings.listMode.isList ? Icons.list : Icons.view_module_sharp),
            onPressed: () {
              if (_settings.listMode.isList)
                _settings.listMode = AnimeListMode.grid;
              else
                _settings.listMode = AnimeListMode.list;
              setState(() {});
            },
          ), // Visualização

          PopupMenuButton<String> (
            itemBuilder: (context) {
              return Arrays.menuMain.map((e) => PopupMenuItem(child: Text(e), value: e)).toList();
            },
            onSelected: (value) => _onMenuItemSelected(context, value),
          ),
        ],
      ),
      body: TabBarView(
        controller: _controller,
        children: tabViews,
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator () :
      (_pageIndex == _ALL_INDEX) ?
      FloatingActionButton(
        tooltip: 'Filtro',
        child: Text(_settings.filtro.toUpperCase()),
        onPressed: () => _onFiltroClick(context),
      ) : null,
    );
  }

  //endregion

  //region Metodos

  void _init() async {
    if (!_animes.sincronizado) {
      _setInProgess(true);
       await _animes.sincronizar();
      _setInProgess(false);
    }
  }

  void _onFiltroChanged(String filtro) {
    setState(() {});
  }
  void _onGenerosChanged(List<String> generos) {
    setState(() {});
  }
  void _onListModeChanged(AnimeListMode listMode) {
    setState(() {});
  }

  void _onPageChanged() {
    _pageIndex = _controller.index;
    _saveIndex(_pageIndex);
    setState(() {});
  }

  void _setInProgess(bool b) {
    _inProgress = b;
    if (mounted)
      setState(() {});
  }

  //endregion

}
