class ResourceModels {
  String id;
  String title;
  String description;
  Map createdBy;
  String createdAt;
  List media;
  Map likes;
  Map comments;
  String checked;
  bool boolCheck;

  ResourceModels(
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

  static ResourceModels fromJson(Map<String, dynamic> json) {
    return ResourceModels(
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
