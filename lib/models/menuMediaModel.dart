class MenuMediaModel {
  String id;
  String filename;
  String type;
  String caption;
  String userid;
  String centerid;
  String uploadedDate;

  MenuMediaModel(
      {required this.id,
      required this.filename,
      required this.type,
      required this.caption,
      required this.userid,
      required this.centerid,
      required this.uploadedDate});

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
