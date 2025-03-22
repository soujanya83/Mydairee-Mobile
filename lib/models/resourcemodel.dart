class ResourceModel {
  String id;
  String title;
  String description;
  String createdBy;
  String createdAt;
  List<dynamic> media;
  Map<String, dynamic> likes;
  Map<String, dynamic> comments;
  String checked;
  bool boolCheck;

  ResourceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.media,
    required this.likes,
    required this.comments,
    required this.checked,
    required this.boolCheck,
  });

  static ResourceModel fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] ?? '',
      media: json['media'] != null ? List<dynamic>.from(json['media']) : [],
      likes: json['likes'] != null ? Map<String, dynamic>.from(json['likes']) : {},
      comments: json['comments'] != null ? Map<String, dynamic>.from(json['comments']) : {},
      checked: json['checked'] ?? 'false',
      boolCheck: json['checked'] != null && json['checked'] != 'null' && json['checked'] != 'false',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'media': media,
      'likes': likes,
      'comments': comments,
      'checked': checked,
      'boolCheck': boolCheck,
    };
  }
}
