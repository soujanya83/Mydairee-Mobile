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

  ChildsAccidentsModel(
      {this.id,
      this.name,
      this.lastname,
      this.dob,
      this.startDate,
      this.room,
      this.imageUrl,
      this.gender,
      this.status,
      this.daysAttending,
      this.createdBy,
      this.createdAt});

   static ChildsAccidentsModel fromJson(Map<String, dynamic> json) {
     return ChildsAccidentsModel(
        id : json['id'],
        name : json['name'],
        lastname : json['lastname'],
        dob : json['dob'],
        startDate : json['startDate'],
        room : json['room'],
        imageUrl : json['imageUrl'],
        gender : json['gender'],
        status : json['status'],
        daysAttending : json['daysAttending'],
        createdBy : json['createdBy'],
        createdAt : json['createdAt'],
     );
   
  }

 
}