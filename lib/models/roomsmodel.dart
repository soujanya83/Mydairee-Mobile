import 'package:mykronicle_mobile/models/childmodel.dart';

class RoomsModel {
  List<ChildModel> child;
  RoomsDescModel room;
  RoomsModel({this.child, this.room});
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
      {this.id,
      this.name,
      this.capacity,
      this.userId,
      this.color,
      this.occupancy,
      this.ageFrom,
      this.ageTo,
      this.userName,
      this.status,
      this.centerid});

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
