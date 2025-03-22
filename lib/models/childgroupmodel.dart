class ChildGroupsModel {
  String id;
  String name;
  List<dynamic> children;

  ChildGroupsModel({
    required this.id,
    required this.name,
    required this.children,
  });

  static ChildGroupsModel fromJson(Map<String, dynamic> json) {
    return ChildGroupsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      children: json['children'] ?? [],
    );
  }
}
