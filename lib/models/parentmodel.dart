class ParentModel {
  String userId;
  String userName;
  String emailId;
  String password;
  String contactNo;
  String name;
  String dob;
  String gender;
  String imageUrl;
  String userType;
  String title;
  String status;
  String authToken;
  String deviceId;
  String deviceType;
  String companyLogo;

  ParentModel({
    required this.userId,
    required this.userName,
    required this.emailId,
    required this.dob,
    required this.password,
    required this.contactNo,
    required this.name,
    required this.imageUrl,
    required this.userType,
    required this.title,
    required this.authToken,
    required this.deviceId,
    required this.deviceType,
    required this.companyLogo,
    required this.gender,
    required this.status,
  });

  static ParentModel fromJson(Map<String, dynamic> json) {
    return ParentModel(
      userId: json['userid'] ?? '',
      userName: json['username'] ?? '',
      emailId: json['emailId'] ?? '',
      dob: json['dob'] ?? '',
      password: json['password'] ?? '',
      contactNo: json['contactNo'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      userType: json['userType'] ?? '',
      title: json['title'] ?? '',
      authToken: json['AuthToken'] ?? '',
      deviceId: json['deviceid'] ?? '',
      deviceType: json['devicetype'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      gender: json['gender'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
