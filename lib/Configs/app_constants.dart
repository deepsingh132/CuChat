
import 'dart:ui';
import 'package:CuChat/Configs/Enum.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//*--App Colors : Replace with your own colours---
//-**********---------- WHATSAPP Color Theme: -------------------------
final campusChat = new Color(0xFFDA0037);
final campusChatLight = new Color(0xFFDA0037);
final campusChatLight2 = new Color(0xFF171717);
final bubbleReply = new Color(0xFFDA0037);

final fiberchatBlack = new Color(0xFF1E1E1E);
final fiberchatBlue = new Color(0xFF02ac88);
final fiberchatDeepGreen = new Color(0xFF01826b);
final fiberchatLightGreen = new Color(0xFF02ac88);
final fiberchatgreen = new Color(0xFF01826b);
final fiberchatteagreen = new Color(0xFFe9fedf);
final fiberchatWhite = Colors.white;
final fiberchatGrey = Color(0xff85959f);
final fiberchatChatbackground = new Color(0xffe8ded5);
const DESIGN_TYPE = Themetype.whatsapp;
const IsSplashOnlySolidColor = false;
const SplashBackgroundSolidColor = Color(
    0xFFFFFFFF); ///applies this colors if "IsSplashOnlySolidColor" is set to true. Color Code: 0xFF005f56 for Whatsapp theme & 0xFFFFFFFF for messenger theme.

//-*********---------- MESSENGER Color Theme: ---------------// Remove below comments for Messenger theme //------------
 //final fiberchatBlack = new Color(0xFF353f58);
 //final fiberchatBlue = new Color(0xFF3d9df5);
// final fiberchatDeepGreen = new Color(0xFF296ac6);
// final fiberchatLightGreen = new Color(0xFF036eff);
// final fiberchatgreen = new Color(0xFF06a2ff);
// final fiberchatteagreen = new Color(0xFFe0eaff);
// final fiberchatWhite = Colors.white;
// final fiberchatGrey = Colors.grey;
// final fiberchatChatbackground = new Color(0xffdde6ea);
// const DESIGN_TYPE = Themetype.messenger;
// const IsSplashOnlySolidColor = false;
// const SplashBackgroundSolidColor = Color(
//     0xFFFFFFFF); //applies this colors if "IsSplashOnlySolidColor" is set to true. Color Code: 0xFF005f56 for Whatsapp theme & 0xFFFFFFFF for messenger theme.

//*--Admob Configurations- (By default Test Ad Units pasted)----------
const IsBannerAdShow =
    false; // Set this to 'true' if you want to show Banner ads throughout the app
const Admob_BannerAdUnitID_Android =
    'ca-app-pub-3940256099942544/6300978111'; // Test Id: 'ca-app-pub-3940256099942544/6300978111'
const Admob_BannerAdUnitID_Ios =
    'ca-app-pub-3940256099942544/2934735716'; // Test Id: 'ca-app-pub-3940256099942544/2934735716'
const IsInterstitialAdShow =
    false; // Set this to 'true' if you want to show Interstitial ads throughout the app
const Admob_InterstitialAdUnitID_Android =
    'ca-app-pub-3940256099942544/1033173712'; // Test Id:  'ca-app-pub-3940256099942544/1033173712'
const Admob_InterstitialAdUnitID_Ios =
    'ca-app-pub-3940256099942544/4411468910'; // Test Id: 'ca-app-pub-3940256099942544/4411468910'
const IsVideoAdShow =
    false; // Set this to 'true' if you want to show Video ads throughout the app
const Admob_RewardedAdUnitID_Android =
    'ca-app-pub-3940256099942544/5224354917'; // Test Id: 'ca-app-pub-3940256099942544/5224354917'
const Admob_RewardedAdUnitID_Ios =
    'ca-app-pub-3940256099942544/1712485313'; // Test Id: 'ca-app-pub-3940256099942544/1712485313'
//Also don't forget to Change the Admob App Id in "fiberchat/android/app/src/main/AndroidManifest.xml" & "fiberchat/ios/Runner/Info.plist"

//*--Agora Configurations---
const Agora_APP_IDD =
    'b556c2a2fc1342f49ca0982b2d488d2f'; // Grab it from: https://www.agora.io/en/
const dynamic Agora_TOKEN =
    null; // not required until you have planned to setup high level of authentication of users in Agora.

//*--Giphy Configurations---
const GiphyAPIKey =
    '2IponYHvnwqMs1amB7F8wiOo8P6td0Mf'; // Grab it from: https://developers.giphy.com/

//*--App Configurations---
const Appname =
    'CuChat'; //app name shown evrywhere with the app where required
const DEFAULT_COUNTTRYCODE_ISO =
    'IN'; //default country ISO 2 letter for login screen
const DEFAULT_COUNTTRYCODE_NUMBER =
    '+91'; //default country code number for login screen
const FONTFAMILY_NAME = 'assets/fonts/Ubuntu-Medium.ttf';
// make sure you have registered the font in pubspec.yaml

//--WARNING----- PLEASE DONT EDIT THE BELOW LINES UNLESS YOU ARE A DEVELOPER -------
const SplashPath = 'assets/images/splashscreen.gif';
const AppLogoPath = 'assets/images/applogo.png';
const loginIcon = 'assets/images/appicon.png';
