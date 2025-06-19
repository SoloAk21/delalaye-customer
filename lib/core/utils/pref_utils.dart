import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delalochu/data/models/brandingModel/branding_model.dart';

class PrefUtils {
  static SharedPreferences? sharedPreferences;

  PrefUtils() {
    SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
    });
  }

  Future<void> init() async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    debugPrint('SharedPreference Initialized');
  }

  ///will clear all the data stored in preference
  void clearPreferencesData() async {
    sharedPreferences!.clear();
  }

  Future<void> setThemeData(String value) {
    return sharedPreferences!.setString('themeData', value);
  }

  String getThemeData() {
    try {
      return sharedPreferences!.getString('themeData')!;
    } catch (e) {
      return 'primary';
    }
  }

  Future<void> saveBranding(Branding branding) async {
    await init();
    await sharedPreferences!
        .setString('branding', jsonEncode(branding.toJson()));
  }

  Future<Branding?> loadBranding() async {
    await init();
    final String? brandingJson = sharedPreferences!.getString('branding');
    return brandingJson != null
        ? Branding.fromJson(jsonDecode(brandingJson))
        : null;
  }

  Future<void> setDarkMode(bool value) async {
    await init();
    await sharedPreferences!.setBool('isDarkMode', value);
  }

  Future<bool> getDarkMode() async {
    await init();
    return sharedPreferences!.getBool('isDarkMode') ?? false;
  }
}
