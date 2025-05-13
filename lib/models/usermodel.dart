class UserModel {
  String userid;
  String emailid;
  String id;
  String dob;
  String password;
  String contactNo;
  String name;
  String imageUrl;
  String userType;
  String title;
  String authToken;
  String deviceid;
  String devicetype;
  String companyLogo;
  String relation;
  String userStatus;

  UserModel({
    required this.userid,
    required this.emailid,
    required this.id,
    required this.dob,
    required this.password,
    required this.contactNo,
    required this.name,
    required this.imageUrl,
    required this.userType,
    required this.title,
    required this.authToken,
    required this.deviceid,
    required this.devicetype,
    required this.companyLogo,
    required this.relation,
    required this.userStatus,
  });

  /// Convert JSON to `UserModel`
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userid: json['userid'] ?? '',
      emailid: json['emailId'] ?? '',
      id: json['id'] ?? '',
      dob: json['dob'] ?? '',
      password: json['password'] ?? '',
      contactNo: json['contactNo'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      userType: json['userType'] ?? '',
      title: json['title'] ?? '',
      authToken: json['AuthToken'] ?? '',
      deviceid: json['deviceid'] ?? '',
      devicetype: json['devicetype'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      relation: json['relation'] ?? '',
      userStatus: json['status'] ?? ''
    );
  }

  /// Convert `UserModel` to JSON
  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'emailId': emailid,
      'id': id,
      'dob': dob,
      'password': password,
      'contactNo': contactNo,
      'name': name,
      'imageUrl': imageUrl,
      'userType': userType,
      'title': title,
      'AuthToken': authToken,
      'deviceid': deviceid,
      'devicetype': devicetype,
      'companyLogo': companyLogo,
      'relation': relation,
      'status': userStatus,
    };
  }
}
