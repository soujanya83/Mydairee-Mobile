class ProgPlanModel {
  String id;
  String roomid;
  String name;
  String startDate;
  String endDate;
  String inqTopicTitle;
  String susTopicTitle;
  String inqTopicDetails;
  String susTopicDetails;
  String artExperiments;
  String activityDetails;
  String outdoorActivityDetails;
  String otherExperience;
  String specialActivity;
  String createdAt;
  String createdBy;
  String checked;
  bool boolCheck;

  ProgPlanModel({
    required this.id,
    required this.roomid,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.inqTopicTitle,
    required this.susTopicTitle,
    required this.inqTopicDetails,
    required this.susTopicDetails,
    required this.artExperiments,
    required this.activityDetails,
    required this.outdoorActivityDetails,
    required this.otherExperience,
    required this.specialActivity,
    required this.createdAt,
    required this.createdBy,
    required this.checked,
    required this.boolCheck,
  });

  static ProgPlanModel fromJson(Map<String, dynamic> json) {
    return ProgPlanModel(
      id: json['id'] ?? '',
      roomid: json['roomid'] ?? '',
      name: json['name'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      inqTopicTitle: json['inqTopicTitle'] ?? '',
      susTopicTitle: json['susTopicTitle'] ?? '',
      inqTopicDetails: json['inqTopicDetails'] ?? '',
      susTopicDetails: json['susTopicDetails'] ?? '',
      artExperiments: json['artExperiments'] ?? '',
      activityDetails: json['activityDetails'] ?? '',
      outdoorActivityDetails: json['outdoorActivityDetails'] ?? '',
      otherExperience: json['otherExperience'] ?? '',
      specialActivity: json['specialActivity'] ?? '',
      createdAt: json['createdAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
      checked: json['checked'] ?? '',
      boolCheck: json['checked'] != null && json['checked'] != 'null',
    );
  }
}
