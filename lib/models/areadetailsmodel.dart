import 'package:mykronicle_mobile/models/areamodel.dart' show AreaModel;
import 'package:mykronicle_mobile/models/lawmodel.dart' show LawModel;
import 'package:mykronicle_mobile/models/standardmodel.dart' show StandardModel;

class AreaDetailsModel {
  AreaModel area;
  List<LawModel> laws;
  String name;
  List previews;
  List<StandardModel> standards;

  AreaDetailsModel({
    required this.area,
    required this.laws,
    required this.name,
    required this.previews,
    required this.standards,
  });

  static AreaDetailsModel fromJson(Map<String, dynamic> json) {
    return AreaDetailsModel(
      area: AreaModel.fromJson(json['area'] ?? {}),
      laws: (json['laws'] as List<dynamic>?)
              ?.map((e) => LawModel.fromJson(e))
              .toList() ??
          [],
      name: json['name'] ?? '',
      previews: json['previews'] ?? [],
      standards: json['standards'],
    );
  }
}
