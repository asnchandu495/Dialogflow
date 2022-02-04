// To parse this JSON data, do
//
//     final customPayload = customPayloadFromJson(jsonString);

import 'dart:convert';

class CustomPayload {
  CustomPayload({
    this.richContent,
    this.contentTitle,
  });

  List<List<RichContent>>? richContent;
  String? contentTitle;

  factory CustomPayload.fromRawJson(String str) => CustomPayload.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CustomPayload.fromJson(Map<String, dynamic> json) => CustomPayload(
    richContent: json["richContent"] == null ? null : List<List<RichContent>>.from(json["richContent"].map((x) => List<RichContent>.from(x.map((x) => RichContent.fromJson(x))))),
    contentTitle: json["contentTitle"] == null ? null : json["contentTitle"],
  );

  Map<String, dynamic> toJson() => {
    "richContent": richContent == null ? null : List<dynamic>.from(richContent!.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
    "contentTitle": contentTitle == null ? null : contentTitle,
  };
}

class RichContent {
  RichContent({
    this.title,
    this.type,
  });

  String? title;
  String? type;

  factory RichContent.fromRawJson(String str) => RichContent.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RichContent.fromJson(Map<String, dynamic> json) => RichContent(
    title: json["title"] == null ? null : json["title"],
    type: json["type"] == null ? null : json["type"],
  );

  Map<String, dynamic> toJson() => {
    "title": title == null ? null : title,
    "type": type == null ? null : type,
  };
}
