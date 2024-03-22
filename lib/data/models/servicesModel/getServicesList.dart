// To parse this JSON data, do
//
//     final services = servicesFromJson(jsonString);

import 'dart:convert';

Services servicesFromJson(String str) => Services.fromJson(json.decode(str));

String servicesToJson(Services data) => json.encode(data.toJson());

class Services {
    List<Service>? services;

    Services({
        this.services,
    });

    factory Services.fromJson(Map<String, dynamic> json) => Services(
        services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
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
