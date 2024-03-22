// To parse this JSON data, do
//
//     final brokerRequestModel = brokerRequestModelFromJson(jsonString);

import 'dart:convert';

BrokerRequestModel brokerRequestModelFromJson(String str) =>
    BrokerRequestModel.fromJson(json.decode(str));

String brokerRequestModelToJson(BrokerRequestModel data) =>
    json.encode(data.toJson());

class BrokerRequestModel {
  int? id;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? userId;
  int? brokerId;
  int? serviceId;

  BrokerRequestModel({
    this.id,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.brokerId,
    this.serviceId,
  });

  factory BrokerRequestModel.fromJson(Map<String, dynamic> json) =>
      BrokerRequestModel(
        id: json["id"],
        status: json["status"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        userId: json["userId"],
        brokerId: json["brokerId"],
        serviceId: json["serviceId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "userId": userId,
        "brokerId": brokerId,
        "serviceId": serviceId,
      };
}
