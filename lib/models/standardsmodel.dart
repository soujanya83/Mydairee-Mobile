import 'package:mykronicle_mobile/models/usermodel.dart';

class StandardsModel {
  String id;
  String areaId;
  String name;
  String about;
  bool expand;
  List<StandardElementModel> elements;

  StandardsModel(
      {this.id,
      this.areaId,
      this.name,
      this.about,
      this.elements,
      this.expand});

  static StandardsModel fromJson(Map<String, dynamic> json) {
    return StandardsModel(
        id: json['id'],
        areaId: json['areaId'],
        name: json['name'],
        about: json['about'],
        expand: false);
  }
}

class StandardElementModel {
  String id;
  String standardId;
  String name;
  String elementName;
  String about;
  String totalusers;
  String extrausers;
  List<UserModel> users;

  StandardElementModel(
      {this.id,
      this.standardId,
      this.name,
      this.elementName,
      this.about,
      this.totalusers,
      this.extrausers,
      this.users});

  static StandardElementModel fromJson(Map<String, dynamic> json) {
    return StandardElementModel(
      id: json['id'],
      standardId: json['standardId'],
      name: json['name'],
      elementName: json['elementName'],
      about: json['about'],
      totalusers: json['totalusers'],
      extrausers: json['extrausers'],
    );
  }
}
