import 'package:flutter/material.dart';
import 'package:delalochu/presentation/homescreen_screen/models/homescreen_model.dart';

/// A provider class for the HomescreenScreen.
///
/// This provider manages the state of the HomescreenScreen, including the
/// current homescreenModelObj

// ignore_for_file: must_be_immutable
class HomescreenProvider extends ChangeNotifier {
  HomescreenModel homescreenModelObj = HomescreenModel();

  bool isSelectedSwitch = true;

  @override
  void dispose() {
    super.dispose();
  }

  void changeSwitchBox1(bool? value) {
    isSelectedSwitch = value!;
    notifyListeners();
  }
}
