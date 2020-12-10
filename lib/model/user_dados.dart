import 'package:anime/auxiliar/import.dart';
import 'package:firebase_auth/firebase_auth.dart';

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