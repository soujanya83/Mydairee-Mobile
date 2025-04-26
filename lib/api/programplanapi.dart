import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var getProgramPlanListUrl = Constants.BASE_URL + 'Programplanlist/programPlanList';

var deletePlanUrl = Constants.BASE_URL + 'Programplanlist/delete';

var planDetailsUrl = Constants.BASE_URL + 'Programplanlist/get_details_list';

var planSupportUrl =
    Constants.BASE_URL + 'Programplanlist/getprogramplandetails';

var getPlanObsLinksUrl =
    Constants.BASE_URL + 'Programplanlist/getAllPublishedObservations/';

var getPlanRefLinksUrl =
    Constants.BASE_URL + 'Programplanlist/getPublishedReflections/';

var getPlanQipLinksUrl =
    Constants.BASE_URL + 'Programplanlist/getPublishedQip/';

var sendCommentsUrl = Constants.BASE_URL + 'Programplanlist/comments';

var getDetailsUrl =
    Constants.BASE_URL + 'Programplanlist/edit_programlistdetails';

var editPlanUrl = Constants.BASE_URL + 'Programplanlist/saveprogramplandetails';

class ProgramPlanApiHandler {
  final Map<String, String> data;

  ProgramPlanApiHandler(this.data);

  Future<dynamic> getDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getDetailsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getProgramPlanList() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getProgramPlanListUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> deletePlan() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(deletePlanUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> planDetails( ) async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(planDetailsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> planSupport() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(planSupportUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getObsLinks(var id) async {
    var link = getPlanObsLinksUrl + MyApp.LOGIN_ID_VALUE + '/$id';

    ServiceWithHeader helper = ServiceWithHeader(link);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getRefLinks(var id) async {
    var link = getPlanRefLinksUrl + MyApp.LOGIN_ID_VALUE + '/$id';

    ServiceWithHeader helper = ServiceWithHeader(link);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipLinks(var id) async {
    var link = getPlanQipLinksUrl + MyApp.LOGIN_ID_VALUE + '/$id';

    ServiceWithHeader helper = ServiceWithHeader(link);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> addComment() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(sendCommentsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> editPlan() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(editPlanUrl, this.data);
    var d = await helper.data();
    return d;
  }
}