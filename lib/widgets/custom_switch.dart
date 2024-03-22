// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';

import 'package:delalochu/core/app_export.dart';

class CustomSwitch extends StatelessWidget {
  CustomSwitch({
    Key? key,
    this.alignment,
    this.value,
    required this.onChange,
    this.width,
    this.height,
    this.margin,
  }) : super(
              key: key,
            );

  final Alignment? alignment;
 final  bool? value;

  final Function(bool) onChange;

  final double? width;

  final double? height;

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        margin: margin,
        child: alignment != null
            ? Align(
                alignment: alignment ?? Alignment.center,
                child: switchWidget,
              )
            : switchWidget);
  }

  Widget get switchWidget => CupertinoSwitch(
        value: value ?? false,
        trackColor: (value ?? false)? appTheme.greenA700:appTheme.gray500,
        thumbColor: (value ?? false) ? appTheme.whiteA700 : appTheme.whiteA700,
        activeColor: appTheme.greenA700,
        onChanged: (value) {
          onChange(value);
        },
      );
}
