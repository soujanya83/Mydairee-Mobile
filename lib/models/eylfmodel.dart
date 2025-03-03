class EylfOutcomeModel {
  String outcomeId;
  String title;
  String name;
  bool choosen;
  String id;
  List<EylfActivityModel> activity;

  EylfOutcomeModel(
      {this.outcomeId,
      this.title,
      this.name,
      this.choosen,
      this.id,
      this.activity});

  static EylfOutcomeModel fromJson(Map<String, dynamic> json) {
    return EylfOutcomeModel(
        outcomeId: json['outcomeId'],
        title: json['title'],
        name: json['name'],
        id: json['id'],
        choosen: false);
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

  EylfActivityModel(
      {this.id,
      this.title,
      this.choosen,
      this.addedBy,
      this.subActivity,
      this.checked,
      this.boolCheck});

  static EylfActivityModel fromJson(Map<String, dynamic> json) {
    return EylfActivityModel(
      id: json['id'],
      title: json['title'],
      choosen: false,
      checked: json['checked'],
      addedBy: json['added_by'],
      boolCheck:
          json['checked'] != null && json['checked'] != 'null' ? true : false,
    );
  }
}

class EylfSubActivityModel {
  String id;
  String title;
  String addedBy;
  String checked;

  EylfSubActivityModel({this.id, this.title, this.addedBy, this.checked});

  static EylfSubActivityModel fromJson(Map<String, dynamic> json) {
    return EylfSubActivityModel(
        id: json['id'],
        title: json['title'],
        addedBy: json['added_by'],
        checked: json['checked']);
  }
}
