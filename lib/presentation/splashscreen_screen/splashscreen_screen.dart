import 'package:delalochu/core/app_export.dart';
import 'package:flutter/material.dart';
import 'provider/splashscreen_provider.dart';

class SplashscreenScreen extends StatefulWidget {
  const SplashscreenScreen({Key? key}) : super(key: key);

  @override
  SplashscreenScreenState createState() => SplashscreenScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SplashscreenProvider(),
      child: SplashscreenScreen(),
    );
  }
}

class SplashscreenScreenState extends State<SplashscreenScreen> {
  @override
  void initState() {
    super.initState();
    var value = PrefUtils.sharedPreferences!.getBool('isLoggedIn') ?? false;
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (value) {
        NavigatorService.popAndPushNamed(
          AppRoutes.homescreenScreens,
        );
      } else {
        NavigatorService.popAndPushNamed(
          AppRoutes.loginscreenScreen,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteA700,
      body: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 31.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgImage190x258,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
