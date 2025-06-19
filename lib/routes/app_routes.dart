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
import 'package:delalochu/presentation/forgotPassword/forgotpassword_screen.dart';
import 'package:delalochu/presentation/forgotPassword/otpcodeverification_screen.dart';
import 'package:provider/provider.dart';
import 'package:delalochu/theme/provider/theme_provider.dart';

class AppRoutes {
  // Route names
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
  static const String settingsScreen = '/settings_screen';

  // Route generator with theme management
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashscreenScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(SplashscreenScreen.builder(context)),
          settings: settings,
        );
      case categoryscreentwoScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(CategoryscreentwoScreen.builder(context)),
          settings: settings,
        );
      case loginscreenScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(LoginscreenScreen.builder(context)),
          settings: settings,
        );
      case signupscreenScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(SignupscreenScreen.builder(context)),
          settings: settings,
        );
      case forgotpasswordScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(ForgotPasswordScreen.builder(context)),
          settings: settings,
        );
      case otpcodeverificationscreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(OTPCodeVerificationScreen.builder(context)),
          settings: settings,
        );
      case categoryscreenoneScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(CategoryscreenoneScreen.builder(context)),
          settings: settings,
        );
      case homescreenScreens:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(HomescreenScreen.builder(context)),
          settings: settings,
        );
      case categoryscreenScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(CategoryscreenScreen.builder(context)),
          settings: settings,
        );
      case profilescreenScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(ProfilescreenScreen.builder(context)),
          settings: settings,
        );
      case historyscreenScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(HistoryscreenScreen.builder(context)),
          settings: settings,
        );
      case selectcategoryscreenScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(SelectcategoryscreenScreen.builder(context)),
          settings: settings,
        );
      case appNavigationScreen:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(AppNavigationScreen.builder(context)),
          settings: settings,
        );
      case initialRoute:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(SplashscreenScreen.builder(context)),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) =>
              _wrapWithTheme(SplashscreenScreen.builder(context)),
          settings: settings,
        );
    }
  }

  // Helper method to wrap widgets with ThemeProvider
  static Widget _wrapWithTheme(Widget child) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: child,
    );
  }

  // Static routes map (alternative to generateRoute)
  static Map<String, WidgetBuilder> get routes => {
        splashscreenScreen: (context) =>
            _wrapWithTheme(SplashscreenScreen.builder(context)),
        categoryscreentwoScreen: (context) =>
            _wrapWithTheme(CategoryscreentwoScreen.builder(context)),
        loginscreenScreen: (context) =>
            _wrapWithTheme(LoginscreenScreen.builder(context)),
        signupscreenScreen: (context) =>
            _wrapWithTheme(SignupscreenScreen.builder(context)),
        forgotpasswordScreen: (context) =>
            _wrapWithTheme(ForgotPasswordScreen.builder(context)),
        otpcodeverificationscreen: (context) =>
            _wrapWithTheme(OTPCodeVerificationScreen.builder(context)),
        categoryscreenoneScreen: (context) =>
            _wrapWithTheme(CategoryscreenoneScreen.builder(context)),
        homescreenScreens: (context) =>
            _wrapWithTheme(HomescreenScreen.builder(context)),
        categoryscreenScreen: (context) =>
            _wrapWithTheme(CategoryscreenScreen.builder(context)),
        profilescreenScreen: (context) =>
            _wrapWithTheme(ProfilescreenScreen.builder(context)),
        historyscreenScreen: (context) =>
            _wrapWithTheme(HistoryscreenScreen.builder(context)),
        selectcategoryscreenScreen: (context) =>
            _wrapWithTheme(SelectcategoryscreenScreen.builder(context)),
        appNavigationScreen: (context) =>
            _wrapWithTheme(AppNavigationScreen.builder(context)),
        initialRoute: (context) =>
            _wrapWithTheme(SplashscreenScreen.builder(context)),
      };
}
