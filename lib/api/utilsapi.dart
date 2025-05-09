import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _listAllCentersURL = Constants.BASE_URL + 'Util/GetAllCenters/';

var _getChildDetails = Constants.BASE_URL + 'Observation/getChildDetails/';

var _getChildrens = Constants.BASE_URL + 'Observation/getChildFromCenter';

var _getStaff = Constants.BASE_URL + 'Util/getCenterEducators';

var _getAuthors = Constants.BASE_URL + 'Resources/getAuthorsFromCenter/';

var _getTrendingTags = Constants.BASE_URL + 'Resources/loadAjaxResources/';

var _getChildTableDetails =
    Constants.BASE_URL + 'Observation/child_table_details'  ;

var _getActTagInfo = Constants.BASE_URL + 'Observation/getActTagInfo/';

class UtilsAPIHandler {
  final Map<String, dynamic> data;

  UtilsAPIHandler(this.data);

  Future<dynamic> getCentersList() async {
    var listAllCentersURL = _listAllCentersURL + MyApp.LOGIN_ID_VALUE + '/';
    ServiceWithHeader helper = ServiceWithHeader(listAllCentersURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getChildDetails() async {
    var getChildDetails = _getChildDetails;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getChildDetails, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getChildTableDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getChildTableDetails, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getChildrens() async {
    var getChildrens = _getChildrens;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getChildrens, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getStaff() async {
    var getStaff = _getStaff;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getStaff, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getAuthors() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getAuthors, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getActTagInfo() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getActTagInfo, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getTrendingTagsData() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getTrendingTags, this.data);
    var d = await helper.data();
    return d;
  }
}
