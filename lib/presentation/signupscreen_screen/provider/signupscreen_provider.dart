
import 'package:flutter/material.dart';
import 'package:delalochu/presentation/signupscreen_screen/models/signupscreen_model.dart';

/// A provider class for the SignupscreenScreen.
///
/// This provider manages the state of the SignupscreenScreen, including the
/// current signupscreenModelObj

// ignore_for_file: must_be_immutable
class SignupscreenProvider extends ChangeNotifier {
  TextEditingController userNameController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  SignupscreenModel signupscreenModelObj = SignupscreenModel(password: '',imageFile: '',phoneNumber: '',userName: '');

  bool isShowPassword = true;
  bool isShowconfirmPassword = true;

  @override
  void dispose() {
    super.dispose();
    userNameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void changePasswordVisibility() {
    isShowPassword = !isShowPassword;
    notifyListeners();
  }
  void changeconfirmPasswordVisibility() {
    isShowconfirmPassword = !isShowconfirmPassword;
    notifyListeners();
  }
}
