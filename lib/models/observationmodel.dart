class ObservationModel {
  String id;
  String userId;
  String title;
  String notes;
  String reflection;
  String status;
  String approver;
  String dateAdded;
  String dateModified;
  String userName;
  String approverName;
  List observationChildrens;
  String montessoricount;
  String eylfcount;
  String milestonecount;
  String checked;
  bool boolCheck;
  String observationsMedia;
  String observationsMediaType;

  ObservationModel(
      {required this.id,
      required this.userId,
      required this.title,
      required this.notes,
      required this.reflection,
      required this.status,
      required this.approver,
      required this.dateAdded,
      required this.dateModified,
      required this.userName,
      required this.approverName,
      required this.observationChildrens,
      required this.montessoricount,
      required this.eylfcount,
      required this.milestonecount,
      required this.checked,
      required this.boolCheck,
      required this.observationsMedia,
      required this.observationsMediaType});

  static ObservationModel fromJson(Map<String, dynamic> json) {
    return ObservationModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      notes: json['notes'],
      reflection: json['reflection'],
      status: json['status'],
      approver: json['approver'],
      dateAdded: json['date_added'],
      dateModified: json['date_modified'],
      userName: json['user_name'],
      approverName: json['approverName'],
      observationChildrens: json['observationChildrens'],
      montessoricount: json['montessoricount'],
      eylfcount: json['eylfcount'],
      milestonecount: json['milestonecount'],
      observationsMedia: json.containsKey('observationsMedia')
          ? json['observationsMedia']
          : 'null',
      checked: json['checked'],
      boolCheck:
          json['checked'] != null && json['checked'] != 'null' ? true : false,
      observationsMediaType: json.containsKey('observationsMediaType')
          ? json['observationsMediaType']
          : 'null',
    );
  }
}
