class CommentModel {
  String id;
  String qipId;
  String elementId;
  String commentText;
  String addedBy;
  String addedAt;
  String userImg;

  CommentModel({
    required this.id,
    required this.qipId,
    required this.elementId,
    required this.commentText,
    required this.addedBy,
    required this.addedAt,
    required this.userImg,
  });

  static CommentModel fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      qipId: json['qipid'] ?? '',
      elementId: json['element_id'] ?? '',
      commentText: json['commentText'] ?? '',
      addedBy: json['added_by'] ?? '',
      addedAt: json['added_at'] ?? '',
      userImg: json['user_img'] ?? '',
    );
  }
}
