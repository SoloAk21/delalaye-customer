import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delalochu/data/models/brandingModel/branding_model.dart';
import 'package:delalochu/domain/apiauthhelpers/apiauth.dart';
import '../../core/utils/pref_utils.dart';

class ThemeProvider extends ChangeNotifier {
  Branding? _branding;
  bool _isDarkMode = false;

  Branding? get branding => _branding;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadBranding();
    _loadThemePreference();
  }

  // Load branding data from API
  Future<void> _loadBranding() async {
    try {
      _branding = await ApiAuthHelper.getBranding();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading branding: $e');
    }
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode =
        prefs.getBool('isDarkMode') ?? _branding?.darkModeDefault ?? false;
    notifyListeners();
  }

  // Toggle dark mode and persist it
  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Save theme string using PrefUtils (your original requirement)
  Future<void> setThemeData(String themeType) async {
    await PrefUtils().setThemeData(themeType);
    notifyListeners();
  }
}
