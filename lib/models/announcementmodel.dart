class AnnouncementModel {
  String id;
  String title;
  String text;
  String eventDate;
  String status;
  String createdBy;
  String createdAt;
  String aid;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.text,
    required this.eventDate,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.aid,
  });

  static AnnouncementModel fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      eventDate: json['eventDate'] ?? '',
      status: json['status'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] ?? '',
      aid: json['aid'] ?? '',
    );
  }
}
