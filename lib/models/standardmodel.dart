
import 'package:mykronicle_mobile/models/elementmodel.dart';

class StandardModel{

  StandardSubModel model;
  List<ElementModel> elements;

  StandardModel({
    this.model,
    this.elements
    });

}


class StandardSubModel{
  String id;
  String areaid;
  String name;
  String about;

  StandardSubModel({
    this.id,
    this.areaid,
    this.name,
    this.about,
    });

  static StandardSubModel fromJson(Map<String,dynamic> json){
    return StandardSubModel(
      id: json['id'],
      areaid: json['areaId'],
      name: json['name'],
      about: json['about'],
    );
  }
}

