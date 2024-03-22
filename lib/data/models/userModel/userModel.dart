// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
    String? token;
    UserClass? user;

    User({
        this.token,
        this.user,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        token: json["token"],
        user: json["user"] == null ? null : UserClass.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "user": user?.toJson(),
    };
}

class UserClass {
    int? id;
    String? fullName;
    dynamic email;
    String? phone;
    String? password;
    String? photo;
    bool? approved;
    int? availablePoints;
    int? totalPoints;
    List<Service>? services;

    UserClass({
        this.id,
        this.fullName,
        this.email,
        this.phone,
        this.password,
        this.photo,
        this.approved,
        this.availablePoints,
        this.totalPoints,
        this.services,
    });

    factory UserClass.fromJson(Map<String, dynamic> json) => UserClass(
        id: json["id"],
        fullName: json["fullName"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        photo: json["photo"],
        approved: json["approved"],
        availablePoints: json["availablePoints"],
        totalPoints: json["totalPoints"],
        services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "password": password,
        "photo": photo,
        "approved": approved,
        "availablePoints": availablePoints,
        "totalPoints": totalPoints,
        "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
    };
}

class Service {
    int? id;
    String? name;
    String? description;
    int? serviceRate;
    String? slug;

    Service({
        this.id,
        this.name,
        this.description,
        this.serviceRate,
        this.slug,
    });

    factory Service.fromJson(Map<String, dynamic> json) => Service(
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
