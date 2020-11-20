import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/auxiliar/logs.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/model/config.dart';
import 'package:anime/model/user.dart';
import 'package:anime/pages/anime_list_page.dart';
import 'package:anime/pages/anime_page.dart';
import 'package:anime/res/dialog_box.dart';
import 'package:anime/res/resources.dart';
import 'package:anime/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimesFragment extends StatefulWidget {
  final List<AnimeList> _data;
  final ListType _list;
  final BuildContext context;

  AnimesFragment(this.context, this._data, this._list);

  @override
  MyPageState createState() => MyPageState(context, _data, _list);
}
class MyPageState extends State<AnimesFragment> with AutomaticKeepAliveClientMixin<AnimesFragment> {

  MyPageState(this.context, this._data, this._list);

  //region Variaveis
  static const String TAG = 'AnimesFragment';
  static String _filtro = '#';

  final BuildContext context;
  final List<AnimeList> _data;
  final ListType _list;
  bool _isOnline = false;
//  bool _inProgress = false;

  User _user;
  //endregion

  //region overrides

 @override
 bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isOnline = _list.isOnline;
    _filtro = Config.filtro;//Import.sharedPreferences.getString(SharedPrefKey.FILTRO) ?? '#';
    if (_isOnline)
      _setFiltro(_filtro);
  }

  @override
  Widget build(BuildContext context) {
   super.build(context);

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isListMode = ItemListMode(Config.itemListMode).isListMode;
    _user = Firebase.user;

    return RefreshIndicator(
      child: Scaffold(
        body: isListMode ?
        ListView.builder(
          padding: EdgeInsets.fromLTRB(10, 10, 10, _isOnline ? 80 : 10),
          itemCount: _data.length,
          itemBuilder: (context, index) {
            var item = _data[index];
            return MyLayouts.animeItemList(
                item,
                onTap: () => _abrirAnime(item),
                list: _list,
                trailing: _isOnline ? MyLayouts.teste(item, _user) : null
//                IconButton(
//                  icon: Icon(Icons.open_in_browser),
//                  onPressed: () => _moverAnime(item),
//                )
            );
          },
        ) :
        GridView.builder(
            itemCount: _data.length,
            padding: EdgeInsets.only(bottom: _isOnline ? 80 : 0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                crossAxisCount: isPortrait ? 3 : 2,
              childAspectRatio: isPortrait ? 1/2 : 3.5
            ),
            itemBuilder: (context, index) {
              var item = _data[index];
              return MyLayouts.animeItemGrid(
                  item,
                  onTap: () => _abrirAnime(item),
                  onLongPress: () => _onItemLongPress(item),
                  isOrientationPortrait: isPortrait,
                  list: _list,
                  footer: _isOnline ? MyLayouts.teste(item, _user, isGrid: isPortrait) : null
              );
            }
            ),
        floatingActionButton: _isOnline ?
        FloatingActionButton.extended(
          label: Text(_filtro),
          onPressed: _alterarFiltro,
        ) :
        RunTime.changeListMode ? CircularProgressIndicator() :
        null,
      ),
      onRefresh: _onRefresh,
    );
  }

  //endregion

  //region Metodos

  Future _onRefresh() async {
    if (!OnlineData.isOnline)
      return;
    if (_list.isOnline)
      await OnlineData.baixarLista();
    else
      await Firebase.atualizarUser();
    _preencherLista();
  }

  void _alterarFiltro() async {
    var title = MyTitles.ALTERAR_FILTRO;
    var controller = TextEditingController();
    controller.text = _filtro;
    var content = SingleChildScrollView(
      child: ListBody(
        children: [
          Text(MyTexts.ALTERAR_FILTRO),
          TextField(
              controller: controller,
            decoration: InputDecoration(
              hintText: 'Ex: 2020'
            ),
          ),
          ElevatedButton(
            child: Text('Generos'),
            onPressed: () async {
              await Navigate.to(context, GenerosFragment(context));
            },
          ),
          ElevatedButton(
            child: Text('Ajuda'),
            onPressed: () {
              var title = 'Exemplos de Filtros';
              var content = SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('A (Uma letra)'),
                    Text('AB (Várias letras)'),
                    Text('VAZIO ou # (Listar tudo)'),
                    Text('2020 (Lançados em 2020)'),
                    Text('0000 (Animes não lançados)'),
                  ],
                ),
              );
              DialogBox.dialogOk(context, title: title, content: content);
            },
          ),
        ],
      ),
    );

    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    if (result.isOK) {
      var text = controller.text.toUpperCase();
      if (text.isEmpty) text = '#';
      _setFiltro(text);
    } else if (RunTime.generosAtualizados) {
      _setFiltro(_filtro);
    }
  }

  void _setFiltro(String filtro) {
    _data.clear();
    switch(filtro) {
      case '#':
        _data.addAll(OnlineData.dataList);
        break;
      default:
        try {
          if (filtro.length != 4) throw ('');
          int i = int.parse(filtro);
          if (i == 0) {
            _data.addAll(OnlineData.dataList.where((x) => x.itemsToList.where((e) => e.status != null).length > 0));
            Log.snack('Animes não lançados');
          }
          else {
            _data.addAll(OnlineData.dataList.where((x) => x.itemsToList.where((e) => e.data.contains(filtro)).length > 0));
            Log.snack('Animes lançados em $filtro');
          }
        } catch(e) {
          _data.addAll(OnlineData.dataList.where((x) => x.nome.toUpperCase().startsWith(filtro.toUpperCase())));
        }
    }
    setState(() {
      _filtro = filtro;
    });
    Config.filtro = filtro;
    Config.save();
  }

  void _abrirAnime(AnimeList items) async {
    AnimeList itemsAux = _getList(items);

    if (itemsAux.items.length == 0)
      return;
    else if (itemsAux.items.length == 1) {
      Anime item = itemsAux.getItem(itemsAux.items.length - 1);
      await Navigate.to(context, AnimePage(_list, anime: item));
    }
    else
      await Navigate.to(context, AnimeListPage(_list, animeList: itemsAux));
    if (RunTime.updateAnimeFragment)
      _preencherLista();
  }

  void _onItemLongPress(AnimeList items) async {
    AnimeList itemsAux = _getList(items);

    var content = AnimeListPage(_list, animeList: itemsAux);
    var contentPadding = EdgeInsets.zero;
    await DialogBox.dialogOk(
        context, title: null,
        content: content,
        contentPadding: contentPadding,
//        insetPadding: contentPadding
    );
    setState(() {});
  }

  AnimeList _getList(AnimeList items) {
    var user = Firebase.user;
    AnimeList itemsAux = AnimeList.newItem(items);
    if (!_list.isOnline) {
      itemsAux.items.clear();
      Map assistindoMap = user.assistindo[items.id];
      Map concluidosMap = user.concluidos[items.id];
      Map favoritosMap = user.favoritos[items.id];

      for (Anime item in items.items.values) {
        switch (_list.value) {
          case ListType.favoritos:
            if (favoritosMap != null && favoritosMap.containsKey(item.id))
              itemsAux.items[item.id] = item;
            break;
          case ListType.assistindo:
            if (assistindoMap != null && assistindoMap.containsKey(item.id))
              itemsAux.items[item.id] = item;
            break;
          case ListType.concluidos:
            if (concluidosMap != null && concluidosMap.containsKey(item.id))
              itemsAux.items[item.id] = item;
            break;
        }
      }
    }
    return itemsAux;
  }

  void _preencherLista() {
    _data.clear();
    setState(() {
      switch(_list.value) {
        case ListType.online:
          _setFiltro(_filtro);
          break;
        case ListType.assistindo:
          _data.addAll(Firebase.user.assistindoList);
          break;
        case ListType.concluidos:
          _data.addAll(Firebase.user.concluidosList);
        break;
        case ListType.favoritos:
          _data.addAll(Firebase.user.favoritosList);
          break;
      }
    });
  }

  //endregion

}

class GenerosFragment extends StatefulWidget {
  final BuildContext context;
  GenerosFragment(this.context);
  @override
  MyPageState2 createState() => MyPageState2();
}
class MyPageState2 extends State<GenerosFragment> {

  bool _allSelected = true;
  bool _mostrarFab = false;
  Map<String, bool> _data = Map();

  @override
  void initState() {
    super.initState();
    for (var s in OnlineData.generos) {
      var b = Config.generos.contains(s);
      _data[s] = b;
      if (!b) _allSelected = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyTitles.GENEROS, style: MyStyles.titleText),
        actions: [
          Tooltip(
            message: _allSelected ? 'Desmarcar Tudo' : 'Marcar Tudo',
            child: Checkbox(
              value: _allSelected,
              onChanged: (value) {
                setState(() {
                  _allSelected = value;
                  for (var key in _data.keys)
                    _data[key] = _allSelected;
                });
              },
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 5))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 80),
        child: Column(
            children: [
              for (var key in _data.keys)
                CheckboxListTile(
                  title: Text(key),
                  value: _data[key],
                  onChanged: (value) {
                    _onMostrarFab(true);
                    setState(() {
                      _data[key] = value;
                      _allSelected = tudoSelecionado;
                    });
                  },
                )
            ]
        ),
      ),
      floatingActionButton: _mostrarFab ? FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _onSave,
      ) : null,
    );
  }

  bool get tudoSelecionado {
    for (var key in _data.keys) {
      if (!_data[key]) return false;
    }
    return true;
  }

  void _onMostrarFab(bool b) {
    setState(() {
      _mostrarFab = b;
    });
  }

  void _onSave() {
    Config.generos = '';
    for (var key in _data.keys) {
      if (_data[key])
        Config.generos += '$key,';
    }
    Config.save();
    RunTime.generosAtualizados = true;

    Log.snack('Dados Salvos');

    _onMostrarFab(false);
  }
}