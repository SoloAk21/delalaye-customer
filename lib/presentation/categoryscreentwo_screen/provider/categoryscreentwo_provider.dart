import 'package:flutter/material.dart';
import 'package:delalochu/presentation/categoryscreentwo_screen/models/categoryscreentwo_model.dart';

/// A provider class for the CategoryscreentwoScreen.
///
/// This provider manages the state of the CategoryscreentwoScreen, including the
/// current categoryscreentwoModelObj

// ignore_for_file: must_be_immutable
class CategoryscreentwoProvider extends ChangeNotifier {
  CategoryscreentwoModel categoryscreentwoModelObj = CategoryscreentwoModel();

  @override
  void dispose() {
    super.dispose();
  }
}
