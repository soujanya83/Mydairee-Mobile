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

  AccidentsListModel(
      {this.status,
      this.centerid,
      this.date,
      this.roomid,
      this.roomname,
      this.roomcolor,
      this.rooms,
      this.childs,
      this.accidents});

  static  AccidentsListModel fromJson(Map<String, dynamic> json) {
    return AccidentsListModel(
      status : json['Status'],
      centerid : json['centerid'],
      date : json['date'],
      roomid : json['roomid'],
      roomname : json['roomname'],
      roomcolor : json['roomcolor'],
      rooms: json['rooms'],
      childs: json['childs'],
      accidents: json['accidents']
    );

    
   
    
  }

  
}