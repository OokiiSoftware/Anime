import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/anime.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  List<AnimeCollection> getCollection(ListType listType) {
    List<AnimeCollection> list = [];
    var map = getList(listType);
    for (dynamic key in map.keys) {
      var itemAux = animes[key];
      if (itemAux == null) continue;
      var item = AnimeCollection.newItem(itemAux);
      if(item != null) {
        var aux = map[key];
        item.items.removeWhere((key, value) => !aux.containsKey(key));
        list.add(item);
      }
    }

    return list..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }

  void addAnime(Anime item, ListType listType) {
    if (animes[item.idPai] == null) {
      var tempItemCollection = OnlineData.getAsync(item.idPai);
      animes[item.idPai] = AnimeCollection.newItem(tempItemCollection)..items.clear();
    }
    animes[item.idPai].items[item.id] = item;
    var id = item.id;
    getListChild(listType, item.idPai, criarPai: true)[id] = id;
  }

  void removeAnime(Anime item, ListType listType) {
    var map = getListChild(listType, item.idPai);
    if (map == null) return;
    map.remove(item.id);

    if (map.values.isEmpty) {
      getList(listType).remove(item.idPai);
      animes.remove(item.idPai);
    }
  }

  int getAnimeLenght(ListType listType) {
    return getList(listType).length;
  }

  Map<dynamic, dynamic> getList(ListType listType) {
    switch(listType.value) {
      case ListType.assistindoValue:
        return assistindo;
      case ListType.concluidosValue:
        return concluidos;
      case ListType.favoritosValue:
        return favoritos;
    }
    return Map();
  }

  Map<dynamic, dynamic> getListChild(ListType listType, String idPai, {bool criarPai = false}) {
    if (getList(listType)[idPai] == null && criarPai)
      getList(listType)[idPai] = Map();
    return getList(listType)[idPai] ?? Map();
  }

  //endregion

  //region get set

  UserDados get dados {
    if (_dados == null)
      _dados = UserDados(FirebaseOki.user);
    return _dados;
  }
  set dados(UserDados value) => _dados = value;

  Map<String, AnimeCollection> get animes {
    if (_animes == null)
      _animes = Map();
    return _animes;
  }
  set animes(Map<String, AnimeCollection> value) => _animes = value;

  Map<dynamic, dynamic> get assistindo {
    if (_assistindo == null)
      _assistindo = Map();
    return _assistindo;
  }
  set assistindo(Map<dynamic, dynamic> value) => _assistindo = value;

  Map<dynamic, dynamic> get concluidos {
    if (_concluidos == null)
      _concluidos = Map();
    return _concluidos;
  }
  set concluidos(Map<dynamic, dynamic> value) => _concluidos = value;

  Map<dynamic, dynamic> get favoritos {
    if (_favoritos == null)
      _favoritos = Map();
    return _favoritos;
  }
  set favoritos(Map<dynamic, dynamic> value) => _favoritos = value;

  //endregion

}

class UserDados {

  //region Variaveis
  static const String TAG = 'UserDados';

  String _id;
  String _nome;
  String _foto;
  String _fotoLocal;
  String _email;
  String _senha;
  //endregion

  UserDados(User user) {
    id = user.uid;
    nome = user.displayName;
    foto = user.photoURL;
    email = user.email;
  }
  UserDados.fromJson(Map<dynamic, dynamic> map) {
    id = map['id'];
    nome = map['nome'];
    // email = map['email'];
    foto = map['foto'];
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "foto": foto,
    "nome": nome,
    // "email": email,
  };

  //region Metodos

  Future<bool> salvar() async {
    Log.d(TAG, 'salvar', 'Iniciando');
    var result = await FirebaseOki.database
        .child(FirebaseChild.USUARIO)
        .child(id)
        .child(FirebaseChild.DADOS)
        .set(toJson()).then((value) {
      Log.d(TAG, 'salvar', 'OK');
      return true;
    }).catchError((e) {
      Log.e(TAG, 'salvar fail', e);
      return false;
    });

    return result;
  }

  //endregion

  //region get set

  String get senha => _senha ?? '';

  set senha(String value) {
    _senha = value;
  }

  String get email => _email ?? '';

  set email(String value) {
    _email = value;
  }

  String get fotoLocal => _fotoLocal ?? '';

  set fotoLocal(String value) {
    _fotoLocal = value;
  }

  String get foto => _foto ?? '';

  set foto(String value) {
    _foto = value;
  }

  String get nome => _nome ?? '';

  set nome(String value) {
    _nome = value;
  }

  String get id => _id ?? '';

  set id(String value) {
    _id = value;
  }

//endregion

}