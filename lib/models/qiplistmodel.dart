class QipListModel {
  String id;
  String centerId;
  String name;
  String createdAt;
  String createdBy;
  String checked;
  bool boolCheck;
  String qipName;

  QipListModel(
      {required this.id,
      required this.centerId,
      required this.name,
      required this.createdAt,
      required this.createdBy,
      required this.checked,
      required this.boolCheck,
      required this.qipName});

  static QipListModel fromJson(Map<String, dynamic> json) {
    return QipListModel(
        id: json['id'],
        centerId: json['centerId'],
        name: json['name'],
        createdBy: json['created_by'],
        createdAt: json['created_at'],
        checked: json['checked'],
        boolCheck:
            json['checked'] != null && json['checked'] != 'null' ? true : false,
        qipName: json['qip_name']);
  }
}
