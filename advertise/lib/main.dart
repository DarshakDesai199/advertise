import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'Home.dart';

/// SDK :-  2.10.4
///
/// Source for native ad :
///
///      https://codelabs.developers.google.com/codelabs/admob-inline-ads-in-flutter#7
///
/// Source for Rewarded ad :
///
///      https://codelabs.developers.google.com/codelabs/admob-ads-in-flutter#8
///

Future<InitializationStatus> _initGoogleMobileAds() {
  // TODO: Initialize Google Mobile Ads SDK
  return MobileAds.instance.initialize();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initGoogleMobileAds();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoScreen(),
    );
  }
}
