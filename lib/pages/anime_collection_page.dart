import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
import 'anime_page.dart';

class AnimeCollectionPage extends StatefulWidget {
  final AnimeCollection animeCollection;
  final ListType listType;
  AnimeCollectionPage(this.listType, {this.animeCollection});
  @override
  _MyState createState() => _MyState(animeCollection, listType);
}
class _MyState extends State<AnimeCollectionPage> {

  _MyState(this.animeCollection, this.listType);

  //region Variaveis
  // static const String TAG = 'AnimeCollectionPage';

  final AnimeCollection animeCollection;
  final ListType listType;
  final List<AnimeCollection> parentes = [];
  final List<Anime> parentesItem = [];

  bool _inProgress = true;
  bool _inEditMode = false;
  bool _parentesOK = false;
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _baixarAnime();
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseOki.userOki;
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
        appBar: AppBar(title: Text(animeCollection.nome, style: TextStyle(color: OkiTheme.text))),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 80),
          child: Column(children: [
            for (Anime item in animeCollection.itemsToList)
              AnimeItemLayout(
                  item,
                  trailing: _inEditMode ? IconButton(
                    icon: Icon(Icons.open_in_browser),
                    onPressed: () => _moverAnime(item),
                  ) :
                  Layouts.markerAnime(item, user),
                  listType: listType, onTap: () => _onItemClick(item)),
            if (_parentesOK)...[
              Divider(color: OkiTheme.accent),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('PARENTES'),
              ),
              for (var item in parentes)
                AnimeItemList(
                    item,
                    trailing: Layouts.markerCollection(item, user),
                    listType: listType, onTap: () => _onParentCollectionClick(item)
                ),
              for (var item in parentesItem)
                AnimeItemLayout(
                    item,
                    trailing: Layouts.markerAnime(item, user),
                    listType: listType, onTap: () => _onParentItemClick(item)
                ),
            ],
            AdsFooter()
          ]),
        ),
        floatingActionButton: _inProgress ? AdsFooter(child: CircularProgressIndicator()) :
        !_inEditMode ? AdsFooter(child: FloatingActionButton.extended(
            label: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _inEditMode = true;
              });
            }
        )) : null,
      ),
    );
  }

  //endregion

  //region Metodos

  _baixarAnime() async {
    await animeCollection.completar();
    if (listType.isOnline)
      _loadParentes();
    setState(() {});
    _setInProgress(false);
  }

  _loadParentes() {
    for (String itemId in animeCollection.parentes) {
      var itemCollection = OnlineData.getAsync(itemId);
      if (itemCollection == null) {
        itemCollection = OnlineData.getAsync(itemId.substring(0, itemId.indexOf('_')));
        if (itemCollection != null) {
          var itemAnime = itemCollection.items[itemId];
          if (itemAnime != null) {
            parentesItem.add(itemAnime);
          }
        }
      }
      else {
        parentes.add(itemCollection);
      }
    }
    if (parentes.isNotEmpty || parentesItem.isNotEmpty)
      setState(() {
        _parentesOK = true;
      });
  }

  void _onItemClick(Anime item) async {
    int init = animeCollection.itemsToList.indexOf(item);
    var result = await Navigate.to(context, AnimePage(anime: animeCollection, listType: listType, inicialItem: init));
    setState(() {});
    if (result != null && result is Function)
      result(context, animeCollection);
  }

  void _onParentCollectionClick(AnimeCollection item) async {
    Navigator.pop(context);
    Navigate.to(context, AnimeCollectionPage(listType, animeCollection: item));
  }

  void _onParentItemClick(Anime item) {
    AnimeCollection itemC = AnimeCollection();
    itemC.id = item.idPai;
    itemC.nome = item.nome;
    itemC.nome2 = item.nome2;
    itemC.items[item.id] = item;
    Navigate.to(context, AnimePage(anime: itemC, listType: listType, inicialItem: 0));
  }

  void _moverAnime(Anime item) async {
    _setInProgress(true);
    if (await Aplication.moverAnime(context, item, listType)) {
      // await FirebaseOki.userOki.atualizar();
      setState(() {
        _inEditMode = false;
        if (!listType.isOnline)
          animeCollection.items.remove(item.id);
      });
    }

    _setInProgress(false);

  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}