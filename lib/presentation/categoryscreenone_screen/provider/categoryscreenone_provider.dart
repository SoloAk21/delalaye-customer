import 'package:flutter/material.dart';
import 'package:delalochu/presentation/categoryscreenone_screen/models/categoryscreenone_model.dart';

/// A provider class for the CategoryscreenoneScreen.
///
/// This provider manages the state of the CategoryscreenoneScreen, including the
/// current categoryscreenoneModelObj

// ignore_for_file: must_be_immutable
class CategoryscreenoneProvider extends ChangeNotifier {
  TextEditingController typeAnythingController = TextEditingController();

  CategoryscreenoneModel categoryscreenoneModelObj = CategoryscreenoneModel();

  @override
  void dispose() {
    super.dispose();
    typeAnythingController.dispose();
  }
}
