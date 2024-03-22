import 'package:flutter/material.dart';
import 'package:delalochu/presentation/categoryscreen_screen/models/categoryscreen_model.dart';

/// A provider class for the CategoryscreenScreen.
///
/// This provider manages the state of the CategoryscreenScreen, including the
/// current categoryscreenModelObj

// ignore_for_file: must_be_immutable
class CategoryscreenProvider extends ChangeNotifier {
  TextEditingController typeAnythingController = TextEditingController();

  CategoryscreenModel categoryscreenModelObj = CategoryscreenModel();

  @override
  void dispose() {
    super.dispose();
    typeAnythingController.dispose();
  }
}
