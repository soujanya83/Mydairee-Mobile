class ProcessChildSubModel {
  String childId;
  String childName;
  String processStatus;
  String imageUrl;
  String processactivityid;
  String subid;
  String createdBy;

  ProcessChildSubModel(
      {this.childId,
      this.childName,
      this.processStatus,
      this.imageUrl,
      this.processactivityid,
      this.subid,
      this.createdBy});

  static ProcessChildSubModel fromJson(Map<String, dynamic> json) {
    return ProcessChildSubModel(
        childId: json['child_id'],
        childName: json['child_name'],
        processStatus: json['process_status'],
        imageUrl: json['child_imageUrl'],
        processactivityid: json['processactivityid'],
        subid: json['subid'],
        createdBy: json['created_by']);
  }
}
