class MenuMediaModel {
  String id;
  String filename;
  String type;
  String caption;
  String userId;
  String centerId;
  String uploadedDate;

  MenuMediaModel({
    required this.id,
    required this.filename,
    required this.type,
    required this.caption,
    required this.userId,
    required this.centerId,
    required this.uploadedDate,
  });

  static MenuMediaModel fromJson(Map<String, dynamic> json) {
    return MenuMediaModel(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      type: json['type'] ?? '',
      caption: json['caption'] ?? '',
      userId: json['userid'] ?? '',
      centerId: json['centerid'] ?? '',
      uploadedDate: json['uploadedDate'] ?? '',
    );
  }
}
