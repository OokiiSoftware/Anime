import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import '../fragments/import.dart';
import '../auxiliar/import.dart';
import '../manager/import.dart';
import '../model/import.dart';
import '../res/import.dart';

class AnimePage extends StatefulWidget {
  final Anime anime;
  final bool showAppBar;
  final bool isRoot;
  AnimePage({this.anime, this.showAppBar = true, this.isRoot = false});
  @override
  _State createState() => _State();
}
class _State extends State<AnimePage> with AutomaticKeepAliveClientMixin {

  //region Variaveis

  // ignore: unused_field
  static const String TAG = 'AnimePage';

  Anime get _anime => widget.anime;
  bool get showAppBar => widget.showAppBar;
  bool get isRoot => widget.isRoot;

  SettingsManager get _settings => SettingsManager.i;

  bool _inProgress = false;

  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!_anime.isComplete) {
      _setInProgress(true);
      _anime.complete()
          .then((value) => _setInProgress(false))
          .catchError((e) => _setInProgress(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String title = _anime.nome;
    if (title.isEmpty)
      title = AppResources.APP_NAME;

    return Scaffold(
      appBar: (showAppBar) ?
      AppBar(
        title: Text(title),
        actions: [
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
      ) : null,
      body: _getBody(),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  Widget _getBody() {
    if (_anime.isCollection || isRoot) {
      return AnimesFragment(
        anime: _anime,
        isListMode: _settings.listMode.isList,
        onItemClick: _onItemClick,
      );
    }

    if (_anime.length == 1) {
      return _AnimeFragment(
        anime: _anime.getAt(0),
      );
    }
    if (_anime.isEmpty) {
      return _AnimeFragment(
        anime: _anime,
      );
    }

    return Center(
      child: Text('Lista vazia'),
    );
  }

  //endregion

  //region Metodos

  void _onItemClick(Anime item) async {
    await Navigate.to(context, AnimePage(
      anime: item,
      showAppBar: item.isCollection,
    ));
    setState(() {});
  }

  void _setInProgress(bool b) {
    if (mounted)
      setState(() {
        _inProgress = b;
      });
  }

  //endregion

}

class _AnimeFragment extends StatefulWidget {
  final Anime anime;
  final Function(Anime) onDelete;
  _AnimeFragment({@required this.anime, this.onDelete});
  @override
  _StateFragment createState() => _StateFragment();
}
class _StateFragment extends State<_AnimeFragment> {

  //region Variaveis

  // ignore: unused_field
  static const String TAG = 'AnimePage';

  Anime get _anime => widget.anime;

  String _linkProvider = '';
  String _fotoUrl = '';

  final Classificacao _c = Classificacao();
  int _episodios = 0;

  static bool _isAvancado = true;
  static bool _showSinopse = false;

  //region TextEditingController
  TextEditingController _desc = TextEditingController();
  TextEditingController _ultimo = TextEditingController();
  //endregion

  static const double _defaultValue = -1;

  double _media = _defaultValue;

  //endregion

  //region overrides

  @override
  void dispose() {
    AdMobManager.i.removeListener(_adMobChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _preencherDados(_anime);

    AdMobManager.i.addListener(_adMobChanged);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_anime.nome),
          actions: [
            IconButton(
              tooltip: 'Reportar problema',
              icon: Icon(Icons.bug_report),
              onPressed: _onBugClick,
            ), // Bug
            if (_anime.isFavorited)...[
              IconButton(
                tooltip: 'Remover Favoritos',
                icon: Icon(Icons.favorite),
                onPressed: () => _onUnFavoriteClick(_anime),
              ), // Delete
            ] else...[
              IconButton(
                tooltip: 'Add Favoritos',
                icon: Icon(Icons.favorite_border),
                onPressed: () => _onFavoriteClick(_anime),
              ), // Delete
            ],
          ],
        ),
        body: SingleChildScrollView(
          padding: adsPadding(right: 20, left: 20),
          child: Column(
            children: [
              _widgetFoto(),
              _headInfo(),

              Card(
                child: Row(
                  children: [
                    if (_anime.trailer.isNotEmpty)
                    _buttonLayout('${Strings.TRAILER}', _onTrailerClick),
                    SizedBox(width: 2,),
                    if(_anime.link.isNotEmpty /*&& AdminManager.i.isAdmin*/)//todo adm
                    _buttonLayout(_linkProvider, _onOpenLinkClick),
                  ],
                ),
              ), // Trailer, Link
              Card(
                child: Row(
                  children: [
                    if (_anime.isCrunchyroll || _anime.parent.isCrunchyroll)
                    _buttonLayout('${Strings.CRUNCHYROLL}', _onCrunchyrollClick),
                    SizedBox(width: 2,),
                    if(_anime.isFunimation || _anime.parent.isFunimation)
                    _buttonLayout(Strings.FUNIMATION, _onFunimationClick, color: Colors.deepPurple),
                  ],
                ),
              ), // Links

              if (_anime.sinopse.isNotEmpty)
                ExpansionTile(
                  initiallyExpanded: _showSinopse,
                  title: Text('${Strings.SINOPSE}: ${_showSinopse ? 'ocultar': 'mostrar'}'),
                  onExpansionChanged: (value) => setState(() => _showSinopse = value),
                  children: [
                    SelectableText(_anime.sinopse),
                    if (_anime.aviso.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(5),
                        child: SelectableText('Info: ${_anime.aviso}', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),

              //region Avancado
              if (_isAvancado)...[
                Divider(),
                if (_anime.isFavorited)...[

                  OkiTextField(
                    controller: _desc,
                    hint: Strings.OBSERVACAO,
                    textInputType: TextInputType.text,
                  ), // Descrição
                  OkiTextField(
                    controller: _ultimo,
                    hint: MyTexts.ULTIMO_VISTO,
                    textInputType: TextInputType.number,
                  ), // Ultimo Assistido

                  _customSlider(_c.animacao, label: Strings.ANIMACAO, onChanged: (value) {setState(() {_c.animacao = value;});}),

                  _customSlider(_c.historia, label: Strings.HIRTORIA, onChanged: (value) {setState(() {_c.historia = value;});}),

                  _customSlider(_c.ecchi, label: Strings.ECCHI, onChanged: (value) {setState(() {_c.ecchi = value;});}),

                  _customSlider(_c.comedia, label: Strings.COMEDIA, onChanged: (value) {setState(() {_c.comedia = value;});}),

                  _customSlider(_c.romance, label: Strings.ROMANCE, onChanged: (value) {setState(() {_c.romance = value;});}),

                  _customSlider(_c.drama, label: Strings.DRAMA, onChanged: (value) {setState(() {_c.drama = value;});}),

                  _customSlider(_c.terror, label: Strings.TERROR, onChanged: (value) {setState(() {_c.terror = value;});}),

                  _customSlider(_c.acao, label: Strings.ACAO, onChanged: (value) {setState(() {_c.acao = value;});}),

                  _customSlider(_c.aventura, label: Strings.AVENTURA, onChanged: (value) {setState(() {_c.aventura = value;});}),
                ],
              ],
              //endregion

              AdsFooter()
            ],
          ),
        ),
      ),
      onWillPop: () async {
        _anime.classificacao.set(_c.toJson());
        _anime.desc = _desc.text;
        _anime.ultimoAssistido = int.tryParse(_ultimo.text) ?? 0;
        return true;
      },
    );
  }

  Image _widgetFoto() {
    return Image(
      image: NetworkToFileImage(
        url: _fotoUrl,
        file: _anime.fotoFile,
      ),
      errorBuilder: (context, widget, e) => MiniaturaAnime(_anime),
      loadingBuilder: (context, widget, progress) {
        if (progress == null) return widget;
        return LinearProgressIndicator(
          value: (progress.expectedTotalBytes == null) ? null :
          progress.cumulativeBytesLoaded / progress.expectedTotalBytes,
        );
      },
    );
  }

  Widget _headInfo() {
    List<String> test = [];

    if ((_anime.nome2 ?? '').isNotEmpty) {
      test.add(_anime.nome2);
      test.add('');
    }

    test.add('Episódios: ${_episodios >= 0 ? _episodios : 'Indefinido'}');

    test.add('Data: ${_anime.data}');

    if (_anime.isNoLancado)
      test.add('Status: Ainda não foi ao ar');

    if (_anime.maturidade.isNotEmpty)
      test.add('Maturidade: ${_anime.maturidade}');

    if(_media >= 0)
      test.add('${Strings.MEDIA}: $_media');

    if (_c.votos > 0)
      test.add('${Strings.VOTOS}: ${_c.votos}');

    if(_anime.generos.isNotEmpty)
      test.add('${Strings.GENEROS}: ${_anime.generos.join(', ')}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome 1
        SelectableText('${Strings.TITULO}: ${_anime.nome}', style: TextStyle(fontSize: 20)),

        SelectableText(test.join('\n')),

        itemLayout('${Strings.TIPO}: ${_anime.tipo}   ', AnimeTypeIcon(value: _anime.tipo)),


      ],
    );
  }

  Widget _customSlider(double currentValue, {@required String label, Function(double) onChanged}) {
    int teste = currentValue.round();

    Color getColor(int value) {
      if ((value == _defaultValue.toInt()))
        return Colors.grey;

      if ((value < 5))
        return OkiColors.textError;
      if ((value <= 7))
        return OkiColors.primary;

        return Colors.greenAccent;
    }

    return OkiSlider(
      title: label,
      value: currentValue,
      color: getColor(teste),
      onChanged: onChanged,
    );
  }

  Widget itemLayout(String value, [Widget trailing]) {
    return Row(
      children: [
        SelectableText(value),
        if (trailing != null)
          trailing,
      ],
    );
  }

  Widget _buttonLayout(String value, Function onPressed, {Color color}) {
    return Expanded(
      child: OkiButton(
        child: Text(value),
        onPressed: onPressed,
        color: color,
      ),
    );
  }

  //endregion

  //region Metodos

  void _onUnFavoriteClick(Anime item) {
    item.isFavorited = false;
    AnimesManager.i.save();
    setState(() {});
  }

  void _onFavoriteClick(Anime item) {
    item.isFavorited = true;
    AnimesManager.i.save();
    setState(() {});
  }

  void _onBugClick() async {
    var controller = TextEditingController();
    var title = MyTexts.REPORTAR_PROBLEMA_TITLE;
    var content = [
      TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: MyTexts.DIGITE_AQUI
        ),
      )
    ];
    var result = await DialogBox(context: context, title: title, content: content,).cancelOK();
    var desc = controller.text;
    if (result.isPositive && desc.trim().isNotEmpty) {
      // BugAnime item = BugAnime();
      // item.idUser = 'tempId';// FirebaseManager.i.user.uid;
      // item.data = DataHora.now();
      // item.idAnime = anime.id;
      // item.descricao = desc;
      // _setInProgress(true);
      // await item.salvar();
      // Log.snack(MyTexts.REPORTAR_PROBLEMA_AGRADECIMENTO);
      // _setInProgress(false);
    }
  }

  void _onOpenLinkClick () {
    AplicationManager.i.openUrl(_anime.link);
  }

  void _onTrailerClick() {
    // Aplication.openUrl(_trailer);
    // Navigate.to(context, YouTubePage(_trailer));
  }

  void _onCrunchyrollClick() {
    String link;
    if (_anime.isCrunchyroll)
      link = _anime.getLink(LinksType.crunchyroll);
    else
      link = _anime.parent.getLink(LinksType.crunchyroll);

    AplicationManager.i.openUrl(link);
  }
  void _onFunimationClick() {
    String link;
    if (_anime.isFunimation)
      link = _anime.getLink(LinksType.funimation);
    else
      link = _anime.parent.getLink(LinksType.funimation);

    AplicationManager.i.openUrl(link);
  }

  void _adMobChanged(bool b) {//todo admob

  }

  void _resetValores() {
    _desc = TextEditingController();

    _c.reset();
    _media = _defaultValue;
    setState(() {});
  }

  void _preencherDados(Anime item,) async {
    _resetValores();

    _episodios = item.episodios;
    _media = item.getMedia;

    _desc.text = item.desc;
    _ultimo.text = item.ultimoAssistido.toString();

    if(item.link.toLowerCase().contains(Strings.CRUNCHYROLL.toLowerCase()))
      _linkProvider = Strings.CRUNCHYROLL;
    else
      _linkProvider = Strings.LINK;

    _c.set(item.classificacao.toJson());

    item.fotoUrl.then((value) => setState(() => _fotoUrl = value)).catchError((e) => {});

    setState(() {});
  }

  //endregion

}

class DataSearch extends SearchDelegate<String> {

  final sugestoes = AnimesManager.i.dataAnimes;
  final List<Anime> listResults = [];

  @override
  String get searchFieldLabel => Strings.PESQUISAR;

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeData(
    brightness: Brightness.dark,
    primaryColor: OkiColors.primary,
  );

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: Icon(Icons.clear), onPressed: () {query = '';})];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: transitionAnimation
        ),
        onPressed: () => close(context, null),
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
    // subtitle: Text(MyTexts.SUJESTAO_ON_SEM_RESULTADOS),
    // onTap: () async {
    //   await Navigate.to(context, GenerosPage());
    //   sugestoes.clear();
    //   _setQueryValues();
    //   sugestoes.addAll(_animes.dataAnimes);
    //   context.setState(() {});
    // },
  );

  ListView listView(List<Anime> list) {
    return ListView.builder(
      padding: adsPadding(all: 10),
      itemBuilder: (context, index) {
        Anime item = list[index];
        return AnimeItemList(
            anime: item,
            showSeconfName: true,
            onClick: (item) => _onItemTap(context, item),
        );
      },
      itemCount: list.length,
    );
  }

  void _setQueryValues() {
    bool b(Anime x) {
      final q = query.toLowerCase();

      if (x.nome.toLowerCase().contains(q))
        return true;
      if ((x.nome2 ?? '').toLowerCase().contains(q))
        return true;

      return false;
    }

    listResults.clear();
    listResults.addAll(query.isEmpty ? [] : sugestoes.where(b).toList());
  }

  void _onItemTap(BuildContext context, Anime item) async {
    var parent = item.parent;
    // int init = collection.indexOf(item);
    await Navigate.to(context, AnimePage(anime: parent, showAppBar: parent.isCollection, /*inicialItem: init*/));
  }
}