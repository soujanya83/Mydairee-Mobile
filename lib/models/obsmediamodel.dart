class ObsMediaModel {
  String id;
  String observationId;
  String mediaUrl;
  String mediaType;

  ObsMediaModel({
    required this.id,
    required this.observationId,
    required this.mediaUrl,
    required this.mediaType, 
  });

  static ObsMediaModel fromJson(Map<String, dynamic> json) {
    return ObsMediaModel(
      id: json['id'] ?? '',
      observationId: json['observationId'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? '',
    );
  }
}
