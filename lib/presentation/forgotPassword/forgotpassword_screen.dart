import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/core/utils/validation_functions.dart';
import 'package:delalochu/presentation/forgotPassword/models/otpCodeModel.dart';
import 'package:delalochu/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import '../../core/utils/progress_dialog_utils.dart';
import '../../domain/apiauthhelpers/apiauth.dart';
import 'provider/forgotpassword_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ForgotPasswordProvider(),
        child: ForgotPasswordScreen());
  }
}

// ignore_for_file: must_be_immutable
class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? phoneNumber;
  bool isContinueClicked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Reset Password',
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
                            'Please enter you phone number to receive a verification code ',
                            style: TextStyle(
                              color: appTheme.blueGray400,
                              fontSize: 14.fSize,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 18.v),
                        _buildPhoneNumber(context),
                      ],
                    ),
                  ),
                ),
              ),
              _buildContinueButton(context),
              SizedBox(height: 60.v),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildPhoneNumber(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 3.h),
      child: Selector<ForgotPasswordProvider, TextEditingController?>(
        selector: (context, provider) => provider.phonenumberController,
        builder: (context, phoneNumberController, child) {
          return CustomTextFormField(
            controller: phoneNumberController,
            isPhoneNumber: true,
            hintText: "msg_enter_your_phone".tr,
            hintStyle: TextStyle(color: appTheme.blueGray400),
            onChanged: (p0) => phoneNumber = p0,
            textStyle: TextStyle(color: appTheme.black900),
            textInputType: TextInputType.phone,
            prefix: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.h, vertical: 13.v),
                child: CustomImageView(
                    imagePath: ImageConstant.imgPhone,
                    color: appTheme.blueGray400,
                    height: 16.adaptSize,
                    width: 16.adaptSize)),
            prefixConstraints: BoxConstraints(maxHeight: 42.v),
            validator: (value) {
              if (value == '' && !isValidPhone(value)) {
                return "err_msg_please_enter_valid_phone_number".tr;
              }
              return null;
            },
            contentPadding: EdgeInsets.only(
              top: 10.v,
              right: 30.h,
              bottom: 10.v,
            ),
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildContinueButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate() && phoneNumber != null) {
          if (isValidPhone(phoneNumber) &&
                  ((phoneNumber.toString().startsWith('09') ||
                          phoneNumber.toString().startsWith('07')) &&
                      phoneNumber.toString().length == 10) ||
              ((phoneNumber.toString().startsWith('+2519') ||
                      phoneNumber.toString().startsWith('+2517')) &&
                  phoneNumber.toString().length == 13)) {
            ProgressDialogUtils.showProgressDialog(
              context: context,
              isCancellable: false,
            );
            var res = await ApiAuthHelper.requestForResetePassword(
              phonenumber: phoneNumber,
            );
            if (res == 'true') {
              ProgressDialogUtils.hideProgressDialog();
              onTapContinueButton();
              ProgressDialogUtils.showSnackBar(
                context: context,
                message: 'We have sent Four digits to $phoneNumber !',
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
            ProgressDialogUtils.showSnackBar(
              context: context,
              message: 'Please enter a valid phone number',
            );
          }
        } else {
          ProgressDialogUtils.showSnackBar(
            context: context,
            message: 'Please enter your phone number',
          );
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
              "Send",
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

  /// Navigates to the categoryscreenoneScreen when the action is triggered.
  onTapContinueButton() {
    NavigatorService.pushNamed(
      AppRoutes.otpcodeverificationscreen,
      arguments: OtpCodeVerificationModel(
        code: phoneNumber ?? '',
      ),
    );
  }
}
