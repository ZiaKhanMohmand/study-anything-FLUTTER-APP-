import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String bannerAdUnitId = 'ca-app-pub-4604628624077755/9215439214';
  static const String interstitialAdUnitId =
      'ca-app-pub-4604628624077755/2969064835';
  static const String rewardedAdUnitId =
      'ca-app-pub-4604628624077755/4613318998';

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
