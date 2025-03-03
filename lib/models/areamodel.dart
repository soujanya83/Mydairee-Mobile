class AreaModel {
  String id;
  String title;
  String color;
  String about;
  double resultPer;

  AreaModel({this.id, this.title, this.color, this.about, this.resultPer});

  static AreaModel fromJson(Map<String, dynamic> json) {
    return AreaModel(
        id: json['id'],
        title: json['title'],
        color: json['color'],
        about: json['about'],
        resultPer: json['resultPer'] != null && json['resultPer'] != ''
            ? (json['resultPer'] / 100)
            : 0);
  }
}
