import 'package:delalochu/presentation/homescreen_screen/models/UsedItemSviceBroker.dart';
import 'package:delalochu/presentation/homescreen_screen/models/houseSaleserviceBroker.dart';
import 'package:flutter/material.dart';
import 'package:delalochu/presentation/homescreen_screen/models/homescreen_model.dart';

import '../../../domain/apiauthhelpers/apiauth.dart';
import '../models/CarRantSviceBroker.dart';
import '../models/CarSaleerviceBroker.dart';
import '../models/HouseMaidSviceBroker.dart';
import '../models/houseRantserviceBroker.dart';

/// A provider class for the HomescreenScreen.
///
/// This provider manages the state of the HomescreenScreen, including the
/// current homescreenModelObj

// ignore_for_file: must_be_immutable
class HomescreenProvider extends ChangeNotifier {
  HomescreenModel homescreenModelObj = HomescreenModel();
  List<HouseSaleBrokerInfo> houseSaleBrokerInfo = [];
  List<HouseRantBrokerInfo> houseRantBrokerInfo = [];
  List<HouseMaidBrokerInfo> houseMaidBrokerInfo = [];
  List<CarSaleBrokerInfo> carSaleBrokerinfo = [];
  List<CarRentBrokerInfo> carRentBrokerinfo = [];
  List<UsedItemBrokerInfo> usedItemBrokerInfo = [];

  bool isSelectedSwitch = true;
  bool ishouseSaleBrokerInfoLoading = false;
  bool ishouseRantBrokerInfoLoading = false;
  bool ishouseMaidBrokerInfoLoading = false;
  bool iscarSaleBrokerinfoLoading = false;
  bool iscarRentBrokerinfoLoading = false;
  bool isusedItemBrokerInfoLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  void changeSwitchBox1(bool? value) {
    isSelectedSwitch = value!;
    notifyListeners();
  }

  isLoadinghouseSaleBrokerInfo(bool value) {
    ishouseSaleBrokerInfoLoading = value;
    notifyListeners();
  }

  isLoadinghouseRantBrokerInfo(bool value) {
    ishouseRantBrokerInfoLoading = value;
    notifyListeners();
  }

  isLoadinghouseMaidBrokerInfo(bool value) {
    ishouseMaidBrokerInfoLoading = value;
    notifyListeners();
  }

  isLoadingcarSaleBrokerinfo(bool value) {
    iscarSaleBrokerinfoLoading = value;
    notifyListeners();
  }

  isLoadingcarRentBrokerinfo(bool value) {
    iscarRentBrokerinfoLoading = value;
    notifyListeners();
  }

  isLoadingusedItemBrokerInfo(bool value) {
    isusedItemBrokerInfoLoading = value;
    notifyListeners();
  }

  fetchBrokerList({latitude, longitude, serviceId}) async {
    if (serviceId == 1) {
      houseSaleBrokerInfo = await ApiAuthHelper.fetchHouseSaleBrokerData(
        latitude: latitude,
        longitude: longitude,
        serviceId: serviceId,
      );
      ishouseSaleBrokerInfoLoading = false;
      notifyListeners();
    } else if (serviceId == 2) {
      houseRantBrokerInfo = await ApiAuthHelper.fetchHouseRantBrokerData(
        latitude: latitude,
        longitude: longitude,
        serviceId: serviceId,
      );
      ishouseRantBrokerInfoLoading = false;
      notifyListeners();
    } else if (serviceId == 3) {
      carSaleBrokerinfo = await ApiAuthHelper.fetchCarSaleBrokerData(
        latitude: latitude,
        longitude: longitude,
        serviceId: serviceId,
      );
      iscarSaleBrokerinfoLoading = false;
      notifyListeners();
    } else if (serviceId == 4) {
      carRentBrokerinfo = await ApiAuthHelper.fetchCarRantBrokerData(
        latitude: latitude,
        longitude: longitude,
        serviceId: serviceId,
      );
      iscarRentBrokerinfoLoading = false;
      notifyListeners();
    } else if (serviceId == 5) {
      houseMaidBrokerInfo = await ApiAuthHelper.fetchHouseMaidBrokerData(
        latitude: latitude,
        longitude: longitude,
        serviceId: serviceId,
      );
      ishouseMaidBrokerInfoLoading = false;
      notifyListeners();
    } else if (serviceId == 6) {
      usedItemBrokerInfo = await ApiAuthHelper.fetchUsedItemBrokerData(
        latitude: latitude,
        longitude: longitude,
        serviceId: serviceId,
      );
      isusedItemBrokerInfoLoading = false;
      notifyListeners();
    }
  }
}
