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
      {this.id,
      this.centerId,
      this.name,
      this.createdAt,
      this.createdBy,
      this.checked,
      this.boolCheck,
      this.qipName});

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
