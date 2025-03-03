
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
    this.area,
    this.laws,
    this.name,
    this.previews,
    this.standards
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


