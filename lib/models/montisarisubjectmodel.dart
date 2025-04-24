// To parse this JSON data, do
//
//     final montessariSubjectModel = montessariSubjectModelFromJson(jsonString);

import 'dart:convert';

MontessariSubjectModel montessariSubjectModelFromJson(String str) =>
    MontessariSubjectModel.fromJson(json.decode(str));

String montessariSubjectModelToJson(MontessariSubjectModel data) =>
    json.encode(data.toJson());

class MontessariSubjectModel {
  String idSubject;
  String name;
  List<Activity> activity;

  MontessariSubjectModel(
      {required this.idSubject,
      required this.name,
      required this.activity, });

  factory MontessariSubjectModel.fromJson(Map<String, dynamic> json) =>
      MontessariSubjectModel(
        idSubject: json["idSubject"],
        name: json["name"],
        activity: List<Activity>.from(
            json["activity"].map((x) => Activity.fromJson(x))), 
      );

  Map<String, dynamic> toJson() => {
        "idSubject": idSubject,
        "name": name,
        "activity": List<dynamic>.from(activity.map((x) => x.toJson())),
      };
}

class Activity {
  String idActivity;
  String idSubject;
  String title;
  dynamic addedBy;
  DateTime addedAt;
  List<SubActivity> subActivity;
  bool choosen;
  Activity({
    required this.idActivity,
    required this.idSubject,
    required this.title,
    required this.addedBy,
    required this.addedAt,
    required this.subActivity,
    required this.choosen,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        choosen: false, //Default
        idActivity: json["idActivity"],
        idSubject: json["idSubject"],
        title: json["title"],
        addedBy: json["added_by"],
        addedAt: DateTime.parse(json["added_at"]),
        subActivity: List<SubActivity>.from(
            json["SubActivity"].map((x) => SubActivity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "idActivity": idActivity,
        "idSubject": idSubject,
        "title": title,
        "added_by": addedBy,
        "added_at": addedAt.toIso8601String(),
        "SubActivity": List<dynamic>.from(subActivity.map((x) => x.toJson())),
      };
}

class SubActivity {
  String idSubActivity;
  String idActivity;
  String title;
  String subject;
  String imageUrl;
  dynamic addedBy;
  DateTime addedAt;
  List<dynamic> extras;

  bool choosen;
  SubActivity({
    required this.idSubActivity,
    required this.idActivity,
    required this.title,
    required this.subject,
    required this.imageUrl,
    required this.addedBy,
    required this.addedAt,
    required this.extras,
    required this.choosen,
  });

  factory SubActivity.fromJson(Map<String, dynamic> json) => SubActivity(
        idSubActivity: json["idSubActivity"],
        idActivity: json["idActivity"],
        title: json["title"],
        subject: json["subject"],
        imageUrl: json["imageUrl"],
        addedBy: json["added_by"],
        addedAt: DateTime.parse(json["added_at"]),
        extras: List<dynamic>.from(json["extras"].map((x) => x)), choosen: false,//Default
      );

  Map<String, dynamic> toJson() => {
        "idSubActivity": idSubActivity,
        "idActivity": idActivity,
        "title": title,
        "subject": subject,
        "imageUrl": imageUrl,
        "added_by": addedBy,
        "added_at": addedAt.toIso8601String(),
        "extras": List<dynamic>.from(extras.map((x) => x)),
      };
}
