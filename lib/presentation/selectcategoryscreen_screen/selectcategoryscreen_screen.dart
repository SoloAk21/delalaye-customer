import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/widgets/custom_elevated_button.dart';
import 'package:delalochu/widgets/custom_outlined_button.dart';
import 'package:delalochu/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'provider/selectcategoryscreen_provider.dart';

class SelectcategoryscreenScreen extends StatefulWidget {
  const SelectcategoryscreenScreen({Key? key}) : super(key: key);

  @override
  SelectcategoryscreenScreenState createState() =>
      SelectcategoryscreenScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SelectcategoryscreenProvider(),
        child: SelectcategoryscreenScreen());
  }
}

class SelectcategoryscreenScreenState
    extends State<SelectcategoryscreenScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: 52.v),
                child: Column(children: [
                  SizedBox(height: 12.v),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 36.h, right: 36.h, bottom: 5.v),
                              child: Column(children: [
                                Text("msg_select_your_category".tr,
                                    style: TextStyle(
                                        color: appTheme.black900,
                                        fontSize: 24.fSize,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500)),
                                SizedBox(height: 26.v),
                                _buildEightyTwoRow(context),
                                SizedBox(height: 46.v),
                                _buildTwentySix(context),
                                SizedBox(height: 46.v),
                                _buildTwentySeven(context),
                                SizedBox(height: 46.v),
                                _buildTwentyFive(context),
                                SizedBox(height: 14.v),
                                _buildThirtyEightColumn(context)
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
  Widget _buildEightyTwoRow(BuildContext context) {
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
  Widget _buildTwentySix(BuildContext context) {
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
  Widget _buildTwentySeven(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _buildRealEstateButton(context),
      _buildHouseMaidButton(context)
    ]);
  }

  /// Section Widget
  Widget _buildSkilledWorkerButton(BuildContext context) {
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
  Widget _buildTwentyFive(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _buildSkilledWorkerButton(context),
      _buildUsedItemsButton(context)
    ]);
  }

  /// Section Widget
  Widget _buildThirtyEightColumn(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.only(left: 10.h),
          child: Text("lbl_others".tr,
              style: TextStyle(
                  color: appTheme.black900,
                  fontSize: 15.fSize,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300))),
      SizedBox(height: 14.v),
      Selector<SelectcategoryscreenProvider, TextEditingController?>(
          selector: (context, provider) => provider.typeAnythingController,
          builder: (context, typeAnythingController, child) {
            return CustomTextFormField(
                controller: typeAnythingController,
                hintText: "msg_type_anything".tr,
                textInputAction: TextInputAction.done,
                maxLines: 8,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.h, vertical: 19.v));
          })
    ]);
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
