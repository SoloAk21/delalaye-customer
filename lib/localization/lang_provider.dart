import 'package:flutter/material.dart';

import '../core/utils/pref_utils.dart';

class LanguageProvider extends ChangeNotifier {
  Locale? _currentLocale = Locale('en', '');

  Locale? get currentLocale => _currentLocale;

  Future<void> init() async {
    // Initialize the selected language from shared preferences
   // SharedPreferences pref .getInstance();
   print('currentLocale is ${PrefUtils.sharedPreferences?.getString('language_code')??'muhi'}');
    String? languageCode =
        PrefUtils.sharedPreferences?.getString('language_code') ?? 'en';
    _currentLocale = Locale(languageCode, '');
  }

  Future<void> changeLanguage(Locale newLocale) async {
    print('this ====> ${newLocale.languageCode}');
    _currentLocale = newLocale;
    // Persist the selected language to shared preferences
    PrefUtils.sharedPreferences!
        .setString('language_code', '${newLocale.languageCode}');
        print('currentLocale fromm Change is ${PrefUtils.sharedPreferences?.getString('language_code')??'muhi'}');
    notifyListeners();
  }
}
