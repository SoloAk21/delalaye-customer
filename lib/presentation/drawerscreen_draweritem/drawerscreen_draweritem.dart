import 'package:delalochu/core/app_export.dart';
import 'package:flutter/material.dart';

class DrawerscreenDraweritem extends StatefulWidget {
  const DrawerscreenDraweritem({Key? key}) : super(key: key);

  @override
  DrawerscreenDraweritemState createState() => DrawerscreenDraweritemState();
}

class DrawerscreenDraweritemState extends State<DrawerscreenDraweritem> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 42.h, vertical: 73.v),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 1.v, bottom: 776.v),
                  child: Text("lbl_menu".tr,
                      style: TextStyle(
                          color: appTheme.gray500,
                          fontSize: 20.fSize,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500))),
              CustomImageView(
                  imagePath: ImageConstant.imgFiSsArrowSmallLeft,
                  height: 32.adaptSize,
                  width: 32.adaptSize,
                  margin: EdgeInsets.only(right: 107.h, bottom: 775.v),
                  onTap: () {
                    onTapImgFiSsArrowSmallLeft(context);
                  })
            ],
          ),
        ),
      ),
    );
  }

  /// Navigates to the homescreenScreen when the action is triggered.
  onTapImgFiSsArrowSmallLeft(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.homescreenScreens,
    );
  }
}
