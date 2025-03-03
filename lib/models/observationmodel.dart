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
      {this.id,
      this.userId,
      this.title,
      this.notes,
      this.reflection,
      this.status,
      this.approver,
      this.dateAdded,
      this.dateModified,
      this.userName,
      this.approverName,
      this.observationChildrens,
      this.montessoricount,
      this.eylfcount,
      this.milestonecount,
      this.checked,
      this.boolCheck,
      this.observationsMedia,
      this.observationsMediaType});

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
