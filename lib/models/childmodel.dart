class ChildModel {
  String id;
  String name;
  String? dob;
  String? startDate;
  String? room;
  String imageUrl;
  String? gender;
  String? status;
  String? daysAttending;
  String? createdBy;
  String? createdAt;
  Map? recentobs;
  int? draft;
  int? pub;
  Map? breakfast;
  Map morningtea;
  Map lunch;
  List sleep;
  Map afternoontea;
  Map snacks;
  List sunscreen;
  Map toileting;
  String? childid;

  ChildModel(
      {required this.id,
      required this.name,
       this.dob,
       this.startDate,
       this.room,
      required this.imageUrl,
       this.gender,
       this.status,
       this.daysAttending,
       this.createdBy,
       this.createdAt,
       this.recentobs,
       this.draft,
       this.pub,
       this.breakfast,
      required this.morningtea,
     required  this.lunch,
      required this.sleep,
      required this.afternoontea,
      required this.snacks,
      required this.sunscreen,
      required this.toileting,
       this.childid});

  static ChildModel fromJson(Map<String, dynamic> json) {
    return ChildModel(
        id: json['id'],
        name: json['name'],
        dob: json['dob'],
        startDate: json['startDate'],
        room: json['room'],
        imageUrl: json['imageUrl'],
        gender: json['gender'],
        status: json['status'],
        daysAttending: json['daysAttending'],
        createdBy: json['createdBy'],
        createdAt: json['createdAt'],
        recentobs: json['recentobs'],
        draft: json['draft'],
        pub: json['pub'],
        breakfast: json['breakfast'],
        morningtea: json['morningtea'],
        lunch: json['lunch'],
        sleep: json['sleep'],
        afternoontea: json['afternoontea'],
        snacks: json['snacks'],
        sunscreen: json['sunscreen'],
        toileting: json['toileting'],
        childid: json['childid']);
  }
}
