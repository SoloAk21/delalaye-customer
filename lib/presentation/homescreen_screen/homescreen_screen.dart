import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/localization/lang_provider.dart';
import 'package:delalochu/widgets/app_bar/custom_app_bar.dart';
import 'package:delalochu/presentation/map_view/place_picker.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/servicesModel/getServicesList.dart';
import 'provider/homescreen_provider.dart';

class HomescreenScreen extends StatefulWidget {
  const HomescreenScreen({Key? key}) : super(key: key);

  @override
  HomescreenScreenState createState() => HomescreenScreenState();

  static Widget builder(BuildContext context) {
    return HomescreenScreen();
  }
}

class HomescreenScreenState extends State<HomescreenScreen> {
  late HomescreenProvider homescreenProvider;
  List<Service>? serviceList;
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    return await location.getLocation();
  }

  getBrokerListBasedOnTheirServiceAndLocation() async {
    await homescreenProvider.isLoadingData(true);
    await homescreenProvider.isLoadinghouseRantBrokerInfo(true);
    await homescreenProvider.isLoadingcarSaleBrokerinfo(true);
    await homescreenProvider.isLoadingcarRentBrokerinfo(true);
    await homescreenProvider.isLoadinghouseMaidBrokerInfo(true);
    await homescreenProvider.isLoadingusedItemBrokerInfo(true);
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

  @override
  void initState() {
    super.initState();
    homescreenProvider =
        Provider.of<HomescreenProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // serviceList = await ApiAuthHelper.getservice();
      // if (mounted) {
      //   setState(() {});
      // }
      // getBrokerListBasedOnTheirServiceAndLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: buildAppBar(context),
      drawer: drawer(),
      body: SizedBox(
        width: SizeUtils.width,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 22.v),
          child: _buildBody(context),
        ),
      ),
    );
  }

  void _rateApp() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.delalayecustomer.app';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  /// drawer widget
  Drawer drawer() {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Drawer(
      child: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveExtension(42).h, vertical: 73.v),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 1.v,
                    ),
                    child: Text(
                      "lbl_menu".tr,
                      style: TextStyle(
                        color: appTheme.gray500,
                        fontSize: 18.fSize,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CustomImageView(
                    imagePath: ImageConstant.imgFiSsArrowSmallLeft,
                    height: 32.adaptSize,
                    width: 32.adaptSize,
                    margin: EdgeInsets.only(
                      right: ResponsiveExtension(10).h,
                    ),
                    onTap: _closeDrawer,
                  )
                ],
              ),
              const SizedBox(height: 46),
              for (int i = 0; i < 6; i++) ...[
                GestureDetector(
                  onTap: () {
                    switch (i) {
                      case 0:
                        _closeDrawer();
                        break;
                      case 1:
                        _closeDrawer();
                        NavigatorService.pushNamed(
                          AppRoutes.profilescreenScreen,
                        );
                        break;
                      case 2:
                        _closeDrawer();
                        NavigatorService.pushNamed(
                          AppRoutes.historyscreenScreen,
                        );
                        break;
                      case 3:
                        _rateApp();
                        break;
                      case 4:
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SimpleDialog(
                                  title: Text('lbl_select_language'.tr),
                                  children: <Widget>[
                                    SimpleDialogOption(
                                      onPressed: () {
                                        setState(() {
                                          Locale newLocale = Locale("en", '');
                                          languageProvider
                                              .changeLanguage(newLocale);
                                        });
                                        Navigator.pop(context);
                                        NavigatorService.pushNamed(
                                            AppRoutes.splashscreenScreen);
                                      },
                                      child: Text('English'),
                                    ),
                                    SimpleDialogOption(
                                      onPressed: () {
                                        setState(() {
                                          Locale newLocale = Locale("am", '');
                                          languageProvider
                                              .changeLanguage(newLocale);
                                        });
                                        Navigator.pop(context);
                                        NavigatorService.pushNamed(
                                            AppRoutes.splashscreenScreen);
                                      },
                                      child: Text('Amharic'),
                                    ),
                                    SimpleDialogOption(
                                      onPressed: () {
                                        setState(() {
                                          Locale newLocale = Locale("da", '');
                                          languageProvider
                                              .changeLanguage(newLocale);
                                        });
                                        Navigator.pop(context);
                                        NavigatorService.pushNamed(
                                            AppRoutes.splashscreenScreen);
                                      },
                                      child: Text('Afaan Oromoo'),
                                    ),
                                  ]);
                            });
                        _closeDrawer();
                        break;
                      case 5:
                        _closeDrawer();
                        PrefUtils.sharedPreferences!
                            .setBool('isLoggedIn', false);
                        NavigatorService.pushNamedAndRemoveUntil(
                          AppRoutes.loginscreenScreen,
                        );
                        break;
                      default:
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        iconList[i],
                        color: i == 5 ? Colors.red : Color(0xFFFFA05B),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          titleList[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: i == 5 ? Colors.red : Colors.black,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: 307,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0x66505862),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static PreferredSizeWidget buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: ResponsiveExtension(118).h,
      height: 80.98.v,
      leading: CustomImageView(
        margin: EdgeInsets.only(left: ResponsiveExtension(25).h, top: 11.v),
        imagePath: ImageConstant.imgImage190x258,
        fit: BoxFit.cover,
      ),
      actions: [
        CustomImageView(
          imagePath: ImageConstant.imgCharmMenuHamburger,
          height: 36.adaptSize,
          width: 36.adaptSize,
          onTap: () => openDrawer(),
          color: Color(0xFFFFA05B),
          margin: EdgeInsets.only(
            right: ResponsiveExtension(25).h,
          ),
        ),
      ],
    );
  }

  var titleList = [
    'lbl_home'.tr,
    'lbl_profile'.tr,
    'lbl_history'.tr,
    'lbl_rate_app'.tr,
    'lbl_language'.tr,
    'lbl_logout'.tr,
  ];
  var listofImageName = [
    'lbl_house_sale'.tr,
    'lbl_house_rent'.tr,
    'lbl_car_sale'.tr,
    'lbl_car_rent'.tr,
    'lbl_house_maid'.tr,
    'lbl_used_items'.tr,
  ];
  static var listOfImage = [
    ImageConstant.housesale,
    ImageConstant.rentHome,
    ImageConstant.car,
    ImageConstant.car,
    ImageConstant.maid,
    ImageConstant.furniture,
  ];
  static Map<String, String> images = {
    "House sell": ImageConstant.housesale,
    "House rent": ImageConstant.rentHome,
    "Car sell": ImageConstant.car,
    "Car rent": ImageConstant.car,
    "House maid": ImageConstant.maid,
    "Ride": ImageConstant.furniture,
  };
  static List<String> listserviceID = ['1', '2', '3', '4', '5', '6'];
  static var iconList = [
    Icons.home,
    Icons.person,
    Icons.history,
    Icons.star,
    Icons.language,
    Icons.logout,
  ];
  static void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

  String _getImagePath(String serviceName) {
    switch (serviceName) {
      case 'House sell':
        return ImageConstant.housesale;
      case 'House rent':
        return ImageConstant.rentHome;
      case 'Car sell':
      case 'Car rent':
        return ImageConstant.car;
      case 'House maid':
        return ImageConstant.maid;
      default:
        return ImageConstant.furniture;
    }
  }

  /// Section Widget
  Widget _buildBody(BuildContext context) {
    return Consumer<HomescreenProvider>(
      builder: (context, homescreenProvider, child) {
        final initialList =
            homescreenProvider.serviceList?.take(5).toList() ?? [];
        final remainingList = homescreenProvider.serviceList?.skip(5).toList();
        return Container(
          margin: EdgeInsets.only(
            left: ResponsiveExtension(15).h,
            right: ResponsiveExtension(15).h,
            bottom: 5.v,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveExtension(16).h,
            vertical: 18.v,
          ),
          child: homescreenProvider.serviceList == null ||
                  homescreenProvider.isLoadingServiceList
              ? Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                )
              : Column(
                  children: [
                    SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(5),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 200.v,
                          crossAxisCount: 3,
                          mainAxisSpacing: ResponsiveExtension(15).h,
                          crossAxisSpacing: ResponsiveExtension(15).h,
                        ),
                        physics: BouncingScrollPhysics(),
                        itemCount: initialList.length + 1,
                        itemBuilder: (context, index) {
                          if (index < initialList.length) {
                            return _buildGridItem(context, initialList[index]);
                          } else {
                            return _buildMoreButton(context, remainingList);
                          }
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildGridItem(BuildContext context, Service service) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlacePicker(
                    ConstantStrings.googleApiKey,
                    service.id.toString(),
                  ),
                ),
              );
            },
            child: Container(
              width: 109.77,
              height: 109.77,
              decoration: AppDecoration.outlineBlack.copyWith(
                borderRadius: BorderRadiusStyle.roundedBorder15,
              ),
              child: Center(
                child: CustomImageView(
                  margin: EdgeInsets.only(top: 1),
                  imagePath: _getImagePath(service.name ?? ""),
                  color: Color(0xFFFFA05B),
                  width: ResponsiveExtension(65).h,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              service.name ?? "",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreButton(BuildContext context, List<Service>? remainingList) {
    return InkWell(
      onTap: () {
        if (remainingList != null && remainingList.isNotEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('More Services'),
                content: Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: remainingList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              remainingList[index].name ?? "",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlacePicker(
                                ConstantStrings.googleApiKey,
                                remainingList[index].id.toString(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              child: Container(
                width: 109.77,
                height: 109.77,
                decoration: AppDecoration.outlineBlack.copyWith(
                  borderRadius: BorderRadiusStyle.roundedBorder15,
                ),
                child: Center(
                  child: CustomImageView(
                    margin: EdgeInsets.only(top: 1),
                    imagePath: ImageConstant.furniture,
                    color: Color(0xFFFFA05B),
                    width: ResponsiveExtension(65).h,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "More",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Showdialog extends StatefulWidget {
  @override
  State<Showdialog> createState() => _ShowdialogState();
}

class _ShowdialogState extends State<Showdialog> {
  @override
  Widget build(BuildContext context) {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return SimpleDialog(
      title: Text('lbl_select_language'.tr),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            setState(() {
              Locale newLocale = Locale("en", '');
              languageProvider.changeLanguage(newLocale);
            });
            NavigatorService.pushNamed(AppRoutes.homescreenScreens);
          },
          child: Text('English'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Locale newLocale = Locale("am", '');
            languageProvider.changeLanguage(newLocale);
            setState(() {});
            Navigator.pop(context);
          },
          child: Text('Amharic'),
        ),
        SimpleDialogOption(
          onPressed: () {
            setState(() {
              Locale newLocale = Locale("da", '');
              languageProvider.changeLanguage(newLocale);
            });
            // Perform action when Afaan Oromo is selected
            // Navigator.pop(context, 'Afaan Oromoo');
            Navigator.pop(context);
            // NavigatorService.pushNamed(AppRoutes.homescreenScreens);
          },
          child: Text('Afaan Oromoo'),
        ),
      ],
    );
  }
}
