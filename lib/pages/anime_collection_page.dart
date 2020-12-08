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
//          if (_fotoUrl.isNotEmpty)
//            Image.network(_fotoUrl),
            for (Anime item in animeCollection.itemsToList)
              AnimeItemLayout(
                  item,
                  trailing: _inEditMode ? IconButton(
                    icon: Icon(Icons.open_in_browser),
                    onPressed: () => _moverAnime(item),
                  ) :
                  Layouts.teste2(item, user),
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
                    trailing: Layouts.teste(item, user),
                    listType: listType, onTap: () => _onParentClick(item)
                ),
              for (var item in parentesItem)
                AnimeItemLayout(
                    item,
                    trailing: Layouts.teste2(item, user),
                    listType: listType, onTap: () => _onParentItemClick(item)
                ),
            ],
            Layouts.adsFooter()
          ]),
        ),
        floatingActionButton: _inProgress ? Layouts.adsFooter(CircularProgressIndicator()) :
        !_inEditMode ? Layouts.adsFooter(FloatingActionButton.extended(
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
    var result = await Navigate.to(context, AnimePage(listType, anime: item));
    setState(() {});
    if (result != null && result is Function)
      result(context, animeCollection);
  }

  void _onParentClick(AnimeCollection item) async {
    Navigator.pop(context);
    Navigate.to(context, AnimeCollectionPage(listType, animeCollection: item));
  }

  void _onParentItemClick(Anime item) {
    Navigate.to(context, AnimePage(listType, anime: item));
  }

  void _moverAnime(Anime item) async {
    _setInProgress(true);
    if (await Aplication.moverAnime(context, item, listType)) {
      await FirebaseOki.atualizarUser();
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