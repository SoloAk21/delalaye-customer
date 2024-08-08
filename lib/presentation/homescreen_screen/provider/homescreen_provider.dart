import 'package:delalochu/presentation/homescreen_screen/models/UsedItemSviceBroker.dart';
import 'package:delalochu/presentation/homescreen_screen/models/houseSaleserviceBroker.dart';
import 'package:flutter/material.dart';
import 'package:delalochu/presentation/homescreen_screen/models/homescreen_model.dart';

import '../../../data/models/servicesModel/getServicesList.dart';
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
  List<HouseSaleBrokerInfo> listOfBrokersWithServece = [];
  List<HouseRantBrokerInfo> houseRantBrokerInfo = [];
  List<HouseMaidBrokerInfo> houseMaidBrokerInfo = [];
  List<CarSaleBrokerInfo> carSaleBrokerinfo = [];
  List<CarRentBrokerInfo> carRentBrokerinfo = [];
  List<UsedItemBrokerInfo> usedItemBrokerInfo = [];
  List<Service>? _serviceList = [];

  bool isLoadingServiceList = false;
  List<Service>? get serviceList => _serviceList;

  bool isSelectedSwitch = true;
  bool isLoadingForData = false;
  bool ishouseRantBrokerInfoLoading = false;
  bool ishouseMaidBrokerInfoLoading = false;
  bool iscarSaleBrokerinfoLoading = false;
  bool iscarRentBrokerinfoLoading = false;
  bool isusedItemBrokerInfoLoading = false;

  HomescreenProvider() {
    isLoadingService(true);
    fetchService();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeSwitchBox1(bool? value) {
    isSelectedSwitch = value!;
    notifyListeners();
  }

  isLoadingData(bool value) {
    isLoadingForData = value;
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

  isLoadingService(bool value) {
    isLoadingServiceList = value;
    notifyListeners();
  }

  fetchService() async {
    _serviceList = await ApiAuthHelper.getservice();
    isLoadingServiceList = false;
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
    listOfBrokersWithServece = await ApiAuthHelper.fetchHouseSaleBrokerData(
      latitude: latitude,
      longitude: longitude,
      serviceId: serviceId,
    );
    isLoadingForData = false;
    notifyListeners();
  }
}
