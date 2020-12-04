import 'dart:io';
import 'package:anime/model/anime.dart';
import 'package:anime/model/user_oki.dart';
import 'package:anime/res/strings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'admin.dart';
import 'logs.dart';
import 'online_data.dart';

class FirebaseOki {
  //region Variaveis
  static const String TAG = 'FirebaseOki';

  // static FirebaseApp _firebaseApp;
  static User _firebaseUser;
  static DatabaseReference _database = FirebaseDatabase.instance.reference();
  static Reference _storage = FirebaseStorage.instance.ref();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();

  static UserOki _user;
  //endregion

  //region Firebase App

  static Future<bool> app() async{
      try {
        var appOptions = FirebaseOptions(
          appId: _dataUrl['appId'],
          projectId: _dataUrl['projectId'],
          messagingSenderId: _dataUrl['messagingSenderId'],
          apiKey: 'AIzaSyA5Gwz7yFccSI8rBSams7IAUADOv68wJcQ',
          storageBucket: _dataUrl['storageBucket'],
          databaseURL: _dataUrl['databaseURL'],
        );
        await Firebase.initializeApp(
            name: MyResources.APP_NAME,
            options: appOptions
        );
      }catch(e) {
        Log.e(TAG, 'app', e);
      }
    return true;
  }

  static FirebaseAuth get auth => _auth;
  static Reference get storage => _storage;

  static User get fUser => _firebaseUser;

  static DatabaseReference get database => _database;

  static Future<User> googleAuth() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    _firebaseUser = user;
    atualizarUser();
    return user;
  }

  //endregion

  //region gets

  static bool get isLogado => _firebaseUser != null;

  static UserOki get user {
    if (_user == null)
      _user = UserOki();
    return _user;
  }

  static Map get _dataUrl => {
    'appId': Platform.isAndroid ? '1:281298385448:android:3a4c74b7c7ae63f297131d' : '',
    'projectId': 'anime-oki',
    'databaseURL': 'AAAAQX6wuig:APA91bF1iiMSFCD5FUXMc9BWw3UjUdRpzMR2tEY1dRIdy_vw1Oa9apsTf3mgN-9U9nqmP9wgXvAE_mzIBU4KPoh0LsoEhcmGAfacdkkLqlYr51kEwJQWB8V4ZqeumQ6NCqvaKZtepgVj',
    'messagingSenderId': 'https://anime-oki.firebaseio.com',
    'storageBucket': 'gs://anime-oki.appspot.com'
  };

  static bool get isAdmin => Admin.isAdmin;

  static set user(UserOki user) => _user = user;

  //endregion

  //region Metodos

  static Future<void> init() async {
    Log.d(TAG, 'init', 'Firebase Iniciando');

    const firebaseUser_Null = 'firebaseUser Null';
    try {
        await app();
      FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-8585143969698496~3199903473');

      _firebaseUser = _auth.currentUser;
      if (_firebaseUser == null)
        throw new Exception(firebaseUser_Null);

      await atualizarUser();
      await Admin.checkAdmin();
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
    Admin.finalize();
    await _auth.signOut();
  }

  static Future<void> atualizarUser() async {
    String uid = _firebaseUser?.uid;
    if (uid == null) return;
    UserOki item = await _baixarUser(uid);
    if (item == null) {
      if (_user == null)
        _user = UserOki();
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

  static Future<UserOki> _baixarUser(String uid) async {
    try {
      var snapshot = await FirebaseOki.database
          .child(FirebaseChild.USUARIO).child(uid).once();
      return UserOki.fromJson(snapshot.value);
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