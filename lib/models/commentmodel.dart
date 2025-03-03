class CommentModel {
  String id;
  String qipId;
  String elementId;
  String commentText;
  String addedBy;
  String addedAt;
  String userImg;

  CommentModel({
    this.id,
    this.qipId,
    this.elementId,
    this.commentText,
    this.addedBy,
    this.addedAt,
    this.userImg,
  });

  static CommentModel fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      qipId: json['qipid'],
      elementId: json['element_id'],
      commentText: json['commentText'],
      addedBy: json['added_by'],
      addedAt: json['added_at'],
      userImg: json['user_img'],
    );
  }
}
