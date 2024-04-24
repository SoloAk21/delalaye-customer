import 'dart:io';

import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/core/utils/image_tools.dart';
import 'package:delalochu/presentation/forgotPassword/models/otpCodeModel.dart';
import 'package:delalochu/presentation/signupscreen_screen/models/signupscreen_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../core/utils/progress_dialog_utils.dart';
import '../../domain/apiauthhelpers/apiauth.dart';
import '../../widgets/custom_text_form_field.dart';
import '../signupscreen_screen/provider/signupscreen_provider.dart';
import 'provider/otp_code_verification_provider.dart';

class OTPCodeVerificationScreen extends StatefulWidget {
  const OTPCodeVerificationScreen({Key? key}) : super(key: key);

  @override
  OTPCodeVerificationScreenState createState() =>
      OTPCodeVerificationScreenState();

  static Widget builder(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => OTPCodeVerificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SignupscreenProvider(),
        )
      ],
      child: OTPCodeVerificationScreen(),
    );
  }

  static OtpCodeVerificationModel getArguments(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null) {
      return route.settings.arguments as OtpCodeVerificationModel;
    }
    throw Exception("Arguments not found");
  }
}

// ignore_for_file: must_be_immutable
class OTPCodeVerificationScreenState extends State<OTPCodeVerificationScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? phoneNumber;
  bool isContinueClicked = false;

  var otpController;

  String? otpCode;

  bool isverified = false;

  String? password;
  String? confirmPassword;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final OtpCodeVerificationModel otpCodeVerificationModel =
        OTPCodeVerificationScreen.getArguments(context);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 60.v),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 40.h, right: 43.h, bottom: 161.v),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomImageView(
                          imagePath: ImageConstant.imgImage190x258,
                          // height: 90.v,
                          width: 258.h,
                          alignment: Alignment.center,
                        ),
                        SizedBox(height: 17.v),
                        if (!isverified) ...[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Verification',
                              style: TextStyle(
                                color: appTheme.blueGray400,
                                fontSize: 24.fSize,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 18.v),
                          Padding(
                            padding: EdgeInsets.only(left: 3.h),
                            child: Text(
                              'Enter four digit code sent to  ${otpCodeVerificationModel.code}',
                              style: TextStyle(
                                color: appTheme.blueGray400,
                                fontSize: 14.fSize,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 18.v),
                          _buildotpField(context),
                          SizedBox(height: 18.v),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.only(left: 3.h),
                              child: GestureDetector(
                                onTap: () async {
                                  ProgressDialogUtils.showProgressDialog(
                                    context: context,
                                    isCancellable: false,
                                  );
                                  var res = await ApiAuthHelper
                                      .requestForResetePassword(
                                    phonenumber: otpCodeVerificationModel.code,
                                  );
                                  if (res == 'true') {
                                    ProgressDialogUtils.hideProgressDialog();
                                    ProgressDialogUtils.showSnackBar(
                                      context: context,
                                      message:
                                          'We have sent Four digits to ${otpCodeVerificationModel.code} !',
                                    );
                                  } else {
                                    ProgressDialogUtils.hideProgressDialog();
                                    ProgressDialogUtils.showSnackBar(
                                      context: context,
                                      message: '$res',
                                    );
                                    return;
                                  }
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Didnt recive code. ',
                                    style: TextStyle(
                                      color: appTheme.blueGray400,
                                      fontSize: 14.fSize,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Send again?',
                                        style: TextStyle(
                                          color: appTheme.orangeA200,
                                          fontSize: 14.fSize,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (isverified) ...[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Create Password',
                              style: TextStyle(
                                color: appTheme.blueGray400,
                                fontSize: 24.fSize,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 18.v),
                          Padding(
                            padding: EdgeInsets.only(left: 3.h),
                            child: Text(
                              'This password is used when you log in for the second time',
                              style: TextStyle(
                                color: appTheme.blueGray400,
                                fontSize: 14.fSize,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 18.v),
                          _buildPassword(context),
                          SizedBox(height: 12.v),
                          Padding(
                            padding: EdgeInsets.only(left: 3.h),
                            child: Text(
                              "msg_confirm_password".tr,
                              style: TextStyle(
                                color: appTheme.blueGray400,
                                fontSize: 14.fSize,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 3.v),
                          _buildConfirmPassword(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              isverified ? _buildContinueButton(context) : SizedBox(),
              SizedBox(height: 60.v),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildotpField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 1,
        top: 33,
        right: 1,
      ),
      child: PinCodeTextField(
        appContext: context,
        controller: otpController,
        length: 4,
        obscureText: false,
        obscuringCharacter: '*',
        keyboardType: TextInputType.number,
        autoDismissKeyboard: true,
        enableActiveFill: true,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => otpCode = value,
        onCompleted: (value) async {
          ProgressDialogUtils.showProgressDialog(
            context: context,
            isCancellable: false,
          );
          var res = await ApiAuthHelper.checkForOTP(
            otpCode: value,
          );
          if (res == true) {
            ProgressDialogUtils.hideProgressDialog();
            setState(() {
              isverified = true;
            });
          } else {
            ProgressDialogUtils.hideProgressDialog();
            ProgressDialogUtils.showSnackBar(
              context: context,
              message: 'Please enter a valid otp code',
            );
            return;
          }
        },
        pinTheme: PinTheme(
          fieldHeight: 45.v,
          fieldWidth: 45.h,
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(8.h),
          selectedFillColor: Colors.white70,
          activeFillColor: Colors.white70,
          inactiveFillColor: Colors.white70,
          inactiveColor: appTheme.lime900,
          selectedColor: appTheme.orangeA200,
          activeColor: appTheme.lime900,
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildPassword(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 3.h),
      child: Consumer<SignupscreenProvider>(
        builder: (context, provider, child) {
          return CustomTextFormField(
            hintText: "msg_enter_a_password".tr,
            hintStyle: TextStyle(color: appTheme.blueGray400),
            textStyle: TextStyle(color: appTheme.black900),
            textInputType: TextInputType.visiblePassword,
            onChanged: (p0) => password = p0,
            prefix: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.h, vertical: 13.v),
              child: CustomImageView(
                imagePath: ImageConstant.imgFisslock,
                color: appTheme.blueGray400,
                height: 16.adaptSize,
                width: 16.adaptSize,
              ),
            ),
            prefixConstraints: BoxConstraints(maxHeight: 42.v),
            suffix: InkWell(
              onTap: () {
                provider.changePasswordVisibility();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(30.h, 13.v, 8.h, 13.v),
                child: provider.isShowPassword
                    ? Icon(Icons.visibility_off_rounded,
                        color: appTheme.blueGray400)
                    : Icon(Icons.visibility, color: appTheme.blueGray400),
              ),
            ),
            suffixConstraints: BoxConstraints(maxHeight: 42.v),
            validator: (value) {
              if (value == null) {
                return "err_msg_please_enter_valid_password".tr;
              } else if (value.length < 8) {
                return "Passwords must be at least 8 characters";
              }
              return null;
            },
            obscureText: provider.isShowPassword,
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildConfirmPassword(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 3.h),
      child: Consumer<SignupscreenProvider>(
        builder: (context, provider, child) {
          return CustomTextFormField(
              controller: provider.confirmPasswordController,
              hintText: "msg_confirm_password".tr,
              hintStyle: TextStyle(color: appTheme.blueGray400),
              textStyle: TextStyle(color: appTheme.black900),
              textInputType: TextInputType.visiblePassword,
              onChanged: (p0) => confirmPassword = p0,
              prefix: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.h, vertical: 13.v),
                  child: CustomImageView(
                      imagePath: ImageConstant.imgFisslock,
                      color: appTheme.blueGray400,
                      height: 16.adaptSize,
                      width: 16.adaptSize)),
              prefixConstraints: BoxConstraints(maxHeight: 42.v),
              suffix: InkWell(
                onTap: () {
                  provider.changeconfirmPasswordVisibility();
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(30.h, 13.v, 8.h, 13.v),
                  child: provider.isShowconfirmPassword
                      ? Icon(Icons.visibility_off_rounded,
                          color: appTheme.blueGray400)
                      : Icon(Icons.visibility, color: appTheme.blueGray400),
                ),
              ),
              suffixConstraints: BoxConstraints(maxHeight: 42.v),
              validator: (value) {
                if (value == null) {
                  return "err_msg_please_enter_valid_password".tr;
                } else if (value.length < 8) {
                  return "Passwords must be at least 8 characters";
                } else if (confirmPassword != password) {
                  return "Password doesn't match";
                }
                return null;
              },
              obscureText: provider.isShowconfirmPassword);
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildContinueButton(BuildContext context) {
    final OtpCodeVerificationModel otpCodeVerificationModel =
        OTPCodeVerificationScreen.getArguments(context);
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          ProgressDialogUtils.showProgressDialog(
            context: context,
            isCancellable: false,
          );
          var result =
              await ApiAuthHelper.changePassword(newpassword: password);
          if (result) {
            var res = await ApiAuthHelper.login(
              password: password!,
              phoneNumber: otpCodeVerificationModel.code,
            );
            if (res == '') {
              ProgressDialogUtils.hideProgressDialog();
              onTapLogin(context);
              ProgressDialogUtils.showSnackBar(
                context: context,
                message:
                    'Your password is changed successfully and also you have logged in to your account.',
              );
            } else {
              ProgressDialogUtils.hideProgressDialog();
              ProgressDialogUtils.showSnackBar(
                context: context,
                message: '$res',
              );
              return;
            }
          } else {
            ProgressDialogUtils.hideProgressDialog();
            ProgressDialogUtils.showSnackBar(
              context: context,
              message: 'Something went wrong, please try again',
            );
          }
        } else {
          return null;
        }
      },
      child: Container(
        width: 343,
        height: 50,
        padding: const EdgeInsets.only(top: 16, bottom: 10),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Done",
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
    );
  }

  /// Navigates to the signupscreenScreen when the action is triggered.
  onTapLogin(BuildContext context) {
    NavigatorService.pushNamedAndRemoveUntil(
      AppRoutes.homescreenScreens,
      arguments: {},
    );
  }

  /// Navigates to the categoryscreenoneScreen when the action is triggered.
  onTapContinueButton(
    BuildContext context,
    String userName,
    String phoneNumber,
    String password,
    File image,
  ) {
    final convertedbase64Encode = ImageTools.convertImagesToBase64(image);
    NavigatorService.pushNamed(
      AppRoutes.categoryscreenoneScreen,
      arguments: SignupscreenModel(
        imageFile: convertedbase64Encode,
        password: password,
        userName: userName,
        phoneNumber: phoneNumber,
      ),
    );
  }
}
