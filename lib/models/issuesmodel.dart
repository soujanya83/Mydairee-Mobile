class IssuesModel {
  String id;
  String qipId;
  String elementId;
  String issueIdentified;
  String outcome;
  String priority;
  String expectedDate;
  String successMeasure;
  String howToGetOutcome;
  String addedBy;
  String status;
  String addedAt;
  String userImg;

  IssuesModel({
    required this.id,
    required this.qipId,
    required this.elementId,
    required this.issueIdentified,
    required this.outcome,
    required this.priority,
    required this.expectedDate,
    required this.successMeasure,
    required this.howToGetOutcome,
    required this.addedBy,
    required this.status,
    required this.addedAt,
    required this.userImg,
  });

  static IssuesModel fromJson(Map<String, dynamic> json) {
    return IssuesModel(
      id: json['id'] ?? '',
      qipId: json['qip_id'] ?? '',
      elementId: json['element_id'] ?? '',
      issueIdentified: json['issueIdentified'] ?? '',
      outcome: json['outcome'] ?? '',
      priority: json['priority'] ?? '',
      expectedDate: json['expectedDate'] ?? '',
      successMeasure: json['successMeasure'] ?? '',
      howToGetOutcome: json['howToGetOutcome'] ?? '',
      addedBy: json['added_by'] ?? '',
      status: json['status'] ?? '',
      addedAt: json['added_at'] ?? '',
      userImg: json['user_img'] ?? '',
    );
  }
}
