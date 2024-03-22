import 'package:flutter/material.dart';
import 'package:delalochu/presentation/drawerscreen_draweritem/models/drawerscreen_model.dart';

/// A provider class for the DrawerscreenDraweritem.
///
/// This provider manages the state of the DrawerscreenDraweritem, including the
/// current drawerscreenModelObj

// ignore_for_file: must_be_immutable
class DrawerscreenProvider extends ChangeNotifier {
  DrawerscreenModel drawerscreenModelObj = DrawerscreenModel();

  @override
  void dispose() {
    super.dispose();
  }
}
