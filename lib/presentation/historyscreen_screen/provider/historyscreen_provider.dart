import 'package:flutter/material.dart';
import 'package:delalochu/presentation/historyscreen_screen/models/historyscreen_model.dart';

import '../../../domain/apiauthhelpers/apiauth.dart';
import '../../homescreen_screen/models/connectionhistoryModel.dart';

/// A provider class for the HistoryscreenScreen.
///
/// This provider manages the state of the HistoryscreenScreen, including the
/// current historyscreenModelObj

// ignore_for_file: must_be_immutable
class HistoryscreenProvider extends ChangeNotifier {
  HistoryscreenModel historyscreenModelObj = HistoryscreenModel();
  bool loading = false;
  List<Connection> connectionData = [];
  bool isSelectedSwitch = true;
  bool isapproved = false;

  Future<void> getBroker() async {
    loading = true;
    connectionData = await ApiAuthHelper.fetchConnectionHistory();
    loading = false;
  }

  HistoryscreenProvider() {
    getBroker();
  }
  @override
  void dispose() {
    super.dispose();
  }
}
