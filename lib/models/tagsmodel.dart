class TagsModel {
  String id;
  String tags;
  String count;
  String lastModified;

  TagsModel({
    this.id,
    this.tags,
    this.count,
    this.lastModified,
  });

  static TagsModel fromJson(Map<String, dynamic> json) {
    return TagsModel(
      id: json['id'],
      tags: json['tags'],
      count: json['count'],
      lastModified: json['last_modified'],
    );
  }
}
