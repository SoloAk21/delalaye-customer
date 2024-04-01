// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:delalochu/localization/lang_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_export.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]),
  ]).then((value) async {
    PrefUtils().init();
    var languageProvider = LanguageProvider();
    await languageProvider.init();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isLoggedIn = (prefs.getBool('isLoggedIn') == null)
        ? false
        : prefs.getBool('isLoggedIn');
    HttpOverrides.global = MyHttpOverrides();

    runApp(MyApp(isLoggedIn: isLoggedIn!));
  });
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({
    Key? key,
    required this.isLoggedIn,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ],
          child:  Consumer2<ThemeProvider, LanguageProvider>(
            builder: (context, provider, languageProvider, child) {
              print('currentLocale ${languageProvider.currentLocale}');
              return MaterialApp(
                theme: theme,
                title: 'delalochu',
                navigatorKey: NavigatorService.navigatorKey,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [
                  AppLocalizationDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: [
                  Locale('en', ''),
                  Locale('am', ''),
                  Locale('da', ''),
                ],
                locale:Locale(PrefUtils.sharedPreferences?.getString('language_code') ?? 'en','') ,
                initialRoute: AppRoutes.initialRoute,
                routes: AppRoutes.routes,
              );
            },
          ),
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
