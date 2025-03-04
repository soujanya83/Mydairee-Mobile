class StaffModel {
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
  String gender;
  String selected;

  StaffModel(
      {required this.userid,
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
      required this.gender,
      required this.selected});

  static StaffModel fromJson(Map<String, dynamic> json) {
    return StaffModel(
        userid: json['userid'],
        emailid: json['emailId'],
        id: json['id']??json['userid'],
        dob: json['dob'],
        password: json['password'],
        contactNo: json['contactNo'],
        name: json['name'],
        imageUrl: json['imageUrl'],
        userType: json['userType'],
        title: json['title'],
        authToken: json['AuthToken'],
        deviceid: json['deviceid'],
        devicetype: json['devicetype'],
        companyLogo: json['companyLogo'],
        gender: json['gender'],
        selected: json['selected']);
  }
}
