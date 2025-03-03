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

  UserModel(
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
      this.relation});

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
        userid: json['userid'],
        emailid: json['emailId'],
        id: json['id'],
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
        relation: json['relation']);
  }
}
