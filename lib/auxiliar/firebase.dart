import 'dart:io';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
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
  static User _user;
  static DatabaseReference _database = FirebaseDatabase.instance.reference();
  static Reference _storage = FirebaseStorage.instance.ref();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();

  static UserOki _userOki;
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
            name: AppResources.APP_NAME,
            options: appOptions
        );
      }catch(e) {
        Log.e(TAG, 'app', e);
      }
    return true;
  }

  static FirebaseAuth get auth => _auth;
  static Reference get storage => _storage;

  static User get user => _user;

  static DatabaseReference get database => _database;

  static Future<bool> googleAuth() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    Log.d(TAG, 'googleAuth OK', user.displayName);
    _user = user;
    atualizarUser();
    return true;
  }

  //endregion

  //region gets

  static bool get isLogado => _user != null;

  static UserOki get userOki {
    if (_userOki == null)
      _userOki = UserOki();
    return _userOki;
  }

  static Map get _dataUrl => {
    'appId': Platform.isAndroid ? '1:281298385448:android:3a4c74b7c7ae63f297131d' : '',
    'projectId': 'anime-oki',
    'databaseURL': 'AAAAQX6wuig:APA91bF1iiMSFCD5FUXMc9BWw3UjUdRpzMR2tEY1dRIdy_vw1Oa9apsTf3mgN-9U9nqmP9wgXvAE_mzIBU4KPoh0LsoEhcmGAfacdkkLqlYr51kEwJQWB8V4ZqeumQ6NCqvaKZtepgVj',
    'messagingSenderId': 'https://anime-oki.firebaseio.com',
    'storageBucket': 'gs://anime-oki.appspot.com'
  };

  static bool get isAdmin => Admin.isAdmin;

  static set userOki(UserOki user) => _userOki = user;

  //endregion

  //region Metodos

  static Future<void> init() async {
    Log.d(TAG, 'init', 'Firebase Iniciando');

    const firebaseUser_Null = 'firebaseUser Null';
    try {
        await app();
      FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-8585143969698496~3199903473');

      _user = _auth.currentUser;
      if (_user == null)
        throw new Exception(firebaseUser_Null);

      atualizarUser();
      Admin.checkAdmin();
      Log.d(TAG, 'init', 'Firebase OK');
    } catch (e) {
      Log.e(TAG, 'init', e, !e.toString().contains(firebaseUser_Null));
    }
  }

  static Future<void> finalize() async {
    _user = null;
    _userOki = null;
    Admin.finalize();
    await _auth.signOut();
  }

  static Future<void> atualizarUser() async {
    String uid = _user?.uid;
    if (uid == null) return;
    UserOki item = await _baixarUser(uid);
    if (item == null) {
      if (_userOki == null)
        _userOki = UserOki();
    } else {
      _userOki = item;
    }
  }

  //Listas (assistindo, concluidos, favoritos)
  static void _organizarListas(/*User user*/) {
    if (_userOki == null) return;

    for(AnimeCollection item in OnlineData.dataList) {
      if (!userOki.animes.containsKey(item.id)) continue;

      //Os dados de backup.items só contém {classificacao, desc, ultimoAssistido, id}
      //Aqui faço um backup pra restaurar depois
      final backup = AnimeCollection.newItem(userOki.animes[item.id]);
      //_getNewAnimeList(...) retorna somente os itens de minhas listas (favoritos, colcluidos, assistindo)
      //Mas esses items não comtém {classificacao, desc, ultimoAssistido}
      _userOki.animes[item.id] = _getNewAnimeList(item);
      final items = userOki.animes[item.id];

      //Aqui restaura os backups
      if (items != null) {
        for (final item in items.itemsToList) {
          var aux = backup.items[item.idPai];
          if (aux != null) {
            item.desc = aux.desc;
            // item.classificacao = aux.classificacao;
            item.ultimoAssistido = aux.ultimoAssistido;
          }
        }
      }
    }
  }

  static AnimeCollection _getNewAnimeList(AnimeCollection items) {
    AnimeCollection itemsAux = AnimeCollection.fromJson(items.toJson(), items.id);
    itemsAux.items.clear();
    Map assistindoMap = userOki.assistindo[items.id];
    Map concluidosMap = userOki.concluidos[items.id];
    Map favoritosMap = userOki.favoritos[items.id];

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