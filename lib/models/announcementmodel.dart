
class AnnouncementModel{
  String id;
  String title;
  String text;
  String eventDate;
  String status;
  String createdBy;
  String createdAt;
  String aid;
  
  AnnouncementModel({
    this.id,
    this.title,
    this.text,
    this.eventDate,
    this.status,
    this.createdBy,
    this.createdAt,
    this.aid
    });

  static AnnouncementModel fromJson(Map<String,dynamic> json){
    return AnnouncementModel(
      id: json['id'],
      title: json['title'],
      text: json['text'],
      eventDate: json['eventDate'],
      status: json['status'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'],
      aid:  json['aid']
    );
  }
}


