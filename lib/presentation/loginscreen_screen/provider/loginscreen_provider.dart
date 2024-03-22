import 'package:flutter/material.dart';
import 'package:delalochu/presentation/loginscreen_screen/models/loginscreen_model.dart';

/// A provider class for the LoginscreenScreen.
///
/// This provider manages the state of the LoginscreenScreen, including the
/// current loginscreenModelObj

// ignore_for_file: must_be_immutable
class LoginscreenProvider extends ChangeNotifier {
  TextEditingController phoneNumberController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  LoginscreenModel loginscreenModelObj = LoginscreenModel();

  bool isShowPassword = true;

  @override
  void dispose() {
    super.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
  }

  void changePasswordVisibility() {
    isShowPassword = !isShowPassword;
    notifyListeners();
  }
}
