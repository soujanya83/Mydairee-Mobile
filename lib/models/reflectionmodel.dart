class ReflectionModel {
  String id;
  String title;
  String about;
  String status;
  String createdBy;
  String createdAt;
  String checked;
  bool boolCheck;

  ReflectionModel(
      {this.id,
      this.title,
      this.about,
      this.status,
      this.createdAt,
      this.createdBy,
      this.checked,
      this.boolCheck});

  static ReflectionModel fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'],
      title: json['title'],
      about: json['about'],
      status: json['status'],
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      checked: json['checked'],
      boolCheck:
          json['checked'] != null && json['checked'] != 'null' ? true : false,
    );
  }
}
