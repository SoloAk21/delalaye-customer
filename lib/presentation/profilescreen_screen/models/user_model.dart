// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  User? user;

  UserModel({
    this.user,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
      };
}

class User {
  int? id;
  String? googleId;
  String? fullName;
  String? email;
  String? phone;
  String? photo;
  String? password;
  String? resetOtp;
  DateTime? resetOtpExpiration;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
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

  factory User.fromJson(Map<String, dynamic> json) => User(
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
