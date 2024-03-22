import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/widgets/app_bar/custom_app_bar.dart';
import 'package:delalochu/presentation/map_view/place_picker.dart';
import 'package:flutter/material.dart';
import 'provider/homescreen_provider.dart';

class HomescreenScreen extends StatefulWidget {
  const HomescreenScreen({Key? key}) : super(key: key);

  @override
  HomescreenScreenState createState() => HomescreenScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => HomescreenProvider(), child: HomescreenScreen());
  }
}

class HomescreenScreenState extends State<HomescreenScreen> {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
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

  /// drawer widget
  Drawer drawer() {
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
                        fontSize: 20.fSize,
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
              for (int i = 0; i < 5; i++) ...[
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
                        _closeDrawer();
                        break;
                      case 4:
                        _closeDrawer();
                        PrefUtils.sharedPreferences!
                            .setBool('isLoggedIn', false);
                        NavigatorService.pushNamedAndRemoveUntil(
                            AppRoutes.loginscreenScreen);
                        break;
                      default:
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        iconList[i],
                        color: i == 4 ? Colors.red : Color(0xFFFFA05B),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          titleList[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: i == 4 ? Colors.red : Colors.black,
                            fontSize: 18,
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
      // title: Text(
      //   "Delalaye",
      //   style: TextStyle(
      //     color: appTheme.orangeA200,
      //     fontSize: 25.fSize,
      //     fontFamily: 'Poppins',
      //     fontWeight: FontWeight.w700,
      //   ),
      // ),
      // centerTitle: true,
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

  static var titleList = [
    'Home',
    'Profile',
    'History',
    'Rate App',
    'Logout',
  ];
  var listofImageName = [
    'House sale',
    'House rent',
    'Car sale',
    'Car rent',
    'Real Estate',
    'House maid',
    'Skilled worker',
    'Used items',
    'Others',
  ];
  static var listOfImage = [
    ImageConstant.housesale,
    ImageConstant.rentHome,
    ImageConstant.car,
    ImageConstant.car,
    ImageConstant.building,
    ImageConstant.maid,
    ImageConstant.mechanic,
    ImageConstant.furniture,
    ImageConstant.more,
  ];
  static var iconList = [
    Icons.home,
    Icons.person,
    Icons.history,
    Icons.star,
    Icons.logout,
  ];
  static void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

  /// Section Widget
  Widget _buildBody(BuildContext context) {
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
        itemCount: listOfImage.length,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PlacePicker(
                          ChapaStrings.googleApiKey,
                          '${index += 1}',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    // margin: EdgeInsets.only(bottom: 10),
                    // margin: EdgeInsets.symmetric(vertical: 20),
                    width: 109.77,
                    height: 109.77,
                    decoration: AppDecoration.outlineBlack.copyWith(
                      borderRadius: BorderRadiusStyle.roundedBorder15,
                    ),
                    child: Center(
                      child: CustomImageView(
                        margin: EdgeInsets.only(top: index == 8 ? 30 : 1),
                        imagePath: listOfImage[index],
                        color: Color(0xFFFFA05B),
                        // height: 64.v,
                        width: ResponsiveExtension(65).h,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  listofImageName[index],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
