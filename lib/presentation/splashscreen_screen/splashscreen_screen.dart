import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/presentation/map_view/place_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  SharedPreferences? prefs;
  @override
  void initState() {
    super.initState();
    initPrefs();
  }

 Future<void> initPrefs() async {
      prefs = await SharedPreferences.getInstance();

  var value = PrefUtils.sharedPreferences!.getBool('isLoggedIn') ?? false;
    Future.delayed(const Duration(milliseconds: 1000), () {
     if(prefs!.getBool('isConnectiong') == false || !prefs!.containsKey('isConnectiong')) {
       if (value) {
        NavigatorService.pushNamedAndRemoveUntil(
          AppRoutes.homescreenScreens,
        );
      } else {
        NavigatorService.pushNamedAndRemoveUntil(
          AppRoutes.loginscreenScreen,
        );
      }
     } else {
      Navigator.push(context, MaterialPageRoute(builder: ((context) => PlacePicker(prefs!.getString('apiKey'), prefs!.getString('selectedServiceId')))));
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
