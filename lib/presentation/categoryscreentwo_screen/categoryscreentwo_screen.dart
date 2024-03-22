import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/widgets/custom_elevated_button.dart';
import 'package:delalochu/widgets/custom_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'provider/categoryscreentwo_provider.dart';

class CategoryscreentwoScreen extends StatefulWidget {
  const CategoryscreentwoScreen({Key? key}) : super(key: key);

  @override
  CategoryscreentwoScreenState createState() => CategoryscreentwoScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => CategoryscreentwoProvider(),
        child: CategoryscreentwoScreen());
  }
}

class CategoryscreentwoScreenState extends State<CategoryscreentwoScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: 52.v),
                child: Column(children: [
                  SizedBox(height: 12.v),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 35.h, right: 35.h, bottom: 5.v),
                              child: Column(children: [
                                Text("msg_select_your_category".tr,
                                    style: TextStyle(
                                        color: appTheme.black900,
                                        fontSize: 24.fSize,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500)),
                                SizedBox(height: 26.v),
                                _buildSeventySix(context),
                                SizedBox(height: 46.v),
                                _buildThirtySix(context),
                                SizedBox(height: 46.v),
                                _buildFiftyOne(context),
                                SizedBox(height: 46.v),
                                _buildFortySeven(context),
                                SizedBox(height: 33.v),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 10.h),
                                        child: Text("lbl_others".tr,
                                            style: TextStyle(
                                                color: appTheme.black900,
                                                fontSize: 15.fSize,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w300)))),
                                SizedBox(height: 10.v),
                                _buildFive(context)
                              ]))))
                ])),
            bottomNavigationBar: _buildContinueButton(context)));
  }

  /// Section Widget
  Widget _buildHouseSaleButton(BuildContext context) {
    return Expanded(
        child: CustomElevatedButton(
            text: "lbl_house_sale".tr, margin: EdgeInsets.only(right: 12.h)));
  }

  /// Section Widget
  Widget _buildHouseRentButton(BuildContext context) {
    return Expanded(
        child: CustomElevatedButton(
            text: "lbl_house_rent".tr, margin: EdgeInsets.only(left: 12.h)));
  }

  /// Section Widget
  Widget _buildSeventySix(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _buildHouseSaleButton(context),
      _buildHouseRentButton(context)
    ]);
  }

  /// Section Widget
  Widget _buildCarSaleButton(BuildContext context) {
    return Expanded(
        child: CustomElevatedButton(
            text: "lbl_car_sale".tr,
            margin: EdgeInsets.only(right: 12.h),
            buttonStyle: CustomButtonStyles.outlineBlackTL5));
  }

  /// Section Widget
  Widget _buildCarRentButton(BuildContext context) {
    return Expanded(
        child: CustomElevatedButton(
            text: "lbl_car_rent".tr, margin: EdgeInsets.only(left: 12.h)));
  }

  /// Section Widget
  Widget _buildThirtySix(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_buildCarSaleButton(context), _buildCarRentButton(context)]);
  }

  /// Section Widget
  Widget _buildRealEstateButton(BuildContext context) {
    return Expanded(
        child: CustomElevatedButton(
            text: "lbl_real_estate".tr, margin: EdgeInsets.only(right: 12.h)));
  }

  /// Section Widget
  Widget _buildHouseMaidButton(BuildContext context) {
    return Expanded(
        child: CustomElevatedButton(
            text: "lbl_house_maid".tr,
            margin: EdgeInsets.only(left: 12.h),
            buttonStyle: CustomButtonStyles.outlineBlackTL5));
  }

  /// Section Widget
  Widget _buildFiftyOne(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _buildRealEstateButton(context),
      _buildHouseMaidButton(context)
    ]);
  }

  /// Section Widget
  Widget _buildSkilledWorker(BuildContext context) {
    return Expanded(
        child: CustomElevatedButton(
            text: "lbl_skilled_worker".tr,
            margin: EdgeInsets.only(right: 12.h)));
  }

  /// Section Widget
  Widget _buildUsedItemsButton(BuildContext context) {
    return Expanded(
        child: CustomElevatedButton(
            text: "lbl_used_items".tr, margin: EdgeInsets.only(left: 12.h)));
  }

  /// Section Widget
  Widget _buildFortySeven(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _buildSkilledWorker(context),
      _buildUsedItemsButton(context)
    ]);
  }

  /// Section Widget
  Widget _buildCleaningServiceButton(BuildContext context) {
    return CustomOutlinedButton(
        height: 30.v,
        width: 163.h,
        text: "msg_cleaning_service".tr,
        rightIcon: Container(
            margin: EdgeInsets.only(left: 14.h),
            child: CustomImageView(
                imagePath: ImageConstant.imgX,
                height: 16.adaptSize,
                width: 16.adaptSize)),
        buttonStyle: CustomButtonStyles.outlineGray);
  }

  /// Section Widget
  Widget _buildFive(BuildContext context) {
    return Container(
        width: 358.h,
        padding: EdgeInsets.symmetric(horizontal: 9.h, vertical: 7.v),
        decoration: AppDecoration.outlineGray
            .copyWith(borderRadius: BorderRadiusStyle.roundedBorder5),
        child: _buildCleaningServiceButton(context));
  }

  /// Section Widget
  Widget _buildContinueButton(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 48.h, right: 39.h, bottom: 52.v),
        child: OutlineGradientButton(
            padding:
                EdgeInsets.only(left: 1.h, top: 1.v, right: 1.h, bottom: 1.v),
            strokeWidth: 1.h,
            gradient: LinearGradient(
                begin: Alignment(-0.29, 1.69),
                end: Alignment(1, 0.72),
                colors: [appTheme.whiteA700, theme.colorScheme.primary]),
            corners: Corners(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8)),
            child: CustomOutlinedButton(
                text: "lbl_continue".tr,
                buttonStyle: CustomButtonStyles.none,
                decoration: CustomButtonStyles
                    .gradientOnPrimaryContainerToOrangeDecoration,
                onPressed: () {
                  onTapContinueButton(context);
                })));
  }

  /// Navigates to the homescreenScreen when the action is triggered.
  onTapContinueButton(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.homescreenScreens,
    );
  }
}
