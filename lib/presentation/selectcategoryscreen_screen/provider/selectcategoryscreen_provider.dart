import 'package:flutter/material.dart';
import 'package:delalochu/presentation/selectcategoryscreen_screen/models/selectcategoryscreen_model.dart';

/// A provider class for the SelectcategoryscreenScreen.
///
/// This provider manages the state of the SelectcategoryscreenScreen, including the
/// current selectcategoryscreenModelObj

// ignore_for_file: must_be_immutable
class SelectcategoryscreenProvider extends ChangeNotifier {
  TextEditingController typeAnythingController = TextEditingController();

  SelectcategoryscreenModel selectcategoryscreenModelObj =
      SelectcategoryscreenModel();

  @override
  void dispose() {
    super.dispose();
    typeAnythingController.dispose();
  }
}
