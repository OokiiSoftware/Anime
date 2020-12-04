import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/auxiliar/logs.dart';
import 'package:anime/auxiliar/online_data.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/model/config.dart';
import 'package:anime/model/user_oki.dart';
import 'package:anime/pages/anime_list_page.dart';
import 'package:anime/pages/anime_page.dart';
import 'package:anime/res/dialog_box.dart';
import 'package:anime/res/resources.dart';
import 'package:anime/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'generos_fragment.dart';

class AnimesFragment extends StatefulWidget {
  final List<AnimeList> items;
  final ListType listType;
  final BuildContext context;

  AnimesFragment(this.context, this.items, this.listType);

  @override
  MyPageState createState() => MyPageState(context, items, listType);
}
class MyPageState extends State<AnimesFragment> with AutomaticKeepAliveClientMixin<AnimesFragment> {

  MyPageState(this.context, this.items, this.listType);

  //region Variaveis
  static const String TAG = 'AnimesFragment';
  static String _filtro = '#';

  final BuildContext context;
  final List<AnimeList> items;
  final ListType listType;
  bool _isOnline = false;
//  bool _inProgress = false;

  UserOki _user;
  //endregion

  //region overrides

 @override
 bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isOnline = listType.isOnline;
    _filtro = Config.filtro;
    if (_isOnline)
      _setFiltro(_filtro);
  }

  @override
  Widget build(BuildContext context) {
   super.build(context);

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isListMode = Config.itemListMode.isListMode;
    _user = FirebaseOki.user;

    return RefreshIndicator(
      child: Scaffold(
        body: isListMode ?
        ListView.builder(
          padding: Layouts.adsPadding(10, 10, 10, _isOnline ? 80 : 10),
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return Layouts.animeItemList(
                item,
                onTap: () => _abrirAnime(item),
                list: listType,
                trailing: _isOnline ? Layouts.teste(item, _user) : null
//                IconButton(
//                  icon: Icon(Icons.open_in_browser),
//                  onPressed: () => _moverAnime(item),
//                )
            );
          },
        ) :
        GridView.builder(
            itemCount: items.length,
            padding: Layouts.adsPadding(0, 0, 0, _isOnline ? 80 : 0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                crossAxisCount: isPortrait ? 3 : 2,
                childAspectRatio: isPortrait ? 1/2 : 3.5
            ),
            itemBuilder: (context, index) {
              var item = items[index];
              return Layouts.animeItemGrid(
                  item,
                  onTap: () => _abrirAnime(item),
                  onLongPress: () => _onItemLongPress(item),
                  isOrientationPortrait: isPortrait,
                  list: listType,
                  footer: _isOnline ? Layouts.teste(item, _user, isGrid: isPortrait) : null
              );
            }
        ),
        floatingActionButton: _isOnline ?
        Layouts.adsFooter(FloatingActionButton.extended(
          label: Text(_filtro),
          onPressed: _alterarFiltro,
        )) :
        RunTime.changeListMode ? Layouts.adsFooter(CircularProgressIndicator()) :
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
    if (listType.isOnline)
      await OnlineData.baixarLista();
    else
      await FirebaseOki.atualizarUser();
    _preencherLista();
  }

  void _alterarFiltro() async {
    var title = Titles.ALTERAR_FILTRO;
    var controller = TextEditingController();
    controller.text = _filtro;
    var content = [
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
          await Navigate.to(context, GenerosFragment());
        },
      ),
      ElevatedButton(
        child: Text('Ajuda'),
        onPressed: () {
          var title = 'Exemplos de Filtros';
          var content = [
            Text('A (Uma letra)'),
            Text('AB (Várias letras)'),
            Text('VAZIO ou # (Listar tudo)'),
            Text('2020 (Lançados em 2020)'),
            Text('0000 (Animes não lançados)'),
          ];
          DialogBox.dialogOK(context, title: title, content: content);
        },
      ),
    ];

    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    if (result.isPositive) {
      var text = controller.text.toUpperCase();
      if (text.isEmpty) text = '#';
      _setFiltro(text);
    } else if (RunTime.generosAtualizados) {
      _setFiltro(_filtro);
    }
  }

  void _setFiltro(String filtro) {
    items.clear();
    switch(filtro) {
      case '#':
        items.addAll(OnlineData.dataList);
        break;
      default:
        try {
          if (filtro.length != 4) throw ('');
          int i = int.parse(filtro);
          if (i == 0) {
            items.addAll(OnlineData.dataList.where((x) => x.itemsToList.where((e) => e.isNoLancado).length > 0));
            Log.snack('Animes não lançados');
          }
          else {
            items.addAll(OnlineData.dataList.where((x) => x.itemsToList.where((e) => e.data.contains(filtro)).length > 0));
            Log.snack('Animes lançados em $filtro');
          }
        } catch(e) {
          items.addAll(OnlineData.dataList.where((x) => x.nome.toUpperCase().startsWith(filtro.toUpperCase())));
        }
    }
    setState(() {
      _filtro = filtro;
    });
    Config.filtro = filtro;
  }

  void _abrirAnime(AnimeList items) async {
    AnimeList itemsAux = _getList(items);

    if (itemsAux.items.length == 0)
      return;
    else if (itemsAux.items.length == 1) {
      Anime item = itemsAux.getItem(0);
      await Navigate.to(context, AnimePage(listType, anime: item));
    }
    else
      await Navigate.to(context, AnimeListPage(listType, animeList: itemsAux));
    if (RunTime.updateAnimeFragment)
      _preencherLista();
  }

  void _onItemLongPress(AnimeList items) async {
    AnimeList itemsAux = _getList(items);

    var content = AnimeListPage(listType, animeList: itemsAux);
    var contentPadding = EdgeInsets.zero;
    await DialogBox.dialogOK(
        context, title: null,
        content: [content],
        contentPadding: contentPadding,
//        insetPadding: contentPadding
    );
    setState(() {});
  }

  AnimeList _getList(AnimeList items) {
    var user = FirebaseOki.user;
    AnimeList itemsAux = AnimeList.newItem(items);
    if (!listType.isOnline) {
      itemsAux.items.clear();
      Map assistindoMap = user.assistindo[items.id];
      Map concluidosMap = user.concluidos[items.id];
      Map favoritosMap = user.favoritos[items.id];

      for (Anime item in items.items.values) {
        switch (listType.value) {
          case ListType.favoritosValue:
            if (favoritosMap != null && favoritosMap.containsKey(item.id))
              itemsAux.items[item.id] = item;
            break;
          case ListType.assistindoValue:
            if (assistindoMap != null && assistindoMap.containsKey(item.id))
              itemsAux.items[item.id] = item;
            break;
          case ListType.concluidosValue:
            if (concluidosMap != null && concluidosMap.containsKey(item.id))
              itemsAux.items[item.id] = item;
            break;
        }
      }
    }
    return itemsAux;
  }

  void _preencherLista() {
    items.clear();
    setState(() {
      switch(listType.value) {
        case ListType.onlineValue:
          _setFiltro(_filtro);
          break;
        case ListType.assistindoValue:
          items.addAll(FirebaseOki.user.assistindoList);
          break;
        case ListType.concluidosValue:
          items.addAll(FirebaseOki.user.concluidosList);
        break;
        case ListType.favoritosValue:
          items.addAll(FirebaseOki.user.favoritosList);
          break;
      }
    });
  }

  //endregion

}