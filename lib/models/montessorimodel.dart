import 'package:mykronicle_mobile/models/extrasmodel.dart';

class MontessoriModel {
  String outcomeId;
  String idSubject;
  String name;
  bool choosen;
  List<MontessoriActivityModel> activity;

  MontessoriModel(
      {this.outcomeId, this.idSubject, this.name, this.choosen, this.activity});

  static MontessoriModel fromJson(Map<String, dynamic> json) {
    return MontessoriModel(
        outcomeId: json['outcomeId'],
        idSubject: json['idSubject'],
        name: json['name'],
        choosen: false);
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

  MontessoriActivityModel(
      {this.idActivity,
      this.idSubActivity,
      this.idSubject,
      this.title,
      this.subject,
      this.choosen,
      this.addedBy,
      this.addedAt,
      this.subActivity,
      this.checked,
      this.boolCheck});

  static MontessoriActivityModel fromJson(Map<String, dynamic> json) {
    return MontessoriActivityModel(
      idActivity: json['idActivity'],
      idSubActivity: json['idSubActivity'],
      idSubject: json['idSubject'],
      title: json['title'],
      subject: json['subject'],
      choosen: false,
      checked: json['checked'],
      addedAt: json['added_at'],
      addedBy: json['added_by'],
      boolCheck:
          json['checked'] != null && json['checked'] != 'null' ? true : false,
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

  MontessoriSubActivityModel(
      {this.idSubActivity,
      this.title,
      this.subject,
      this.checked,
      this.addedBy,
      this.addedAt,
      this.extrasModel});

  static MontessoriSubActivityModel fromJson(Map<String, dynamic> json) {
    return MontessoriSubActivityModel(
      idSubActivity: json['idSubActivity'],
      title: json['title'],
      subject: json['subject'],
      addedAt: json['added_at'],
      addedBy: json['added_by'],
      checked: json['checked'],
    );
  }
}
