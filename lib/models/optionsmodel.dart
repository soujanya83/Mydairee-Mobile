class OptionsModel {
  String id;
  String subActivityId;
  String title;

  OptionsModel({
    required this.id,
    required this.subActivityId,
    required this.title,
  });

  static OptionsModel fromJson(Map<String, dynamic> json) {
    return OptionsModel(
      id: json['id'] ?? '',
      subActivityId: json['idsubactivity'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
