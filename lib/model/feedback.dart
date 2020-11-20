import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/auxiliar/logs.dart';

class BugAnime extends Sugestao{
  static const String TAG = 'BugAnime';

  String _idAnime;

  BugAnime();

  BugAnime.fromJson(Map map) {
    descricao = map['descricao'];
    idAnime = map['idAnime'];
    idUser = map['idUser'];
    data = map['data'];
  }

  @override
  Map toJson() => {
    "descricao": descricao,
    "idAnime": idAnime,
    "idUser": idUser,
    "data": data,
  };

  @override
  Future<bool> salvar([bool isSugestaoAnime = false]) async {
    var result = await Firebase.databaseReference
        .child(FirebaseChild.BUG_ANIME)
        .child(data)
        .set(toJson())
        .then((value) {
      Log.d(TAG, 'salvar', data, 'OK');
      return true;
    }).catchError((e) {
      Log.d(TAG, 'salvar', data, e);
      return true;
    });
    return result;
  }

  @override
  Future<bool> delete() async {
    var result = await Firebase.databaseReference
        .child(FirebaseChild.BUG_ANIME)
        .child(data)
        .remove()
        .then((value) {
      Log.d(TAG, 'delete', data, 'OK');
      return true;
    }).catchError((e) {
      Log.d(TAG, 'delete', data, e);
      return true;
    });
    return result;
  }

  //region get set

  String get idAnime => _idAnime ?? '';

  set idAnime(String value) {
    _idAnime = value;
  }

  //endregion

}

class Sugestao {
  static const String TAG = 'Sugestao';

  String _data;
  String _idUser;
  String _descricao;

  Sugestao();
  Sugestao.fromJson(Map map) {
    descricao = map['descricao'];
    idUser = map['idUser'];
    data = map['data'];
  }
  Map toJson() => {
    "descricao": descricao,
    "idUser": idUser,
    "data": data,
  };

  Future<bool> salvar([bool isSugestaoAnime = false]) async {
    String child = isSugestaoAnime ? FirebaseChild.SUGESTAO_ANIME : FirebaseChild.SUGESTAO;
    var result = await Firebase.databaseReference
        .child(child)
        .child(data)
        .set(toJson())
        .then((value) {
      Log.d(TAG, 'salvar', data, 'OK');
      return true;
    }).catchError((e) {
      Log.d(TAG, 'salvar', data, e);
      return true;
    });
    return result;
  }

  Future<bool> delete() async {
    var result = await Firebase.databaseReference
        .child(FirebaseChild.SUGESTAO)
        .child(data)
        .remove()
        .then((value) {
      Log.d(TAG, 'delete', data, 'OK');
      return true;
    }).catchError((e) {
      Log.d(TAG, 'delete', data, e);
      return true;
    });
    return result;
  }

  //region get set

  String get idUser => _idUser ?? '';

  set idUser(String value) {
    _idUser = value;
  }

  String get data => _data ?? '';

  set data(String value) {
    _data = value;
  }

  String get descricao => _descricao ?? '';

  set descricao(String value) {
    _descricao = value;
  }

  //endregion

}

class Erro {

  bool isExpanded = false;

  String classe;
  String userId;
  String metodo;
  String valor;
  String data;
//  List<String> _similares;

  Erro();

  Erro.fromJson(Map map) {
    classe = map['classe'];
    userId = map['userId'];
    metodo = map['metodo'];
    valor = map['valor'];
    data = map['data'];
  }
  Map toJson() => {
    "classe": classe,
    "userId": userId,
    "metodo": metodo,
    "valor": valor,
    "data": data,
  };

//  Future<bool> salvar() async {
//    try {
//      var result = await getFirebase.databaseReference()
//          .child(FirebaseChild.LOGS)
//          .child(data)
//          .set(toJson())
//          .then((value) => true)
//          .catchError((ex) => false);
//      Log.d('Error', 'salvar', result);
//      return result;
//    } catch(e) {
//      //Todo \(ºvº)/
//      return false;
//    }
//  }

//  Future<bool> _delete(String key) async {
//    try {
//      var result = await getFirebase.databaseReference()
//          .child(FirebaseChild.LOGS)
//          .child(key)
//          .remove()
//          .then((value) => true)
//          .catchError((ex) => false);
//      Log.d('Error', 'delete', result);
//      return result;
//    } catch(e) {
//      //Todo \(ºvº)/
//      return false;
//    }
//  }

//  Future<bool> deleteAll() async {
//    List<bool> list = [];
//    for (String key in similares) {
//      list.add(await _delete(key));
//    }
//    var quantidade = list.where((x) => x == false).length;
//    return quantidade == 0;
//  }
//
//  List<String> get similares {
//    if (_similares == null)
//      _similares = [];
//    return _similares;
//  }

}