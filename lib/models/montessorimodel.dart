import 'package:mykronicle_mobile/models/extrasmodel.dart';

class MontessoriModel {
  String outcomeId;
  String idSubject;
  String name;
  bool choosen;
  List<MontessoriActivityModel> activity;

  MontessoriModel({
    required this.outcomeId,
    required this.idSubject,
    required this.name,
    required this.choosen,
    required this.activity,
  });

  static MontessoriModel fromJson(Map<String, dynamic> json) {
    return MontessoriModel(
      outcomeId: json['outcomeId'] ?? '',
      idSubject: json['idSubject'] ?? '',
      name: json['name'] ?? '',
      choosen: false,
      activity: (json['activity'] as List<dynamic>?)
              ?.map((e) => MontessoriActivityModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MontessoriActivityModel {
  String idActivity;
  String idSubActivity;
  String idSubject;
  String title;
  String subject;
  bool choosen;
  String addedBy;
  String addedAt;
  List<MontessoriSubActivityModel> subActivity;

  String checked;
  bool boolCheck;

  MontessoriActivityModel({
    required this.idActivity,
    required this.idSubActivity,
    required this.idSubject,
    required this.title,
    required this.subject,
    required this.choosen,
    required this.addedBy,
    required this.addedAt,
    required this.subActivity,
    required this.checked,
    required this.boolCheck,
  });

  static MontessoriActivityModel fromJson(Map<String, dynamic> json) {
    return MontessoriActivityModel(
      idActivity: json['idActivity'] ?? '',
      idSubActivity: json['idSubActivity'] ?? '',
      idSubject: json['idSubject'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      choosen: false,
      checked: json['checked'] ?? '',
      addedAt: json['added_at'] ?? '',
      addedBy: json['added_by'] ?? '',
      boolCheck: json['checked'] != null && json['checked'] != 'null',
      subActivity: (json['subActivity'] as List<dynamic>?)
              ?.map((e) => MontessoriSubActivityModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MontessoriSubActivityModel {
  String idSubActivity;
  String title;
  String subject;
  String checked;
  String addedBy;
  String addedAt;
  List<ExtrasModel> extrasModel;

  MontessoriSubActivityModel({
    required this.idSubActivity,
    required this.title,
    required this.subject,
    required this.checked,
    required this.addedBy,
    required this.addedAt,
    required this.extrasModel,
  });

  static MontessoriSubActivityModel fromJson(Map<String, dynamic> json) {
    return MontessoriSubActivityModel(
      idSubActivity: json['idSubActivity'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      addedAt: json['added_at'] ?? '',
      addedBy: json['added_by'] ?? '',
      checked: json['checked'] ?? '',
      extrasModel: (json['extrasModel'] as List<dynamic>?)
              ?.map((e) => ExtrasModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
