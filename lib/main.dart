import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/api/api_token_refresher.dart';
import 'package:flutterrestaurant/api/ps_api_service.dart';
import 'package:flutterrestaurant/config/ps_theme_data.dart';
import 'package:flutterrestaurant/config/router.dart' as router;
import 'package:flutterrestaurant/provider/common/ps_theme_provider.dart';
import 'package:flutterrestaurant/provider/ps_provider_dependencies.dart';
import 'package:flutterrestaurant/repository/ps_theme_repository.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/language.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_manager/theme_manager.dart';

import 'config/ps_colors.dart';
import 'config/ps_config.dart';
import 'db/common/ps_shared_preferences.dart';
import 'firebase_options.dart';


Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };
  // add this, and it should be the first line in main method
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  if (prefs.getString('codeC') == null) {
    await prefs.setString('codeC', '');
    await prefs.setString('codeL', '');
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb)
  if (Platform.isIOS) {
    FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true
    );
  }
  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  /*Future<void> initializeLocalNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    // app_icon needs to be a added as a drawable resource to the
    // Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid);
        //initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  initializeLocalNotifications();
  Future<void> _createNotificationChannel(String id, String name,
      String description) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidNotificationChannel = AndroidNotificationChannel(
      id,
      name,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }
  _createNotificationChannel('Channel ID', 'name', 'description');*/
 /* if(!kIsWeb) {
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('fcmToken: $fcmToken');
  }*/
  //GoogleApiAvailability.makeGooglePlayServicesAvailable();
  //check is apple signin is available
  if(!kIsWeb)
    await Utils.checkAppleSignInAvailable();
  await EasyLocalization.ensureInitialized();

  runApp(
      EasyLocalization(
      path: 'assets/langs',
      saveLocale: true,
      // startLocale: PsConfig.defaultLanguage.toLocale(),
      supportedLocales: getSupportedLanguages(),
      child: PSApp()));
}

List<Locale> getSupportedLanguages() {
  final List<Locale> localeList = <Locale>[];
  for (final Language lang in PsConfig.psSupportedLanguageList) {
    localeList.add(Locale(lang.languageCode!, lang.countryCode));
  }
  print('Loaded Languages');
  return localeList;
}

class PSApp extends StatefulWidget {
  static final ApiTokenRefresher apiTokenRefresher = ApiTokenRefresher(psApiService: PsApiService());
  @override
  _PSAppState createState() => _PSAppState();
}

// Future<dynamic> initAds() async {
//   if (PsConfig.showAdMob && await Utils.checkInternetConnectivity()) {
//     // FirebaseAdMob.instance.initialize(appId: Utils.getAdAppId());
//   }
// }

class _PSAppState extends State<PSApp> {
  Completer<ThemeData>? themeDataCompleter;
  PsSharedPreferences? psSharedPreferences;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(PSApp.apiTokenRefresher);
    super.initState();
    
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(PSApp.apiTokenRefresher);
    print('disposed called');
    super.dispose();
  }

  Future<ThemeData> getSharePerference(
      EasyLocalization provider, dynamic data) {
    Utils.psPrint('>> get share perference');
    if (themeDataCompleter == null) {
      Utils.psPrint('init completer');
      themeDataCompleter = Completer<ThemeData>();
    }

    if (psSharedPreferences == null) {
      Utils.psPrint('init ps shared preferences');
      psSharedPreferences = PsSharedPreferences.instance;
      Utils.psPrint('get shared');
      //SharedPreferences sh = await
      psSharedPreferences!.futureShared.then((SharedPreferences sh) {
        psSharedPreferences!.shared = sh;

        Utils.psPrint('init theme provider');
        final PsThemeProvider psThemeProvider = PsThemeProvider(
            repo: PsThemeRepository(psSharedPreferences: psSharedPreferences!));

        Utils.psPrint('get theme');
        final ThemeData themeData = psThemeProvider.getTheme();

        themeDataCompleter!.complete(themeData);
        Utils.psPrint('theme data loading completed');
      });
    }
    return themeDataCompleter!.future;
  }

  List<Locale> getSupportedLanguages() {
    final List<Locale> localeList = <Locale>[];
    for (final Language lang in PsConfig.psSupportedLanguageList) {
      localeList.add(Locale(lang.languageCode!, lang.countryCode));
    }
    print('Loaded Languages');
    return localeList;
  }

  @override
  Widget build(BuildContext context) {


    PsColors.loadColor(context);
    return MultiProvider(
        providers: <SingleChildWidget>[
          ...providers,

        ],
        child: ThemeManager(
              defaultBrightnessPreference: BrightnessPreference.light,
              data: (Brightness brightness) {
                if (brightness == Brightness.light) {

                  return themeData(ThemeData.light());
                } else {
                  return themeData(ThemeData.dark());
                }
              },
              loadBrightnessOnStart: true,
              themedWidgetBuilder: (BuildContext context, ThemeData theme) {
                return MaterialApp(
                  builder: (context, widget) {
                    Widget error = const Text('...loading...');
                    if (widget is Scaffold || widget is Navigator) {
                      error = Scaffold(body: Center(child: error));
                    }
                    ErrorWidget.builder = (errorDetails) => error;
                    if (widget != null) return widget;
                    throw StateError('widget is null');
                  },
                  debugShowCheckedModeBanner: false,
                  title: 'IT Retail-Software',
                  theme: theme,
                  themeMode: ThemeMode.system,
                  initialRoute: '/',
                  onGenerateRoute: router.generateRoute,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: EasyLocalization.of(context)!.supportedLocales,
                  locale: EasyLocalization.of(context)!.locale,
                );
              }
          )
      );
  }
}
