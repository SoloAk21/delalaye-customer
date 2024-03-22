import 'package:flutter/material.dart';
import 'package:delalochu/presentation/splashscreen_screen/splashscreen_screen.dart';
import 'package:delalochu/presentation/categoryscreentwo_screen/categoryscreentwo_screen.dart';
import 'package:delalochu/presentation/loginscreen_screen/loginscreen_screen.dart';
import 'package:delalochu/presentation/signupscreen_screen/signupscreen_screen.dart';
import 'package:delalochu/presentation/categoryscreenone_screen/categoryscreenone_screen.dart';
import 'package:delalochu/presentation/homescreen_screen/homescreen_screen.dart';
import 'package:delalochu/presentation/categoryscreen_screen/categoryscreen_screen.dart';
import 'package:delalochu/presentation/profilescreen_screen/profilescreen_screen.dart';
import 'package:delalochu/presentation/historyscreen_screen/historyscreen_screen.dart';
import 'package:delalochu/presentation/selectcategoryscreen_screen/selectcategoryscreen_screen.dart';
import 'package:delalochu/presentation/app_navigation_screen/app_navigation_screen.dart';

import '../presentation/forgotPassword/forgotpassword_screen.dart';
import '../presentation/forgotPassword/otpcodeverification_screen.dart';

class AppRoutes {
  static const String splashscreenScreen = '/splashscreen_screen';

  static const String categoryscreentwoScreen = '/categoryscreentwo_screen';

  static const String loginscreenScreen = '/loginscreen_screen';

  static const String signupscreenScreen = '/signupscreen_screen';

  static const String forgotpasswordScreen = '/forgotPassword_screen';

  static const String otpcodeverificationscreen = '/otpcodeverification_screen';

  static const String categoryscreenoneScreen = '/categoryscreenone_screen';

  static const String homescreenScreens = '/homescreen_screen';

  static const String homescreenwithbottomshitoneScreen =
      '/homescreenwithbottomshitone_screen';

  static const String homescreenwithbottomshittwoScreen =
      '/homescreenwithbottomshittwo_screen';

  static const String categoryscreenScreen = '/categoryscreen_screen';

  static const String profilescreenScreen = '/profilescreen_screen';

  static const String historyscreenScreen = '/historyscreen_screen';

  static const String selectcategoryscreenScreen =
      '/selectcategoryscreen_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static const String initialRoute = '/initialRoute';

  static Map<String, WidgetBuilder> get routes => {
        splashscreenScreen: SplashscreenScreen.builder,
        categoryscreentwoScreen: CategoryscreentwoScreen.builder,
        loginscreenScreen: LoginscreenScreen.builder,
        signupscreenScreen: SignupscreenScreen.builder,
        forgotpasswordScreen: ForgotPasswordScreen.builder,
        otpcodeverificationscreen: OTPCodeVerificationScreen.builder,
        categoryscreenoneScreen: CategoryscreenoneScreen.builder,
        homescreenScreens: HomescreenScreen.builder,
        categoryscreenScreen: CategoryscreenScreen.builder,
        profilescreenScreen: ProfilescreenScreen.builder,
        historyscreenScreen: HistoryscreenScreen.builder,
        selectcategoryscreenScreen: SelectcategoryscreenScreen.builder,
        appNavigationScreen: AppNavigationScreen.builder,
        initialRoute: SplashscreenScreen.builder
      };
}
