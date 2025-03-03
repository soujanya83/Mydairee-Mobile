class LessonChildSubModel {
  String childId;
  String childName;
  String imageUrl;
  List<LessonChildProcessModel> lessonProcess;

  LessonChildSubModel(
      {this.childId, this.childName, this.imageUrl, this.lessonProcess});

  static LessonChildSubModel fromJson(Map<String, dynamic> json) {
    return LessonChildSubModel(
      childId: json['child_id'],
      childName: json['child_name'],
      imageUrl: json['child_imageUrl'],
    );
  }
}

class LessonChildProcessModel {
  String activity;
  String subactivity;
  String subTitle;

  LessonChildProcessModel({
    this.activity,
    this.subactivity,
    this.subTitle,
  });

  static LessonChildProcessModel fromJson(Map<String, dynamic> json) {
    return LessonChildProcessModel(
      activity: json['activity'],
      subactivity: json['subactivity'],
      subTitle: json['sub_title'],
    );
  }
}
