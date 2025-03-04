import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _listObservationsURL =
    Constants.BASE_URL + 'observation/getListObservations/';

var _listChildsURL = Constants.BASE_URL + 'Children/getChilds/';

var _listUsersURL = Constants.BASE_URL + 'Observation/getAllChildsAndStaffs/';

var _listGroupsURL = Constants.BASE_URL + 'Observation/getChildrenGroups/';

var _viewObservationURL = Constants.BASE_URL + 'observation/getObservation/';

var _viewObservationDataURL = Constants.BASE_URL + 'observation/getObsView/';

var _viewAssesmentsDataURL = Constants.BASE_URL + 'observation/getAssessments/';

var _viewLinksDataURL =
    Constants.BASE_URL + 'observation/getPublishedObsAndRef/';

var _createCommentURL = Constants.BASE_URL + 'observation/createComment';

var _deleteMediaURL = Constants.BASE_URL + 'Observation/deleteMedia/';

var _getMediaUrl = Constants.BASE_URL + 'Observation/getMediaTags/';

var _getMediaImagesUrl =
    Constants.BASE_URL + 'observation/getUploadedMediaFiles/';

var _getPublishedQipUrl = Constants.BASE_URL + 'observation/getPublishedQip/';

var _getPublishedProgPlanUrl =
    Constants.BASE_URL + 'observation/getPublishedProgPlan/';

var _getAllMontUrl = Constants.BASE_URL + 'Observation/getAllMontSubAct';

var _viewTabsUrl = Constants.BASE_URL + 'Observation/getAssessmentSettings';

class ObservationsAPIHandler {
  final Map<String, String> data;

  ObservationsAPIHandler(this.data);

  Future<dynamic> getMediaImages() async {
    ServiceWithHeader helper =
        ServiceWithHeader(_getMediaImagesUrl + MyApp.LOGIN_ID_VALUE);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getList(centerid) async {
    var listObservationsURL =
        _listObservationsURL + MyApp.LOGIN_ID_VALUE + '/$centerid';
    ServiceWithHeader helper = ServiceWithHeader(listObservationsURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> viewTabs() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_viewTabsUrl, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getChildList() async {
    var listChildsURL = _listChildsURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(listChildsURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getUsersList() async {
    var listUsersURL = _listUsersURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(listUsersURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getAllMont() async {
    var getAllMontUrl = _getAllMontUrl;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getAllMontUrl, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getListGroup() async {
    var listGroupsURL = _listGroupsURL + MyApp.LOGIN_ID_VALUE + '/';
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(listGroupsURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getObservationDetails() async {
    var viewObservationURL =
        _viewObservationURL + MyApp.LOGIN_ID_VALUE + '/' + '${data['id']??""}' + '/';
    ServiceWithHeader helper = ServiceWithHeader(viewObservationURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getObservationDataDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_viewObservationDataURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getLinksList() async {
    var viewLinksDataURL = _viewLinksDataURL + MyApp.LOGIN_ID_VALUE + '/';
    if (data['id'] != '') {
      viewLinksDataURL = viewLinksDataURL + '${data['id']??""}' + '/';
    }
    ServiceWithHeader helper = ServiceWithHeader(viewLinksDataURL);
    var d = await helper.data();
    print(d);
    return d;
  }

  Future<dynamic> getPublishedQip(centerid) async {
    var getPublihedQipUrl =
        _getPublishedQipUrl + MyApp.LOGIN_ID_VALUE + '/$centerid';
    ServiceWithHeader helper = ServiceWithHeader(getPublihedQipUrl);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getPublishedProgPlan(centerid) async {
    var getPublihedProgPlanUrl =
        _getPublishedProgPlanUrl + MyApp.LOGIN_ID_VALUE + '/$centerid';
    ServiceWithHeader helper = ServiceWithHeader(getPublihedProgPlanUrl);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getAssesmentsData() async {
    // String val = '';
    // if (data['obsid'] != 'val') {
    //   val = data['obsid'] + '/';
    // }
    //var viewAssesmentsDataURL = _viewAssesmentsDataURL + val;
    var viewAssesmentsDataURL = _viewAssesmentsDataURL;
    print(viewAssesmentsDataURL);
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(viewAssesmentsDataURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> createComment() async {
    var createCommentURL = _createCommentURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(createCommentURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getMedia() async {
    var getMediaUrl = _getMediaUrl;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getMediaUrl, data);
    var d = await helper.data();
    print(d);
    return d;
  }

  Future<dynamic> deleteMedia() async {
    var deleteMediaURL =
        _deleteMediaURL + MyApp.LOGIN_ID_VALUE + '/' + '${data['mediaid']??""}';
    ServiceWithHeader helper = ServiceWithHeader(deleteMediaURL);
    var d = await helper.data();
    print(d);
    return d;
  }
}
