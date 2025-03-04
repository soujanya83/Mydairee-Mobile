class RoomAccidentsModel {
  String id;
  String name;
  String capacity;
  String userId;
  String color;
  String ageFrom;
  String ageTo;
  String status;
  String centerid;

  RoomAccidentsModel(
      {required this.id,
      required this.name,
      required this.capacity,
      required this.userId,
      required this.color,
      required this.ageFrom,
      required this.ageTo,
      required this.status,
      required this.centerid});

   static RoomAccidentsModel fromJson(Map<String, dynamic> json) {
     return RoomAccidentsModel(
        id : json['id'],
        name : json['name'],
        capacity : json['capacity'],
        userId : json['userId'],
        color : json['color'],
        ageFrom : json['ageFrom'],
        ageTo : json['ageTo'],
        status : json['status'],
        centerid : json['centerid'],
     );
   
  }

  
}
