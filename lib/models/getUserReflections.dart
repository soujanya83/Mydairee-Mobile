class GetUserReflectionsModel {
  String status;
  List<Reflections> reflections;
  String permission;

  GetUserReflectionsModel({this.status, this.reflections, this.permission});

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
      {this.id,
      this.title,
      this.about,
      this.centerid,
      this.status,
      this.createdBy,
      this.createdAt,
      this.media,
      this.childs,
      this.staffs});

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

  Media({this.id, this.reflectionid, this.mediaUrl, this.mediaType});

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

  Childs({this.childid, this.name, this.imageUrl});

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

  Staffs({this.userid, this.name, this.imageUrl});

  static Staffs fromJson(Map<String, dynamic> json) {
    return Staffs(
      userid: json['userid'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}
