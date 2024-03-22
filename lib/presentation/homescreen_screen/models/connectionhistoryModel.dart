// To parse this JSON data, do
//
//     final connectionHistory = connectionHistoryFromJson(jsonString);

import 'dart:convert';

ConnectionHistory connectionHistoryFromJson(String str) =>
    ConnectionHistory.fromJson(json.decode(str));

String connectionHistoryToJson(ConnectionHistory data) =>
    json.encode(data.toJson());

class ConnectionHistory {
  List<Connection>? connections;

  ConnectionHistory({
    this.connections,
  });

  factory ConnectionHistory.fromJson(Map<String, dynamic> json) =>
      ConnectionHistory(
        connections: json["connections"] == null
            ? []
            : List<Connection>.from(
                json["connections"]!.map((x) => Connection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "connections": connections == null
            ? []
            : List<dynamic>.from(connections!.map((x) => x.toJson())),
      };
}

class Connection {
  int? id;
  String? reasonForCancellation;
  String? status;
  double? locationLongtude;
  double? locationLatitude;
  bool? userHasCalled;
  String? locationName;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? userId;
  int? brokerId;
  int? serviceId;
  BrokerConnectionHistory? broker;

  Connection({
    this.id,
    this.reasonForCancellation,
    this.status,
    this.locationLongtude,
    this.locationLatitude,
    this.userHasCalled,
    this.locationName,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.brokerId,
    this.serviceId,
    this.broker,
  });

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        id: json["id"],
        reasonForCancellation: json["reasonForCancellation"],
        status: json["status"],
        locationLongtude: json["locationLongtude"]?.toDouble(),
        locationLatitude: json["locationLatitude"]?.toDouble(),
        userHasCalled: json["userHasCalled"],
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
            : BrokerConnectionHistory.fromJson(json["broker"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reasonForCancellation": reasonForCancellation,
        "status": status,
        "locationLongtude": locationLongtude,
        "locationLatitude": locationLatitude,
        "userHasCalled": userHasCalled,
        "locationName": locationName,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "userId": userId,
        "brokerId": brokerId,
        "serviceId": serviceId,
        "broker": broker?.toJson(),
      };
}

class BrokerConnectionHistory {
  int? id;
  String? googleId;
  String? fullName;
  String? email;
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
  double? averageRating;

  BrokerConnectionHistory({
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
    this.averageRating,
  });

  factory BrokerConnectionHistory.fromJson(Map<String, dynamic> json) =>
      BrokerConnectionHistory(
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
        averageRating: json["averageRating"]?.toDouble(),
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
        "averageRating": averageRating,
      };
}
