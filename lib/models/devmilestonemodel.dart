class DevMilestoneModel {
  String id;
  String ageGroup;
  bool choosen;
  List<MainModel> main;

  DevMilestoneModel({
    required this.id,
    required this.ageGroup,
    required this.choosen,
    required this.main,
  });

  static DevMilestoneModel fromJson(Map<String, dynamic> json) {
    return DevMilestoneModel(
      id: json['id'] ?? '',
      ageGroup: json['ageGroup'] ?? '',
      choosen: false,
      main: (json['main'] as List<dynamic>?)
              ?.map((e) => MainModel.fromJson(e))
              .toList() ??
          [],
    );
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

  MainModel({
    required this.id,
    required this.name,
    required this.ageId,
    required this.choosen,
    required this.addedBy,
    required this.checked,
    required this.subjects,
  });

  static MainModel fromJson(Map<String, dynamic> json) {
    return MainModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      ageId: json['ageId'] ?? '',
      addedBy: json['added_by'] ?? '',
      checked: json['checked'] ?? '',
      choosen: false,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => SubjectModel.fromJson(e))
              .toList() ??
          [],
    );
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

  SubjectModel({
    required this.id,
    required this.milestoneid,
    required this.name,
    required this.subject,
    required this.choosen,
    required this.extras,
    required this.boolCheck,
    required this.checked,
    required this.addedBy,
  });

  static SubjectModel fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      milestoneid: json['milestoneid'] ?? '',
      subject: json['subject'] ?? '',
      checked: json['checked'] ?? '',
      addedBy: json['added_by'] ?? '',
      choosen: false,
      boolCheck: json['checked'] != null && json['checked'] != 'null',
      extras: (json['extras'] as List<dynamic>?)
              ?.map((e) => MilestoneExtrasModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MilestoneExtrasModel {
  String id;
  String idsubactivity;
  String title;
  String addedBy;
  String? checked; // Nullable field

  MilestoneExtrasModel({
    required this.id,
    required this.idsubactivity,
    required this.title,
    required this.addedBy,
    this.checked,
  });

  static MilestoneExtrasModel fromJson(Map<String, dynamic> json) {
    return MilestoneExtrasModel(
      id: json['id'] ?? '',
      idsubactivity: json['idsubactivity'] ?? '',
      title: json['title'] ?? '',
      addedBy: json['added_by'] ?? '',
      checked: json['checked'],
    );
  }
}
