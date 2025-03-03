class MenuMediaModel {
  String id;
  String filename;
  String type;
  String caption;
  String userid;
  String centerid;
  String uploadedDate;

  MenuMediaModel(
      {this.id,
      this.filename,
      this.type,
      this.caption,
      this.userid,
      this.centerid,
      this.uploadedDate});

  static MenuMediaModel fromJson(Map<String, dynamic> json) {
    return MenuMediaModel(
        id: json['id'],
        filename: json['filename'],
        type: json['type'],
        caption: json['caption'],
        userid: json['userid'],
        centerid: json['centerid'],
        uploadedDate: json['uploadedDate']);
  }
}
