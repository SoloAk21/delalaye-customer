import 'dart:io';

import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/core/utils/validation_functions.dart';
import 'package:delalochu/domain/apiauthhelpers/apiauth.dart';
import 'package:delalochu/widgets/app_bar/appbar_leading_image.dart';
import 'package:delalochu/widgets/app_bar/appbar_title.dart';
import 'package:delalochu/widgets/app_bar/custom_app_bar.dart';
import 'package:delalochu/widgets/custom_text_form_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../core/utils/image_tools.dart';
import '../../core/utils/progress_dialog_utils.dart';
import 'provider/profilescreen_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';

class ProfilescreenScreen extends StatefulWidget {
  const ProfilescreenScreen({Key? key}) : super(key: key);

  @override
  ProfilescreenScreenState createState() => ProfilescreenScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfilescreenProvider(),
      child: ProfilescreenScreen(),
    );
  }
}

// ignore_for_file: must_be_immutable
class ProfilescreenScreenState extends State<ProfilescreenScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String username = "";
  String phonenumber = "";
  String password = "";

  File? fileImages;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 31.v),
          child:
              Consumer<ProfilescreenProvider>(builder: (context, value, child) {
            if (value.loading) {
              return Center(
                child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator()),
              );
            } else {
              return Padding(
                padding: EdgeInsets.only(left: 33.h, right: 16.h, bottom: 5.v),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          fileImages != null
                              ? GestureDetector(
                                  onTap: () {
                                    _showOption(context);
                                  },
                                  child: DottedBorder(
                                    color: appTheme.blueGray400,
                                    padding: EdgeInsets.only(
                                        left: 1.h,
                                        top: 1.v,
                                        right: 1.h,
                                        bottom: 1.v),
                                    strokeWidth: 1.h,
                                    radius: Radius.circular(35),
                                    borderType: BorderType.RRect,
                                    dashPattern: [2, 2],
                                    child: Container(
                                      height: 70.v,
                                      width: 70.h,
                                      decoration: AppDecoration.outlineBlueGray
                                          .copyWith(
                                        borderRadius:
                                            BorderRadiusStyle.circleBorder35,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(fileImages!),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : CustomImageView(
                                  onTap: () {
                                    _showOption(context);
                                  },
                                  imagePath: value.brokerData.user != null &&
                                          value.brokerData.user!.photo != null
                                      ? value.brokerData.user!.photo
                                      : ImageConstant.imageNotFound,
                                  height: 70.adaptSize,
                                  width: 70.adaptSize,
                                  radius: BorderRadius.circular(35.h),
                                ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 15.h, top: 15.v, bottom: 13.v),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("lbl_change".tr,
                                    style: TextStyle(
                                        color: appTheme.blueGray400,
                                        fontSize: 14.fSize,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400)),
                                Text(
                                  "lbl_profile_photo".tr,
                                  style: TextStyle(
                                    color: appTheme.gray40001,
                                    fontSize: 14.fSize,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28.v),
                    _buildUsername(context, value),
                    SizedBox(height: 15.v),
                    _buildPhoneNumber(context, value),
                    SizedBox(height: 15.v),
                    _buildPassword(context, value),
                    SizedBox(height: 333.v),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (password != '' && fileImages != null) {
                            ProgressDialogUtils.showProgressDialog(
                              context: context,
                              isCancellable: false,
                            );
                            final convertedbase64Encode =
                                ImageTools.convertImagesToBase64(fileImages!);
                            var res = await ApiAuthHelper.updateProfile(
                              isnopasandimage: false,
                              image: convertedbase64Encode,
                              username: username == ''
                                  ? value.brokerData.user != null &&
                                          value.brokerData.user!.fullName !=
                                              null
                                      ? value.brokerData.user!.fullName
                                      : username
                                  : username,
                              password: password,
                              phoneNumber: phonenumber == ''
                                  ? value.brokerData.user != null &&
                                          value.brokerData.user!.phone != null
                                      ? value.brokerData.user!.phone
                                      : phonenumber
                                  : phonenumber,
                            );
                            if (res) {
                              ProgressDialogUtils.hideProgressDialog();
                              ProgressDialogUtils.showSnackBar(
                                context: context,
                                message:
                                    'You have successfully updated your profile',
                              );
                            } else {
                              ProgressDialogUtils.hideProgressDialog();
                              ProgressDialogUtils.showSnackBar(
                                context: context,
                                message: 'something went wrong',
                              );
                            }
                          } else if (username != '' || phonenumber != '') {
                            ProgressDialogUtils.showProgressDialog(
                              context: context,
                              isCancellable: false,
                            );
                            var res = await ApiAuthHelper.updateProfile(
                              isnopasandimage: true,
                              username: username == ''
                                  ? value.brokerData.user != null &&
                                          value.brokerData.user!.fullName !=
                                              null
                                      ? value.brokerData.user!.fullName
                                      : username
                                  : username,
                              phoneNumber: phonenumber == ''
                                  ? value.brokerData.user != null &&
                                          value.brokerData.user!.phone != null
                                      ? value.brokerData.user!.phone
                                      : phonenumber
                                  : phonenumber,
                            );
                            if (res) {
                              ProgressDialogUtils.hideProgressDialog();
                              ProgressDialogUtils.showSnackBar(
                                context: context,
                                message:
                                    'You have successfully updated your profile',
                              );
                            } else {
                              ProgressDialogUtils.hideProgressDialog();
                              ProgressDialogUtils.showSnackBar(
                                context: context,
                                message: 'something went wrong',
                              );
                            }
                          } else if (password != '' && fileImages == null) {
                            ProgressDialogUtils.showProgressDialog(
                              context: context,
                              isCancellable: false,
                            );
                            var res = await ApiAuthHelper.updateProfile(
                              isnopasandimage: true,
                              username: username == ''
                                  ? value.brokerData.user != null &&
                                          value.brokerData.user!.fullName !=
                                              null
                                      ? value.brokerData.user!.fullName
                                      : username
                                  : username,
                              phoneNumber: phonenumber == ''
                                  ? value.brokerData.user != null &&
                                          value.brokerData.user!.phone != null
                                      ? value.brokerData.user!.phone
                                      : phonenumber
                                  : phonenumber,
                              password: password,
                            );
                            if (res) {
                              ProgressDialogUtils.hideProgressDialog();
                              ProgressDialogUtils.showSnackBar(
                                context: context,
                                message:
                                    'You have successfully updated your profile',
                              );
                            } else {
                              ProgressDialogUtils.hideProgressDialog();
                              ProgressDialogUtils.showSnackBar(
                                context: context,
                                message: 'something went wrong',
                              );
                            }
                          } else if (password == '' && fileImages != null) {
                            ProgressDialogUtils.showProgressDialog(
                              context: context,
                              isCancellable: false,
                            );
                            final convertedbase64Encode =
                                ImageTools.convertImagesToBase64(fileImages!);
                            var res = await ApiAuthHelper.updateProfile(
                              isnopasandimage: true,
                              username: username == ''
                                  ? value.brokerData.user != null &&
                                          value.brokerData.user!.fullName !=
                                              null
                                      ? value.brokerData.user!.fullName
                                      : username
                                  : username,
                              phoneNumber: phonenumber == ''
                                  ? value.brokerData.user != null &&
                                          value.brokerData.user!.phone != null
                                      ? value.brokerData.user!.phone
                                      : phonenumber
                                  : phonenumber,
                              image: convertedbase64Encode,
                            );
                            if (res) {
                              ProgressDialogUtils.hideProgressDialog();
                              ProgressDialogUtils.showSnackBar(
                                context: context,
                                message:
                                    'You have successfully updated your profile',
                              );
                            } else {
                              ProgressDialogUtils.hideProgressDialog();
                              ProgressDialogUtils.showSnackBar(
                                context: context,
                                message: 'something went wrong',
                              );
                            }
                          }
                        },
                        child: Container(
                          width: 343,
                          height: 50,
                          padding: EdgeInsets.only(left: 10.h, right: 27.h),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.79, 0.61),
                              end: Alignment(-0.79, -0.61),
                              colors: [Color(0xFFF06400), Color(0xFFFFA05B)],
                            ),
                            shape: RoundedRectangleBorder(
                              side:
                                  BorderSide(width: 0.50, color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "lbl_save_changes".tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    );
  }

  Uint8List convertBase64ToImage(String base64String) {
    Uint8List decodedBytes = base64Decode(base64String);
    return decodedBytes;
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 75.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgFiSsArrowSmallLeft,
        margin: EdgeInsets.only(left: 43.h, top: 12.v, bottom: 12.v),
        onTap: () {
          onTapFiSsArrowSmallLeft(context);
        },
      ),
      centerTitle: true,
      title: AppbarTitle(text: "lbl_profile".tr),
    );
  }

  /// Section Widget
  Widget _buildUsername(BuildContext context, ProfilescreenProvider value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 3.h),
          child: Text(
            "lbl_username".tr,
            style: TextStyle(
              color: appTheme.blueGray400,
              fontSize: 14.fSize,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: 10.v),
        Padding(
          padding: EdgeInsets.only(left: 3.h),
          child: Consumer<ProfilescreenProvider>(
            builder: (context, provider, child) {
              return CustomTextFormField(
                initialValue: (value.brokerData.user != null) &&
                        (value.brokerData.user!.fullName != null)
                    ? value.brokerData.user!.fullName
                    : '',
                hintText: value.brokerData.user != null &&
                        value.brokerData.user!.fullName != null
                    ? value.brokerData.user!.fullName
                    : '',
                onChanged: (p0) => username = p0,
                autofocus: false,
                textStyle: TextStyle(color: Colors.black),
                prefix: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.h, vertical: 15.v),
                  child: CustomImageView(
                    imagePath: ImageConstant.imgFissuser,
                    height: 16.adaptSize,
                    width: 16.adaptSize,
                  ),
                ),
                prefixConstraints: BoxConstraints(maxHeight: 46.v),
                suffix: Container(
                  margin: EdgeInsets.fromLTRB(30.h, 15.v, 20.h, 15.v),
                  child: CustomImageView(
                    imagePath: ImageConstant.imgEdit,
                    height: 16.adaptSize,
                    width: 16.adaptSize,
                  ),
                ),
                suffixConstraints: BoxConstraints(maxHeight: 46.v),
              );
            },
          ),
        )
      ],
    );
  }

  /// Section Widget
  Widget _buildPhoneNumber(BuildContext context, ProfilescreenProvider value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 3.h),
            child: Text("lbl_phone_number2".tr,
                style: TextStyle(
                    color: appTheme.blueGray400,
                    fontSize: 14.fSize,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400))),
        SizedBox(height: 10.v),
        Padding(
          padding: EdgeInsets.only(left: 3.h),
          child: Consumer<ProfilescreenProvider>(
            builder: (context, provider, child) {
              return CustomTextFormField(
                initialValue: value.brokerData.user != null &&
                        value.brokerData.user!.phone != null
                    ? value.brokerData.user!.phone
                    : '',
                hintText: value.brokerData.user != null &&
                        value.brokerData.user!.phone != null
                    ? value.brokerData.user!.phone
                    : '',
                onChanged: (p0) => phonenumber = p0,
                textStyle: TextStyle(color: Colors.black),
                prefix: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.h, vertical: 15.v),
                  child: CustomImageView(
                    imagePath: ImageConstant.imgPhone,
                    height: 16.adaptSize,
                    width: 16.adaptSize,
                  ),
                ),
                prefixConstraints: BoxConstraints(maxHeight: 46.v),
                suffix: Container(
                  margin: EdgeInsets.fromLTRB(30.h, 15.v, 20.h, 15.v),
                  child: CustomImageView(
                    imagePath: ImageConstant.imgEdit,
                    height: 16.adaptSize,
                    width: 16.adaptSize,
                  ),
                ),
                suffixConstraints: BoxConstraints(maxHeight: 46.v),
                validator: (value) {
                  if (value == '' && !isValidPhone(value)) {
                    return "err_msg_please_enter_valid_phone_number".tr;
                  }
                  return null;
                },
              );
            },
          ),
        )
      ],
    );
  }

  /// Section Widget
  Widget _buildPassword(BuildContext context, ProfilescreenProvider value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 3.h),
            child: Text("lbl_password".tr,
                style: TextStyle(
                    color: appTheme.blueGray400,
                    fontSize: 14.fSize,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400))),
        SizedBox(height: 10.v),
        Padding(
          padding: EdgeInsets.only(left: 3.h),
          child: Consumer<ProfilescreenProvider>(
            builder: (context, provider, child) {
              return CustomTextFormField(
                  onChanged: (p0) => password = p0,
                  hintText: "lbl2".tr,
                  textInputAction: TextInputAction.done,
                  textInputType: TextInputType.visiblePassword,
                  textStyle: TextStyle(color: Colors.black),
                  prefix: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 8.h, vertical: 15.v),
                    child: CustomImageView(
                      imagePath: ImageConstant.imgFisslock,
                      height: 16.adaptSize,
                      width: 16.adaptSize,
                    ),
                  ),
                  prefixConstraints: BoxConstraints(maxHeight: 46.v),
                  suffix: InkWell(
                    onTap: () {
                      provider.changePasswordVisibility();
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(30.h, 15.v, 8.h, 15.v),
                      child: CustomImageView(
                        imagePath: ImageConstant.imgFisseye,
                        height: 16.adaptSize,
                        width: 16.adaptSize,
                      ),
                    ),
                  ),
                  suffixConstraints: BoxConstraints(maxHeight: 46.v),
                  validator: (value) {
                    if (value == null ||
                        (!isValidPassword(value, isRequired: true))) {
                      return "err_msg_please_enter_valid_password".tr;
                    }
                    return null;
                  },
                  obscureText: provider.isShowPassword);
            },
          ),
        )
      ],
    );
  }

  /// Navigates to the homescreenScreen when the action is triggered.
  onTapFiSsArrowSmallLeft(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.homescreenScreens,
    );
  }

  /// Navigates to the homescreenScreen when the action is triggered.
  onTapSaveChanges(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.homescreenScreens,
    );
  }

  // show the image picker options
  void _showOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.only(bottom: 150, left: 100, right: 1, top: 20),
          child: Wrap(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
                child: const Column(
                  children: <Widget>[
                    Icon(
                      Icons.image,
                      size: 60,
                    ),
                    Text(
                      'Gallery',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromCamera();
                },
                child: const Column(
                  children: <Widget>[
                    Icon(
                      Icons.camera_alt,
                      size: 60,
                    ),
                    Text(
                      'Camera',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// from camera
  Future _getImageFromCamera() async {
    var pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (pickedFile == null) {
      return;
    }

    var image = File(pickedFile.path);

    var path = image.path;
    var imageDecode = img.decodeImage(image.readAsBytesSync());

    path = '${path.substring(0, path.lastIndexOf('.'))}.png';
    await image.rename(path).then((onValue) {
      onValue.writeAsBytesSync(img.encodePng(imageDecode!));
      setState(() {
        fileImages = onValue;
      });
    });
  }

// from gallery
  Future _getImageFromGallery() async {
    var pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (pickedFile == null) {
      return;
    }

    var image = File(pickedFile.path);

    if (UniversalPlatform.isIOS) {
      var path = image.path;
      var imageDecode = img.decodeImage(image.readAsBytesSync());

      path = '${path.substring(0, path.lastIndexOf('.'))}.png';
      await image.rename(path).then((onValue) {
        onValue.writeAsBytesSync(img.encodePng(imageDecode!));
        setState(() {
          fileImages = onValue;
        });
      });
    } else {
      setState(() {
        fileImages = image;
      });
    }
  }
}
