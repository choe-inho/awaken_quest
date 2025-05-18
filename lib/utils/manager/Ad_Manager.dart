// lib/utils/ad/ad_manager.dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../manager/Import_Manager.dart';

class AdManager {
  // 싱글톤 패턴
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // 광고 관련 상태 변수
  RxBool rewardAvailable = false.obs;
  DateTime? lastInterstitialTime;
  DateTime? lastRewardedTime;

  // 광고 ID (실제 앱에서는 이 값들을 실제 AdMob ID로 변경)
  final String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // 테스트 ID
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // 실제 ID

  final String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // 테스트 ID
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // 실제 ID

  final String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // 테스트 ID
      : 'ca-app-pub-1383239433512849/4277155306'; // 실제 ID

  // 광고 객체
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // 배너 광고 로드
  Future<BannerAd?> loadBannerAd() async {
    if (_bannerAd != null) {
      return _bannerAd;
    }

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('배너 광고 로드 성공');
        },
        onAdFailedToLoad: (ad, error) {
          print('배너 광고 로드 실패: $error');
          ad.dispose();
          _bannerAd = null;
        },
        onAdOpened: (ad) => print('배너 광고가 열렸습니다'),
        onAdClosed: (ad) => print('배너 광고가 닫혔습니다'),
        onAdImpression: (ad) => print('배너 광고 노출'),
      ),
    );

    await _bannerAd?.load();
    return _bannerAd;
  }

  // 전면 광고 로드
  Future<void> loadInterstitialAd() async {
    if (_interstitialAd != null) return;

    // 광고 표시 간격 제한 (5분)
    if (lastInterstitialTime != null) {
      final difference = DateTime.now().difference(lastInterstitialTime!);
      if (difference.inMinutes < 5) {
        print('전면 광고 표시 제한 시간: ${5 - difference.inMinutes}분 남음');
        return;
      }
    }

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('전면 광고 로드 성공');
          _interstitialAd = ad;
          _setupInterstitialCallbacks();
        },
        onAdFailedToLoad: (error) {
          print('전면 광고 로드 실패: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  // 전면 광고 콜백 설정
  void _setupInterstitialCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('전면 광고 표시됨'),
      onAdDismissedFullScreenContent: (ad) {
        print('전면 광고 닫힘');
        ad.dispose();
        _interstitialAd = null;
        // 다음 광고 미리 로드
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('전면 광고 표시 실패: $error');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
      onAdImpression: (ad) => print('전면 광고 노출'),
    );
  }

  // 보상형 광고 로드
  Future<void> loadRewardedAd() async {
    if (_rewardedAd != null) return;

    // 광고 표시 간격 제한 (10분)
    if (lastRewardedTime != null) {
      final difference = DateTime.now().difference(lastRewardedTime!);
      if (difference.inMinutes < 10) {
        print('보상형 광고 표시 제한 시간: ${10 - difference.inMinutes}분 남음');
        rewardAvailable.value = false;
        return;
      }
    }

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('보상형 광고 로드 성공');
          _rewardedAd = ad;
          rewardAvailable.value = true;
          _setupRewardedCallbacks();
        },
        onAdFailedToLoad: (error) {
          print('보상형 광고 로드 실패: $error');
          _rewardedAd = null;
          rewardAvailable.value = false;
        },
      ),
    );
  }

  // 보상형 광고 콜백 설정
  void _setupRewardedCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('보상형 광고 표시됨'),
      onAdDismissedFullScreenContent: (ad) {
        print('보상형 광고 닫힘');
        ad.dispose();
        _rewardedAd = null;
        rewardAvailable.value = false;
        // 다음 광고 미리 로드
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('보상형 광고 표시 실패: $error');
        ad.dispose();
        _rewardedAd = null;
        rewardAvailable.value = false;
        loadRewardedAd();
      },
      onAdImpression: (ad) => print('보상형 광고 노출'),
    );
  }

  // 전면 광고 표시
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd == null) {
      await loadInterstitialAd();
      if (_interstitialAd == null) {
        return false;
      }
    }

    _interstitialAd?.show();
    lastInterstitialTime = DateTime.now();
    return true;
  }

  // 보상형 광고 표시
  Future<bool> showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
  }) async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
      if (_rewardedAd == null) {
        return false;
      }
    }

    _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        print('보상 획득: ${reward.amount} ${reward.type}');
        lastRewardedTime = DateTime.now();
        onUserEarnedReward(reward);
      },
    );

    return true;
  }

  // 광고 리소스 해제
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
  }
}