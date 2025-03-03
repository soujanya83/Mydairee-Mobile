class AssesmentModel {
  String id;
  String centerid;
  String name;
  String addedBy;
  String addedAt;
  List educators;

  AssesmentModel(
      {this.id,
      this.centerid,
      this.name,
      this.addedBy,
      this.addedAt,
      this.educators});

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
