import 'package:anime/auxiliar/import.dart';
import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/model/config.dart';
import 'package:anime/pages/anime_page.dart';
import 'package:anime/res/resources.dart';
import 'package:anime/res/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimeListPage extends StatefulWidget {
  final AnimeList animeList;
  final ListType _list;
  AnimeListPage(this._list, {this.animeList});
  @override
  MyPageState createState() => MyPageState(animeList, _list);
}
class MyPageState extends State<AnimeListPage> {

  MyPageState(this.anime, this._list);

  //region Variaveis
  final AnimeList anime;
  final ListType _list;

  bool _inProgress = true;
  bool _inEditMode = false;
//  String _fotoUrl = '';
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _baixarAnime();
  }

  @override
  Widget build(BuildContext context) {
    var user = Firebase.user;
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
            title: Text(anime.nome, style: TextStyle(color: MyTheme.text()))),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(children: [
//          if (_fotoUrl.isNotEmpty)
//            Image.network(_fotoUrl),
            for (Anime item in anime.itemsToList)
              MyLayouts.anime(
                  item,
                  trailing: _inEditMode ? IconButton(
                    icon: Icon(Icons.open_in_browser),
                    onPressed: () => _moverAnime(item),
                  ) :
                  MyLayouts.teste2(item, user),
                  list: _list, onTap: () => _onItemClick(item))
          ]),
        ),
        floatingActionButton: _inProgress ? CircularProgressIndicator() :
        !_inEditMode ? FloatingActionButton.extended(
            label: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _inEditMode = true;
              });
            }
        ) : null,
      ),
    );
  }

  //endregion

  //region Metodos

  _baixarAnime() async {
    await anime.completar();
    setState(() {});
    _setInProgress(false);
  }

  void _onItemClick(Anime item) async {
    await Navigate.to(context, AnimePage(_list, anime: item));
    if (RunTime.updateAnimeFragment)
      Navigator.pop(context);
  }

  void _moverAnime(Anime item) async {
    _setInProgress(true);
    if (await Import.moverAnime(context, item, _list)) {
      await Firebase.atualizarUser();
      RunTime.updateAnimeFragment = true;
      setState(() {
        _inEditMode = false;
        if (!_list.isOnline)
          anime.items.remove(item.id);
      });
    }

    _setInProgress(false);

  }

  void _setInProgress(bool b) {
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}