import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
import 'package:anime/pages/import.dart';
import 'generos_fragment.dart';

class AnimesFragment extends StatefulWidget {
  final ListType listType;
  final BuildContext context;

  AnimesFragment(this.context, this.listType);

  @override
  _MyState createState() => _MyState(context, listType);
}
class _MyState extends State<AnimesFragment> with AutomaticKeepAliveClientMixin<AnimesFragment> {

  _MyState(this.context, this.listType);

  //region Variaveis
  static const String TAG = 'AnimesFragment';
  static String _filtro = '#';

  final BuildContext context;
  final ListType listType;
  List<AnimeCollection> collections = [];
  bool _isOnline = false;

  //endregion

  //region overrides

 @override
 bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isOnline = listType.isOnline;
    _filtro = Config.filtro;
    _preencherLista(ignoreRunTime: true);
  }

  @override
  Widget build(BuildContext context) {
   super.build(context);
   Log.d(TAG, 'build', listType.value);

   _preencherLista();

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isListMode = Config.itemListMode.isListMode;
    var user = FirebaseOki.userOki;

    return RefreshIndicator(
      child: Scaffold(
        body: (collections.isEmpty && _isOnline) ?
            // Sem Resultados
        ListView.builder(
          itemCount: 1,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Sem resultados'),
                subtitle: Text('Clique aqui para selecionar alguns generos'),
                onTap: () async {
                  await Navigate.to(context, GenerosFragment());
                  if (RunTime.updateOnlineFragment) {
                    _setFiltro(_filtro);
                  }
                },
              );
            }
        ) :
        isListMode ?
        ListView.builder(
          padding: Layouts.adsPadding(10, 10, 10, _isOnline ? 80 : 10),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            var item = collections[index];
            if (item.items.isEmpty) return Container();
            return AnimeItemList(
                item,
                onTap: () => _abrirAnime(item),
                listType: listType,
                trailing: _isOnline ? Layouts.markerCollection(item, user) : null
            );
          },
        ) :
        GridView.builder(
            itemCount: collections.length,
            padding: Layouts.adsPadding(0, 0, 0, _isOnline ? 80 : 0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                crossAxisCount: isPortrait ? 3 : 2,
                childAspectRatio: isPortrait ? 1/2 : 3.5
            ),
            itemBuilder: (context, index) {
              var item = collections[index];
              return AnimeItemGrid(
                  item,
                  onTap: () => _abrirAnime(item),
                  isOrientationPortrait: isPortrait,
                  listType: listType,
                  footer: _isOnline ? Layouts.markerCollection(item, user, isGrid: isPortrait) : null
              );
            }
        ),
        floatingActionButton: _isOnline ?
        AdsFooter(
            child: FloatingActionButton.extended(
              label: Text(_filtro),
              onPressed: _alterarFiltro
            )) :
        RunTime.changeListMode ? AdsFooter(child: CircularProgressIndicator()) :
        null,
      ),
      onRefresh: _onRefresh,
    );
  }

  //endregion

  //region Metodos

  Future _onRefresh() async {
    if (!RunTime.isOnline)
      return;
    Log.d(TAG, 'onRefresh');
    if (listType.isOnline)
      await OnlineData.baixarLista();
    else
      await FirebaseOki.userOki.atualizar();
    _preencherLista(ignoreRunTime: true);
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
      _saveFiltro(text);
    } else if (RunTime.updateOnlineFragment) {
      _setFiltro(_filtro);
      _saveFiltro(_filtro);
    }
  }

  void _setFiltro(String filtro) {
    collections.clear();
    switch(filtro) {
      case '#':
        collections.addAll(OnlineData.dataList);
        break;
      default:
        try {
          if (filtro.length != 4) throw ('');
          int i = int.parse(filtro);
          if (i == 0) {
            collections.addAll(OnlineData.dataList.where((x) => x.itemsToList.where((e) => e.isNoLancado).length > 0));
            Log.snack('Animes não lançados');
          }
          else {
            collections.addAll(OnlineData.dataList.where((x) => x.itemsToList.where((e) => e.data.contains(filtro)).length > 0));
            Log.snack('Animes lançados em $filtro');
          }
        } catch(e) {
          collections.addAll(OnlineData.dataList.where((x) => x.nome.toUpperCase().startsWith(filtro.toUpperCase())));
        }
    }
  }

  _saveFiltro(String filtro) {
    setState(() {
      _filtro = filtro;
    });
    Config.filtro = filtro;
  }

  void _abrirAnime(AnimeCollection items) async {
    AnimeCollection itemsAux = _getList(items);

    if (itemsAux.items.length == 0) return;
    else if (itemsAux.items.length == 1) {
      // Anime item = itemsAux.getItem(0);
      await Navigate.to(context, AnimePage(anime: items, listType: listType));
    }
    else
      await Navigate.to(context, AnimeCollectionPage(listType, animeCollection: itemsAux));

    _preencherLista();
  }

  AnimeCollection _getList(AnimeCollection items) {
    var user = FirebaseOki.userOki;
    AnimeCollection itemsAux = AnimeCollection.newItem(items);
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

  void _preencherLista({bool ignoreRunTime = false}) {
    var user = FirebaseOki.userOki;
    setState(() {
      switch(listType.value) {
        case ListType.onlineValue:
          if (RunTime.updateOnlineFragment || ignoreRunTime) {
            collections.clear();
            _setFiltro(_filtro);
          }
          break;
        case ListType.assistindoValue:
          if (RunTime.updateAssistindoFragment || ignoreRunTime) {
            collections.clear();
            collections.addAll(user.assistindoList);
          }
          break;
        case ListType.concluidosValue:
          if (RunTime.updateConcluidosFragment || ignoreRunTime) {
            collections.clear();
            collections.addAll(user.concluidosList);
          }
        break;
        case ListType.favoritosValue:
          if (RunTime.updateFavoritosFragment || ignoreRunTime) {
            collections.clear();
            collections.addAll(user.favoritosList);
          }
          break;
      }
    });
  }

  //endregion

}