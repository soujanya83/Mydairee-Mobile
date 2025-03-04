class ExtrasModel {
  String idExtra;
  String idSubActivity;
  String title;
  String checked;
  String addedAt;
  String addedBy;

  ExtrasModel(
      {required this.idExtra,
      required this.idSubActivity,
      required this.title,
      required this.checked,
      required this.addedAt,
      required this.addedBy});

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
