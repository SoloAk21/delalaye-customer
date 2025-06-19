// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/provider/theme_provider.dart';

class CustomImageView extends StatelessWidget {
  ///[imagePath] is required parameter for showing image
  String? imagePath;

  double? height;
  double? width;
  Color? color;
  BoxFit? fit;
  final String placeHolder;
  Alignment? alignment;
  VoidCallback? onTap;
  EdgeInsetsGeometry? margin;
  BorderRadius? radius;
  BoxBorder? border;

  ///a [CustomImageView] it can be used for showing any type of images
  /// it will shows the placeholder image if image is not found on network image
  CustomImageView({
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.placeHolder = 'assets/images/image_not_found.png',
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final logo = themeProvider.isDarkMode
        ? themeProvider.branding?.logoDark
        : themeProvider.branding?.logoLight;

    // Use the theme logo if available, otherwise fall back to the provided imagePath
    final effectiveImagePath = logo ?? imagePath;

    return alignment != null
        ? Align(
            alignment: alignment!,
            child: _buildWidget(effectiveImagePath),
          )
        : _buildWidget(effectiveImagePath);
  }

  Widget _buildWidget(String? effectiveImagePath) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: _buildCircleImage(effectiveImagePath),
      ),
    );
  }

  ///build the image with border radius
  _buildCircleImage(String? effectiveImagePath) {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: _buildImageWithBorder(effectiveImagePath),
      );
    } else {
      return _buildImageWithBorder(effectiveImagePath);
    }
  }

  ///build the image with border and border radius style
  _buildImageWithBorder(String? effectiveImagePath) {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: _buildImageView(effectiveImagePath),
      );
    } else {
      return _buildImageView(effectiveImagePath);
    }
  }

  Widget _buildImageView(String? effectiveImagePath) {
    if (effectiveImagePath != null) {
      switch (effectiveImagePath.imageType) {
        case ImageType.svg:
          return Container(
            height: height,
            width: width,
            child: SvgPicture.asset(
              effectiveImagePath,
              height: height,
              width: width,
              fit: fit ?? BoxFit.contain,
              colorFilter:
                  ColorFilter.mode(color ?? Colors.black, BlendMode.srcIn),
            ),
          );
        case ImageType.file:
          return Image.file(
            File(effectiveImagePath),
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
          );
        case ImageType.network:
          return CachedNetworkImage(
            height: height,
            width: width,
            fit: fit,
            imageUrl: effectiveImagePath,
            color: color,
            placeholder: (context, url) => Container(
              height: 30,
              width: 30,
              child: LinearProgressIndicator(
                color: Colors.grey.shade200,
                backgroundColor: Colors.grey.shade100,
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              placeHolder,
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
            ),
          );
        case ImageType.png:
        default:
          return Image.asset(
            effectiveImagePath,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
          );
      }
    }
    return Image.asset(
      placeHolder,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
    );
  }
}

extension ImageTypeExtension on String {
  ImageType get imageType {
    if (this.startsWith('http') || this.startsWith('https')) {
      return ImageType.network;
    } else if (this.endsWith('.svg')) {
      return ImageType.svg;
    } else if (this.startsWith('file://')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, file, unknown }
