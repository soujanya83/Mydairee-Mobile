

class ChildGroupsModel{

  String id;
  String name;
  List children;

  ChildGroupsModel({
    required this.id,
    required this.name,
    required this.children
    });

  static ChildGroupsModel fromJson(Map<String,dynamic> json){
    return ChildGroupsModel(
      name: json['name'],
      id: json['id'],
      children: json['children']
    );
  }
}


