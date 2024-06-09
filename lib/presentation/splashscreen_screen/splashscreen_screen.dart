import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/presentation/map_view/place_picker.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../homescreen_screen/provider/homescreen_provider.dart';
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
  late HomescreenProvider homescreenProvider;
  @override
  void initState() {
    super.initState();
    homescreenProvider =
        Provider.of<HomescreenProvider>(context, listen: false);
    initPrefs();
  }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    return await location.getLocation();
  }

  getBrokerListBasedOnTheirServiceAndLocation() async {
    getCurrentLocation().then((locationData) async {
      for (var i = 1; i < 7; i++) {
        debugPrint(
            'Info - $i: ${locationData.latitude}, ${locationData.longitude}');
        await homescreenProvider.fetchBrokerList(
          latitude: locationData.latitude ?? 0.0,
          longitude: locationData.longitude ?? 0.0,
          serviceId: i,
        );
      }
    });
  }

  Future<void> initPrefs() async {
    // getBrokerListBasedOnTheirServiceAndLocation();
    prefs = await SharedPreferences.getInstance();
    var value = PrefUtils.sharedPreferences!.getBool('isLoggedIn') ?? false;
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (prefs!.getBool('isConnectiong') == false ||
          !prefs!.containsKey('isConnectiong')) {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => PlacePicker(
                  prefs!.getString('apiKey'),
                  prefs!.getString('selectedServiceId'),
                )),
          ),
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
