import 'dart:io';
import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/auxiliar/logs.dart';

class ListType {
  static const int assistindo = 0;
  static const int favoritos = 1;
  static const int concluidos = 2;
  static const int online = 3;

  ListType(this.value);
  int value;

  bool get isFavoritos => value == favoritos;
  bool get isAssistindo => value == assistindo;
  bool get isConcluidos => value == concluidos;
  bool get isOnline => value == online;
}

class AnimeTipo {

  static const String TV = 'TV';
  static const String OVA = 'OVA';
  static const String ONA = 'ONA';
  static const String MOVIE = 'MOVIE';
  static const String SPECIAL = 'SPECIAL';
  static const String INDEFINIDO = 'INDEFINIDO';

  AnimeTipo(this.value);
  String value;

  bool get isTV => value == TV;
  bool get isOVA => value == OVA;
  bool get isONA => value == ONA;
  bool get isMOVIE => value == MOVIE;
  bool get isSPECIAL => value == SPECIAL;
  bool get isINDEFINIDO => (!isTV && !isOVA && !isOVA && !isMOVIE && !isSPECIAL);
}

class AnimeList {

  static const String TAG = 'AnimeList';

  String _id;
  String _idUser;
  String _nome;
  String _nome2;
  Map<String, Anime> _items;
  List<dynamic> _generos;

  //region Construttores

  AnimeList();

  static AnimeList newItem(AnimeList item) => AnimeList.fromJson(item.toJson(), item.id);

  AnimeList.fromJson(Map<dynamic, dynamic> map, String idPai) {
    try {
      id = idPai;
//    id = map['id'];
      nome = map['nome'];
      nome2 = map['nome2'];
      idUser = map['idUser'];
      generos = map['generos'];
      if(map['items'] != null) {
        items = Anime.fromJsonList(map['items']/*, idPai*/);
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
    'generos': generos
  };

  static Map<String, AnimeList> fromJsonList(Map map) {
    Map<String, AnimeList> items = Map();
    if (map == null) return items;

    for (String key in map.keys)
      items[key] = AnimeList.fromJson(map[key], key);

    return items;
  }

   //endregion

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
    return items.values.toList()..sort((a, b) => a.data.compareTo(b.data));
  }

  Anime getItem(int position) {
    return itemsToList[position];
  }

  Future<void> completar() async {
    var snapshot = await Firebase.databaseReference
        .child(FirebaseChild.ANIME)
        .child(FirebaseChild.COMPLEMENTO)
        .child(id)
        .once();
    var map = snapshot.value;
    if(map == null) return;
    map = map['items'];
    if(map == null) return;
    for (Anime item in itemsToList) {
      if (valueNotNull(map[item.id])) {
        Log.d(TAG, 'completar', map[item.id]);
        Anime aux = Anime.fromJson(map[item.id]);
        if (aux != null) item.completar(aux);
      }
    }
  }

  static bool valueNotNull(dynamic value) => value != null;

  //region get set

  String get id => _id ?? '';

  set id(String value) {
    _id = value;
  }

  String get idUser => _idUser ?? null;

  set idUser(String value) {
    _idUser = value;
  }

  String get nome => _nome ?? '';

  set nome(String value) {
    _nome = value;
  }

  Map<String, Anime> get items {
    if (_items == null)
      _items = Map();
    return _items;
  }

  set items(Map<String, Anime> value) {
    _items = value;
  }

  String get nome2 => _nome2 ?? null;

  set nome2(String value) {
    _nome2 = value;
  }

  List<dynamic> get generos {
    if (_generos == null)
      _generos = [];
    return _generos;
  }

  set generos(List<dynamic> value) {
    _generos = value;
  }

  //endregion

}

class Anime {

  //region Variaveis
  static const String TAG = 'Anime';

  String _id;
//  String _idPai;
  String _nome;
  String _nome2;
  String _desc;
  String _link;
  String _data;
  String _tipo;
  String _foto;
  String _aviso;
  String _status;
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
    id = map['id'];
    nome = map['nome'];
    nome2 = map['nome2'];
    desc = map['desc'];
    link = map['link'];
    data = map['data'];
    tipo = map['tipo'];
    foto = map['foto'];
    aviso = map['aviso'];
    status = map['status'];
    sinopse = map['sinopse'];
    generos = map['generos'];
    isCopiado = map['isCopiado'];
    episodios = map['episodios'];
    miniatura = map['miniatura'];
    ultimoAssistido = map['ultimoAssistido'];
    classificacao = new Classificacao.fromJson(map['classificacao']);
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nome": nome,
    "nome2": nome2,
    "desc": desc,
    "link": link,
    "data": data,
    "tipo": tipo,
    "foto": foto,
    "aviso": aviso,
    "status": status,
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

  void completar(Anime item) {
    foto = item.foto;
    link = item.link;
    tipo = item.tipo;
    status = item.status;
    sinopse = item.sinopse;
    episodios = item.episodios;
  }

  Future<bool> salvar(ListType list) async {
    String child = '';

    switch(list.value) {
      case ListType.assistindo:
        Firebase.user.assistindo[id] = id;
        child = FirebaseChild.DESEJOS;
        break;
      case ListType.concluidos:
        Firebase.user.concluidos[id] = id;
        child = FirebaseChild.CONCLUIDOS;
        break;
      case ListType.favoritos:
        Firebase.user.favoritos[id] = id;
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
      await Firebase.databaseReference
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
      return await Firebase.databaseReference
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
  Future<bool> salvarAdmin() async {
    try {
      return await Firebase.databaseReference
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
      case ListType.assistindo:
        Firebase.user.assistindo[id] = id;
        childNew = FirebaseChild.DESEJOS;
        break;
      case ListType.concluidos:
        Firebase.user.concluidos[id] = id;
        childNew = FirebaseChild.CONCLUIDOS;
        break;
      case ListType.favoritos:
        Firebase.user.favoritos[id] = id;
        childNew = FirebaseChild.FAVORITOS;
        break;
    }

    switch(old.value) {
      case ListType.assistindo:
        Firebase.user.assistindo.remove(id);
        childOld = FirebaseChild.DESEJOS;
        break;
      case ListType.concluidos:
        Firebase.user.concluidos.remove(id);
        childOld = FirebaseChild.CONCLUIDOS;
        break;
      case ListType.favoritos:
        Firebase.user.favoritos.remove(id);
        childOld = FirebaseChild.FAVORITOS;
        break;
    }

    try {
      await salvar(list);

      var result = await Firebase.databaseReference
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
        Firebase.databaseReference
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
      await Firebase.databaseReference
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
      case ListType.assistindo:
        Firebase.user.assistindo.remove(key);
        child = FirebaseChild.DESEJOS;
        break;
      case ListType.concluidos:
        Firebase.user.concluidos.remove(key);
        child = FirebaseChild.CONCLUIDOS;
        break;
      case ListType.favoritos:
        Firebase.user.favoritos.remove(key);
        child = FirebaseChild.FAVORITOS;
        break;
    }

    try {
      return await Firebase.databaseReference
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

  File get fotoToFile {
    return File(OfflineData.localPath + '/' + fotoLocal);
  }

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

  set id(String value) {
    _id = value;
  }

  String get idUser => Firebase.fUser.uid;

  String get idPai => id.substring(0, id.indexOf('_'));
//
//  set idPai(String value) {
//    _idPai = value;
//  }

  String get nome => _nome ?? '';

  set nome(String value) {
    _nome = value;
  }

  String get tipo => _tipo ?? '';

  set tipo(String value) {
    _tipo = value;
  }

  String get nome2 => _nome2 ?? null;

  set nome2(String value) {
    _nome2 = value;
  }

  String get desc => _desc ?? '';

  set desc(String value) {
    _desc = value;
  }

  int get episodios => _episodios ?? 0;

  set episodios(int value) {
    _episodios = value;
  }

  String get aviso => _aviso ?? null;

  set aviso(String value) {
    _aviso = value;
  }

  String get status => _status ?? null;

  set status(String value) {
    _status = value;
  }

  String get foto {
    if (_foto == null || _foto.isEmpty) return miniatura;
    return _foto;
  }

  set foto(String value) {
    _foto = value;
  }

  String get miniatura => _miniatura ?? '';

  set miniatura(String value) {
    _miniatura = value;
  }

  String get sinopse => _sinopse ?? '';

  set sinopse(String value) {
    _sinopse = value;
  }

  List<dynamic> get generos {
    if (_generos == null)
      _generos = [];
    return _generos;
  }

  set generos(List<dynamic> value) {
    _generos = value;
  }

  String get link => _link ?? '';

  set link(String value) {
    _link = value;
  }

  Classificacao get classificacao {
    if (_classificacao == null)
      _classificacao = Classificacao();
    return _classificacao;
  }

  set classificacao(Classificacao value) {
    _classificacao = value;
  }

  bool get isCopiado => _isCopiado ?? false;

  set isCopiado(bool value) {
    _isCopiado = value;
  }

  int get ultimoAssistido => _ultimoAssistido ?? 0;

  set ultimoAssistido(int value) {
    _ultimoAssistido = value;
  }

  String get data => _data ?? '';

  set data(String value) {
    _data = value;
  }

  //endregion

}

class Classificacao {

  //region Variaveis
  static const String ACAO = 'acao';
  static const String DRAMA = 'drama';
  static const String TERROR = 'terror';
  static const String ROMANCE = 'romance';
  static const String COMEDIA = 'comedia';
  static const String ANIMACAO = 'animacao';
  static const String AVENTURA = 'aventura';
  static const String HISTORIA = 'historia';
  static const String ECCHI = 'ecchi';
  static const String FIM = 'fim';
  static const String VOTOS = 'votos';

  double _acao;
  double _drama;
  double _terror;
  double _romance;
  double _comedia;
  double _animacao;
  double _aventura;
  double _historia;
  double _ecchi;
  double _fim;
  int _votos;
  //endregion

  //region Construtores

  Classificacao();

  Classificacao.fromJson(Map<dynamic, dynamic> map) {
    if (map == null) return;
    //A forma que eu usava antes <map[ACAO]?.toString()> não estava funcionando
    //então fiz essa verificação <_mapNotNull>
    if(_mapNotNull(map[ACAO])) acao = double.tryParse(map[ACAO]?.toString());
    if(_mapNotNull(map[DRAMA])) drama = double.tryParse(map[DRAMA]?.toString());
    if(_mapNotNull(map[TERROR])) terror = double.tryParse(map[TERROR]?.toString());
    if(_mapNotNull(map[ROMANCE])) romance = double.tryParse(map[ROMANCE]?.toString());
    if(_mapNotNull(map[COMEDIA])) comedia = double.tryParse(map[COMEDIA]?.toString());
    if(_mapNotNull(map[ANIMACAO])) animacao = double.tryParse(map[ANIMACAO]?.toString());
    if(_mapNotNull(map[AVENTURA])) aventura = double.tryParse(map[AVENTURA]?.toString());
    if(_mapNotNull(map[HISTORIA])) historia = double.tryParse(map[HISTORIA]?.toString());
    if(_mapNotNull(map[ECCHI])) ecchi = double.tryParse(map[ECCHI]?.toString());
    if(_mapNotNull(map[FIM])) fim = double.tryParse(map[FIM]?.toString());
    if(_mapNotNull(map[VOTOS])) votos = map[VOTOS];
  }

  Map<String, dynamic> toJson() => {
    ACAO: acao,
    DRAMA: drama,
    TERROR: terror,
    ROMANCE: romance,
    COMEDIA: comedia,
    ANIMACAO: animacao,
    AVENTURA: aventura,
    HISTORIA: historia,
    ECCHI: ecchi,
    FIM: fim,
    VOTOS: votos,
  };

  //endregion

  //region Metodos

  double get media {
    List<double> values = mediaValues();

    if (values.length == 0)
      return -1.0;
    double value = 0;
    double total = 0;
    for (double v in values) {
      value += v;
    }
    total = value / values.length;
    return double.parse(total.toStringAsFixed(2));
  }

  List<double> mediaValues({bool tudo = false}) {
    List<double> values = [];
    if (acao >= 0) values.add(acao);
    if (drama >= 0) values.add(drama);
    if (romance >= 0) values.add(romance);
    if (comedia >= 0) values.add(comedia);
    if (animacao >= 0) values.add(animacao);
    if (aventura >= 0) values.add(aventura);
    if (historia >= 0) values.add(historia);
    if (fim >= 0) values.add(fim);
    if (tudo) {
      if (terror >= 0) values.add(terror);
      if (ecchi >= 0) values.add(ecchi);
    }

    return values;
  }

  static bool _mapNotNull(dynamic value) {
    return value != null;
  }

  //endregion

  //region get set

  double get historia => _historia ?? -1.0;

  set historia(double value) {
    _historia = value;
  }

  double get fim => _fim ?? -1.0;

  set fim(double value) {
    _fim = value;
  }

  double get animacao => _animacao ?? -1.0;

  set animacao(double value) {
    _animacao = value;
  }

  double get ecchi => _ecchi ?? -1.0;

  set ecchi(double value) {
    _ecchi = value;
  }

  double get comedia => _comedia ?? -1.0;

  set comedia(double value) {
    _comedia = value;
  }

  double get romance => _romance ?? -1.0;

  set romance(double value) {
    _romance = value;
  }

  double get drama => _drama ?? -1.0;

  set drama(double value) {
    _drama = value;
  }

  double get acao => _acao ?? -1.0;

  set acao(double value) {
    _acao = value;
  }

  double get aventura => _aventura ?? -1.0;

  set aventura(double value) {
    _aventura = value;
  }

  double get terror => _terror ?? -1.0;

  set terror(double value) {
    _terror = value;
  }

  int get votos => _votos ?? null;

  set votos(int value) {
    _votos = value;
  }

  //endregion

}