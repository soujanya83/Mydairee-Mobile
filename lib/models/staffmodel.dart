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
      {this.userid,
      this.emailid,
      this.id,
      this.dob,
      this.password,
      this.contactNo,
      this.name,
      this.imageUrl,
      this.userType,
      this.title,
      this.authToken,
      this.deviceid,
      this.devicetype,
      this.companyLogo,
      this.gender,
      this.selected});

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
