import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auxiliar/import.dart';
import '../res/import.dart';
import 'import.dart';

class AplicationManager {
  static AplicationManager i = AplicationManager();

  static const String _TAG = 'Aplication';

  int appVersionInDatabase = 0;
  PackageInfo packageInfo;

  bool get isRelease => bool.fromEnvironment('dart.vm.product');
  Locale get locale => Locale('pt', 'BR');

  Future<bool> init({Function(dynamic) onError}) async {
    Log.d(_TAG, 'init', 'iniciando');

    try {
      await Preferences.pref.init();
    } catch(e) {
      Log.e(_TAG, 'Preferences', e);
      onError?.call(e);
      return false;
    }
    try {
      ThemeManager.i.load();
    } catch(e) {
      Log.e(_TAG, 'ThemeManager', e);
      onError?.call(e);
      return false;
    }
    try {
      await StorageManager.i.init();
    } catch(e) {
      Log.e(_TAG, 'StorageManager', e);
      onError?.call(e);
      return false;
    }
    try {
      await FirebaseManager.i.init();
    } catch(e) {
      Log.e(_TAG, 'FirebaseManager', e);
      onError?.call(e);
      return false;
    }
    try {
      // await AdminManager.i.init();//todo
    } catch(e) {
      Log.e(_TAG, 'AdminManager', e);
      onError?.call(e);
    }
    try {
      AnimesManager.i.load();
    } catch(e) {
      Log.e(_TAG, 'AnimesManager', e);
      onError?.call(e);
    }
    try {
      if (!Platform.isWindows)
      packageInfo = await PackageInfo.fromPlatform();
    } catch(e) {
      Log.e(_TAG, 'PackageInfo', e);
      onError?.call(e);
    }
    Log.d(_TAG, 'init', 'OK');
    return true;
  }

  Future<String> buscarAtualizacao() async {
    try {
      // var snapshot = await _firebase.database
      //     .child(FirebaseChild.VERSAO)
      //     .once();
      //
      // int value = snapshot.value;
      //
      // Log.d(_TAG, 'buscarAtualizacao', 'Web Version', value, 'Local Version', packageInfo.buildNumber);
      // appVersionInDatabase = value;
      // int appVersion = int.parse(packageInfo.buildNumber);
      //
      // if (value > appVersion)
      //   return 'https://play.google.com/store/apps/details?id=com.ookiisoftware.anime';

      return null;
    } catch(e) {
      Log.e(_TAG, 'buscarAtualizacao', e);
      return null;
    }

  }

  Future<void> openUrl(String url) async {
    try {
      await launch(url);
    } catch(e) {
      Log.snack(MyErros.ABRIR_LINK, isError: true);
      Log.e(_TAG, 'openUrl', e);
    }
  }

  void openEmail(String email) async {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: '$email',
        queryParameters: {
          'subject': 'Anime App'
        }
    );
    try {
      await launch(_emailLaunchUri.toString());
    } catch(e) {
      Log.snack(MyErros.ABRIR_EMAIL, isError: true);
      Log.e(_TAG, 'openEmail', e);
    }
  }

}