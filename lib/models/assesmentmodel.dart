class AssesmentModel {
  String id;
  String centerid;
  String name;
  String addedBy;
  String addedAt;
  List educators;

  AssesmentModel(
      {required this.id,
     required  this.centerid,
     required  this.name,
     required  this.addedBy,
     required  this.addedAt,
     required  this.educators});

  static AssesmentModel fromJson(Map<String, dynamic> json) {
    return AssesmentModel(
        id: json['id'],
        centerid: json['centerid'],
        name: json['name'],
        addedBy: json['added_by'],
        addedAt: json['addedAt'],
        educators: json['educators']);
  }
}
