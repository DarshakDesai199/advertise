import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  NativeAd? _ad;
  RewardedAd? _rewardedAd;
  bool load = false;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      /// Native Ad

      nativeAds();
    });
    Future.delayed(const Duration(seconds: 3), () {
      _loadRewardedAd();
    });

    super.initState();
  }

  /// Native Ad
  void nativeAds() {
    _ad = NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110',
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() async {
            _ad = ad as NativeAd;
            Future.delayed(Duration.zero, () {
              setState(() {
                load = true;
              });
            });
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );
    _ad!.load();
    setState(() {});
  }

  /// Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
    _rewardedAd!.rewardedAdLoadCallback;
  }

  /// Interstitial Ad
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  void _createInterstitialAd(String id) {
    InterstitialAd.load(
      adUnitId: id,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            _createInterstitialAd(id);
          } else {
            print('Fail to load');
          }
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        /* Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
        );*/
        print('Fail to load');
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void dispose() {
    _ad!.dispose();
    _interstitialAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Text("Native Ad"),
            SizedBox(
              height: 30,
            ),
            load == true
                ? Container(
                    height: 72.0,
                    alignment: Alignment.center,
                    child: AdWidget(ad: _ad!),
                  )
                : Container(
                    color: Colors.yellow,
                    height: 72.0,
                    alignment: Alignment.center,
                    child: Center(child: Text('Native Ad Loading')),
                  ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    if (_rewardedAd != null)
                      _rewardedAd?.show(
                        onUserEarnedReward: (_, reward) {},
                      );
                  },
                  child: Text("Rewarded Ad")),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    _createInterstitialAd(
                        "ca-app-pub-3940256099942544/8691691433");
                  },
                  child: Text("Video Interstitial")),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    _createInterstitialAd(
                        "ca-app-pub-3940256099942544/1033173712");
                  },
                  child: Text("Image Interstitial")),
            )
          ],
        ),
      ),
    );
  }
}
