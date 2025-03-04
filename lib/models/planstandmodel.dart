class PlanStandModel {
  String id;
  String roomid;
  String startDate;
  String endDate;
  String createdAt;
  String createdBy;
  String checked;
  bool boolCheck;
  String updatedAt;
  String updatedBy;

  PlanStandModel(
      {required this.id,
      required this.roomid,
      required this.startDate,
      required this.endDate,
      required this.createdAt,
      required this.createdBy,
      required this.checked,
      required this.boolCheck,
      required this.updatedAt,
      required this.updatedBy});

  static PlanStandModel fromJson(Map<String, dynamic> json) {
    return PlanStandModel(
      id: json['id'],
      roomid: json['room_id'],
      startDate: json['startdate'],
      endDate: json['enddate'],
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      checked: json['checked'],
      boolCheck:
          json['checked'] != null && json['checked'] != 'null' ? true : false,
      updatedAt: json['updatedAt'],
      updatedBy: json['updatedBy'],
    );
  }
}
