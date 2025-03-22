class LessonChildSubModel {
  String childId;
  String childName;
  String imageUrl;
  List<LessonChildProcessModel> lessonProcess;

  LessonChildSubModel({
    required this.childId,
    required this.childName,
    required this.imageUrl,
    required this.lessonProcess,
  });

  static LessonChildSubModel fromJson(Map<String, dynamic> json) {
    return LessonChildSubModel(
      childId: json['child_id'] ?? '',
      childName: json['child_name'] ?? '',
      imageUrl: json['child_imageUrl'] ?? '',
      lessonProcess: (json['lesson_process'] as List<dynamic>?)
              ?.map((e) => LessonChildProcessModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class LessonChildProcessModel {
  String activity;
  String subActivity;
  String subTitle;

  LessonChildProcessModel({
    required this.activity,
    required this.subActivity,
    required this.subTitle,
  });

  static LessonChildProcessModel fromJson(Map<String, dynamic> json) {
    return LessonChildProcessModel(
      activity: json['activity'] ?? '',
      subActivity: json['subactivity'] ?? '',
      subTitle: json['sub_title'] ?? '',
    );
  }
}
