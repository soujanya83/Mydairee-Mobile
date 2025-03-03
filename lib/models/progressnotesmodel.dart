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

  ProgressNotesModel(
      {this.id,
      this.qipId,
      this.elementId,
      this.notetext,
      this.addedBy,
      this.approvedBy,
      this.addedAt,
      this.userImg,
      this.approvedImg});

  static ProgressNotesModel fromJson(Map<String, dynamic> json) {
    return ProgressNotesModel(
        id: json['id'],
        qipId: json['qip_id'],
        elementId: json['element_id'],
        notetext: json['notetext'],
        addedBy: json['added_by'],
        approvedBy: json['approved_by'],
        addedAt: json['added_at'],
        userImg: json['user_img'],
        approvedImg: json['approved_img']);
  }
}
