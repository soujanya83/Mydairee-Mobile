class LRModel {
  String id;
  String areaid;
  String nationalLaw;
  String nationalRegulation;
  String associatedElements;
  String status;
  String actions;

  LRModel(
      {required this.id,
      required this.areaid,
      required this.nationalLaw,
      required this.nationalRegulation,
      required this.associatedElements,
      required this.status,
      required this.actions});

  static LRModel fromJson(Map<String, dynamic> json) {
    return LRModel(
        id: json['id'],
        areaid: json['areaid'],
        nationalLaw: json['national_law'],
        nationalRegulation: json['national_regulation'],
        associatedElements: json['associated_elements'],
        status: json['status'],
        actions: json['actions']);
  }
}
