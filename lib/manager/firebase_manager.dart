import 'package:anime/res/import.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auxiliar/import.dart';

class FirebaseManager {
  static FirebaseManager i = FirebaseManager();

  //region Variaveis

  static const String _TAG = 'FirebaseManager';

  FirebaseApp _app = Firebase.app(AppResources.APP_NAME);
  DatabaseReference _database = FirebaseDatabase.instance.reference();
  Reference _storage = FirebaseStorage.instance.ref();
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  //endregion

  //region Firebase App

  DatabaseReference get database => _database;
  FirebaseAuth get auth => _auth;
  Reference get storage => _storage;
  User get user => _auth.currentUser;

  Future<bool> app() async{
    try {
      await Firebase.initializeApp(
        name: AppResources.APP_NAME,
      );
    } catch(e) {
      Log.e(_TAG, 'app', e);
    }
    return true;
  }

  Future<bool> googleAuth() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser
        .authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    Log.d(_TAG, 'googleAuth OK', user.displayName);
    return true;
  }

  //endregion

  bool get isLogado => user != null;

  //region Metodos

  Future<void> init() async {
    try {
      await app();
      Log.d(_TAG, 'init', 'Firebase OK');
    } catch (e) {
      Log.e(_TAG, 'init', e);
    }
  }

  Future<void> finalize() async {
    // _userOki = null;
    // AdminManager.i.finalize();
    await _auth.signOut();
  }

  //endregion

}

class FirebaseChild {
  static const String TESTE = 'teste';
  static const String USUARIO = 'usuario';
  static const String DADOS = '_dados';
  static const String DESEJOS = 'assistindo';
  static const String CONCLUIDOS = 'concluidos';
  static const String FAVORITOS = 'favoritos';
  static const String ONLINE = 'online';
  static const String ANIMES = 'animes';
  static const String ANIME = 'anime';
  static const String CAPA = 'capa';
  static const String BASICO = 'basico';
  static const String COMPLEMENTO = 'complemento';
  static const String ITEMS = 'items';
  static const String CLASSIFICACAO = 'classificacao';
  static const String ADMINISTRADORES = 'admins';
  static const String BUG_ANIME = 'bug_anime';
  static const String SUGESTAO = 'sugestao';
  static const String SUGESTAO_ANIME = 'sugestao_anime';
  static const String VERSAO = 'versao';
}