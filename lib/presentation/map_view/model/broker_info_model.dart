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
  String? bio;
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
  dynamic averageRating;
  List<BrokerAddress>? addresses;
  List<BrokerService>? services;

  BrokerInfo({
    this.id,
    this.googleId,
    this.fullName,
    this.email,
    this.phone,
    this.password,
    this.photo,
    this.bio,
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
    this.addresses,
    this.services,
  });

  factory BrokerInfo.fromJson(Map<String, dynamic> json) => BrokerInfo(
        id: json["id"],
        googleId: json["googleId"],
        fullName: json["fullName"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        photo: json["photo"],
        bio: json["bio"],
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
        averageRating: json["averageRating"],
        addresses: json["addresses"] == null
            ? null
            : List<BrokerAddress>.from(
                json["addresses"].map((x) => BrokerAddress.fromJson(x))),
        services: json["services"] == null
            ? null
            : List<BrokerService>.from(
                json["services"].map((x) => BrokerService.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "googleId": googleId,
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "password": password,
        "photo": photo,
        "bio": bio,
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
        "addresses": addresses == null
            ? null
            : List<dynamic>.from(addresses!.map((x) => x.toJson())),
        "services": services == null
            ? null
            : List<dynamic>.from(services!.map((x) => x.toJson())),
      };
}

class BrokerAddress {
  int? id;
  int? brokerId;
  double? longitude;
  double? latitude;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;

  BrokerAddress({
    this.id,
    this.brokerId,
    this.longitude,
    this.latitude,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory BrokerAddress.fromJson(Map<String, dynamic> json) => BrokerAddress(
        id: json["id"],
        brokerId: json["brokerId"],
        longitude: json["longitude"]?.toDouble(),
        latitude: json["latitude"]?.toDouble(),
        name: json["name"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "brokerId": brokerId,
        "longitude": longitude,
        "latitude": latitude,
        "name": name,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class BrokerService {
  int? id;
  String? name;
  String? description;
  int? serviceRate;
  String? slug;

  BrokerService({
    this.id,
    this.name,
    this.description,
    this.serviceRate,
    this.slug,
  });

  factory BrokerService.fromJson(Map<String, dynamic> json) => BrokerService(
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
