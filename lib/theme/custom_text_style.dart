import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A collection of pre-defined text styles for customizing text appearance,
/// categorized by different font families and weights.
/// Additionally, this class includes extensions on [TextStyle] to easily apply specific font families to text.

class CustomTextStyles {
  // Body text style
  static get bodyLargeBluegray400 => theme.textTheme.bodyLarge!.copyWith(
        color: appTheme.blueGray400,
        fontWeight: FontWeight.w400,
      );
  static get bodyLargeInterWhiteA700 =>
      theme.textTheme.bodyLarge!.inter.copyWith(
        color: appTheme.whiteA700,
        fontWeight: FontWeight.w400,
      );
  static get bodyLargeNunitoSansGray800 =>
      theme.textTheme.bodyLarge!.nunitoSans.copyWith(
        color: appTheme.gray800,
        fontWeight: FontWeight.w400,
      );
  static get bodyLargeOnPrimaryContainer => theme.textTheme.bodyLarge!.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w400,
      );
  static get bodyLargeRobotoBlack900 =>
      theme.textTheme.bodyLarge!.roboto.copyWith(
        color: appTheme.black900.withOpacity(0.6),
        fontWeight: FontWeight.w400,
      );
  static get bodyMediumBlack900 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.black900,
        fontSize: 15.fSize,
        fontWeight: FontWeight.w300,
      );
  static get bodyMediumBlack900Light => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w300,
      );
  static get bodyMediumBlack900_1 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.black900,
      );
  static get bodyMediumGray40001 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray40001,
      );
  static get bodyMediumOnPrimary => theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.onPrimary,
      );
  // Headline text style
  static get headlineLargeWhiteA700 => theme.textTheme.headlineLarge!.copyWith(
        color: appTheme.whiteA700,
      );
  static get headlineSmallPoppinsBlack900 =>
      theme.textTheme.headlineSmall!.poppins.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w500,
      );
  static get headlineSmallPoppinsBluegray400 =>
      theme.textTheme.headlineSmall!.poppins.copyWith(
        color: appTheme.blueGray400,
        fontWeight: FontWeight.w500,
      );
  // Title text style
  static get titleLargeGray500 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.gray500,
        fontWeight: FontWeight.w500,
      );
  static get titleLargeInterOrangeA200 =>
      theme.textTheme.titleLarge!.inter.copyWith(
        color: appTheme.orangeA200,
        fontWeight: FontWeight.w900,
      );
  static get titleLargeInterWhiteA700 =>
      theme.textTheme.titleLarge!.inter.copyWith(
        color: appTheme.whiteA700,
        fontWeight: FontWeight.w900,
      );
  static get titleLargeInterWhiteA700SemiBold =>
      theme.textTheme.titleLarge!.inter.copyWith(
        color: appTheme.whiteA700,
        fontWeight: FontWeight.w600,
      );
  static get titleLargeInterWhiteA700_1 =>
      theme.textTheme.titleLarge!.inter.copyWith(
        color: appTheme.whiteA700,
      );
  static get titleLargeWhiteA700 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.whiteA700,
      );
  static get titleMediumBluegray400 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blueGray400,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumInter => theme.textTheme.titleMedium!.inter;
  static get titleMediumInterMedium =>
      theme.textTheme.titleMedium!.inter.copyWith(
        fontWeight: FontWeight.w500,
      );
  static get titleMediumOrangeA200 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.orangeA200,
      );
  static get titleMediumOrangeA200Medium =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.orangeA200,
        fontWeight: FontWeight.w500,
      );
}

extension on TextStyle {
  TextStyle get nunitoSans {
    return copyWith(
      fontFamily: 'Nunito Sans',
    );
  }

  TextStyle get poppins {
    return copyWith(
      fontFamily: 'Poppins',
    );
  }

  TextStyle get roboto {
    return copyWith(
      fontFamily: 'Roboto',
    );
  }

  TextStyle get inter {
    return copyWith(
      fontFamily: 'Inter',
    );
  }
}
