import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';

class AnimePage extends StatefulWidget {
  final Anime anime;
  final ListType listType;
  AnimePage(this.listType, {this.anime});
  @override
  _MyState createState() => _MyState(anime, listType);
}
class _MyState extends State<AnimePage> {

  _MyState(Anime anime, this.listType) {
    this._anime = new Anime.fromJson(anime.toJson());
    _isOnline = listType.isOnline;
    _perguntarSalvar = listType.isOnline;
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

  int _episodios = 0;

  bool _isOnline = false;
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
  void initState() {
    super.initState();
    if (anime != null)
      _preencherDados(anime);
//    else if (_anime != null)
//      _preencherDados(_anime);
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = _getTitle();

    return WillPopScope(
      onWillPop: () async {
        if (_inEditMode) {
          setState(() {
            _inEditMode = false;
          });
          return false;
        }
        else return true;
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(pageTitle, style: Styles.titleText),
          actions: [
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
//                IconButton(
//                  icon: Icon(_isAvancado ? Icons.visibility : Icons.visibility_off),
//                  tooltip: _isAvancado ? MyStrings.SIMPLES : MyStrings.AVANCADO,
//                  onPressed: () {
//                    setState(() {
//                      _isAvancado = !_isAvancado;
//                    });
//                  },
//                ),
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (_fotoUrl.isNotEmpty)
                _widgetFoto(),
              _headInfo(),

              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 70),
                child: Column(
                  children: [
                    if (_sinopce.isNotEmpty)...[
                      Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            child: Text('${Strings.SINOPSE}: ${_showSinopse ? 'ocultar': 'mostrar'}'),
                            onPressed: _switchSinopse,
                          )
                      ),
                      if(_showSinopse)...[
                        Container(
                          padding: EdgeInsets.all(5),
                          child: Text(_sinopce),
                        ),
                        if (_aviso.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(5),
                            child: Text('Info: $_aviso', style: TextStyle(color: Colors.red)),
                          ),
                      ]
                    ],

                    if(_media >= 0)
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(10),
                        child: Text('${Strings.MEDIA}: $_media'),
                      ),
                    if (_votos > 0)
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(5),
                        child: Text('${Strings.VOTOS}: $_votos'),
                      ),
                    if(_link.isNotEmpty && FirebaseOki.isAdmin)
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(5),
                        child: ElevatedButton(
                          child: Text(_linkProvider),
                          onPressed: _onOpenLinkClick,
                        ),
                      ),
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
              Layouts.adsFooter()
            ],
          ),
        ),
        floatingActionButton: _inProgress ? Layouts.adsFooter(CircularProgressIndicator()) :
        _inEditMode ? Layouts.adsFooter(FloatingActionButton(
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
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(5),
          child: Text('${Strings.TITULO}: $_nome', style: TextStyle(fontSize: 20)),
        ),
        if (_nome2.isNotEmpty)
          Container(
            alignment: Alignment.centerLeft,
            padding: paddingH,
            child: Text('$_nome2'),
          ),
        Container(
          alignment: Alignment.centerLeft,
          padding: paddingH,
          child: Row(children: [
            Text('${Strings.TIPO}: $_tipo   '),
            Layouts.getIcon(_tipo),
          ]),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: paddingH,
          child: Text('Data: $_data'),
        ),
        if (_status.isNotEmpty)
          Container(
            alignment: Alignment.centerLeft,
            padding: paddingH,
            child: Text('Status: $_status'),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: paddingH,
            child: Text('Episódios: ${_episodios >= 0 ? _episodios : 'Indefinido'}'),
          )
        ,
        if(_generos.isNotEmpty)
          Container(
            alignment: Alignment.centerLeft,
            padding: paddingH,
            child: Text('${Strings.GENEROS}: $_generos'),
          ),
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

      try {
        if (FirebaseOki.userOki.animes[item.idPai] == null)
          FirebaseOki.userOki.animes[item.idPai] = AnimeCollection();
        FirebaseOki.userOki.animes[item.idPai].items[item.id] = item;
      } catch(e) {
        Log.e(TAG, 'saveManager', e);
      }

      if (RunTime.isOnline) {
        await item.salvar(listType);
        await FirebaseOki.atualizarUser();
      } else {
        item.salvar(listType);
        Log.snack('Você está Offline', isError: true);
      }
      setState(() {
        _media = item.classificacao.media;
        _inEditMode = false;
      });

      RunTime.updateFragment(listType);
      await OfflineData.saveOfflineData();
      Log.snack('Dados Salvos');
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
      String id = item.id;
      bool deleteAll = (!_desejoRepetido(id) || listType.isAssistindo) &&
          (!_concluidoRepetido(id) || listType.isConcluidos) &&
          (!_favoritoRepetido(id) || listType.isFavoritos);

      _setInProgress(true);
      if (await item.delete(listType, deleteAll: deleteAll)) {
        await FirebaseOki.atualizarUser();
        RunTime.updateFragment(listType);
        Navigator.pop(context, _voidRetornoOnDelete);
      }
      else Log.snack(MyErros.ERRO_GENERICO, isError: true);
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
    // _fotoUrl = item.foto;todo
    _sinopce = item.sinopse;
    _status = item.isNoLancado ? 'Ainda não foi ao ar' : '';
    _aviso = item.aviso ?? '';
    _isCopiado = item.isCopiado;
    _episodios = item.episodios;
    _media = item.classificacao.media;

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
      await FirebaseOki.atualizarUser();
      Navigator.pop(context);
    }
    _setInProgress(false);
  }

  _voidRetornoOnDelete(context, AnimeCollection animeCollection) {
    Log.d(TAG, 'voidRetorno', 'AnimeId', anime.id);
    setState(() {
      animeCollection.items.remove(anime.id);
    });
    if (animeCollection.items.length == 0)
      Navigator.pop(context);
  }

  String _getTitle() {
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

  Future<bool> _verificar(Anime item) async {
    try {
      var desejoRepetido = _desejoRepetido(item.id);
      var concluidoRepetido = _concluidoRepetido(item.id);
      var favoritoRepetido = _favoritoRepetido(item.id);

      if (_perguntarSalvar) {
        var title = Titles.AVISO_ITEM_REPETIDO;
        var content = Text(MyTexts.AVISO_ITEM_REPETIDO);
        switch(listType.value) {
          case ListType.assistindoValue: {
            title += Strings.ASSISTINDO;
            if (desejoRepetido) {
              var r = await DialogBox.dialogCancelOK(context, title: title, content: [content]);
              return r.isPositive;
            }
            break;
          }
          case ListType.concluidosValue: {
            if (concluidoRepetido) {
              title += Strings.CONCLUIDOS;
              var r = await DialogBox.dialogCancelOK(context, title: title, content: [content]);
              return r.isPositive;
            }
            break;
          }
          case ListType.favoritosValue:
            if (favoritoRepetido) {
              title += Strings.FAVORITOS;
              var r = await DialogBox.dialogCancelOK(context, title: title, content: [content]);
              return r.isPositive;
            }
            break;
        }
      }

      return true;
    } catch(e) {
      return false;
    }
  }

  bool _desejoRepetido(String key) => FirebaseOki.userOki.assistindo.containsKey(key);
  bool _concluidoRepetido(String key) => FirebaseOki.userOki.concluidos.containsKey(key);
  bool _favoritoRepetido(String key) => FirebaseOki.userOki.favoritos.containsKey(key);

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