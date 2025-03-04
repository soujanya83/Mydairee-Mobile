import 'dart:io';

class QuestionHelperModel {
  String choosenValue;
  bool mandatory;
  File image;
  File video;
  String question;
  String imgUrl;
  String vidUrl;
  List<String> options1;
  List<String> options2;
  List<String> options3;
  List<String> options4;
  List<String> options5;

  QuestionHelperModel({
    required this.choosenValue,
    required this.mandatory,
    required this.imgUrl,
    required this.vidUrl,
    required this.image,
    required this.video,
    required this.question,
    required this.options1,
    required this.options2,
    required this.options3,
    required this.options4,
    required this.options5,
  });
}
