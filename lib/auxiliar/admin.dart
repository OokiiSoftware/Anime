import 'package:anime/model/user_oki.dart';
import 'firebase.dart';
import 'logs.dart';

class Admin {
  static const String TAG = 'Admin';

  static Map<String, UserOki> _users = new Map();
  static Map<String, UserOki> get users => _users;
  static List<UserOki> get usersList => _users.values.toList();
  static Map<String, bool> _admins = Map();// <id, isEnabled>

  static bool _isAdmin;
  static bool get isAdmin => _isAdmin ?? false;

  static Future<UserOki> get(String key) async {
    if (_users[key] == null) {
      var item = await baixarUser(key);
      if (item != null)
        add(item);
    }
    return _users[key];
  }
  static void add(UserOki item) {
    _users[item.dados.id] = item;
  }
  static void addAll(Map<String, UserOki> items) {
    _users.addAll(items);
  }
  static void remove(String key) {
    _users.remove(key);
  }
  static void reset() {
    _users.clear();
  }

  static Future<void> baixarUsers() async {
    try {
      var snapshot = await FirebaseOki.database.child(FirebaseChild.USUARIO).once();
      Map<dynamic, dynamic> map = snapshot.value;
      dd(map);
      Log.d(TAG, 'baixa', 'OK');
    } catch (e) {
      Log.e(TAG, 'baixa', e);
    }
  }
  static Future<UserOki> baixarUser(String uid) async {
    try {
      var snapshot = await FirebaseOki.database
          .child(FirebaseChild.USUARIO).child(uid).once();
      UserOki user = UserOki.fromJson(snapshot.value);
      return user;
    } catch (e) {
      Log.e(TAG, 'baixarUser', e);
      return null;
    }
  }
  static void dd(Map<dynamic, dynamic> map) {
    if (map == null)
      return;

    reset();

    for (String key in map.keys) {
      try {
        UserOki item = UserOki.fromJson(map[key]);
        item.dados.id = key;
        add(item);
      } catch(e) {
        Log.e(TAG, 'dd', e);
        continue;
      }
    }
  }

  static Future<void> checkAdmin() async {
    try {
      var snapshot = await FirebaseOki.database.child(FirebaseChild.ADMINISTRADORES).once();
      Map<dynamic, dynamic> map = snapshot.value;
      for (dynamic key in map.keys) {
        _admins[key] = map[key];
      }
      if (_admins.containsKey(FirebaseOki.user.uid))
        _isAdmin = map[FirebaseOki.user.uid];
      if (_isAdmin)
        Admin.init();
    } catch (e) {
      Log.e(TAG, '_checkAdmin', e);
    }
  }

  static void init() async {
    Log.e(TAG, 'init', 'iniciando');
    await baixarUsers();
    Log.d(TAG, 'init', 'OK');
  }
  static void finalize() {
    _isAdmin = false;
    _admins.clear();
  }
}