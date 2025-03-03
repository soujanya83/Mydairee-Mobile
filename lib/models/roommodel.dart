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
      {this.id,
      this.name,
      this.capacity,
      this.userId,
      this.color,
      this.ageFrom,
      this.ageTo,
      this.status,
      this.centerid});

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
