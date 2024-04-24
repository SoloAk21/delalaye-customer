// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/core/utils/progress_dialog_utils.dart';

import '../../domain/apiauthhelpers/apiauth.dart';
import '../../widgets/custom_text_form_field.dart';
import '../homescreen_screen/homescreen_screen.dart';

class AllBrokerInfo extends StatefulWidget {
  final String fullName;
  final String phoneNumber;
  final String brokerId;
  final int connectionID;
  const AllBrokerInfo({
    Key? key,
    required this.fullName,
    required this.phoneNumber,
    required this.brokerId,
    required this.connectionID,
  }) : super(key: key);

  @override
  State<AllBrokerInfo> createState() => _AllBrokerInfoState();
}

class _AllBrokerInfoState extends State<AllBrokerInfo> {
  var reviewController = TextEditingController();
  var titleController = TextEditingController();
  String title = "";
  String review = "";
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: HomescreenScreenState.scaffoldKey,
      appBar: HomescreenScreenState.buildAppBar(context),
      drawer: drawer(),
      body: Container(
        padding: EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomImageView(
                      imagePath: ImageConstant.imageNotFound,
                      height: 60.adaptSize,
                      width: 60.adaptSize,
                      border: Border.all(color: appTheme.orangeA200, width: 1),
                      radius: BorderRadius.circular(
                        30.h,
                      ),
                      margin: EdgeInsets.only(
                        top: 2.v,
                        bottom: 7.v,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 19.h,
                        top: 2.v,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fullName,
                            style: TextStyle(
                              color: appTheme.blueGray400,
                              fontSize: 20.fSize,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8.v),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '1',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              RatingBar.builder(
                                initialRating: 0,
                                itemSize: 30,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 30),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
                //   child: Text(
                //     'A very experienced broker with a passion for the financial markets.',
                //     style: const TextStyle(
                //       fontSize: 16,
                //     ),
                //   ),
                // ),
                SizedBox(height: 30),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  height: 60.77,
                  decoration: BoxDecoration(
                    color: appTheme.whiteA700,
                    boxShadow: [
                      BoxShadow(
                        color: appTheme.black900.withOpacity(0.25),
                        spreadRadius: 1.h,
                        blurRadius: 1.h,
                        offset: Offset(
                          0,
                          0,
                        ),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.phone_outlined,
                          color: appTheme.orangeA200,
                          size: 30,
                        ),
                        onPressed: () async {
                          ProgressDialogUtils.showProgressDialog(
                            context: context,
                            isCancellable: false,
                          );
                          var respo = await ApiAuthHelper.calltobroker(
                            connectionId: widget.connectionID,
                          );
                          if (respo) {
                            ProgressDialogUtils.hideProgressDialog();
                            final url =
                                Uri(scheme: 'tel', path: widget.phoneNumber);
                            if (await canLaunchUrl(url)) {
                              launchUrl(url).then(
                                (value) =>
                                    NavigatorService.pushNamedAndRemoveUntil(
                                        AppRoutes.homescreenScreens),
                              );
                            }
                          } else {
                            ProgressDialogUtils.hideProgressDialog();
                            ProgressDialogUtils.showSnackBar(
                              context: context,
                              message: 'Something went wrong',
                            );
                          }
                        },
                      ),
                      Text(
                        widget.phoneNumber,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'poppins',
                            fontSize: 18),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'poppins',
                          fontSize: 35,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy_outlined,
                          color: appTheme.orangeA200,
                          size: 30,
                        ),
                        onPressed: () async {
                          ProgressDialogUtils.showProgressDialog(
                            context: context,
                            isCancellable: false,
                          );
                          var respo = await ApiAuthHelper.calltobroker(
                            connectionId: widget.connectionID,
                          );
                          if (respo) {
                            ProgressDialogUtils.hideProgressDialog();
                            await Clipboard.setData(
                              ClipboardData(text: widget.phoneNumber),
                            ).then((value) {
                              ProgressDialogUtils.showSnackBar(
                                context: context,
                                message: 'Phone number copied to clipboard',
                              );
                              NavigatorService.pushNamedAndRemoveUntil(
                                  AppRoutes.homescreenScreens);
                            });
                          } else {
                            ProgressDialogUtils.hideProgressDialog();
                            ProgressDialogUtils.showSnackBar(
                              context: context,
                              message: 'Something went wrong',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Rate',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
                RatingBar.builder(
                  initialRating: 0,
                  itemSize: 30,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(
                    horizontal: 4.0,
                  ),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: CustomTextFormField(
                    controller: titleController,
                    hintText: "Title ",
                    onChanged: (p0) => title = p0,
                    hintStyle: TextStyle(
                      color: appTheme.blueGray400,
                    ),
                    textInputAction: TextInputAction.done,
                    textStyle: TextStyle(
                      color: appTheme.black900,
                    ),
                    maxLines: 1,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.h,
                      vertical: 19.v,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: CustomTextFormField(
                    controller: reviewController,
                    hintText: "Review: ",
                    onChanged: (p0) => review = p0,
                    hintStyle: TextStyle(
                      color: appTheme.blueGray400,
                    ),
                    textInputAction: TextInputAction.done,
                    textStyle: TextStyle(
                      color: appTheme.black900,
                    ),
                    maxLines: 8,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.h,
                      vertical: 19.v,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Center(child: _buildRatebutton(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildRatebutton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        ProgressDialogUtils.showProgressDialog(
          context: context,
          isCancellable: false,
        );
        var respo = await ApiAuthHelper.calltobroker(
          connectionId: widget.connectionID,
        );
        if (respo) {
          ProgressDialogUtils.hideProgressDialog();
          final url = Uri(scheme: 'tel', path: widget.phoneNumber);
          if (await canLaunchUrl(url)) {
            launchUrl(url).then(
              (value) => NavigatorService.pushNamedAndRemoveUntil(
                  AppRoutes.homescreenScreens),
            );
          }
        } else {
          ProgressDialogUtils.hideProgressDialog();
          ProgressDialogUtils.showSnackBar(
            context: context,
            message: 'Something went wrong',
          );
        }
      },
      child: Container(
        width: 343,
        height: 50,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.79, 0.61),
            end: Alignment(-0.79, -0.61),
            colors: [Color(0xFFF06400), Color(0xFFFFA05B)],
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.50, color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Call now',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
      ),
    );
  }

  /// drawer widget
  Drawer drawer() {
    var titleList = [
      'lbl_home'.tr,
      'lbl_profile'.tr,
      'lbl_history'.tr,
      'lbl_rate_app'.tr,
      'lbl_language'.tr,
      'lbl_logout'.tr,
    ];
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
                        NavigatorService.pushNamedAndRemoveUntil(
                          AppRoutes.homescreenScreens,
                        );
                        break;
                      case 1:
                        _closeDrawer();
                        NavigatorService.pushNamed(
                            AppRoutes.profilescreenScreen);
                        break;
                      case 2:
                        _closeDrawer();
                        NavigatorService.pushNamed(
                          AppRoutes.historyscreenScreen,
                        );
                        break;
                      case 3:
                        Navigator.of(context).pop();
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
                        HomescreenScreenState.iconList[i],
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

  void _closeDrawer() {
    HomescreenScreenState.scaffoldKey.currentState?.closeDrawer();
  }
}
