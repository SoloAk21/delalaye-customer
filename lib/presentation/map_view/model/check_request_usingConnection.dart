// To parse this JSON data, do
//
//     final checkForCustomerRequestModel = checkForCustomerRequestModelFromJson(jsonString);

import 'dart:convert';

CheckForCustomerRequestModel checkForCustomerRequestModelFromJson(String str) =>
    CheckForCustomerRequestModel.fromJson(json.decode(str));

String checkForCustomerRequestModelToJson(CheckForCustomerRequestModel data) =>
    json.encode(data.toJson());

class CheckForCustomerRequestModel {
  bool? hasRequest;
  ConnectionRequests? connectionRequests;

  CheckForCustomerRequestModel({
    this.hasRequest,
    this.connectionRequests,
  });

  factory CheckForCustomerRequestModel.fromJson(Map<String, dynamic> json) =>
      CheckForCustomerRequestModel(
        hasRequest: json["hasRequest"],
        connectionRequests: json["connectionRequests"] == null
            ? null
            : ConnectionRequests.fromJson(json["connectionRequests"]),
      );

  Map<String, dynamic> toJson() => {
        "hasRequest": hasRequest,
        "connectionRequests": connectionRequests?.toJson(),
      };
}

class ConnectionRequests {
  int? id;
  String? reasonForCancellation;
  String? status;
  double? locationLongtude;
  double? locationLatitude;
  String? locationName;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? userId;
  int? brokerId;
  int? serviceId;
  BrokerForRequest? broker;
  UserForRequest? user;
  ServiceForRequest? service;

  ConnectionRequests({
    this.id,
    this.reasonForCancellation,
    this.status,
    this.locationLongtude,
    this.locationLatitude,
    this.locationName,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.brokerId,
    this.serviceId,
    this.broker,
    this.user,
    this.service,
  });

  factory ConnectionRequests.fromJson(Map<String, dynamic> json) =>
      ConnectionRequests(
        id: json["id"],
        reasonForCancellation: json["reasonForCancellation"],
        status: json["status"],
        locationLongtude: json["locationLongtude"]?.toDouble(),
        locationLatitude: json["locationLatitude"]?.toDouble(),
        locationName: json["locationName"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        userId: json["userId"],
        brokerId: json["brokerId"],
        serviceId: json["serviceId"],
        broker: json["broker"] == null
            ? null
            : BrokerForRequest.fromJson(json["broker"]),
        user:
            json["user"] == null ? null : UserForRequest.fromJson(json["user"]),
        service: json["service"] == null
            ? null
            : ServiceForRequest.fromJson(json["service"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reasonForCancellation": reasonForCancellation,
        "status": status,
        "locationLongtude": locationLongtude,
        "locationLatitude": locationLatitude,
        "locationName": locationName,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "userId": userId,
        "brokerId": brokerId,
        "serviceId": serviceId,
        "broker": broker?.toJson(),
        "user": user?.toJson(),
        "service": service?.toJson(),
      };
}

class BrokerForRequest {
  int? id;
  dynamic googleId;
  String? fullName;
  dynamic email;
  String? phone;
  String? password;
  String? photo;
  bool? approved;
  DateTime? approvedDate;
  bool? avilableForWork;
  DateTime? serviceExprireDate;
  double? locationLongtude;
  double? locationLatitude;
  bool? hasCar;
  String? resetOtp;
  DateTime? resetOtpExpiration;
  DateTime? createdAt;
  DateTime? updatedAt;

  BrokerForRequest({
    this.id,
    this.googleId,
    this.fullName,
    this.email,
    this.phone,
    this.password,
    this.photo,
    this.approved,
    this.approvedDate,
    this.avilableForWork,
    this.serviceExprireDate,
    this.locationLongtude,
    this.locationLatitude,
    this.hasCar,
    this.resetOtp,
    this.resetOtpExpiration,
    this.createdAt,
    this.updatedAt,
  });

  factory BrokerForRequest.fromJson(Map<String, dynamic> json) =>
      BrokerForRequest(
        id: json["id"],
        googleId: json["googleId"],
        fullName: json["fullName"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        photo: json["photo"],
        approved: json["approved"],
        approvedDate: json["approvedDate"] == null
            ? null
            : DateTime.parse(json["approvedDate"]),
        avilableForWork: json["avilableForWork"],
        serviceExprireDate: json["serviceExprireDate"] == null
            ? null
            : DateTime.parse(json["serviceExprireDate"]),
        locationLongtude: json["locationLongtude"]?.toDouble(),
        locationLatitude: json["locationLatitude"]?.toDouble(),
        hasCar: json["hasCar"],
        resetOtp: json["resetOtp"],
        resetOtpExpiration: json["resetOtpExpiration"] == null
            ? null
            : DateTime.parse(json["resetOtpExpiration"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "googleId": googleId,
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "password": password,
        "photo": photo,
        "approved": approved,
        "approvedDate": approvedDate?.toIso8601String(),
        "avilableForWork": avilableForWork,
        "serviceExprireDate": serviceExprireDate?.toIso8601String(),
        "locationLongtude": locationLongtude,
        "locationLatitude": locationLatitude,
        "hasCar": hasCar,
        "resetOtp": resetOtp,
        "resetOtpExpiration": resetOtpExpiration?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class ServiceForRequest {
  int? id;
  String? name;
  String? description;
  int? serviceRate;
  String? slug;

  ServiceForRequest({
    this.id,
    this.name,
    this.description,
    this.serviceRate,
    this.slug,
  });

  factory ServiceForRequest.fromJson(Map<String, dynamic> json) =>
      ServiceForRequest(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        serviceRate: json["serviceRate"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "serviceRate": serviceRate,
        "slug": slug,
      };
}

class UserForRequest {
  int? id;
  dynamic googleId;
  String? fullName;
  String? email;
  String? phone;
  dynamic photo;
  String? password;
  String? resetOtp;
  DateTime? resetOtpExpiration;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserForRequest({
    this.id,
    this.googleId,
    this.fullName,
    this.email,
    this.phone,
    this.photo,
    this.password,
    this.resetOtp,
    this.resetOtpExpiration,
    this.createdAt,
    this.updatedAt,
  });

  factory UserForRequest.fromJson(Map<String, dynamic> json) => UserForRequest(
        id: json["id"],
        googleId: json["googleId"],
        fullName: json["fullName"],
        email: json["email"],
        phone: json["phone"],
        photo: json["photo"],
        password: json["password"],
        resetOtp: json["resetOtp"],
        resetOtpExpiration: json["resetOtpExpiration"] == null
            ? null
            : DateTime.parse(json["resetOtpExpiration"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "googleId": googleId,
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "photo": photo,
        "password": password,
        "resetOtp": resetOtp,
        "resetOtpExpiration": resetOtpExpiration?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
