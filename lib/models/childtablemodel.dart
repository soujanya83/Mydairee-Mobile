class ChildTableModel {
  String id;
  String childName;
  String childId;
  String name;
  String image;
  String obsId;
  String obsDate;
  String obsCount;
  String centerid;

  ChildTableModel(
      {required this.id,
      required this.childName,
      required this.childId,
      required this.name,
      required this.image,
      required this.obsId,
      required this.obsDate,
      required this.obsCount,
      required this.centerid});

  static ChildTableModel fromJson(Map<String, dynamic> json) {
    return ChildTableModel(
        id: json['id'],
        childName: json['child_name'],
        childId: json['childId'],
        name: json['name'],
        image: json['image'],
        obsId: json['observationId'],
        obsDate: json['observation_date'],
        obsCount: json['observation_countid'],
        centerid: json['centerid']);
  }
}
