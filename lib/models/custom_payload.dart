// To parse this JSON data, do
//
//     final customPayload = customPayloadFromJson(jsonString);

import 'dart:convert';

class CustomPayload {
  CustomPayload({
    this.contentTitle,
    this.layoutType,
    this.richContent,
    this.outputValue,
  });

  String? contentTitle;
  int? layoutType;
  List<List<RichContent>>? richContent;
  int? outputValue;

  factory CustomPayload.fromRawJson(String str) =>
      CustomPayload.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CustomPayload.fromJson(Map<String, dynamic> json) => CustomPayload(
        contentTitle:
            json["contentTitle"] == null ? null : json["contentTitle"],
        layoutType: json["layoutType"] == null ? null : json["layoutType"],
        richContent: json["richContent"] == null
            ? null
            : List<List<RichContent>>.from(json["richContent"].map((x) =>
                List<RichContent>.from(x.map((x) => RichContent.fromJson(x))))),
        outputValue: json["outputValue"] == null ? null : json["outputValue"],
      );

  Map<String, dynamic> toJson() => {
        "contentTitle": contentTitle == null ? null : contentTitle,
        "layoutType": layoutType == null ? null : layoutType,
        "richContent": richContent == null
            ? null
            : List<dynamic>.from(richContent!
                .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        "outputValue": outputValue == null ? null : outputValue,
      };
}

class RichContent {
  RichContent({
    this.type,
    this.title,
    this.subtitle,
    this.options,
  });

  String? type;
  String? title;
  String? subtitle;
  Options? options;

  factory RichContent.fromRawJson(String str) =>
      RichContent.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RichContent.fromJson(Map<String, dynamic> json) => RichContent(
        type: json["type"] == null ? null : json["type"],
        title: json["title"] == null ? null : json["title"],
        subtitle: json["subtitle"] == null ? null : json["subtitle"],
        options:
            json["options"] == null ? null : Options.fromJson(json["options"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "title": title == null ? null : title,
        "subtitle": subtitle == null ? null : subtitle,
        "options": options == null ? null : options!.toJson(),
      };
}

class Options {
  Options({
    this.oType,
    this.days,
    this.weeks,
    this.months,
    this.temperature,
  });

  int? oType;
  List<int>? days;
  List<int>? weeks;
  List<int>? months;
  List<String>? temperature;

  factory Options.fromRawJson(String str) => Options.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Options.fromJson(Map<String, dynamic> json) => Options(
        oType: json["oType"] == null ? null : json["oType"],
        days: json["days"] == null
            ? null
            : List<int>.from(json["days"].map((x) => x)),
        weeks: json["weeks"] == null
            ? null
            : List<int>.from(json["weeks"].map((x) => x)),
        months: json["months"] == null
            ? null
            : List<int>.from(json["months"].map((x) => x)),
        temperature: json["temperature"] == null
            ? null
            : List<String>.from(json["temperature"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "oType": oType == null ? null : oType,
        "days": days == null ? null : List<dynamic>.from(days!.map((x) => x)),
        "weeks":
            weeks == null ? null : List<dynamic>.from(weeks!.map((x) => x)),
        "months":
            months == null ? null : List<dynamic>.from(months!.map((x) => x)),
        "temperature": temperature == null
            ? null
            : List<dynamic>.from(temperature!.map((x) => x)),
      };
}
