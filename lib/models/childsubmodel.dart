class ChildSubModel {
  String childId;
  String childName;
  String dob;
  String imageUrl;

  ChildSubModel({
    required this.childId,
    required this.childName,
    required this.dob,
    required this.imageUrl,
  });

  static ChildSubModel fromJson(Map<String, dynamic> json) {
    return ChildSubModel(
      childId: json['child_id'] ?? '',
      childName: json['child_name'] ?? '',
      dob: json['dob'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class EducatorMediaModel {
  String id;
  String mediaId;
  String userId;
  String name;
  String imageUrl;

  EducatorMediaModel({
    required this.id,
    required this.mediaId,
    required this.userId,
    required this.name,
    required this.imageUrl,
  });

  static EducatorMediaModel fromJson(Map<String, dynamic> json) {
    return EducatorMediaModel(
      id: json['id'] ?? '',
      mediaId: json['mediaId'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class ChildMediaModel {
  String id;
  String mediaId;
  String childId;
  String name;
  String imageUrl;

  ChildMediaModel({
    required this.id,
    required this.mediaId,
    required this.childId,
    required this.name,
    required this.imageUrl,
  });

  static ChildMediaModel fromJson(Map<String, dynamic> json) {
    return ChildMediaModel(
      id: json['id'] ?? '',
      mediaId: json['mediaId'] ?? '',
      childId: json['childId'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
