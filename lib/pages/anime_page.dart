import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/pages/youtube_player_page.dart';
import 'package:anime/res/import.dart';
import 'package:flutter/services.dart';

class AnimePage extends StatefulWidget {
  final AnimeCollection anime;
  final ListType listType;
  final int inicialItem;
  AnimePage({@required this.anime, @required  this.listType, this.inicialItem = 0});
  @override
  _MyState createState() => _MyState(anime, listType, inicialItem);
}
class _MyState extends State<AnimePage> with SingleTickerProviderStateMixin {

  _MyState(this.animeCollection, this.listType, this.inicialItem);

  //region variaveis
  final AnimeCollection animeCollection;
  final ListType listType;
  final int inicialItem;

  final List<Widget> tabViews = [];

  TabController tabController;
  Anime currentItem;

  String title = '';
  //endregion

  //region overrides

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    for (Anime item in animeCollection.itemsToList)
      tabViews.add(_AnimeFragment(item, listType));

    currentItem = animeCollection.getItem(inicialItem);
    tabController = TabController(
      vsync: this,
      initialIndex: inicialItem,
      length: animeCollection.items.length,
    );
    tabController.addListener(_onTabChanged);

    _setTitle(inicialItem);

    _mostrarSetasDeslise();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.1,
          title: Text(title, style: Styles.titleText),
      ),
      body: TabBarView(
        controller: tabController,
        children: tabViews,
      ),
    );
  }

  //endregion

  //region Metodos

  _onTabChanged() {
    int index = tabController.index;
    currentItem = animeCollection.getItem(index);
    _setTitle(index);
  }

  _setTitle(int index) {
    setState(() {
      title = '$_getTitle ${index + 1}/${animeCollection.items.length}';
    });
  }

  String get _getTitle {
    switch(listType.value) {
      case ListType.assistindoValue:
        return Titles.DESEJOS;
        break;
      case ListType.concluidosValue:
        return Titles.CONCLUIDOS;
        break;
      case ListType.favoritosValue:
        return Titles.FAVORITOS;
        break;
      default:
        return Titles.ONLINE;
    }
  }

  // Mostra uma popup com dicas para deslizar
  _mostrarSetasDeslise() async {
    if (animeCollection.items.length <= 1) return;

    bool mostreiEssaDica = Preferences.getBool(PreferencesKey.PAGE_ANIME_DICA_DESLIZE);

    if (mostreiEssaDica) return;

    Preferences.setBool(PreferencesKey.PAGE_ANIME_DICA_DESLIZE, true);

    await Future.delayed(Duration(milliseconds: 500));
    if (!mounted) {
      await Future.delayed(Duration(milliseconds: 100));
      if (!mounted) {
        _mostrarSetasDeslise();
        return;
      }
    }

    var content = [
      Expanded(
        flex: 5,
        child: SizedBox.expand(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    "Deslize entre os animes",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            )
        ),
      ),
      Expanded(
        flex: 1,
        child: GestureDetector(
          child: Text(
            "Fechar",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
    ];
    DialogFullScreen.show(context, content);
  }

  //endregion

}

class _AnimeFragment extends StatefulWidget {
  final Anime anime;
  final ListType listType;
  _AnimeFragment(this.anime, this.listType);
  @override
  _MyStateFragment createState() => _MyStateFragment(anime, listType);
}
class _MyStateFragment extends State<_AnimeFragment> with AutomaticKeepAliveClientMixin<_AnimeFragment> {

  _MyStateFragment(Anime anime, this.listType) {
    this._anime = new Anime.fromJson(anime.toJson());
    _isOnline = listType.isOnline;
    _perguntarSalvar = _isOnline;
    _IS_ONLINE_FINAL = _isOnline;
    if (_isOnline) _isAvancado = true;
  }

  //region Variaveis
  static const String TAG = 'AnimePage';

  ListType listType;
  Anime _anime;
  Anime get anime => _anime;

  String _nome = '';
  String _nome2 = '';
  String _data = '';
  String _sinopce = '';
  String _generos = '';
  String _link = '';
  String _linkProvider = '';
  String _fotoUrl = '';
  String _tipo = '';
  String _status = '';
  String _aviso = '';
  String _trailer = '';
  String _maturidade = '';

  int _episodios = 0;

  // ignore: non_constant_identifier_names
  bool _IS_ONLINE_FINAL;
  bool _isOnline = false;
  bool _isSalvo = false;
  bool _isCopiado = false;
  bool _inEditMode = false;
  bool _inProgress = false;
  bool _perguntarSalvar = false;
  static bool _isAvancado = true;
  static bool _showSinopse = false;

  //region TextEditingController
  TextEditingController _desc = TextEditingController();
  TextEditingController _ultimo = TextEditingController();
  //endregion

  //region Slider Values
  static const double _defaultValue = -1;
  double _fimValue = _defaultValue;
  double _historiaValue = _defaultValue;
  double _animacaoValue = _defaultValue;
  double _ecchiValue = _defaultValue;
  double _comediaValue = _defaultValue;
  double _romanceValue = _defaultValue;
  double _dramaValue = _defaultValue;
  double _acaoValue = _defaultValue;
  double _aventuraValue = _defaultValue;
  double _terrorValue = _defaultValue;

  double _media = _defaultValue;
  int _votos = 0;
  //endregion

  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (anime != null)
      _preencherDados(anime);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () async {
        if (_inEditMode) {
          if (_IS_ONLINE_FINAL && !_isSalvo)
            setState(() {
              _isOnline = true;
            });
          setState(() {
            _inEditMode = false;
          });
          return false;
        }
        else return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  if (_fotoUrl.isNotEmpty)
                    _widgetFoto(),
                  _headInfo(),

                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 70),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (_sinopce.isNotEmpty)
                              itemButtonLayout('${Strings.SINOPSE}: ${_showSinopse ? 'ocultar': 'mostrar'}', _switchSinopse),

                            if (_trailer.isNotEmpty)
                              itemButtonLayout('${Strings.TRAILER}', onTrailerClick),

                            if(_link.isNotEmpty && FirebaseOki.isAdmin)
                              itemButtonLayout(_linkProvider, _onOpenLinkClick),
                          ],
                        ),

                        if(_sinopce.isNotEmpty && _showSinopse)...[
                          itemLayout(_sinopce),
                          if (_aviso.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Text('Info: $_aviso', style: TextStyle(color: Colors.red)),
                            ),
                        ],

                        if (_isAvancado)...[
                          Divider(),
                          if (!_isOnline && _inEditMode)...[
                            Text(Strings.AVANCADO),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(MyTexts.EDICAO_OBS_1),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(MyTexts.EDICAO_OBS_2),
                            ),
                          ],
                          if (_inEditMode || _animacaoValue >= 0)
                            _customSlider(_animacaoValue, label: Strings.ANIMACAO, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_animacaoValue = value;});}),

                          if (_inEditMode || _historiaValue >= 0)
                            _customSlider(_historiaValue, label: Strings.HIRTORIA, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_historiaValue = value;});}),

                          if (_inEditMode || _ecchiValue >= 0)
                            _customSlider(_ecchiValue, label: Strings.ECCHI, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_ecchiValue = value;});}),

                          if (_inEditMode || _comediaValue >= 0)
                            _customSlider(_comediaValue, label: Strings.COMEDIA, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_comediaValue = value;});}),

                          if (_inEditMode || _romanceValue >= 0)
                            _customSlider(_romanceValue, label: Strings.ROMANCE, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_romanceValue = value;});}),

                          if (_inEditMode || _dramaValue >= 0)
                            _customSlider(_dramaValue, label: Strings.DRAMA, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_dramaValue = value;});}),

                          if (_inEditMode || _terrorValue >= 0)
                            _customSlider(_terrorValue, label: Strings.TERROR, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_terrorValue = value;});}),

                          if (_inEditMode || _acaoValue >= 0)
                            _customSlider(_acaoValue, label: Strings.ACAO, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_acaoValue = value;});}),

                          if (_inEditMode || _aventuraValue >= 0)
                            _customSlider(_aventuraValue, label: Strings.AVENTURA, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_aventuraValue = value;});}),
                        ],
                      ],
                    ),
                  ),
                  AdsFooter()
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: OkiTheme.textInvert(0.3),
                        blurRadius: 30,
                      ),
                    ]
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isOnline)...[
                      IconButton(
                        tooltip: MyTexts.REPORTAR_PROBLEMA,
                        icon: Icon(Icons.bug_report),
                        onPressed: _onMenuReportBugClick,
                      ),
                      IconButton(
                        tooltip: Strings.EDITAR,
                        icon: Icon(Icons.edit),
                        onPressed: _onMenuEditClick,
                      ),
                    ]
                    else ...[
                      if (_inEditMode)...[
                        IconButton(
                          icon: Icon(Icons.refresh),
                          tooltip: MyTexts.LIMPAR_TUDO,
                          onPressed: _resetValores,
                        ),
                      ]
                      else...[
                        IconButton(
                          tooltip: Strings.EXCLUIR,
                          icon: Icon(Icons.delete_forever),
                          onPressed: () => _deleteItem(anime),
                        ),
                        IconButton(
                          tooltip: Strings.MOVER,
                          icon: Icon(Icons.open_in_browser),
                          onPressed: () => _onMoverItem(anime),
                        ),
                        IconButton(
                          tooltip: Strings.EDITAR,
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _inEditMode = true;
//                      _isReadOnly = false;
                            });
                          },
                        ),
                      ]
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _inProgress ? AdsFooter(child: CircularProgressIndicator()) :
        _inEditMode ? AdsFooter(child: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: _saveManager,
        )) :
        null,
      ),
    );
  }

  //endregion

  //region Metodos

  Image _widgetFoto() {
    return Image.network(_fotoUrl,
      errorBuilder: (context, widget, e) => Icon(Icons.image),
        loadingBuilder: (context, widget, progress) {
          if (progress == null) return widget;
          return CircularProgressIndicator(/*value: (progress.expectedTotalBytes == null) ? null : progress.cumulativeBytesLoaded / progress.expectedTotalBytes*/);
        },
    );
  }

  Widget _headInfo() {
    var paddingH = EdgeInsets.symmetric(horizontal: 10, vertical: 2);

    return Column(
      children: [
        // Nome 1
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(5),
          child: Text('${Strings.TITULO}: $_nome', style: TextStyle(fontSize: 20)),
        ),
        if (_nome2.isNotEmpty)
          itemLayout('$_nome2'),

        itemLayout('Episódios: ${_episodios >= 0 ? _episodios : 'Indefinido'}'),

        // Tipo
        Container(
          alignment: Alignment.centerLeft,
          padding: paddingH,
          child: Row(children: [
            Text('${Strings.TIPO}: $_tipo   '),
            Layouts.getAnimeTypeIcon(_tipo),
          ]),
        ),

        itemLayout('Data: $_data'),

        if (_status.isNotEmpty)
          itemLayout('Status: $_status'),

        if (_maturidade.isNotEmpty)
          itemLayout('Maturidade: $_maturidade'),

        if(_media >= 0)
          itemLayout('${Strings.MEDIA}: $_media'),

        if (_votos > 0)
          itemLayout('${Strings.VOTOS}: $_votos'),

        if(_generos.isNotEmpty)
          itemLayout('${Strings.GENEROS}: $_generos'),

        if(!_isOnline)
          _customTextField(_desc, TextInputType.text, Strings.OBSERVACAO, isReadOnly: !_inEditMode),
        if (listType.isAssistindo)
          _customTextField(_ultimo, TextInputType.number, MyTexts.ULTIMO_VISTO, isReadOnly: !_inEditMode),

      ],
    );
  }

  Widget _customTextField(TextEditingController _controller, TextInputType _inputType, String labelText, {bool valueIsEmpty = false, TextInputAction inputAction = TextInputAction.next, int maxLines = 1, bool isReadOnly = false, void onTap()}) {
    //region Variaveis
    double itemPaddingValue = 10;
    double height = 50.0 * maxLines;

    //region Container que contem os textField
    var itemPadding = EdgeInsets.only(left: itemPaddingValue, right: itemPaddingValue, top: 7);
    var itemContentPadding = EdgeInsets.fromLTRB(12, 0, 12, 0);

    // var itemlBorder = OutlineInputBorder(borderSide: BorderSide(color: MyTheme.textInvert()));
    // var itemDecoration = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: MyTheme.tint);
    // var itemTextStyle = TextStyle(color: MyTheme.primaryDark, fontSize: 14);
    // var itemPrefixStyle = TextStyle(color: MyTheme.textInvert());
    var itemPrefixStyleErro = TextStyle(color: OkiTheme.textError);
    //endregion

    //endregion

    return Container(
      height: height,
      margin: EdgeInsets.only(top: 10),
      padding: itemPadding,
      // decoration: itemDecoration,
      child: TextField(
        textInputAction: inputAction,
        controller: _controller,
        readOnly: isReadOnly,
        keyboardType: _inputType,
        maxLines: maxLines,
        // style: itemTextStyle,
        decoration: InputDecoration(
          contentPadding: itemContentPadding,
          // enabledBorder: itemlBorder,
          // focusedBorder: itemlBorder,
          labelStyle: valueIsEmpty ? itemPrefixStyleErro : null,
          labelText: labelText.toUpperCase(),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _customSlider(double currentValue, {@required String label, onChanged(double value), bool isReadOnly = false}) {
    int teste = currentValue.round();

    return Row(
      children: [
        Text(label),
        Expanded(child: Slider(
          value: currentValue,
          min: -1,
          max: 10,
          divisions: 11,

          activeColor: (teste == _defaultValue.round()) ?
          OkiTheme.primary :
          ((teste < 5) ? OkiTheme.textError : OkiTheme.accent),

          label: currentValue.round().toString(),
          onChanged: isReadOnly ? null : onChanged,
          onChangeEnd: (value) {
            setState(() {
              teste = value.round();
            });
          },
        )),
        Text(teste.toString())
      ],
    );
  }

  Widget itemLayout(String value) {
    var paddingH = EdgeInsets.symmetric(horizontal: 10, vertical: 2);
    return Container(
      alignment: Alignment.centerLeft,
      padding: paddingH,
      child: Text('$value'),
    );
  }
  Widget itemButtonLayout(String value, onClick()) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(5),
      child: FlatButton(
        child: Text(value),
        onPressed: onClick,
      ),
    );
  }

  void _resetValores() {
    if(!_isCopiado) {
      _link =
      _fotoUrl =
      _sinopce = '';
    }
    _desc = TextEditingController();

    _fimValue =
    _historiaValue =
    _animacaoValue =
    _ecchiValue =
    _comediaValue =
    _romanceValue =
    _dramaValue =
    _acaoValue =
    _aventuraValue =
    _terrorValue = _defaultValue;

    _media = _defaultValue;
    _votos = 0;
    setState(() {});
  }

  void _saveManager() async {
    _setInProgress(true);

    var item = _criarAnime();
    if (await _verificar(item)) {
      if (RunTime.isOnline) {
        await item.salvar(listType);
      } else {
        item.salvar(listType);
        Log.snack('Você está Offline', isError: true);
      }
      FirebaseOki.userOki.addAnime(item, listType);
      setState(() {
        _media = item.classificacao.media;
        _inEditMode = false;
      });

      RunTime.updateFragment(listType);
      await OfflineData.saveOfflineData();
      Log.snack('Dados Salvos');
      _isSalvo = true;
    }

    _setInProgress(false);
  }

  Anime _criarAnime() {
    Anime item = new Anime.fromJson(anime.toJson());
    item.desc = _desc.text;
    if(_ultimo.text.isEmpty) item.ultimoAssistido = 0;
    else item.ultimoAssistido = int.parse(_ultimo.text);

    var c = Classificacao();
    c.fim = _fimValue;
    c.historia = _historiaValue;
    c.animacao = _animacaoValue;
    c.ecchi = _ecchiValue;
    c.comedia = _comediaValue;
    c.romance = _romanceValue;
    c.drama = _dramaValue;
    c.acao = _acaoValue;
    c.aventura = _aventuraValue;
    c.terror = _terrorValue;
    c.votos = _votos;

    item.classificacao = c;

    return item;
  }

  void _deleteItem(Anime item) async {
    if (item == null) return;

    String lista = listType.isConcluidos ? Strings.CONCLUIDOS : listType.isAssistindo ? Strings.ASSISTINDO : Strings.FAVORITOS;
    var title = item.nome;
    var content = Text('${MyTexts.EXCLUIR_ITEM} $lista?');
    var result = await DialogBox.dialogCancelOK(context, title: title, content: [content]);
    if (result.isPositive) {
      var user = FirebaseOki.userOki;

      user.removeAnime(item, listType);
      RunTime.updateFragment(listType);

      _setInProgress(true);
      if (await item.delete(listType, deleteAll: !user.animes.containsKey(item.idPai)))
        Navigator.pop(context, _voidRetornoOnDelete);
      else
        Log.snack(MyErros.ERRO_GENERICO, isError: true);
      _setInProgress(false);
    }
  }

  void _preencherDados(Anime item, {bool reload = true}) async {
    _resetValores();

    _nome = item.nome;
    _nome2 = item.nome2 ?? '';
    _link = item.link;
    _data = item.data;
    _tipo = item.tipo;
    _sinopce = item.sinopse;
    _trailer = item.trailer;
    _maturidade = item.maturidade;
    _status = item.isNoLancado ? 'Ainda não foi ao ar' : '';
    _aviso = item.aviso ?? '';
    _isCopiado = item.isCopiado;
    _episodios = item.episodios;
    _media = listType.isOnline ? item.getMedia : item.classificacao.media;

    if (_data.contains('i')) _data = 'Indefinido';

    _desc.text = item.desc;
    _ultimo.text = item.ultimoAssistido.toString();

    if(item.link.toLowerCase().contains(Strings.CRUNCHYROLL.toLowerCase()))
      _linkProvider = Strings.CRUNCHYROLL;
    else
      _linkProvider = Strings.LINK;

    Classificacao c = item.classificacao;
    _fimValue = c.fim;
    _historiaValue = c.historia;
    _animacaoValue = c.animacao;
    _ecchiValue = c.ecchi;
    _comediaValue = c.comedia;
    _romanceValue = c.romance;
    _dramaValue = c.drama;
    _acaoValue = c.acao;
    _aventuraValue = c.aventura;
    _terrorValue = c.terror;

    _votos = c.votos ?? 0;

    String mini = item.miniatura;
    _fotoUrl = mini;
    item.foto.then((value) => setState(() => _fotoUrl = value ?? mini)).catchError((e) => {});

    _generos = '';
    for (String i in item.generos) {
      _generos += '$i, ';
    }
    if (reload && !item.isComplete) {
      _setInProgress(true);
      await item.complete();
      _preencherDados(item, reload: false);
      _setInProgress(false);
    }
    setState(() {});
    Log.d(TAG, '_preencherDados', _trailer);
  }

  void _onMenuEditClick() async {
    var title = Titles.ADD_ITEM;
    var content = [
      FlatButton(child: Text(Strings.ASSISTINDO), onPressed: () {
        Navigator.pop(context, DialogResult.aux2);
      }),
      FlatButton(child: Text(Strings.FAVORITOS), onPressed: () {
        Navigator.pop(context, DialogResult.aux);
      }),
      if (anime.isLancado)
        FlatButton(child: Text(Strings.CONCLUIDOS), onPressed: () {
          Navigator.pop(context, DialogResult.positive);
        }),
    ];
    var result = await DialogBox.dialogCancel(context, title: title, content: content);

    switch(result.value) {
      case DialogResult.auxValue:
        listType = ListType.favoritos;
        break;
      case DialogResult.positiveValue:
        listType = ListType.concluidos;
        break;
      case DialogResult.aux2Value:
        listType = ListType.assistindo;
        break;
    }
    if (!result.isNone && !result.isNegative) {
      _isCopiado = true;
      _isOnline = false;
      _inEditMode = true;
      _resetValores();
    }
  }

  void _onOpenLinkClick () async {
//    if (getFirebase.isAdmin) {/// TODO remover essa condição depois dos testes
//      if (await Import.appIsTnstaled(MyResources.CRUNCHYROLL_PACKAGE))
//        await Import.openApp(MyResources.CRUNCHYROLL_PACKAGE, anime.nome);
//      else
//        await Import.openUrl(_link, context);
//    }
//    else
      await Aplication.openUrl(_link, context);
  }

  void _onMenuReportBugClick() async {
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
    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    var desc = controller.text;
    if (result.isPositive && desc.trim().isNotEmpty) {
      BugAnime item = BugAnime();
      item.idUser = FirebaseOki.user.uid;
      item.data = DataHora.now();
      item.idAnime = anime.id;
      item.descricao = desc;
      _setInProgress(true);
      await item.salvar();
      Log.snack(MyTexts.REPORTAR_PROBLEMA_AGRADECIMENTO);
      _setInProgress(false);
    }
  }

  void _onMoverItem(Anime item) async {
    _setInProgress(true);
    if (await Aplication.moverAnime(context, anime, listType)) {
      // await FirebaseOki.userOki.atualizar();
      Navigator.pop(context);
    }
    _setInProgress(false);
  }

  void onTrailerClick() {
    // Aplication.openUrl(_trailer);
    Navigate.to(context, YouTubePage(_trailer));
  }

  _voidRetornoOnDelete(context, AnimeCollection animeCollection) {
    Log.d(TAG, 'voidRetorno', 'AnimeId', anime.id);
    setState(() {
      animeCollection.items.remove(anime.id);
    });
    if (animeCollection.items.length == 0)
      Navigator.pop(context);
  }

  Future<bool> _verificar(Anime item) async {
    try {
      var user = FirebaseOki.userOki;
      var repetido = user.getListChild(listType, item.idPai).containsKey(item.id);

      if (_perguntarSalvar) {
        var title = Titles.AVISO_ITEM_REPETIDO;
        title += listType.valueName;
        var content = Text(MyTexts.AVISO_ITEM_REPETIDO);

        if (repetido) {
          var r = await DialogBox.dialogCancelOK(context, title: title, content: [content]);
          return r.isPositive;
        }
      }

      return true;
    } catch(e) {
      return false;
    }
  }

  void _switchSinopse() {
    setState(() {
      _showSinopse = !_showSinopse;
    });
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}
