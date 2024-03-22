// To parse this JSON data, do
//
//     final brokerInfo = brokerInfoFromJson(jsonString);

import 'dart:convert';

List<BrokerInfo> brokerInfoFromJson(String str) =>
    List<BrokerInfo>.from(json.decode(str).map((x) => BrokerInfo.fromJson(x)));

String brokerInfoToJson(List<BrokerInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BrokerInfo {
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

  BrokerInfo({
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

  factory BrokerInfo.fromJson(Map<String, dynamic> json) => BrokerInfo(
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
