// To parse this JSON data, do
//
//     final delalayeTermsAndConditionModel = delalayeTermsAndConditionModelFromJson(jsonString);

import 'dart:convert';

DelalayeTermsAndConditionModel delalayeTermsAndConditionModelFromJson(
        String str) =>
    DelalayeTermsAndConditionModel.fromJson(json.decode(str));

String delalayeTermsAndConditionModelToJson(
        DelalayeTermsAndConditionModel data) =>
    json.encode(data.toJson());

class DelalayeTermsAndConditionModel {
  String? body;

  DelalayeTermsAndConditionModel({
    this.body,
  });

  factory DelalayeTermsAndConditionModel.fromJson(Map<String, dynamic> json) =>
      DelalayeTermsAndConditionModel(
        body: json["body"],
      );

  Map<String, dynamic> toJson() => {
        "body": body,
      };
}
