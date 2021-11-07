// import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../auxiliar/import.dart';
// import 'import.dart';

class AdMobManager {
  static const _TAG = 'AdMobManager';
  static AdMobManager i = AdMobManager();

  final List<Function(bool)> _changeListener = [];

  // BannerAd _banner;

  Future load() async {
    // MobileAds.instance.initialize();

    // AdRequest request = AdRequest();
    // await dispose();
    // String adUnitId;
    // if (!AplicationManager.i.isRelease /*|| AdminManager.i.isAdmin*/)//todo
    //   adUnitId = BannerAd.testAdUnitId;
    // else
    //   adUnitId = 'ca-app-pub-8585143969698496/1877059427';

    // _banner = BannerAd(
    //     adUnitId: adUnitId,
    //     size: AdSize.banner,
    //     request: request,
    //     listener: BannerAdListener(
    //       onAdClosed: _setFalse,
    //       onAdFailedToLoad: _setFalse,
    //       onAdImpression: _setTrue,
    //     )
    // );
    // if (await _banner.load())
    //   await _banner.show();
  }

  Future dispose() async {
    try {
      // await _banner?.dispose();
      // _banner = null;
    } catch (e) {
      Log.e(_TAG, 'dispose', e);
    }
  }

  void addListener(Function(bool) item) {
    if (!_changeListener.contains(item))
      _changeListener.add(item);
  }
  void removeListener(Function(bool) item) {
    _changeListener.remove(item);
  }

  // void _callListener(bool b) {
  //   _changeListener.forEach((item) {
  //     item?.call(b);
  //   });
  //   Log.d(_TAG, 'callListener', "");
  // }

  // void _setTrue(Ad ad) {
  //   _callListener(true);
  // }
  // void _setFalse(Ad ad, [dynamic e]) {
  //   _callListener(false);
  // }

  Future<bool> isLoaded() async => /*await _banner?.isLoaded() ??*/ false;
}
