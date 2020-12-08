import 'dart:io';
import 'package:anime/auxiliar/import.dart';
import 'data_hora.dart';
import 'classificacao.dart';

class ListType {
  static const int assistindoValue = 0;
  static const int favoritosValue = 1;
  static const int concluidosValue = 2;
  static const int onlineValue = 3;

  static ListType get assistindo => ListType(assistindoValue);
  static ListType get favoritos => ListType(favoritosValue);
  static ListType get concluidos => ListType(concluidosValue);
  static ListType get online => ListType(onlineValue);

  ListType(this.value);
  int value;

  bool get isFavoritos => value == favoritos.value;
  bool get isAssistindo => value == assistindo.value;
  bool get isConcluidos => value == concluidos.value;
  bool get isOnline => value == online.value;
}

class AnimeType {
  static const String TV = 'TV';
  static const String OVA = 'OVA';
  static const String ONA = 'ONA';
  static const String MOVIE = 'MOVIE';
  static const String SPECIAL = 'SPECIAL';
  static const String INDEFINIDO = 'INDEFINIDO';
}

class AnimeCollection {

  static const String TAG = 'AnimeCollection';

  //region variaveis
  String _id;
  String _idUser;
  String _nome;
  String _nome2;
  Map<String, Anime> _items;
  List<dynamic> _parentes;
  List<dynamic> _generos;
  //endregion

  //region Construttores

  AnimeCollection();

  static AnimeCollection newItem(AnimeCollection item) {
    var novo = AnimeCollection();
    novo.id = item.id;
    novo.nome = item.nome;
    novo.nome2 = item.nome2;
    novo.idUser = item.idUser;
    novo.generos.addAll(item.generos);
    novo.parentes.addAll(item.parentes);
    novo.items.addAll(item.items);
    return novo;
  }

  static Map<String, AnimeCollection> fromJsonList(Map map) {
    Map<String, AnimeCollection> items = Map();
    if (map == null) return items;

    for (String key in map.keys)
      items[key] = AnimeCollection.fromJson(map[key], key);

    return items;
  }

  AnimeCollection.fromJson(Map<dynamic, dynamic> map, String idPai) {
    try {
      id = idPai;
      nome = map['nome'];
      nome2 = map['nome2'];
      idUser = map['idUser'];
      generos = map['generos'];
      if(map['items'] != null) {
        items = Anime.fromJsonList(map['items']);
      }
      if(map['parentes'] != null) {
        parentes = map['parentes'];
      }
      for (var item in items.values) {
        if (item.generos.length == 0)
          item.generos = generos;
      }
    } catch (e) {
      Log.e(TAG, 'AnimeList.fromJson', e);
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'nome2': nome2,
    'items': items,
    "idUser": idUser,
    'generos': generos,
    'parentes': parentes,
  };

   //endregion

  //region gets
  bool get isCompleto => itemsToList[0].tipo != null;

  double get media {
    double value = 0.0;
    double i = 0.0;
    for (var item in items.values) {
      var media = item.classificacao.media;
      if (media >= 0) {
        i++;
        value += media;
      }
    }
    if (i == 0) return -1;

    value = value / i;
    return value;
  }

  int get episodios {
    int value = 0;
    bool contemIndefinidos = false;
    for (var item in items.values)
      if (item.episodios >= 0)
        value += item.episodios;
      else contemIndefinidos = true;
      return contemIndefinidos ? -value : value;
  }

  bool get isDataInicioFimIguais => anoInicio == anoFim;

  String get anoInicio {
    var item = itemsToList[0];
    return item.ano;
  }

  String get anoFim {
    var item = itemsToList[itemsToList.length-1];
    return item.ano;
  }

  List<Anime> get itemsToList {
    switch(Config.listOrder) {
      case ListOrder.nome:
        return items.values.toList()..sort((a, b) => a.nome.compareTo(b.nome));
        break;
      case ListOrder.dataAsc:
        return items.values.toList()..sort((a, b) => a.data.compareTo(b.data));
      break;
      default:
        return items.values.toList()..sort((a, b) => b.data.compareTo(a.data));
        break;
    }
  }
  //endregion

  //region metodos

  Anime getItem(int position) {
    if (position < 0) return null;
    return itemsToList[position];
  }

  Future<void> completar() async {
    var snapshot = await FirebaseOki.database
        .child(FirebaseChild.ANIME)
        .child(FirebaseChild.COMPLEMENTO)
        .child(id)
        .once();
    var map = snapshot.value;
    if(map == null) return;
    var items = map['items'];
    if(items == null) return;
    if (valueNotNull(map['parentes']))
      parentes = map['parentes'];

    for (Anime item in itemsToList) {
      if (valueNotNull(items[item.id])) {
        Anime aux = Anime.fromJson(items[item.id]);
        if (aux != null) item._completar(aux);
      }
    }
  }

  static bool valueNotNull(dynamic value) => value != null;

  //endregion

  //region get set

  String get id => _id ?? '';
  set id(String value) => _id = value;

  String get idUser => _idUser ?? null;
  set idUser(String value) => _idUser = value;

  String get nome => _nome ?? '';
  set nome(String value) => _nome = value;

  Map<String, Anime> get items {
    if (_items == null)
      _items = Map();
    return _items;
  }
  set items(Map<String, Anime> value) => _items = value;

  String get nome2 => _nome2 ?? null;
  set nome2(String value) => _nome2 = value;

  List<dynamic> get generos {
    if (_generos == null)
      _generos = [];
    return _generos;
  }
  set generos(List<dynamic> value) => _generos = value;

  List<dynamic> get parentes {
    if (_parentes == null)
      _parentes = [];
    return _parentes;
  }
  set parentes(List<dynamic> value) => _parentes = value;

  //endregion

}

class Anime {

  //region Variaveis
  static const String TAG = 'Anime';

  String _id;
  String _nome;
  String _nome2;
  String _desc;
  String _link;
  String _data;
  String _tipo;
  // String _foto;//todo
  String _aviso;
  String _miniatura;
  String _sinopse;
  String _fotoLocal;
  int _episodios;
  int _ultimoAssistido;
  bool _isCopiado;
  List<dynamic> _generos;

  Classificacao _classificacao;
  //endregion

  //region Construttores

  Anime();

  Anime.fromJson(Map<dynamic, dynamic> map) {
    if (mapIsNoNull(map['id'])) id = map['id'];
    if (mapIsNoNull(map['nome'])) nome = map['nome'];
    if (mapIsNoNull(map['nome2'])) nome2 = map['nome2'];
    if (mapIsNoNull(map['desc'])) desc = map['desc'];
    if (mapIsNoNull(map['link'])) link = map['link'];
    if (mapIsNoNull(map['data'])) data = map['data'];
    if (mapIsNoNull(map['tipo'])) tipo = map['tipo'];
    // if (mapIsNoNull(map['foto'])) foto = map['foto'];todo
    if (mapIsNoNull(map['aviso'])) aviso = map['aviso'];
    if (mapIsNoNull(map['sinopse'])) sinopse = map['sinopse'];
    if (mapIsNoNull(map['generos'])) generos = map['generos'];
    if (mapIsNoNull(map['isCopiado'])) isCopiado = map['isCopiado'];
    if (mapIsNoNull(map['episodios'])) episodios = map['episodios'];
    if (mapIsNoNull(map['miniatura'])) miniatura = map['miniatura'];
    if (mapIsNoNull(map['ultimoAssistido'])) ultimoAssistido = map['ultimoAssistido'];
    if (mapIsNoNull(map['classificacao'])) classificacao = new Classificacao.fromJson(map['classificacao']);
  }

  bool mapIsNoNull(dynamic map) => map != null;

  Map<String, dynamic> toJson() => {
    "id": id,
    "nome": nome,
    "nome2": nome2,
    "desc": desc,
    "link": link,
    "data": data,
    "tipo": tipo,
    // "foto": foto,
    "aviso": aviso,
    "sinopse": sinopse,
    "generos": generos,
    "isCopiado": isCopiado,
    "episodios": episodios,
    "miniatura": miniatura,
    "ultimoAssistido": ultimoAssistido,
    "classificacao": classificacao.toJson(),
  };

  static Map<String, Anime> fromJsonList(Map map) {
    Map<String, Anime> items = Map();
    if (map == null)
      return items;

    for (String key in map.keys) {
      var aux = map[key];
      Anime item;

      if (aux is Anime) item = aux;
      else item = Anime.fromJson(map[key]);

      items[key] = item;
    }

    return items;
  }

  //endregion

  //region Metodos

  void _completar(Anime item) {
    // foto = item.foto;todo
    link = item.link;
    tipo = item.tipo;
    // status = item.status;
    sinopse = item.sinopse;
    episodios = item.episodios;
    episodios = item.episodios;
  }

  Future<bool> complete() async {
    try{
      var snapshot = await FirebaseOki.database
          .child(FirebaseChild.ANIME)
          .child(FirebaseChild.COMPLEMENTO)
          .child(idPai)
          .child(FirebaseChild.ITEMS)
          .child(id)
          .once();
      Log.d(TAG, 'complete', id, idPai);
      var item = Anime.fromJson(snapshot.value);
      if (item != null)
        _completar(item);
      return true;
    } catch(e) {
      Log.e(TAG, 'complete', id, e);
      return false;
    }
  }

  Future<bool> salvar(ListType list) async {
    String child = '';

    switch(list.value) {
      case ListType.assistindoValue:
        FirebaseOki.userOki.assistindo[id] = id;
        child = FirebaseChild.DESEJOS;
        break;
      case ListType.concluidosValue:
        FirebaseOki.userOki.concluidos[id] = id;
        child = FirebaseChild.CONCLUIDOS;
        break;
      case ListType.favoritosValue:
        FirebaseOki.userOki.favoritos[id] = id;
        child = FirebaseChild.FAVORITOS;
        break;
    }

    var temp = {
      "id": id,
      "desc": desc,
      "ultimoAssistido": ultimoAssistido,
      "classificacao": classificacao.toJson(),
    };

    try {
      await FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .child(idUser)
          .child(FirebaseChild.ANIMES)
          .child(idPai)
          .child(FirebaseChild.ITEMS)
          .child(id)
          .set(temp).then((value) {
        Log.d(TAG, 'salvar', idPai, id, 'OK');
        return true;
      }).catchError((e) {
        Log.e(TAG, 'salvar fail', id, e);
        return false;
      });
      return await FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .child(idUser)
          .child(child)
          .child(idPai)
          .child(id)
          .set(id).then((value) {
        Log.d(TAG, 'salvar', id, 'OK');
        return true;
      }).catchError((e) {
        Log.e(TAG, 'salvar fail', id, e);
        return false;
      });
    } catch (e) {
      Log.e(TAG, 'salvar', id, e);
      return false;
    }
  }
  Future<bool> salvarAdmin1() async {
    try {
      return await FirebaseOki.database
          .child(FirebaseChild.ANIMES)
          .child(id)
          .set(toJson()).then((value) {
        Log.d(TAG, 'salvarAdmin', id, 'OK');
        return true;
      }).catchError((e) {
        Log.e(TAG, 'salvarAdmin fail', id, e);
        return false;
      });
    } catch (e) {
      Log.e(TAG, 'salvarAdmin', id, e);
      return false;
    }
  }

  Future<bool> mover(ListType list, ListType old) async {
    if (list == old) return true;
    String childNew = '';
    String childOld = '';

    switch(list.value) {
      case ListType.assistindoValue:
        FirebaseOki.userOki.assistindo[id] = id;
        childNew = FirebaseChild.DESEJOS;
        break;
      case ListType.concluidosValue:
        FirebaseOki.userOki.concluidos[id] = id;
        childNew = FirebaseChild.CONCLUIDOS;
        break;
      case ListType.favoritosValue:
        FirebaseOki.userOki.favoritos[id] = id;
        childNew = FirebaseChild.FAVORITOS;
        break;
    }

    switch(old.value) {
      case ListType.assistindoValue:
        FirebaseOki.userOki.assistindo.remove(id);
        childOld = FirebaseChild.DESEJOS;
        break;
      case ListType.concluidosValue:
        FirebaseOki.userOki.concluidos.remove(id);
        childOld = FirebaseChild.CONCLUIDOS;
        break;
      case ListType.favoritosValue:
        FirebaseOki.userOki.favoritos.remove(id);
        childOld = FirebaseChild.FAVORITOS;
        break;
    }

    try {
      await salvar(list);

      var result = await FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .child(idUser)
          .child(childNew)
          .child(idPai)
          .child(id)
          .set(id).then((value) {
        Log.d(TAG, 'mover', id, 'OK');
        return true;
      }).catchError((e) {
        Log.e(TAG, 'mover fail', id, e);
        return false;
      });
      if (result) {
        FirebaseOki.database
            .child(FirebaseChild.USUARIO)
            .child(idUser)
            .child(childOld)
            .child(idPai)
            .child(id)
            .remove().then((value) {
          Log.d(TAG, 'mover: remove', id, 'OK');
          return true;
        }).catchError((e) {
          Log.e(TAG, 'mover: remove fail', id, e);
          return false;
        });
      }
      return result;
    } catch (e) {
      Log.e(TAG, 'mover', id, e);
      return false;
    }
  }

  Future<bool> delete(ListType list, {bool save = true, bool deleteAll = false}) async {
    var result = await _deleteAux(list, id);
    if (deleteAll) {
      result = await FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .child(idUser)
          .child(FirebaseChild.ANIMES)
          .child(idPai)
          .child(id)
          .remove().then((value) {
        Log.d(TAG, 'delete', id, 'OK');
        return true;
      }).catchError((e) {
        Log.e(TAG, 'delete fail', id, e);
        return false;
      });
    }
    if (save)
      return await OfflineData.saveOfflineData();
    return result;
  }
  Future<bool> _deleteAux(ListType list, String key) async {
    String child = '';
    switch(list.value) {
      case ListType.assistindoValue:
        FirebaseOki.userOki.assistindo.remove(key);
        child = FirebaseChild.DESEJOS;
        break;
      case ListType.concluidosValue:
        FirebaseOki.userOki.concluidos.remove(key);
        child = FirebaseChild.CONCLUIDOS;
        break;
      case ListType.favoritosValue:
        FirebaseOki.userOki.favoritos.remove(key);
        child = FirebaseChild.FAVORITOS;
        break;
    }

    try {
      return await FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .child(idUser)
          .child(child)
          .child(idPai)
          .child(id)
          .remove().then((value) {
        Log.d(TAG, '_deleteAux', id, 'OK');
        return true;
      }).catchError((e) {
        Log.e(TAG, '_deleteAux fail', id, e);
        return false;
      });
    } catch(e) {
      Log.e(TAG, '_deleteAux', e);
      return false;
    }
  }

  bool get fotoLocalExist {
    File file = File(OfflineData.localPath + '/' + fotoLocal);
    return file.existsSync();
  }
  bool get isComplete => tipo.isNotEmpty;
  bool get isNoLancado => !isLancado;
  bool get isLancado => data.compareTo(DataHora.now()) < 0;

  File get fotoToFile => File(OfflineData.localPath + '/' + fotoLocal);

  String get fotoLocal {
    if (_fotoLocal == null)
      _fotoLocal = '$id.jpg';
    return _fotoLocal;
  }

  String get ano {
    if (data.contains('-'))
      return data.substring(0, data.indexOf('-'));
    return data;
  }

  //endregion

  //region get set

  String get id => _id ?? '';
  set id(String value) => _id = value;

  String get idUser => FirebaseOki.user.uid;
  String get idPai {
    if (id[0] == '_') {
      var temp = id.substring(1, id.length);
      return '_' + temp.substring(0, temp.indexOf('_'));
    }
    return id.substring(0, id.indexOf('_'));
  }

  String get nome => _nome ?? '';
  set nome(String value) => _nome = value;

  String get tipo => _tipo ?? '';
  set tipo(String value) => _tipo = value;

  String get nome2 => _nome2 ?? null;
  set nome2(String value) => _nome2 = value;

  String get desc => _desc ?? '';
  set desc(String value) => _desc = value;

  int get episodios => _episodios ?? 0;
  set episodios(int value) => _episodios = value;

  String get aviso => _aviso ?? null;
  set aviso(String value) => _aviso = value;

  Future<String> get foto async {
    var ref = FirebaseOki.storage
        .child(FirebaseChild.ANIME)
        .child(FirebaseChild.CAPA).child(id[0])
        .child('$id.jpg');
    try {
      return await ref.getDownloadURL();
    } catch(e) {
      Log.e(TAG, 'foto', e, !e.toString().contains('Not Found.  Could not get object'));
      return null;
    }

    // if (_foto == null || _foto.isEmpty) return miniatura;
    // return _foto;
  }
  // set foto(String value) {todo
  //   _foto = value;
  // }

  String get miniatura => _miniatura ?? '';
  set miniatura(String value) => _miniatura = value;

  String get sinopse => _sinopse ?? '';
  set sinopse(String value) => _sinopse = value;

  List<dynamic> get generos {
    if (_generos == null)
      _generos = [];
    return _generos;
  }
  set generos(List<dynamic> value) => _generos = value;

  String get link => _link ?? '';
  set link(String value) =>  _link = value;

  Classificacao get classificacao {
    if (_classificacao == null)
      _classificacao = Classificacao();
    return _classificacao;
  }
  set classificacao(Classificacao value) => _classificacao = value;

  bool get isCopiado => _isCopiado ?? false;
  set isCopiado(bool value) => _isCopiado = value;

  int get ultimoAssistido => _ultimoAssistido ?? 0;
  set ultimoAssistido(int value) => _ultimoAssistido = value;

  String get data => _data ?? '';
  set data(String value) => _data = value;

  //endregion

}
