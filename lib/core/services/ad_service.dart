import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get bannerAdUnitId => dotenv.env['ADMOB_BANNER_ID'] ?? '';
  static String get interstitialAdUnitId =>
      dotenv.env['ADMOB_INTERSTITIAL_ID'] ?? '';
  static String get rewardedAdUnitId => dotenv.env['ADMOB_REWARDED_ID'] ?? '';

  static void initialize() {
    MobileAds.instance.initialize();
  }

  static BannerAd createBanner({required BannerAdListener listener}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener,
    )..load();
  }

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
