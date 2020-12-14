import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
import 'package:anime/pages/import.dart';

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

  final BuildContext context;
  final ListType listType;
  List<AnimeCollection> collections = [];

  //endregion

  //region overrides

 @override
 bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Log.d(TAG, 'initState', 'Init');
    _preencherLista(ignoreRunTime: true);
  }

  @override
  Widget build(BuildContext context) {
   super.build(context);
   // Log.d(TAG, 'build', listType.valueName);

   _preencherLista();

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isListMode = Config.itemListMode.isListMode;

    return RefreshIndicator(
      child: Scaffold(
        body: isListMode ?
        ListView.builder(
          padding: Layouts.adsPadding(10),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            var item = collections[index];
            if (item.items.isEmpty) return Container();
            return AnimeItemList(
                item,
                onTap: () => _abrirAnime(item),
                listType: listType,
            );
          },
        ) :
        GridView.builder(
            itemCount: collections.length,
            padding: Layouts.adsPadding(0),
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
              );
            }
        ),
        floatingActionButton: RunTime.changeListMode ? AdsFooter(child: CircularProgressIndicator()) : null,
      ),
      onRefresh: _onRefresh,
    );
  }

  //endregion

  //region Metodos

  Future _onRefresh() async {
    if (!RunTime.isOnline) return;
    Log.d(TAG, 'onRefresh');
    await FirebaseOki.userOki.atualizar();
    _preencherLista(ignoreRunTime: true);
  }

  void _preencherLista({bool ignoreRunTime = false}) {
    var user = FirebaseOki.userOki;
    if (RunTime.updateFavoritosFragment ||
        RunTime.updateConcluidosFragment ||
        RunTime.updateAssistindoFragment || ignoreRunTime) {
      Log.d(TAG, '_preencherLista', RunTime.updateFavoritosFragment, RunTime.updateConcluidosFragment, RunTime.updateAssistindoFragment, ignoreRunTime);
      // Log.d(TAG, '_preencherLista', listType.valueName);
      collections.clear();
      setState(() {
        collections.addAll(user.getCollection(listType));
      });
    }
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
    itemsAux.items.clear();
    Map listMap = user.getList(listType)[items.id];

    for (Anime item in items.items.values) {
      if (listMap != null && listMap.containsKey(item.id))
        itemsAux.items[item.id] = item;
    }
    return itemsAux;
  }

  //endregion

}