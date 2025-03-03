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
      {this.id,
      this.title,
      this.description,
      this.createdBy,
      this.createdAt,
      this.media,
      this.likes,
      this.comments,
      this.checked,
      this.boolCheck});

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
