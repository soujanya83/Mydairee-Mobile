import 'package:mykronicle_mobile/models/accidents.dart';
import 'package:mykronicle_mobile/models/childaccidentmodel.dart';
import 'package:mykronicle_mobile/models/roommodel.dart';

class AccidentsListModel {
  String status;
  int centerid;
  String date;
  int roomid;
  String roomname;
  String roomcolor;
  List<RoomAccidentsModel> rooms;
  List<ChildsAccidentsModel> childs;
  List<AccidentsModel> accidents;

  AccidentsListModel({
    required this.centerid,
    required this.status,
    required this.date,
    required this.roomid,
    required this.roomname,
    required this.roomcolor,
    required this.rooms,
    required this.childs,
    required this.accidents,
  });

  static AccidentsListModel fromJson(Map<String, dynamic> json) {
    try {
      return AccidentsListModel(
        centerid: json['centerid'] ?? 0,
        status: json['Status'] ?? '',
        date: json['date'] ?? '',
        roomid: json['roomid'] ?? 0,
        roomname: json['roomname'] ?? '',
        roomcolor: json['roomcolor'] ?? '',
        rooms: (json['rooms'] as List<dynamic>?)?.map((e) => RoomAccidentsModel.fromJson(e)).toList() ?? [],
        childs: (json['childs'] as List<dynamic>?)?.map((e) => ChildsAccidentsModel.fromJson(e)).toList() ?? [],
        accidents: (json['accidents'] as List<dynamic>?)?.map((e) => AccidentsModel.fromJson(e)).toList() ?? [],
      );
    } catch (e) {
      return AccidentsListModel(
        centerid: 0,
        status: '',
        date: '',
        roomid: 0,
        roomname: '',
        roomcolor: '',
        rooms: [],
        childs: [],
        accidents: [],
      );
    }
  }
}
