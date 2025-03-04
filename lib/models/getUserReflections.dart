class GetUserReflectionsModel {
  String status;
  List<Reflections> reflections;
  String permission;

  GetUserReflectionsModel({required this.status, required this.reflections, required this.permission});

  static GetUserReflectionsModel fromJson(Map<String, dynamic> json) {
    return GetUserReflectionsModel(
      status: json['Status'],
      reflections: json['Reflections'],
      permission: json['permission'],
    );
  }
}

class Reflections {
  String id;
  String title;
  String about;
  String centerid;
  String status;
  String createdBy;
  String createdAt;
  List media;
  List childs;
  List staffs;

  Reflections(
      {required this.id,
      required this.title,
      required this.about,
      required this.centerid,
      required this.status,
      required this.createdBy,
      required this.createdAt,
      required this.media,
      required this.childs,
      required this.staffs});

  static Reflections fromJson(Map<String, dynamic> json) {
    return Reflections(
      id: json['id'],
      title: json['title'],
      about: json['about'],
      centerid: json['centerid'],
      status: json['status'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'],
      media: json['media'],
      childs: json['childs'],
      staffs: json['staffs'],
    );
  }
}

class Media {
  String id;
  String reflectionid;
  String mediaUrl;
  String mediaType;

  Media({required this.id, required this.reflectionid, required this.mediaUrl, required this.mediaType});

  static Media fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      reflectionid: json['reflectionid'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'],
    );
  }
}

class Childs {
  String childid;
  String name;
  String imageUrl;

  Childs({required this.childid, required this.name, required this.imageUrl});

  static Childs fromJson(Map<String, dynamic> json) {
    return Childs(
      childid: json['childid'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}

class Staffs {
  String userid;
  String name;
  String imageUrl;

  Staffs({required this.userid, required this.name, required this.imageUrl});

  static Staffs fromJson(Map<String, dynamic> json) {
    return Staffs(
      userid: json['userid'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}
