class AccidentsModel {
  String id;
  String childName;
  String childGender;
  String roomid;
  String incidentDate;

  AccidentsModel({
    required this.id,
    required this.childName,
    required this.childGender,
    required this.roomid,
    required this.incidentDate,
  });

  static AccidentsModel fromJson(Map<String, dynamic> json) {
    return AccidentsModel(
      id: json['id'] ?? "",
      childName: json['child_name'] ?? "",
      childGender: json['child_gender'] ?? "",
      roomid: json['roomid'] ?? "",
      incidentDate: json['incident_date'] ?? "",
    );
  }
}