class SurveyModel {
  String id;
  String title;
  String description;
  String response;
  String createdBy;
  String createdByName;
  String createdAt;
  String checked;
  bool boolCheck;

  SurveyModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.response,
      required this.createdBy,
      required this.createdByName,
      required this.createdAt,
      required this.checked,
      required this.boolCheck});

  static SurveyModel fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      response: json['response'].toString(),
      createdBy: json['createdBy'],
      createdByName: json['createdByName'],
      createdAt: json['createdAt'],
      checked: json['checked'],
      boolCheck:
          json['checked'] != null && json['checked'] != 'null' ? true : false,
    );
  }
}
