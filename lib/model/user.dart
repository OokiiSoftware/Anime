import 'package:anime/auxiliar/import.dart';
import 'package:anime/auxiliar/logs.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/model/user_dados.dart';

class User {

  //region Variaveis
  static const String TAG = 'User';

  UserDados _dados;
  Map<String, AnimeList> _animes;
  Map<dynamic, dynamic> _assistindo;
  Map<dynamic, dynamic> _concluidos;
  Map<dynamic, dynamic> _favoritos;

  //endregion

  //region Construtores

  User();

  User.fromJson(Map<dynamic, dynamic> map) {
    try {
      if(map == null) return;
      if (_mapNotNull(map['animes'])) {
        var itemsList = AnimeList.fromJsonList(map['animes']);
        for (String key in itemsList.keys) {
          var items = AnimeList.newItem(OnlineData.data[key]);
          if (items == null) continue;

          for (var item in items.itemsToList) {
            var temp = itemsList[key].items[item.id];
            if (temp != null) {
              item.id = temp.id;
              item.desc = temp.desc;
              item.ultimoAssistido = temp.ultimoAssistido;
              item.classificacao = temp.classificacao;
            }
          }
          animes[key] = items;
        }
      }
      if (_mapNotNull(map['assistindo']))
        assistindo = map['assistindo'];
      if (_mapNotNull(map['concluidos']))
        concluidos = map['concluidos'];
      if (_mapNotNull(map['favoritos']))
        favoritos = map['favoritos'];
    } catch (e) {
      Log.e(TAG, 'User.fromJson', e);
    }
  }

  Map<String, dynamic> toJson() => {
//    "dados": dados.toJson(),
    "animes": animes,
    "assistindo": assistindo,
    "concluidos": concluidos,
    "favoritos": favoritos,
  };

  static Map<String, User> fromMapList(Map map) {
    Map<String, User> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = User.fromJson(map[key]);
    return items;
  }

  //endregion

  //region Metodos

  static bool _mapNotNull(dynamic value) => value != null;

  List<AnimeList> get favoritosList {
    List<AnimeList> list = [];
    for (dynamic key in favoritos.keys) {
      var itemAux = animes[key];
      if (itemAux == null) continue;
      var item = AnimeList.newItem(itemAux);
      if (item != null) {
        var aux = favoritos[key];
        item.items.removeWhere((key, value) => !aux.containsKey(key));
        list.add(item);
      }
    }
    return list..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }
  List<AnimeList> get assistindoList {
    List<AnimeList> list = [];
    for (dynamic key in assistindo.keys) {
      var itemAux = animes[key];
      if (itemAux == null) continue;
      var item = AnimeList.newItem(itemAux);
      if (item != null) {
        var aux = assistindo[key];
        item.items.removeWhere((key, value) => !aux.containsKey(key));
        list.add(item);
      }
    }
    return list..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }
  List<AnimeList> get concluidosList {
    List<AnimeList> list = [];
    for (dynamic key in concluidos.keys) {
      var itemAux = animes[key];
      if (itemAux == null) continue;
      var item = AnimeList.newItem(itemAux);
      if(item != null) {
        var aux = concluidos[key];
        item.items.removeWhere((key, value) => !aux.containsKey(key));
        list.add(item);
      }
    }

    return list..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }

  //endregion

  //region get set

  UserDados get dados {
    if (_dados == null)
      _dados = UserDados();
    return _dados;
  }

  set dados(UserDados value) {
    _dados = value;
  }


  Map<String, AnimeList> get animes {
    if (_animes == null)
      _animes = Map();
    return _animes;
  }

  set animes(Map<String, AnimeList> value) {
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