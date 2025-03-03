
class ParentModel{
  
  String userid;
  String username;
  String emailid;
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
  String deviceid;
  String devicetype;
  String companyLogo;

  ParentModel({
    this.userid,
    this.username,
    this.emailid,
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
    this.status
    });

  static ParentModel fromJson(Map<String,dynamic> json){
    return ParentModel(
      userid: json['userid'],
      username: json['username'],
      emailid: json['emailId'],
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
      status: json['status']
    );
  }
}

