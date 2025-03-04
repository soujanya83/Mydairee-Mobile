
import 'package:mykronicle_mobile/models/areamodel.dart';
import 'package:mykronicle_mobile/models/lawmodel.dart';
import 'package:mykronicle_mobile/models/standardmodel.dart';

class AreaDetailsModel{
  AreaModel area;
  List<LawModel> laws;
  String name;
  List previews;
  List<StandardModel> standards;

  AreaDetailsModel({
   required  this.area,
   required  this.laws,
   required  this.name,
   required  this.previews,
   required  this.standards
    });

  static AreaDetailsModel fromJson(Map<String,dynamic> json){
    return AreaDetailsModel(
      area: json['id'],
      laws: json['laws'],
      name: json['name'],
      previews: json['previews'],
      standards: json['standards']
    );
  }
}


