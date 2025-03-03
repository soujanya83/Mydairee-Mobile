import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var getProgressPlan =
    Constants.BASE_URL + 'Progressplan/getProgressplandetails';

var createProgressPlan = Constants.BASE_URL + 'Progressplan/createPlan';

var updateProgressPlan = Constants.BASE_URL + 'Progressplan/updatePlan';

class ProgressPlanApiHandler {
  final Map<String, String> data;

  ProgressPlanApiHandler(this.data);

  Future<dynamic> getProgressPlanDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getProgressPlan, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> createPlan() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(createProgressPlan, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> updatePlan() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(updateProgressPlan, this.data);
    var d = await helper.data();
    return d;
  }
}
