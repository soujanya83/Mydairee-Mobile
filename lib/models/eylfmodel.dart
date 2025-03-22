class EylfOutcomeModel {
  String outcomeId;
  String title;
  String name;
  bool choosen;
  String id;
  List<EylfActivityModel> activity;

  EylfOutcomeModel({
    required this.outcomeId,
    required this.title,
    required this.name,
    required this.choosen,
    required this.id,
    required this.activity,
  });

  static EylfOutcomeModel fromJson(Map<String, dynamic> json) {
    return EylfOutcomeModel(
      outcomeId: json['outcomeId'] ?? '',
      title: json['title'] ?? '',
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      choosen: false, // Default value
      activity: (json['activity'] as List<dynamic>?)
              ?.map((e) => EylfActivityModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EylfActivityModel {
  String id;
  String title;
  bool choosen;
  String addedBy;
  List<EylfSubActivityModel> subActivity;
  String checked;
  bool boolCheck;

  EylfActivityModel({
    required this.id,
    required this.title,
    required this.choosen,
    required this.addedBy,
    required this.subActivity,
    required this.checked,
    required this.boolCheck,
  });

  static EylfActivityModel fromJson(Map<String, dynamic> json) {
    return EylfActivityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      choosen: false, // Default value
      checked: json['checked'] ?? '',
      addedBy: json['added_by'] ?? '',
      boolCheck: json['checked'] != null && json['checked'] != 'null',
      subActivity: (json['subActivity'] as List<dynamic>?)
              ?.map((e) => EylfSubActivityModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EylfSubActivityModel {
  String id;
  String title;
  String addedBy;
  String checked;

  EylfSubActivityModel({
    required this.id,
    required this.title,
    required this.addedBy,
    required this.checked,
  });

  static EylfSubActivityModel fromJson(Map<String, dynamic> json) {
    return EylfSubActivityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      addedBy: json['added_by'] ?? '',
      checked: json['checked'] ?? '',
    );
  }
}
