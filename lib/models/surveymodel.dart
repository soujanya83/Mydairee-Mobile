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

  SurveyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.response,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.checked,
    required this.boolCheck,
  });

  /// Convert JSON to `SurveyModel`
  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      response: json['response']?.toString() ?? '',
      createdBy: json['createdBy'] ?? '',
      createdByName: json['createdByName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      checked: json['checked'] ?? '',
      boolCheck: json['checked'] != null && json['checked'] != 'null',
    );
  }

  /// Convert `SurveyModel` to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'response': response,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt,
      'checked': checked,
      'boolCheck': boolCheck,
    };
  }
}
