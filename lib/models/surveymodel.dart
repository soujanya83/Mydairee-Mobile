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
      {this.id,
      this.title,
      this.description,
      this.response,
      this.createdBy,
      this.createdByName,
      this.createdAt,
      this.checked,
      this.boolCheck});

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
