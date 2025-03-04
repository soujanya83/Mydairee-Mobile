import 'package:mykronicle_mobile/models/childmodel.dart';

class RoomsModel {
  List<ChildModel> child;
  RoomsDescModel room;
  RoomsModel({required this.child, required this.room});
}

class RoomsDescModel {
  String id;
  String name;
  String capacity;
  String userId;
  String color;
  Map occupancy;
  String ageFrom;
  String ageTo;
  String userName;
  String status;
  String centerid;

  RoomsDescModel(
      {required this.id,
      required this.name,
      required this.capacity,
      required this.userId,
      required this.color,
      required this.occupancy,
      required this.ageFrom,
      required this.ageTo,
      required this.userName,
      required this.status,
      required this.centerid});

  static RoomsDescModel fromJson(Map<String, dynamic> json) {
    return RoomsDescModel(
        id: json['id'],
        name: json['name'],
        capacity: json['capacity'],
        userId: json['userId'],
        color: json['color'],
        occupancy: json['occupancy'],
        ageFrom: json['ageFrom'],
        ageTo: json['ageTo'],
        userName: json['userName'],
        status: json['status'],
        centerid: json['centerid']);
  }
}
