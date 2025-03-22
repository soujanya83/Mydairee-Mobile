class ChildsAccidentsModel {
  String id;
  String name;
  String lastname;
  String dob;
  String startDate;
  String room;
  String imageUrl;
  String gender;
  String status;
  String daysAttending;
  String createdBy;
  String createdAt;

  ChildsAccidentsModel({
    required this.id,
    required this.name,
    required this.lastname,
    required this.dob,
    required this.startDate,
    required this.room,
    required this.imageUrl,
    required this.gender,
    required this.status,
    required this.daysAttending,
    required this.createdBy,
    required this.createdAt,
  });

  static ChildsAccidentsModel fromJson(Map<String, dynamic> json) {
    return ChildsAccidentsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      dob: json['dob'] ?? '',
      startDate: json['startDate'] ?? '',
      room: json['room'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      gender: json['gender'] ?? '',
      status: json['status'] ?? '',
      daysAttending: json['daysAttending'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
