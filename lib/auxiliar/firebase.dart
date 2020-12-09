import 'dart:io';
import 'package:anime/auxiliar/criptografia.dart';
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

        String decript(String value) => Cript.decript(_dataUrl[value]);

        var appOptions = FirebaseOptions(
          appId: decript('appId'),
          projectId: decript('projectId'),
          messagingSenderId: decript('messagingSenderId'),
          apiKey: decript('apiKey'),
          storageBucket: decript('storageBucket'),
          databaseURL: decript('databaseURL'),
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
    'apiKey': '®PU✕ⅱD❘ⅆZFCー÷KKEⅲ‥W¿ⅉWH‥§Gⅸ✕VℙⅈRFF〝¦Lⅉ⟨IJOⅰ⨉QSⅸ‥L®ⅰEY⟩✕KGH®ⅱB§▁NZⅸ▁TFW¿¦MQ®¦V✕ⅈTO´⨉TE´ℙKBⅉⅈQI[✕ªKⅱ~BONⅆ❘F÷ⅸWⅆⅈZXⅱERGXℚSO§£QQRーℙCDR£ⅉKTOⅸ⟨YHZ÷£C§ⅆW⟩⟩ZUⅈ⟨HEⅲ',
    'appId': Platform.isAndroid ? '✕Yⅸ¿OHT☡ªDℚ⟨T⟨✕SEVℙ,SLF¿⟨NV〝ⅰQHP✕ⅸG~〝Uー⟨Lℚ§V⟩§CMHℚ⟩ZXⅰKBN~ーOEYⅈ❘DY☡ⅉHMV⨉⨉QⅱⅸVYV¦ⅰFBⅰⅆNZQ⨉¦NK⟨‥I®⟩W〝❘Y⟩ⅈCNX⟨Y[WⅉⅲP¿£NC▁¦EQⅆ,ONW❘´P▁‥WNVªⅰOCⅆ~HC[®ⅸF⟩ℙEⅉ〝T‥£C⟩❘FYF⨉¦LDⅉⅸNⅲ÷NBMℚ⨉Cℙ' : '',
    'projectId': 'ⅱEⅱ⟩SOℚℚL☡ーPFY~〝CZ[▁〝CJYℚ´PS⟨⟩RQPℙ‥P¿',
    'databaseURL': 'ⅱZ❘£JIℚⅉM´,WSC⨉☡CPZ▁ⅆTTⅲℚNℙ‥QROⅉ´RGW®⟨HFⅈℚDI÷ªODⅲªLVW〝ⅱGGJ☡⟨KG´☡UPℚ✕PCI¿ⅸFRª£Kℙ⟨CRℙⅸYC,ⅈZP〝XDZⅉ÷TO❘ªKⅱ▁D‥ⅱRR☡ⅈZⅲⅉC£ⅉYZⅉ´HGIⅰ⟨AB®',
    'messagingSenderId': 'ⅈBG~ⅱERGXⅸL,⟨RG✕ⅈWDℙーERMⅸーQFUⅰ£C§☡N÷XYⅰ´YEW‥÷E§ⅰP¿ⅉYⅈ®C❘÷WW¦£Qⅉ®JPQ®▁ZTⅉ~H☡▁WLDX´NUDⅈⅆY[Wⅰ®O▁ℙFHWⅸ⟨JUIX~JH¿XROF÷¦HℙⅈK[´ⅈISV,ⅈCRF⟩´ZH£⟩UUG⨉´TOー§UGV§¿DDZ✕ⅸFKDℙⅱWUY⟨ℙRS§▁CFK®❘AUT£⟨TTⅱ✕YUMⅈ§CG❘§HOWーⅱK§ⅲRK[▁ªVH‥¦VT⨉✕Oー‥DEFª✕DYEⅲ⟨RB⟩ⅉCQVⅸ®EWⅰ⟨WNⅉ⟩ID✕⨉I✕÷H▁ⅲNL⨉ⅆDHℙ¦DⅈⅈI§⟩KBⅸ´S[,ーQ❘❘FOO®®BQZ§ⅰZR§☡CNL~ⅉEⅈ⨉DFFⅆ‥NQ®❘K÷ⅰFHFⅱ®R⟩▁S~ーJℙXRQ¦§EX~SHIªªAIª~DPDⅱ§N®´IWW☡⨉IGⅰ§ZⅱⅸLYWⅰ¦WℚℙBⅈⅲZDFℚℚB÷ⅱIMU〝®VF~✕PB¿ⅰCⅸⅉVM⨉⟩OOPª¿FLK®▁KOⅲⅰORⅱ❘WM[〝ⅱFⅸⅆERTⅸⅰEX¿ZMD〝,OGZªⅸLP☡⨉UDZ⟩ⅱVⅸ÷Kⅈ✕DYEⅲⅆOTH~✕L§÷LKSℚⅈHZJⅰ¿UKCⅉⅲY¿ⅸKQZ,ℚPOG☡¿QKYⅰ¿Uª〝BⅱªPℚªYVQ✕ⅉQDOⅸⅸQ[S¦‥UMIℚXJJ⟨ーIXℚQTYーⅸNM‥´H´¦N´ⅆL¦´YUⅲⅉDDX´NL®¦Mⅆ',
    'storageBucket': 'ªTQUℙ‥Sⅈ‥O☡〝FYC✕⟩VHー÷R£⟨GI®®YⅸⅱL▁⟩PQZ£▁TN⟨ⅰCⅰ,BO´ⅱTFF⟨ⅆZRP¿ーOEYⅈ¦HOK✕ℙQI~¿INI®XPYEℙⅸEJDℚªZªⅆJT✕~IHL❘¿BV£ⅉL§'
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