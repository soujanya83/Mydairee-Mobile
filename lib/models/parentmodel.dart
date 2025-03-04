
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
    required this.userid,
    required this.username,
    required this.emailid,
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
    required this.status
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

