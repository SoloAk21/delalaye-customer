import 'dart:convert';
import 'dart:io';

import 'package:delalochu/data/models/servicesModel/getServicesList.dart';
import 'package:delalochu/presentation/homescreen_screen/models/CarRantSviceBroker.dart';
import 'package:delalochu/presentation/homescreen_screen/models/CarSaleerviceBroker.dart';
import 'package:delalochu/presentation/homescreen_screen/models/UsedItemSviceBroker.dart';
import 'package:delalochu/presentation/homescreen_screen/models/houseSaleserviceBroker.dart';
import 'package:delalochu/presentation/map_view/model/broker_info_model.dart';
import 'package:delalochu/presentation/map_view/model/broker_request_model.dart';
import 'package:delalochu/presentation/profilescreen_screen/models/user_model.dart';
import 'package:delalochu/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inspireui/utils/logs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/navigator_service.dart';
import '../../core/utils/pref_utils.dart';
import '../../presentation/homescreen_screen/models/HouseMaidSviceBroker.dart';
import '../../presentation/homescreen_screen/models/connectionhistoryModel.dart';
import '../../presentation/homescreen_screen/models/houseRantserviceBroker.dart';

class ApiAuthHelper {
  static String baseURL = "https://api.delalaye.com";
  // static String baseURL = "https://dev-api.delalaye.com";

  static Future<bool> updateProfile(
      {username, phoneNumber, password, image, isnopasandimage}) async {
    try {
      debugPrint('image $image');
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      var userId = PrefUtils.sharedPreferences!.getInt('userId') ?? '';
      var headers = {'x-auth-token': token, 'Content-Type': 'application/json'};
      var request =
          http.Request('PUT', Uri.parse('$baseURL/api/users/profile/$userId'));
      if (isnopasandimage) {
        debugPrint('is no pass and iamge');
        request.body =
            json.encode({"fullName": username, "phone": phoneNumber});
      } else {
        if (password != '' && image == '') {
          debugPrint(' pass and no iamge');

          request.body = json.encode({
            "fullName": username,
            "phone": phoneNumber,
            "password": password
          });
        } else if (password == '' && image != '') {
          debugPrint('is no pass and has iamge $image');
          request.body = json.encode(
              {"fullName": username, "phone": phoneNumber, "photo": image});
        } else if (password != '' && image != '') {
          debugPrint('has pass and iamge');

          request.body = json.encode({
            "fullName": username,
            "phone": phoneNumber,
            "password": password,
            "photo": image
          });
        }
      }
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        debugPrint(await response.stream.bytesToString());
        return true;
      } else {
        debugPrint(await response.stream.bytesToString());
        return false;
      }
    } catch (e, s) {
      debugPrint('updateProfile Error: $e StackTres => $s');
      return false;
    }
  }

  static Future<bool> rateBroker({
    comment,
    brokerId,
    rateValue,
  }) async {
    try {
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      var headers = {'Content-Type': 'application/json', 'x-auth-token': token};
      var request = http.Request(
          'PUT', Uri.parse('$baseURL/api/users/rate-broker/$brokerId'));
      request.body = json.encode({"rating": rateValue, "comment": comment});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        debugPrint(await response.stream.bytesToString());
        return true;
      } else {
        debugPrint(await response.stream.bytesToString());
        return false;
      }
    } catch (e, s) {
      debugPrint('updateProfile Error: $e StackTres => $s');
      return false;
    }
  }

  static Future<List<Service>> getservice() async {
    List<Service> services = [];
    try {
      var request =
          http.Request('GET', Uri.parse('$baseURL/api/broker/services'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Parse the JSON response and return the list of Service objects
        var jsonResponse = json.decode(await response.stream.bytesToString());
        Services servicesData = Services.fromJson(jsonResponse);

        services = servicesData.services ?? [];
      } else {
        debugPrint('Failed to load services: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    }

    return services;
  }

  static Stream<List<BrokerRequestModel>> getBrokerDatastreams(
      {connectionId}) async* {
    List<BrokerRequestModel> brokerdata = [];
    try {
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET', Uri.parse('$baseURL/api/users/request/$connectionId'));

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        BrokerRequestModel res = BrokerRequestModel.fromJson(jsonResponse);
        brokerdata.add(res);
      } else if (response.statusCode == 401) {}
    } catch (e, s) {
      debugPrint('Error: $e StackTres => $s');
    }
    debugPrint('===================> $baseURL/api/users/request/$connectionId');
    yield brokerdata;
  }

  static Future<List<Connection>> fetchConnectionHistory(
      {status, cennectionId}) async {
    List<Connection> listofres = [];
    try {
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      debugPrint('token: ' + token);
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET', Uri.parse('$baseURL/api/users/connection/history'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        for (var item in responseData['connections']) {
          listofres.add(Connection.fromJson(item));
        }
        listofres.sort(
            (a, b) => b.createdAt!.compareTo(a.createdAt ?? DateTime.now()));
      }
    } catch (e, s) {
      debugPrint('cancelBrokerRequest Exception: => $e' 'StackTrace:' '$s');
    }
    return listofres;
  }

  static Future<List<BrokerRequestModel>> getConnectionData(
      {connectionId}) async {
    List<BrokerRequestModel> brokerdata = [];
    try {
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET', Uri.parse('$baseURL/api/users/request/$connectionId'));

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        BrokerRequestModel res = BrokerRequestModel.fromJson(jsonResponse);
        brokerdata.add(res);
      } else if (response.statusCode == 401) {}
    } catch (e, s) {
      debugPrint('Error: $e StackTres => $s');
    }
    debugPrint('===================> $baseURL/api/users/request/$connectionId');
    return brokerdata;
  }

  static Future<UserModel> getUserData() async {
    UserModel brokerdata = UserModel();
    try {
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      debugPrint('token =>$token ');
      var headers = {'x-auth-token': token};
      var request = http.Request('GET', Uri.parse('$baseURL/api/auth/user'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(await response.stream.bytesToString());
        UserModel res = UserModel.fromJson(jsonResponse);
        return res;
      } else if (response.statusCode == 401) {
        PrefUtils.sharedPreferences!.setBool('isLoggedIn', false);
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginscreenScreen);
        return brokerdata;
      } else {
        return brokerdata;
      }
    } catch (e, s) {
      debugPrint('getBrokerData Error: $e StackTres => $s');
      return brokerdata;
    }
  }

  static Future<List<BrokerRequestModel>> getBrokerDatastream({
    usreId,
    serviceId,
    locationName,
    locationLatitude,
    locationLongtude,
  }) async {
    List<BrokerRequestModel> brokerdata = [];
    try {
      debugPrint(
          '$usreId: $serviceId: $locationName: $locationLatitude: $locationLongtude ');
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      debugPrint('token ==> $token');
      var headers = {'Content-Type': 'application/json', 'x-auth-token': token};
      var request =
          http.Request('POST', Uri.parse('$baseURL/api/users/request-broker'));
      request.body = json.encode({
        "brokerId": usreId,
        "serviceId": serviceId,
        "locationName": locationName,
        "locationLatitude": locationLatitude,
        "locationLongtude": locationLongtude
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var req = await response.stream.bytesToString();
        var jsonResponse = json.decode(req);
        BrokerRequestModel res = BrokerRequestModel.fromJson(jsonResponse);
        brokerdata.add(res);
      }
    } catch (e, s) {
      debugPrint('Error: $e StackTres => $s');
    }
    return brokerdata;
  }

  static Future<bool> checkForOTP({otpCode}) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('PUT', Uri.parse('$baseURL/api/users/check-otp'));
      request.body = json.encode({"otp": otpCode});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();
        var jsonResponse = json.decode(res);
        if (jsonResponse['user'] != null) {
          PrefUtils.sharedPreferences!
              .setInt('userId', jsonResponse['user']['id']);
          return true;
        }
      }
    } catch (e, s) {
      debugPrint('updateStatus Error: $e StackTres => $s');
    }
    return false;
  }

  static Future<bool> calltobroker({connectionId}) async {
    try {
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      var headers = {'Content-Type': 'application/json', 'x-auth-token': token};
      var request = http.Request(
          'PUT', Uri.parse('$baseURL/api/users/connection/call/$connectionId'));
      request.body = json.encode({"reason": "1"});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();
        debugPrint('this response => $res');
        return true;
      }
    } catch (e, s) {
      debugPrint('updateStatus Error: $e StackTres => $s');
    }
    return false;
  }

  static Future<bool> directCalltobroker({
    brokerId,
    serviceId,
    locationName,
    locationLatitude,
    locationLongtude,
  }) async {
    try {
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      print(' token ==> $token');
      var headers = {'Content-Type': 'application/json', 'x-auth-token': token};
      var request = http.Request(
          'POST', Uri.parse('$baseURL/api/users/call-broker-directly'));
      print(
          '$brokerId, $serviceId, $locationLatitude, $locationLongtude $locationName');
      request.body = json.encode({
        "brokerId": "$brokerId",
        "serviceId": "$serviceId",
        "locationName": "$locationName",
        "locationLatitude": "$locationLatitude",
        "locationLongtude": "$locationLongtude",
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return true;
      } else {
        print(response.reasonPhrase);
        print(response.statusCode);
        return false;
      }
    } catch (e, s) {
      debugPrint('updateStatus Error: $e StackTres => $s');
      return false;
    }
  }

  static Future<bool> changePassword({newpassword}) async {
    try {
      var userId = PrefUtils.sharedPreferences!.getInt('userId') ?? '';
      // print('================================================================');
      // print('====UserId: ' + userId.toString());
      // print('================================================================');
      if (userId != '') {
        var headers = {'Content-Type': 'application/json'};
        var request = http.Request(
            'PUT', Uri.parse('$baseURL/api/users/reset-password/$userId'));
        request.body = json.encode({"newPassword": newpassword});
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          debugPrint(await response.stream.bytesToString());
          return true;
        } else {
          debugPrint(
              ' debugPrint(await response.stream.bytesToString()); ==> ${await response.stream.bytesToString()}');
          debugPrint(
              ' debugPrint(await response.stream.bytesToString()); ==> ${response.statusCode}');
        }
      } else {
        debugPrint(
            ' debugPrint(await response.stream.bytesToString()); ==> user Id is null ');
      }
    } catch (e, s) {
      debugPrint('changePassword Error: $e StackTres => $s');
    }
    return false;
  }

  static Future<String> requestForResetePassword({phonenumber}) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('PUT', Uri.parse('$baseURL/api/users/forgot-password/'));
      request.body = json.encode({"phone": phonenumber});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        debugPrint(await response.stream.bytesToString());
        return 'true';
      } else if (response.statusCode == 400) {
        var jsonResponse = json.decode(await response.stream.bytesToString());
        var errorMsgs = jsonResponse['errors'] as List<dynamic>;
        if (errorMsgs.isNotEmpty) {
          var firstError = errorMsgs[0];
          var errorMessage = firstError['msg'] ?? 'Unknown error';
          return errorMessage;
        }
        return 'Unknown error';
      } else {
        debugPrint(response.reasonPhrase);
        return 'false';
      }
    } catch (e, s) {
      debugPrint('requestForResetePassword Error: $e StackTres => $s');
      if (e is SocketException) {
        return 'No internet connection, please try again!';
      }
      return 'Something went wrong, please try again';
    }
  }

  static Future<String> signUp({
    required String userName,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse('$baseURL/api/auth/signup/user'));
      request.body = json.encode({
        "fullName": userName,
        "password": password,
        "phone": phoneNumber,
        "googleId": "",
        "email": "$userName@gmail.com"
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var data = json.decode(await response.stream.bytesToString());
        PrefUtils.sharedPreferences!.setString('token', data['token']);
        PrefUtils.sharedPreferences!.setBool('isLoggedIn', true);
        PrefUtils.sharedPreferences!.setInt('userId', data['user']['id']);
        return 'true';
      } else {
        var jsonResponse = json.decode(await response.stream.bytesToString());
        var errorMsgs = jsonResponse['errors'] as List<dynamic>;
        if (errorMsgs.isNotEmpty) {
          var firstError = errorMsgs[0];
          var errorMessage = firstError['msg'] ?? 'Unknown error';
          return errorMessage;
        }
        return '${response.reasonPhrase}';
      }
    } catch (e, s) {
      if (e is SocketException) {
        return 'No internet connection, please try again!';
      }
      debugPrint('Error ==> $e  StackTrace => $s');
      return '$e';
    }
  }

  static Future<String> login({
    required String password,
    required String phoneNumber,
  }) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse('$baseURL/api/auth/user/login'));
      request.body = json.encode({"phone": phoneNumber, "password": password});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var data = json.decode(await response.stream.bytesToString());
        PrefUtils.sharedPreferences!.setString('token', data['token']);
        PrefUtils.sharedPreferences!.setBool('isLoggedIn', true);
        PrefUtils.sharedPreferences!.setInt('userId', data['user']['id']);
        debugPrint('token => ${data['token']}');
        return ''; // Handle success case here if needed
      } else if (response.statusCode == 400) {
        // Parse the error response and return the "msg" value
        var jsonResponse = json.decode(await response.stream.bytesToString());
        var errorMsgs = jsonResponse['errors'] as List<dynamic>;
        if (errorMsgs.isNotEmpty) {
          var firstError = errorMsgs[0];
          var errorMessage = firstError['msg'] ?? 'Unknown error';
          return errorMessage;
        }
        return 'Unknown error';
      } else {
        debugPrint(response.reasonPhrase);
        return response.reasonPhrase.toString();
      }
    } catch (e, s) {
      if (e is SocketException) {
        return 'No internet connection, please try again!';
      }
      debugPrint('Error ==> $e  StackTrace => $s');
      return '$e';
    }
  }

  static Future<String> topupURl({
    required int amount,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var userId = prefs.getInt('userId') ?? '';
      var headers = {'x-auth-token': token, 'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse('$baseURL/api/broker/topup/$userId'));
      request.body = json.encode({"amount": amount});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        var checkoutUrl = jsonResponse["response"]['data']['checkout_url'];
        debugPrint("Checkout URL: $checkoutUrl");
        return checkoutUrl.toString();
      } else if (response.statusCode == 400) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        debugPrint('Error From  ==> $jsonResponse');
        return '';
      } else if (response.statusCode == 401) {
        debugPrint('Error ==> ${response.reasonPhrase}');
        return '';
      } else {
        debugPrint('Error ==> ${response.reasonPhrase}');
        return '';
      }
    } catch (e, s) {
      debugPrint('Error ==> $e  StackTrace => $s');
      return '';
    }
  }

  static Future<String> googleSignIn({
    required String accessToken,
  }) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse('$baseURL/api/auth/user/login/google/'));
      request.body = json.encode({"idToken": "$accessToken"});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var data = json.decode(await response.stream.bytesToString());
        PrefUtils.sharedPreferences!.setString('token', data['token']);
        PrefUtils.sharedPreferences!.setBool('isLoggedIn', true);
        PrefUtils.sharedPreferences!.setInt('userId', data['user']['id']);
        return ''; // Handle success case here if needed
      } else if (response.statusCode == 400) {
        // Parse the error response and return the "msg" value
        var jsonResponse = json.decode(await response.stream.bytesToString());
        var errorMsgs = jsonResponse['errors'] as List<dynamic>;
        if (errorMsgs.isNotEmpty) {
          var firstError = errorMsgs[0];
          var errorMessage = firstError['msg'] ?? 'Unknown error';
          return errorMessage;
        }
        return 'Unknown error';
      } else {
        debugPrint(response.reasonPhrase);
        return response.reasonPhrase.toString();
      }
    } catch (e, s) {
      debugPrint('Error ==> $e  StackTrace => $s');
      if (e is SocketException) {
        return 'No internet connection, please try again!';
      }
      return '$e';
    }
  }

  static Future<List<BrokerInfo>> fetchBrokerData(
      {latitude, longitude, serviceId}) async {
    var brokerInfo = <BrokerInfo>[];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      print('Latitude: $latitude $longitude $serviceId');
      var request = http.Request(
          'GET',
          Uri.parse(
              '$baseURL/api/broker/filter?serviceId=$serviceId&latitude=$latitude&longitude=$longitude'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        if (responseData != []) {
          for (var item in responseData) {
            brokerInfo.add(BrokerInfo.fromJson(item));
          }
        }
        debugPrint('Broker======> ${responseData.toString()}');
      } else {
        debugPrint(
            '==========================> $brokerInfo ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e, s) {
      printLog('fetchBrokerData Exception: $e' 'StackTrace:' '$s');
    }
    return brokerInfo;
  }

  static Future<List<HouseSaleBrokerInfo>> fetchHouseSaleBrokerData(
      {latitude, longitude, serviceId}) async {
    debugPrint(
        '================================> here is a fetchHouseSaleBrokerData');
    var brokerInfo = <HouseSaleBrokerInfo>[];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET',
          Uri.parse(
              '$baseURL/api/broker/filter?serviceId=$serviceId&latitude=$latitude&longitude=$longitude'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        if (responseData != []) {
          for (var item in responseData) {
            brokerInfo.add(HouseSaleBrokerInfo.fromJson(item));
          }
        }
      }
    } catch (e, s) {
      printLog('fetchBrokerData Exception: $e' 'StackTrace:' '$s');
    }
    return brokerInfo;
  }

  static Future<List<HouseRantBrokerInfo>> fetchHouseRantBrokerData(
      {latitude, longitude, serviceId}) async {
    debugPrint(
        '================================> here is a fetchHouseRantBrokerData');
    var brokerInfo = <HouseRantBrokerInfo>[];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET',
          Uri.parse(
              '$baseURL/api/broker/filter?serviceId=$serviceId&latitude=$latitude&longitude=$longitude'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        if (responseData != []) {
          for (var item in responseData) {
            brokerInfo.add(HouseRantBrokerInfo.fromJson(item));
          }
        }
      }
    } catch (e, s) {
      printLog('fetchBrokerData Exception: $e' 'StackTrace:' '$s');
    }
    return brokerInfo;
  }

  static Future<List<HouseMaidBrokerInfo>> fetchHouseMaidBrokerData(
      {latitude, longitude, serviceId}) async {
    debugPrint(
        '================================> here is a fetchHouseMaidBrokerData');
    var brokerInfo = <HouseMaidBrokerInfo>[];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET',
          Uri.parse(
              '$baseURL/api/broker/filter?serviceId=$serviceId&latitude=$latitude&longitude=$longitude'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        if (responseData != []) {
          for (var item in responseData) {
            brokerInfo.add(HouseMaidBrokerInfo.fromJson(item));
          }
        }
      }
    } catch (e, s) {
      printLog('fetchBrokerData Exception: $e' 'StackTrace:' '$s');
    }
    return brokerInfo;
  }

  static Future<List<CarSaleBrokerInfo>> fetchCarSaleBrokerData(
      {latitude, longitude, serviceId}) async {
    debugPrint(
        '================================> here is a fetchCarSaleBrokerData');
    var brokerInfo = <CarSaleBrokerInfo>[];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET',
          Uri.parse(
              '$baseURL/api/broker/filter?serviceId=$serviceId&latitude=$latitude&longitude=$longitude'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        if (responseData != []) {
          for (var item in responseData) {
            brokerInfo.add(CarSaleBrokerInfo.fromJson(item));
          }
        }
      }
    } catch (e, s) {
      printLog('fetchBrokerData Exception: $e' 'StackTrace:' '$s');
    }
    return brokerInfo;
  }

  static Future<List<CarRentBrokerInfo>> fetchCarRantBrokerData(
      {latitude, longitude, serviceId}) async {
    debugPrint(
        '================================> here is a fetchCarRantBrokerData');
    var brokerInfo = <CarRentBrokerInfo>[];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET',
          Uri.parse(
              '$baseURL/api/broker/filter?serviceId=$serviceId&latitude=$latitude&longitude=$longitude'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        if (responseData != []) {
          for (var item in responseData) {
            brokerInfo.add(CarRentBrokerInfo.fromJson(item));
          }
        }
      }
    } catch (e, s) {
      printLog('fetchBrokerData Exception: $e' 'StackTrace:' '$s');
    }
    return brokerInfo;
  }

  static Future<List<UsedItemBrokerInfo>> fetchUsedItemBrokerData(
      {latitude, longitude, serviceId}) async {
    debugPrint(
        '================================> here is a fetchUsedItemBrokerData');
    var brokerInfo = <UsedItemBrokerInfo>[];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET',
          Uri.parse(
              '$baseURL/api/broker/filter?serviceId=$serviceId&latitude=$latitude&longitude=$longitude'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(await response.stream.bytesToString());
        if (responseData != []) {
          for (var item in responseData) {
            brokerInfo.add(UsedItemBrokerInfo.fromJson(item));
          }
        }
      }
    } catch (e, s) {
      printLog('fetchBrokerData Exception: $e' 'StackTrace:' '$s');
    }
    return brokerInfo;
  }

  static Future<bool> cancelBrokerRequest({reason, cennectionId}) async {
    var res = false;
    try {
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      var headers = {'Content-Type': 'application/json', 'x-auth-token': token};
      var request = http.Request('PUT',
          Uri.parse('$baseURL/api/users/connection/cancel/$cennectionId'));
      request.body = json.encode({"reason": reason});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        debugPrint(await response.stream.bytesToString());
        return true;
      } else {
        debugPrint(
            'Request for cancel is not done => $baseURL/api/users/connection/cancel/$cennectionId');
        return false;
      }
    } catch (e, s) {
      printLog('cancelBrokerRequest Exception: => $e' 'StackTrace:' '$s');
    }
    return res;
  }
}
