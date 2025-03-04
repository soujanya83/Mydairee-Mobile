import 'package:mykronicle_mobile/models/usermodel.dart';

class StandardsModel {
  String id;
  String areaId;
  String name;
  String about;
  bool expand;
  List<StandardElementModel> elements;

  StandardsModel({
    required this.id,
    required this.areaId,
    required this.name,
    required this.about,
    required this.elements,
    required this.expand,
  });

  static StandardsModel fromJson(Map<String, dynamic> json) {
    return StandardsModel(
      id: json['id'] ?? '',
      areaId: json['areaId'] ?? '',
      name: json['name'] ?? '',
      about: json['about'] ?? '',
      expand: false,
      elements: (json['elements'] as List<dynamic>?)
              ?.map((e) => StandardElementModel.fromJson(e))
              .toList() ??
          [],
    );
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

  StandardElementModel({
    required this.id,
    required this.standardId,
    required this.name,
    required this.elementName,
    required this.about,
    required this.totalusers,
    required this.extrausers,
    required this.users,
  });

  static StandardElementModel fromJson(Map<String, dynamic> json) {
    return StandardElementModel(
      id: json['id'] ?? '',
      standardId: json['standardId'] ?? '',
      name: json['name'] ?? '',
      elementName: json['elementName'] ?? '',
      about: json['about'] ?? '',
      totalusers: json['totalusers'] ?? '',
      extrausers: json['extrausers'] ?? '',
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => UserModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
