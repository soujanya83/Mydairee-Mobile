class RoomAccidentsModel {
  String id;
  String name;
  int capacity;
  String userId;
  String color;
  int ageFrom;
  int ageTo;
  String status;
  String centerId;

  RoomAccidentsModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.userId,
    required this.color,
    required this.ageFrom,
    required this.ageTo,
    required this.status,
    required this.centerId,
  });

  static RoomAccidentsModel fromJson(Map<String, dynamic> json) {
    return RoomAccidentsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      capacity: json['capacity'] != null ? int.parse(json['capacity'].toString()) : 0,
      userId: json['userId'] ?? '',
      color: json['color'] ?? '',
      ageFrom: json['ageFrom'] != null ? int.parse(json['ageFrom'].toString()) : 0,
      ageTo: json['ageTo'] != null ? int.parse(json['ageTo'].toString()) : 0,
      status: json['status'] ?? '',
      centerId: json['centerid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'userId': userId,
      'color': color,
      'ageFrom': ageFrom,
      'ageTo': ageTo,
      'status': status,
      'centerId': centerId,
    };
  }
}
