import 'package:anime/auxiliar/import.dart';

class AdMob {
  static const TAG = 'AdMob';
  static AdMob instance = AdMob();

  BannerAd _banner;

  Future load() async {
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      // keywords: <String>['flutterio', 'Anime'],
      // contentUrl: 'https://flutter.io',
      childDirected: false,
      testDevices: <String>[], // Android emulators are considered test devices
    );
    dispose();
    _banner = BannerAd(
        adUnitId: /*BannerAd.testAdUnitId,*/'ca-app-pub-8585143969698496/1877059427',
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          Log.d('MainPage', 'loadAdMob', "BannerAd event is $event");
          switch(event) {
            case MobileAdEvent.loaded:
              RunTime.mostrandoAds = true;
              break;
            default:
              RunTime.mostrandoAds = false;
          }
        }
    );
    if (await _banner.load())
      await _banner.show();
  }

  void dispose() {
    try {
      _banner?.dispose();
      _banner = null;
      RunTime.mostrandoAds = false;
    } catch (e) {
      Log.e(TAG, 'dispose', e);
    }
  }

  Future<bool> isLoaded() async => _banner?.isLoaded() ?? false;
}
