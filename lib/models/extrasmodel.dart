class ExtrasModel {
  String idExtra;
  String idSubActivity;
  String title;
  String checked;
  String addedAt;
  String addedBy;

  ExtrasModel(
      {this.idExtra,
      this.idSubActivity,
      this.title,
      this.checked,
      this.addedAt,
      this.addedBy});

  static ExtrasModel fromJson(Map<String, dynamic> json) {
    return ExtrasModel(
      idExtra: json['idExtra'],
      idSubActivity: json['idSubActivity'],
      title: json['title'],
      checked: json['checked'],
      addedAt: json['added_at'],
      addedBy: json['added_by'],
    );
  }
}
