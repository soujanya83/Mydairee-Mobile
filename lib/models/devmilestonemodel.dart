class DevMilestoneModel {
  String id;
  String ageGroup;
  bool choosen;
  List<MainModel> main;

  DevMilestoneModel({this.id, this.ageGroup, this.choosen, this.main});

  static DevMilestoneModel fromJson(Map<String, dynamic> json) {
    return DevMilestoneModel(
        id: json['id'], ageGroup: json['ageGroup'], choosen: false);
  }
}

class MainModel {
  String id;
  String name;
  String ageId;
  bool choosen;
  String addedBy;
  String checked;
  List<SubjectModel> subjects;

  MainModel(
      {this.id,
      this.name,
      this.ageId,
      this.choosen,
      this.addedBy,
      this.checked,
      this.subjects});

  static MainModel fromJson(Map<String, dynamic> json) {
    return MainModel(
        id: json['id'],
        name: json['name'],
        ageId: json['ageId'],
        addedBy: json['added_by'],
        checked: json['checked'],
        choosen: false);
  }
}

class SubjectModel {
  String id;
  String milestoneid;
  String name;
  String subject;
  bool choosen;

  String addedBy;
  String checked;
  bool boolCheck;

  List<MilestoneExtrasModel> extras;

  SubjectModel(
      {this.id,
      this.milestoneid,
      this.name,
      this.subject,
      this.choosen,
      this.extras,
      this.boolCheck,
      this.checked,
      this.addedBy});

  static SubjectModel fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      name: json['name'],
      milestoneid: json['milestoneid'],
      choosen: false,
      subject: json['subject'],
      checked: json['checked'],
      addedBy: json['added_by'],
      boolCheck:
          json['checked'] != null && json['checked'] != 'null' ? true : false,
    );
  }
}

class MilestoneExtrasModel {
  String id;
  String idsubactivity;
  String title;
  String addedBy;
  String checked;

  MilestoneExtrasModel(
      {this.id, this.idsubactivity, this.title, this.addedBy, this.checked});

  static MilestoneExtrasModel fromJson(Map<String, dynamic> json) {
    return MilestoneExtrasModel(
        id: json['id'],
        idsubactivity: json['idsubactivity'],
        title: json['title'],
        addedBy: json['added_by'],
        checked: json['checked']);
  }
}
