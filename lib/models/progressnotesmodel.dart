class ProgressNotesModel {
  String id;
  String qipId;
  String elementId;
  String notetext;
  String addedBy;
  String approvedBy;
  String addedAt;
  String userImg;
  String approvedImg;

  ProgressNotesModel({
    required this.id,
    required this.qipId,
    required this.elementId,
    required this.notetext,
    required this.addedBy,
    required this.approvedBy,
    required this.addedAt,
    required this.userImg,
    required this.approvedImg,
  });

  static ProgressNotesModel fromJson(Map<String, dynamic> json) {
    return ProgressNotesModel(
      id: json['id'] ?? '',
      qipId: json['qip_id'] ?? '',
      elementId: json['element_id'] ?? '',
      notetext: json['notetext'] ?? '',
      addedBy: json['added_by'] ?? '',
      approvedBy: json['approved_by'] ?? '',
      addedAt: json['added_at'] ?? '',
      userImg: json['user_img'] ?? '',
      approvedImg: json['approved_img'] ?? '',
    );
  }
}
