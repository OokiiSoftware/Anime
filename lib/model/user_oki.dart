import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/model/user_dados.dart';

class UserOki {

  //region Variaveis
  static const String TAG = 'User';

  UserDados _dados;
  Map<String, AnimeCollection> _animes;
  Map<dynamic, dynamic> _assistindo;
  Map<dynamic, dynamic> _concluidos;
  Map<dynamic, dynamic> _favoritos;

  //endregion

  //region Construtores

  UserOki();

  UserOki.fromJson(Map<dynamic, dynamic> map) {
    try {
      if(map == null) return;
      if (_mapNotNull(map['animes'])) {
        var itemsList = AnimeCollection.fromJsonList(map['animes']);
        for (String key in itemsList.keys) {
          try {
            var tempItemCollection = OnlineData.getAsync(key);
            var itemCollection = AnimeCollection.newItem(tempItemCollection);

            for (var itemAnime in itemCollection.itemsToList) {
              var temp = itemsList[key].items[itemAnime.id];
              if (temp != null) {
                itemAnime.desc = temp.desc;
                itemAnime.ultimoAssistido = temp.ultimoAssistido;
                itemAnime.classificacao = temp.classificacao;
              }
            }
            animes[key] = itemCollection;
          } catch(e) {
            continue;
          }
        }
      }
      if (_mapNotNull(map['assistindo']))
        assistindo = map['assistindo'];
      if (_mapNotNull(map['concluidos']))
        concluidos = map['concluidos'];
      if (_mapNotNull(map['favoritos']))
        favoritos = map['favoritos'];
      if (_mapNotNull(map['_dados']))
        dados = UserDados.fromJson(map['_dados']);
    } catch (e) {
      Log.e(TAG, 'User.fromJson', e);
    }
  }

  Map<String, dynamic> toJson() => {
   "_dados": dados.toJson(),
    "animes": animes,
    "assistindo": assistindo,
    "concluidos": concluidos,
    "favoritos": favoritos,
  };

  static Map<String, UserOki> fromMapList(Map map) {
    Map<String, UserOki> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = UserOki.fromJson(map[key]);
    return items;
  }

  //endregion

  //region Metodos

  Future<bool> atualizar() async {
    try {
      var snapshot = await FirebaseOki.database
          .child(FirebaseChild.USUARIO).child(dados.id).once();
      var item = UserOki.fromJson(snapshot.value);
      if (item != null) {
        dados = item.dados;
        animes = item.animes;
        favoritos = item.favoritos;
        assistindo = item.assistindo;
        concluidos = item.concluidos;
      }
      return true;
    } catch (e) {
      Log.e(TAG, 'atualizar', e);
      return false;
    }
  }

  static bool _mapNotNull(dynamic value) => value != null;

  List<AnimeCollection> get favoritosList {
    List<AnimeCollection> list = [];
    for (dynamic key in favoritos.keys) {
      var itemAux = animes[key];
      if (itemAux == null) continue;
      var item = AnimeCollection.newItem(itemAux);
      if (item != null) {
        var aux = favoritos[key];
        item.items.removeWhere((key, value) => !aux.containsKey(key));
        list.add(item);
      }
    }
    return list..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }
  List<AnimeCollection> get assistindoList {
    List<AnimeCollection> list = [];
    for (dynamic key in assistindo.keys) {
      var itemAux = animes[key];
      if (itemAux == null) continue;
      var item = AnimeCollection.newItem(itemAux);
      if (item != null) {
        var aux = assistindo[key];
        item.items.removeWhere((key, value) => !aux.containsKey(key));
        list.add(item);
      }
    }
    return list..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }
  List<AnimeCollection> get concluidosList {
    List<AnimeCollection> list = [];
    for (dynamic key in concluidos.keys) {
      var itemAux = animes[key];
      if (itemAux == null) continue;
      var item = AnimeCollection.newItem(itemAux);
      if(item != null) {
        var aux = concluidos[key];
        item.items.removeWhere((key, value) => !aux.containsKey(key));
        list.add(item);
      }
    }

    return list..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }

  Map<dynamic, dynamic> getAssistindo(String key) => assistindo[key] ?? Map();
  Map<dynamic, dynamic> getConcluido(String key) => concluidos[key] ?? Map();
  Map<dynamic, dynamic> getFavorito(String key) => favoritos[key] ?? Map();

  //endregion

  //region get set

  UserDados get dados {
    if (_dados == null)
      _dados = UserDados(FirebaseOki.user);
    return _dados;
  }

  set dados(UserDados value) {
    _dados = value;
  }


  Map<String, AnimeCollection> get animes {
    if (_animes == null)
      _animes = Map();
    return _animes;
  }

  set animes(Map<String, AnimeCollection> value) {
    _animes = value;
  }

  Map<dynamic, dynamic> get assistindo {
    if (_assistindo == null)
      _assistindo = Map();
    return _assistindo;
  }

  set assistindo(Map<dynamic, dynamic> value) {
    _assistindo = value;
  }

  Map<dynamic, dynamic> get concluidos {
    if (_concluidos == null)
      _concluidos = Map();
    return _concluidos;
  }

  set concluidos(Map<dynamic, dynamic> value) {
    _concluidos = value;
  }

  Map<dynamic, dynamic> get favoritos {
    if (_favoritos == null)
      _favoritos = Map();
    return _favoritos;
  }

  set favoritos(Map<dynamic, dynamic> value) {
    _favoritos = value;
  }

  //endregion

}