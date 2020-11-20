import 'dart:io';
import 'package:anime/model/anime.dart';
import 'package:anime/model/user.dart';
import 'package:anime/res/strings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'import.dart';
import 'logs.dart';

class Firebase {
  //region Variaveis
  static const String TAG = 'getFirebase';

  static FirebaseApp _firebaseApp;
  static FirebaseUser _firebaseUser;
  static DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();

  static User _user;
  static bool _isAdmin;
  static Map<String, bool> _admins = Map();// <id, isEnabled>
  //endregion

  //region Firebase App

  static Future<FirebaseApp> app() async{
    if (_firebaseApp == null) {
      var iosOptions = FirebaseOptions(
        googleAppID: '',
        gcmSenderID: '',
        storageBucket: _dataUrl['storageBucket'],
        databaseURL: _dataUrl['databaseURL'],
      );
      var androidOptions = FirebaseOptions(
        googleAppID: '1:281298385448:android:3a4c74b7c7ae63f297131d',
        apiKey: 'AIzaSyA5Gwz7yFccSI8rBSams7IAUADOv68wJcQ',
        storageBucket: _dataUrl['storageBucket'],
        databaseURL: _dataUrl['databaseURL'],
      );

      _firebaseApp = await FirebaseApp.configure(
          name: MyResources.APP_NAME,
          options: Platform.isIOS ? iosOptions : androidOptions
      );
    }

    return _firebaseApp;
  }

  static FirebaseAuth get auth => _auth;

  static FirebaseUser get fUser => _firebaseUser;

  static DatabaseReference get databaseReference => _databaseReference;

  static Future<FirebaseUser> googleAuth() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    _firebaseUser = user;
    atualizarUser();
    return user;
  }

  //endregion

  //region Metodos

  static bool get isLogado => _firebaseUser != null;

  static User get user {
    if (_user == null)
      _user = User();
    return _user;
  }

  static Map get _dataUrl => {
    'databaseURL': 'https://anime-oki.firebaseio.com',
    'storageBucket': 'gs://anime-oki.appspot.com'
  };

  static bool get isAdmin => _isAdmin ?? false;

  static set user(User user) => _user = user;

  static Future<void> init() async {
    Log.d(TAG, 'init', 'Firebase Iniciando');

    const firebaseUser_Null = 'firebaseUser Null';
    try {
      await app();

      _firebaseUser = await _auth.currentUser();
      if (_firebaseUser == null)
        throw new Exception(firebaseUser_Null);

      await OnlineData.baixarLista();
      await atualizarUser();
      await _checkAdmin();
      Log.d(TAG, 'init', 'Firebase OK');
    } catch (e) {
      if (e.toString().contains(firebaseUser_Null)) {
        Log.e(TAG, 'init', e, false);
      } else
        Log.e(TAG, 'init', e);
    }
  }

  static Future<void> finalize() async {
    _firebaseUser = null;
    _user = null;
    _isAdmin = false;
    _admins.clear();
    await _auth.signOut();
  }

  static Future<void> _checkAdmin() async {
    try {
      var snapshot = await databaseReference.child(FirebaseChild.ADMINISTRADORES).once();
      Map<dynamic, dynamic> map = snapshot.value;
      for (dynamic key in map.keys) {
        _admins[key] = map[key];
      }
      if (_admins.containsKey(fUser.uid))
        _isAdmin = map[fUser.uid];
      if (isAdmin)
        getAdmin.init();
    } catch (e) {
      Log.e(TAG, '_checkAdmin', e);
    }
  }

  static Future<void> atualizarUser() async {
    String uid = _firebaseUser?.uid;
    if (uid == null) return;
    User item = await _baixarUser(uid);
    if (item == null) {
      if (_user == null)
        _user = User();
    } else {
      _user = item;
//      _organizarListas();
    }
  }

  //Listas (assistindo, concluidos, favoritos)
  static void organizarListas(/*User user*/) {
    if (_user == null) return;

    for(AnimeList item in OnlineData.dataList) {
      if (!user.animes.containsKey(item.id)) continue;

      //Os dados de backup.items só contém {classificacao, desc, ultimoAssistido, id}
      //Aqui faço um backup pra restaurar depois
      final backup = AnimeList.newItem(user.animes[item.id]);
      //_getNewAnimeList(...) retorna somente os itens de minhas listas (favoritos, colcluidos, assistindo)
      //Mas esses items não comtém {classificacao, desc, ultimoAssistido}
      _user.animes[item.id] = _getNewAnimeList(item);
      final items = user.animes[item.id];

      //Aqui restaura os backups
      if (items != null) {
        for (final item in items.itemsToList) {
          var aux = backup.items[item.idPai];
          if (aux != null) {
            item.desc = aux.desc;
            item.classificacao = aux.classificacao;
            item.ultimoAssistido = aux.ultimoAssistido;
          }
        }
      }
    }
  }

  static AnimeList _getNewAnimeList(AnimeList items) {
    AnimeList itemsAux = AnimeList.fromJson(items.toJson(), items.id);
    itemsAux.items.clear();
    Map assistindoMap = user.assistindo[items.id];
    Map concluidosMap = user.concluidos[items.id];
    Map favoritosMap = user.favoritos[items.id];

    for (Anime item in items.items.values) {
      var aux = Anime.fromJson(item.toJson());
      if (favoritosMap != null && favoritosMap.containsKey(item.id))
        itemsAux.items[item.id] = aux;
      if (assistindoMap != null && assistindoMap.containsKey(item.id))
        itemsAux.items[item.id] = aux;
      if (concluidosMap != null && concluidosMap.containsKey(item.id))
        itemsAux.items[item.id] = aux;
    }
    return itemsAux;
  }

  static Future<User> _baixarUser(String uid) async {
    try {
      var snapshot = await Firebase.databaseReference
          .child(FirebaseChild.USUARIO).child(uid).once();
      return User.fromJson(snapshot.value);
    } catch (e) {
      Log.e(TAG, 'baixarUser', e);
      return null;
    }
  }

  //endregion

}

class FirebaseChild {
  static const String USUARIO = 'usuario';
  static const String DADOS = '_dados';
  static const String DESEJOS = 'assistindo';
  static const String CONCLUIDOS = 'concluidos';
  static const String FAVORITOS = 'favoritos';
  static const String ANIMES = 'animes';
  static const String ANIME = 'anime';
  static const String BASICO = 'basico';
  static const String COMPLEMENTO = 'complemento';
  static const String ITEMS = 'items';
  static const String CLASSIFICACAO = 'classificacao';
  static const String ADMINISTRADORES = 'admins';
  static const String BUG_ANIME = 'bug_anime';
  static const String SUGESTAO = 'sugestao';
  static const String SUGESTAO_ANIME = 'sugestao_anime';
}