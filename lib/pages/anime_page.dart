import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/auxiliar/logs.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/model/config.dart';
import 'package:anime/model/feedback.dart';
import 'package:anime/model/data_hora.dart';
import 'package:anime/res/dialog_box.dart';
import 'package:anime/res/resources.dart';
import 'package:anime/res/strings.dart';
import 'package:anime/res/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimePage extends StatefulWidget {
  final Anime anime;
  final ListType _list;
  AnimePage(this._list, {this.anime});
  @override
  MyPageState createState() => MyPageState(anime, _list);
}
class MyPageState extends State<AnimePage> {

  MyPageState(Anime anime, this._list) {
    this._anime = new Anime.fromJson(anime.toJson());
    _isOnline = _list.isOnline;
    _perguntarSalvar = _list.isOnline;
    if (_isOnline) _isAvancado = true;
  }

  //region Variaveis
  static const String TAG = 'AnimePage';

  ListType _list;
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
            title: Text(pageTitle, style: MyStyles.titleText),
          actions: [
            if (_isOnline)...[
              IconButton(
                tooltip: MyTexts.REPORTAR_PROBLEMA,
                icon: Icon(Icons.bug_report),
                onPressed: _onMenuReportBugClick,
              ),
              IconButton(
                tooltip: MyStrings.EDITAR,
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
                  tooltip: MyStrings.EXCLUIR,
                  icon: Icon(Icons.delete_forever),
                  onPressed: () => _deleteItem(anime),
                ),
                IconButton(
                  tooltip: MyStrings.MOVER,
                  icon: Icon(Icons.open_in_browser),
                  onPressed: () => _onMoverItem(anime),
                ),
                IconButton(
                  tooltip: MyStrings.EDITAR,
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
//              if (isPortrait)...[
//                if (_fotoUrl.isNotEmpty)
//                  image,
//                _headInfo(),
//              ] else...[
//                Row(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: [
//                    if (_fotoUrl.isNotEmpty)
//                      image,
//                    Expanded(child: _headInfo())
//                  ]
//                )
//              ],
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
                            child: Text('${MyStrings.SINOPSE}: ${_showSinopse ? 'ocultar': 'mostrar'}'),
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
                        child: Text('${MyStrings.MEDIA}: $_media'),
                      ),
                    if (_votos > 0)
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(5),
                        child: Text('${MyStrings.VOTOS}: $_votos'),
                      ),
                    if(_link.isNotEmpty && Firebase.isAdmin)
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
                        Text(MyStrings.AVANCADO),
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
                        _customSlider(_animacaoValue, label: MyStrings.ANIMACAO, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_animacaoValue = value;});}),

                      if (_inEditMode || _historiaValue >= 0)
                        _customSlider(_historiaValue, label: MyStrings.HIRTORIA, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_historiaValue = value;});}),

                      if (_inEditMode || _ecchiValue >= 0)
                        _customSlider(_ecchiValue, label: MyStrings.ECCHI, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_ecchiValue = value;});}),

                      if (_inEditMode || _comediaValue >= 0)
                        _customSlider(_comediaValue, label: MyStrings.COMEDIA, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_comediaValue = value;});}),

                      if (_inEditMode || _romanceValue >= 0)
                        _customSlider(_romanceValue, label: MyStrings.ROMANCE, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_romanceValue = value;});}),

                      if (_inEditMode || _dramaValue >= 0)
                        _customSlider(_dramaValue, label: MyStrings.DRAMA, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_dramaValue = value;});}),

                      if (_inEditMode || _terrorValue >= 0)
                        _customSlider(_terrorValue, label: MyStrings.TERROR, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_terrorValue = value;});}),

                      if (_inEditMode || _acaoValue >= 0)
                        _customSlider(_acaoValue, label: MyStrings.ACAO, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_acaoValue = value;});}),

                      if (_inEditMode || _aventuraValue >= 0)
                        _customSlider(_aventuraValue, label: MyStrings.AVENTURA, isReadOnly: !_inEditMode, onChanged: (value) {setState(() {_aventuraValue = value;});}),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _inProgress ? CircularProgressIndicator() :
        _inEditMode ? FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: _saveManager,
        ) :
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
          child: Text('${MyStrings.TITULO}: $_nome', style: TextStyle(fontSize: 20)),
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
            Text('${MyStrings.TIPO}: $_tipo   '),
            MyLayouts.getIcon(_tipo),
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
            child: Text('${MyStrings.GENEROS}: $_generos'),
          ),
        if(!_isOnline)
          _customTextField(_desc, TextInputType.text, MyStrings.OBSERVACAO, isReadOnly: !_inEditMode),
        if (_list.isAssistindo)
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

    var itemlBorder = OutlineInputBorder(borderSide: BorderSide(color: MyTheme.textInvert()));
    var itemDecoration = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: MyTheme.tint());
    var itemTextStyle = TextStyle(color: MyTheme.primaryDark(), fontSize: 14);
    var itemPrefixStyle = TextStyle(color: MyTheme.textInvert());
    var itemPrefixStyleErro = TextStyle(color: MyTheme.textError());
    //endregion

    //endregion

    return Container(
      height: height,
      margin: EdgeInsets.only(top: 10),
      padding: itemPadding,
      decoration: itemDecoration,
      child: TextField(
        textInputAction: inputAction,
        controller: _controller,
        readOnly: isReadOnly,
        keyboardType: _inputType,
        maxLines: maxLines,
        style: itemTextStyle,
        decoration: InputDecoration(
          contentPadding: itemContentPadding,
          enabledBorder: itemlBorder,
          focusedBorder: itemlBorder,
          labelStyle: valueIsEmpty ? itemPrefixStyleErro : itemPrefixStyle,
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
          MyTheme.primary() :
          ((teste < 5) ? MyTheme.textError() : MyTheme.accent()),

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
//      _nome = TextEditingController();
      _link = '';
      _fotoUrl = '';
      _sinopce = '';
//      _anime = null;
    }
    _desc = TextEditingController();

    _fimValue = _defaultValue;
    _historiaValue = _defaultValue;
    _animacaoValue = _defaultValue;
    _ecchiValue = _defaultValue;
    _comediaValue = _defaultValue;
    _romanceValue = _defaultValue;
    _dramaValue = _defaultValue;
    _acaoValue = _defaultValue;
    _aventuraValue = _defaultValue;
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
        if (Firebase.user.animes[item.idPai] == null)
          Firebase.user.animes[item.idPai] = AnimeList();
        Firebase.user.animes[item.idPai].items[item.id] = item;
      } catch(e) {
        Log.e(TAG, 'saveManager', e);
      }

      if (OnlineData.isOnline) {
        await item.salvar(_list);
        await Firebase.atualizarUser();
      } else {
        item.salvar(_list);
        Log.snack('Você está Offline', isError: true);
      }
      setState(() {
        _media = item.classificacao.media;
        _inEditMode = false;
      });
      RunTime.updateAnimeFragment = true;

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

    String lista = _list.isConcluidos ? MyStrings.CONCLUIDOS : _list.isAssistindo ? MyStrings.ASSISTINDO : MyStrings.FAVORITOS;
    var title = item.nome;
    var content = Text('${MyTexts.EXCLUIR_ITEM} $lista?');
    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    if (result.isOK) {
      String id = item.id;
      bool deleteAll = (!_desejoRepetido(id) || _list.isAssistindo) &&
          (!_concluidoRepetido(id) || _list.isConcluidos) &&
          (!_favoritoRepetido(id) || _list.isFavoritos);

      _setInProgress(true);
      if (await item.delete(_list, deleteAll: deleteAll)) {
        await Firebase.atualizarUser();
        RunTime.updateAnimeFragment = true;
        Navigator.pop(context);
      }
      else Log.snack(MyErros.ERRO_GERENIRO, isError: true);
    }
  }

  void _preencherDados(Anime item) {
    _nome = item.nome;
    _nome2 = item.nome2 ?? '';
    _link = item.link;
    _data = item.data;
    _tipo = item.tipo;
    _fotoUrl = item.foto;
    _sinopce = item.sinopse;
    _status = item.status ?? '';
    _aviso = item.aviso ?? '';
    _isCopiado = item.isCopiado;
    _episodios = item.episodios;
    _media = item.classificacao.media;

    _desc.text = item.desc;
    _ultimo.text = item.ultimoAssistido.toString();

    if(item.link.toLowerCase().contains(MyStrings.CRUNCHYROLL.toLowerCase()))
      _linkProvider = MyStrings.CRUNCHYROLL;
    else
      _linkProvider = MyStrings.LINK;

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

    for (String i in item.generos) {
      _generos += '$i, ';
    }
  }

  void _onMenuEditClick() async {
    var title = MyTitles.ADD_ITEM;
    var content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlatButton(child: Text(MyStrings.ASSISTINDO), onPressed: () {
            Navigator.pop(context, DialogResult(DialogResult.nao));
          }),
          FlatButton(child: Text(MyStrings.FAVORITOS), onPressed: () {
            Navigator.pop(context, DialogResult(DialogResult.ok));
          }),
          if (anime.status != null && anime.status != 'Ainda não foi ao ar')
            FlatButton(child: Text(MyStrings.CONCLUIDOS), onPressed: () {
              Navigator.pop(context, DialogResult(DialogResult.sim));
            }),
        ]
      ),
    );
    var result = await DialogBox.dialogCancel(context, title: title, content: content);

    switch(result.result) {
      case DialogResult.ok:
        _list = ListType(ListType.favoritos);
        break;
      case DialogResult.sim:
        _list = ListType(ListType.concluidos);
        break;
      case DialogResult.nao:
        _list = ListType(ListType.assistindo);
        break;
    }
    if (!result.isNone && !result.isCancel) {
      _isCopiado = true;
      _isOnline = false;
      _inEditMode = true;
//      _isReadOnly = false;
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
      await Import.openUrl(_link, context);
  }

  void _onMenuReportBugClick() async {
    var controller = TextEditingController();
    var title = MyTexts.REPORTAR_PROBLEMA_TITLE;
    var content = SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: MyTexts.DIGITE_AQUI
            ),
          )
        ],
      ),
    );
    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    var desc = controller.text;
    if (result.isOK && desc.trim().isNotEmpty) {
      BugAnime item = BugAnime();
      item.idUser = Firebase.fUser.uid;
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
    if (await Import.moverAnime(context, anime, _list)) {
      await Firebase.atualizarUser();
      RunTime.updateAnimeFragment = true;
      Navigator.pop(context);
    }
    _setInProgress(false);
  }

  String _getTitle() {
    switch(_list.value) {
      case ListType.assistindo:
        return MyTitles.DESEJOS;
        break;
      case ListType.concluidos:
        return MyTitles.CONCLUIDOS;
        break;
      case ListType.favoritos:
        return MyTitles.FAVORITOS;
        break;
      default:
        return MyTitles.ONLINE;
    }
  }

  Future<bool> _verificar(Anime item) async {
    try {
      var desejoRepetido = _desejoRepetido(item.id);
      var concluidoRepetido = _concluidoRepetido(item.id);
      var favoritoRepetido = _favoritoRepetido(item.id);

      if (_perguntarSalvar) {
        var title = MyTitles.AVISO_ITEM_REPETIDO;
        var content = Text(MyTexts.AVISO_ITEM_REPETIDO);
        switch(_list.value) {
          case ListType.assistindo: {
            title += MyStrings.ASSISTINDO;
            if (desejoRepetido) {
              var r = await DialogBox.dialogCancelOK(context, title: title, content: content);
              return r.isOK;
            }
            break;
          }
          case ListType.concluidos: {
            if (concluidoRepetido) {
              title += MyStrings.CONCLUIDOS;
              var r = await DialogBox.dialogCancelOK(context, title: title, content: content);
              return r.isOK;
            }
            break;
          }
          case ListType.favoritos:
            if (favoritoRepetido) {
              title += MyStrings.FAVORITOS;
              var r = await DialogBox.dialogCancelOK(context, title: title, content: content);
              return r.isOK;
            }
            break;
        }
      }

      return true;
    } catch(e) {
      return false;
    }
  }

  bool _desejoRepetido(String key) => Firebase.user.assistindo.containsKey(key);
  bool _concluidoRepetido(String key) => Firebase.user.concluidos.containsKey(key);
  bool _favoritoRepetido(String key) => Firebase.user.favoritos.containsKey(key);

  void _switchSinopse() {
    setState(() {
      _showSinopse = !_showSinopse;
    });
  }

  void _setInProgress(bool b) {
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}