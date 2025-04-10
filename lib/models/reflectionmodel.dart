class ReflectionModel {
  String id;
  String title;
  String about;
  String status;
  String createdBy;
  String createdAt;
  String checked;
  bool boolCheck;

  ReflectionModel({
    required this.id,
    required this.title,
    required this.about,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    required this.checked,
    required this.boolCheck,
  });

  static ReflectionModel fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      about: json['about'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
      checked: json['checked'] ?? 'false',
      boolCheck: json['checked'] != null && json['checked'] != 'null' && json['checked'] != 'false',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'about': about,
      'status': status,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'checked': checked,
      'boolCheck': boolCheck,
    };
  }
}
