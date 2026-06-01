import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // TEST IDs — replace with real ones before release
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static void initialize() {
    MobileAds.instance.initialize();
  }

  // Banner
  static BannerAd createBanner({required BannerAdListener listener}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener,
    )..load();
  }

  // Interstitial
  static void loadInterstitial({
    required void Function(InterstitialAd ad) onLoaded,
  }) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  // Rewarded
  static void loadRewarded({required void Function(RewardedAd ad) onLoaded}) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (_) {},
      ),
    );
  }
}
