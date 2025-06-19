import 'package:flutter/material.dart';
import '../../core/app_export.dart';

/// Helper class for managing themes and colors.
class ThemeHelper {
  // The current app theme
  var _appTheme = PrefUtils().getThemeData();

  // A map of custom color themes supported by the app
  final Map<String, PrimaryColors> _supportedCustomColor = {
    'primary': PrimaryColors()
  };

  // A map of color schemes supported by the app
  final Map<String, ColorScheme> _supportedColorScheme = {
    'primary': ColorSchemes.primaryColorScheme
  };

  /// Returns the primary colors for the current theme.
  PrimaryColors _getThemeColors() {
    if (!_supportedCustomColor.containsKey(_appTheme)) {
      throw Exception(
          "$_appTheme is not found. Make sure you have added this theme class in JSON. Try running flutter pub run build_runner");
    }
    return _supportedCustomColor[_appTheme] ?? PrimaryColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    if (!_supportedColorScheme.containsKey(_appTheme)) {
      throw Exception(
          "$_appTheme is not found. Make sure you have added this theme class in JSON. Try running flutter pub run build_runner");
    }

    final colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.primaryColorScheme;

    return _buildThemeData(colorScheme);
  }

  /// Builds theme data from color scheme
  ThemeData _buildThemeData(ColorScheme colorScheme) {
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      scaffoldBackgroundColor: appTheme.whiteA700,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.h),
          ),
          shadowColor: appTheme.black900.withOpacity(0.25),
          elevation: 0,
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.primary,
          side: BorderSide(
            color: colorScheme.primary,
            width: 1.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.h),
          ),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        space: 1,
        color: appTheme.gray50,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      }),
    );
  }

  /// Returns dynamic theme data based on context (supports dark mode and branding)
  ThemeData getDynamicThemeData(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final branding = themeProvider.branding;
    final isDarkMode = themeProvider.isDarkMode;

    debugPrint("Branding fetched: ${branding?.toJson()}");

    final colorScheme = ColorScheme(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primary: Color(int.parse(
          branding?.primaryColor.replaceFirst('#', '0xFF') ?? '0xFFCC5B09')),
      onPrimary: isDarkMode ? Colors.white : Color(0xFF1E1E1E),
      secondary: Color(int.parse(
          branding?.secondaryColor.replaceFirst('#', '0xFF') ?? '0xFFFFA05B')),
      onSecondary: isDarkMode ? Colors.white : Color(0xFF1E1E1E),
      surface: isDarkMode ? Color(0xFF121212) : Colors.white,
      onSurface: isDarkMode ? Colors.white : Colors.black,
      background: isDarkMode ? Color(0xFF121212) : Colors.white,
      onBackground: isDarkMode ? Colors.white : Colors.black,
      error: Color(0xFFF61A4E),
      onError: Colors.white,
    );

    return _buildThemeData(colorScheme).copyWith(
      scaffoldBackgroundColor: colorScheme.background,
      dividerTheme: DividerThemeData(
        thickness: 1,
        space: 1,
        color: isDarkMode ? Color(0xFF333333) : appTheme.gray50,
      ),
    );
  }

  /// Returns the primary colors for the current theme.
  PrimaryColors themeColor() => _getThemeColors();

  /// Returns the current theme data (static).
  ThemeData themeData() => _getThemeData();

  /// Returns the dynamic theme data (with dark mode and branding support).
  ThemeData themeDataDynamic(BuildContext context) =>
      getDynamicThemeData(context);
}

/// Class containing the supported text theme styles.
class TextThemes {
  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(
        bodyLarge: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 16.fSize,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w300,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.brightness == Brightness.dark
              ? colorScheme.onBackground.withOpacity(0.7)
              : appTheme.blueGray400,
          fontSize: 14.fSize,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        displayMedium: TextStyle(
          color: colorScheme.brightness == Brightness.dark
              ? colorScheme.onBackground.withOpacity(0.7)
              : appTheme.blueGray400,
          fontSize: 40.fSize,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          color: colorScheme.secondary,
          fontSize: 32.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w900,
        ),
        headlineSmall: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 24.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        titleLarge: TextStyle(
          color: colorScheme.brightness == Brightness.dark
              ? colorScheme.onBackground.withOpacity(0.7)
              : appTheme.blueGray400,
          fontSize: 20.fSize,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        titleMedium: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 16.fSize,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: colorScheme.brightness == Brightness.dark
              ? colorScheme.onBackground.withOpacity(0.5)
              : appTheme.gray40001,
          fontSize: 14.fSize,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      );
}

/// Class containing the supported color schemes.
class ColorSchemes {
  static final primaryColorScheme = ColorScheme.light(
    // Primary colors
    primary: Color(0XFFCC5B09),
    onPrimary: Color(0XFF1E1E1E),
    onPrimaryContainer: Color(0XFFFFA05B),
  );
}

/// Class containing custom colors for a primary theme.
class PrimaryColors {
  // Getter methods that use the theme's color scheme
  Color primary(BuildContext context) => Theme.of(context).colorScheme.primary;
  Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;
  Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  Color onSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondary;

  // Static colors
  Color get black900 => Color(0XFF000000);
  Color get blueGray400 => Color(0XFF888888);
  Color get blueGray50 => Color(0XFFF1F1F1);
  Color get gray400 => Color(0XFFC4C4C4);
  Color get gray40001 => Color(0XFFC5C5C5);
  Color get gray50 => Color(0XFFF9F9F9);
  Color get gray500 => Color(0XFFA1A1AA);
  Color get gray800 => Color(0XFF4E4E4E);
  Color get greenA700 => Color(0XFF00B628);
  Color get lime900 => Color(0XFF7B3D02);
  Color get redA400 => Color(0XFFF61A4E);
  Color get whiteA700 => Color(0XFFFFFFFF);

  // Deprecated - use primary() instead
  @Deprecated('Use primary() method that respects theme')
  Color get orangeA200 => ThemeHelper().themeData().colorScheme.primary;
}

PrimaryColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();
