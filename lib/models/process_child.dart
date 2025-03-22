class ProcessChildSubModel {
  String childId;
  String childName;
  String processStatus;
  String imageUrl;
  String processactivityid;
  String subid;
  String createdBy;

  ProcessChildSubModel({
    required this.childId,
    required this.childName,
    required this.processStatus,
    required this.imageUrl,
    required this.processactivityid,
    required this.subid,
    required this.createdBy,
  });

  static ProcessChildSubModel fromJson(Map<String, dynamic> json) {
    return ProcessChildSubModel(
      childId: json['child_id'] ?? '',
      childName: json['child_name'] ?? '',
      processStatus: json['process_status'] ?? '',
      imageUrl: json['child_imageUrl'] ?? '',
      processactivityid: json['processactivityid'] ?? '',
      subid: json['subid'] ?? '',
      createdBy: json['created_by'] ?? '',
    );
  }
}
