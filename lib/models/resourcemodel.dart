class ResourceModel {
  String id;
  String title;
  String description;
  String createdBy;
  String createdAt;
  List media;
  Map likes;
  Map comments;
  String checked;
  bool boolCheck;

  ResourceModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.createdBy,
      required this.createdAt,
      required this.media,
      required this.likes,
      required this.comments,
      required this.checked,
      required this.boolCheck});

  static ResourceModel fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'],
      media: json['media'],
      likes: json['likes'],
      comments: json['comments'],
      checked: json['checked'],
      boolCheck:
          json['checked'] != null && json['checked'] != 'null' ? true : false,
    );
  }
}
