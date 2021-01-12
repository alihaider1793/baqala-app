import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'generated/l10n.dart';
import 'route_generator.dart';
import 'src/helpers/app_config.dart' as config;
import 'src/helpers/custom_trace.dart';
import 'src/models/setting.dart';
import 'src/repository/settings_repository.dart' as settingRepo;
import 'src/repository/user_repository.dart' as userRepo;
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_version/get_version.dart';
// import 'package:connectivity/connectivity.dart';

import 'package:firebase_core/firebase_core.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getBaseURL();

  // initializing app with firebase
  await Firebase.initializeApp();
  print("app initialized");

  await GlobalConfiguration().loadFromAsset("configurations");
  print(CustomTrace(StackTrace.current,
      message: "base_url: ${GlobalConfiguration().getString('base_url')}"));
  print(CustomTrace(StackTrace.current,
      message:
          "api_base_url: ${GlobalConfiguration().getString('api_base_url')}"));
  HttpOverrides.global = new MyHttpOverrides();

  runApp(Phoenix(child: MyApp()));
}

Future<void> getBaseURL() async {
  String baseURL = "";
  String baseAPIURL = "";
  // set up POST request arguments
  String url = 'http://173.249.13.154:8888/api/server-switcher';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json1 = '{"package_name": "com.appllc.baqala"}';
  // make POST request
  Response response = await post(url, headers: headers, body: json1);
  // check the status code for the result
  // this API passes back the id of the new item added to the body
  String body = response.body;
  final res = json.decode(body);
  if (res['status'] == 200 || res['status'] == '200') {
    baseURL = res['data']['server_ip'];
    baseAPIURL = res['data']['server_ip'] + 'api/';
    GlobalConfiguration().updateValue('api_base_url', baseAPIURL);
    GlobalConfiguration().updateValue('base_url', baseURL);
  }
  print('MAIN DART Server Switcher URL: ' + res['data']['server_ip']);
  print('MAIN DART Server Switcher URL base URL: ' +
      GlobalConfiguration().getString('base_url'));
  print('MAIN DART Server Switcher URL base api URL: ' +
      GlobalConfiguration().getString('api_base_url'));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
//  /// Supply 'the Controller' for this application.
//  MyApp({Key key}) : super(con: Controller(), key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Setting settingObject = new Setting();

  void _initPlatformState() async
  {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetVersion.platformVersion;
    } catch (e) {
      print(e);
      platformVersion = 'Failed to get platform version.';
    }

    String projectVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      projectVersion = await GetVersion.projectVersion;
    } catch (e) {
      print(e);
      projectVersion = 'Failed to get project version.';
    }

    String projectCode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      projectCode = await GetVersion.projectCode;
    } catch (e) {
      print(e);
      projectCode = 'Failed to get build number.';
    }

    String projectAppID;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      projectAppID = await GetVersion.appID;
    } catch (e) {
      print(e);
      projectAppID = 'Failed to get app ID.';
    }

    String projectName;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      projectName = await GetVersion.appName;
    } catch (e) {
      print(e);
      projectName = 'Failed to get app name.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

      Setting.platformVersion = platformVersion;
      Setting.projectVersion = projectVersion;
      settingObject.projectCode = projectCode;
      settingObject.projectAppID = projectAppID;
      settingObject.projectName = projectName;

  }

  @override
  void initState() {
    _initPlatformState();
    getBaseURL().then((value) {
      print("in main init .then");
      settingRepo.initSettings();
      settingRepo.getCurrentLocation();
      userRepo.getCurrentUser();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("in main build");
    return ValueListenableBuilder(
        valueListenable: settingRepo.setting,
        builder: (context, Setting _setting, _) {
          return MaterialApp(
              navigatorKey: settingRepo.navigatorKey,
              title: _setting.appName,
              initialRoute: '/Splash',
              onGenerateRoute: RouteGenerator.generateRoute,
              debugShowCheckedModeBanner: false,
              locale: _setting.mobileLanguage.value,
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              theme: _setting.brightness.value == Brightness.light
                  ? ThemeData(
                      fontFamily: 'Gothic',
                      primaryColor: Colors.white,
                      floatingActionButtonTheme: FloatingActionButtonThemeData(
                          elevation: 0, foregroundColor: Colors.white),
                      brightness: Brightness.light,
                      accentColor: config.Colors().mainColor(1),
                      dividerColor: config.Colors().accentColor(0.1),
                      focusColor: config.Colors().accentColor(1),
                      hintColor: config.Colors().secondColor(1),
                      textTheme: TextTheme(
                        headline5: TextStyle(
                            fontSize: 22.0,
                            color: config.Colors().secondColor(1),
                            height: 1.3),
                        headline4: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: config.Colors().secondColor(1),
                            height: 1.3),
                        headline3: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            color: config.Colors().secondColor(1),
                            height: 1.3),
                        headline2: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                            color: config.Colors().mainColor(1),
                            height: 1.4),
                        headline1: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w300,
                            color: config.Colors().secondColor(1),
                            height: 1.4),
                        subtitle1: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            color: config.Colors().secondColor(1),
                            height: 1.3),
                        headline6: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w700,
                            color: config.Colors().mainColor(1),
                            height: 1.3),
                        bodyText2: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: config.Colors().secondColor(1),
                            height: 1.2),
                        bodyText1: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: config.Colors().secondColor(1),
                            height: 1.3),
                        caption: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            color: config.Colors().accentColor(1),
                            height: 1.2),
                      ),
                    )
                  : ThemeData(
                      fontFamily: 'fontFamily',
                      primaryColor: Color(0xFF252525),
                      brightness: Brightness.dark,
                      scaffoldBackgroundColor: Color(0xFF2C2C2C),
                      accentColor: config.Colors().mainDarkColor(1),
                      dividerColor: config.Colors().accentColor(0.1),
                      hintColor: config.Colors().secondDarkColor(1),
                      focusColor: config.Colors().accentDarkColor(1),
                      textTheme: TextTheme(
                        headline5: TextStyle(
                            fontSize: 22.0,
                            color: config.Colors().secondDarkColor(1),
                            height: 1.3),
                        headline4: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: config.Colors().secondDarkColor(1),
                            height: 1.3),
                        headline3: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            color: config.Colors().secondDarkColor(1),
                            height: 1.3),
                        headline2: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                            color: config.Colors().mainDarkColor(1),
                            height: 1.4),
                        headline1: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w300,
                            color: config.Colors().secondDarkColor(1),
                            height: 1.4),
                        subtitle1: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            color: config.Colors().secondDarkColor(1),
                            height: 1.3),
                        headline6: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w700,
                            color: config.Colors().mainDarkColor(1),
                            height: 1.3),
                        bodyText2: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: config.Colors().secondDarkColor(1),
                            height: 1.2),
                        bodyText1: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: config.Colors().secondDarkColor(1),
                            height: 1.3),
                        caption: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            color: config.Colors().secondDarkColor(0.6),
                            height: 1.2),
                      ),
                    ));
        });
  }
}
