import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var getLessonPlanUrl = Constants.BASE_URL + 'Lessonplan/getlessondetails';

var printLessonPlanUrl = Constants.BASE_URL + 'Lessonplan/printlessonPDF';

var setLessonPlanUrl = Constants.BASE_URL + 'Lessonplan/getlessonstatusdetails';

class LessonPlanApiHandler {
  final Map<String, String> data;

  LessonPlanApiHandler(this.data);

  Future<dynamic> getLessonPlan() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getLessonPlanUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> printPlan() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(printLessonPlanUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> setPlan() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(setLessonPlanUrl, this.data);
    var d = await helper.data();
    return d;
  }
}
