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
      {this.id,
      this.roomid,
      this.startDate,
      this.endDate,
      this.createdAt,
      this.createdBy,
      this.checked,
      this.boolCheck,
      this.updatedAt,
      this.updatedBy});

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
