import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _listQipURL = Constants.BASE_URL + 'qip/getQips/';

var _deleteItemUrl = Constants.BASE_URL + 'qip/delete/';

var _getQipAreasUrl = Constants.BASE_URL + 'qip/getQipForm/';

var _renameQipUrl = Constants.BASE_URL + 'Qip/renameQip';

var _getDiscussionQipUrl = Constants.BASE_URL + 'Qip/viewDiscussions/';

var _addCommentQipUrl = Constants.BASE_URL + 'Qip/addComment/';

var _getQipStandardsUrl = Constants.BASE_URL + 'qip/viewStandard/';

var _getStandardsDetailsUrl = Constants.BASE_URL + 'qip/getStandardDetails/';

var _updateStandardsDetailsUrl = Constants.BASE_URL + 'qip/updateQipStandard/';

var _getAreaStandardsUrl = Constants.BASE_URL + 'Qip/getAreaStandards';

var _getQipObsLinksUrl =
    Constants.BASE_URL + 'Qip/getAllPublishedObservations/';

var _getQipRefLinksUrl = Constants.BASE_URL + 'Qip/getPublishedReflections/';

var _getQipResLinksUrl = Constants.BASE_URL + 'Qip/getPublishedResources/';

var _getQipSurveyLinksUrl = Constants.BASE_URL + 'Qip/getPublishedSurveys/';

var _getQipProgramPlansUrl = Constants.BASE_URL + 'Qip/getProgramPlans';

var _getQipMontUrl = Constants.BASE_URL + 'Qip/getAllMonSubACts';

var _getQipDevUrl = Constants.BASE_URL + 'Qip/getAllDevMiles';

var _getQipEylfUrl = Constants.BASE_URL + 'Qip/getAllEylf';

var _getQipElemetUrl = Constants.BASE_URL + 'qip/viewElement/';

var _addQipUrl = Constants.BASE_URL + 'qip/addNewQip/';

var _getElementsUrl = Constants.BASE_URL + 'Qip/getStandardElements';

var _saveNotesUrl = Constants.BASE_URL + 'Qip/saveProgressNotes/';

var _saveCommentUrl = Constants.BASE_URL + 'Qip/saveElementComment/';

var _saveIssueUrl = Constants.BASE_URL + 'Qip/saveElementIssues/';

var _addStaffUrl = Constants.BASE_URL + 'Qip/addElementStaffs/';

var _getStaffUrl = Constants.BASE_URL + 'Qip/getCenterStaffs/';

var _addSelfAssesUrl =
    Constants.BASE_URL + 'SelfAssessment/addNewSelfAssessment/';

var _viewSelfAssesUrl =
    Constants.BASE_URL + 'SelfAssessment/editSelfAssessment/';
//---------------------------------------

var _getSelfAssesmentUrl =
    Constants.BASE_URL + 'SelfAssessment/getAllSelfAssessments/';

var _saveSelfAssesmentUrl =
    Constants.BASE_URL + 'SelfAssessment/saveSelfAssessment/';

var _getSelfAssesmentStaffUrl =
    Constants.BASE_URL + 'SelfAssessment/getSelfAsmntStaffs/';

var _addSelfAssesmentStaffUrl =
    Constants.BASE_URL + 'SelfAssessment/addSelfAssessmentStaffs/';

var _saveProgressUrl = Constants.BASE_URL + 'Qip/saveProgressNotes/';

class QipAPIHandler {
  final Map<String, String> data;

  QipAPIHandler(this.data);

  Future<dynamic> getList(String centerid) async {
    var listQipURL = _listQipURL + MyApp.LOGIN_ID_VALUE + '/$centerid';
    ServiceWithHeaderPost helper = ServiceWithHeaderPost(listQipURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> deleteListItem() async {
    var deleteItemUrl =
        _deleteItemUrl + MyApp.LOGIN_ID_VALUE + '/' + '${data['id']??""}';
    ServiceWithHeader helper = ServiceWithHeader(deleteItemUrl);
    var d = await helper.data();
    return d;
  }

  // --------------------------------------------------

  Future<dynamic> getQipAreas(String centerid, String qipid) async {
    var getQipAreasUrl =
        _getQipAreasUrl + MyApp.LOGIN_ID_VALUE + '/$centerid/$qipid';

    ServiceWithHeader helper = ServiceWithHeader(getQipAreasUrl);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> renameQip() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_renameQipUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> viewQipList() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getDiscussionQipUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> addQipComment() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_addCommentQipUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getStandards() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getQipStandardsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getStandardElements() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getElementsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getStandardDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getStandardsDetailsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> updateStandardDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_updateStandardsDetailsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getAreaStandards() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getAreaStandardsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipObsLinks(String centerid, String qipid) async {
    var getQipObsLinksUrl =
        _getQipObsLinksUrl + MyApp.LOGIN_ID_VALUE + '/$centerid/$qipid';

    ServiceWithHeader helper = ServiceWithHeader(getQipObsLinksUrl);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipRefLinks(String centerid, String qipid) async {
    var getQipRefLinksUrl =
        _getQipRefLinksUrl + MyApp.LOGIN_ID_VALUE + '/$centerid/$qipid';

    ServiceWithHeader helper = ServiceWithHeader(getQipRefLinksUrl);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipResLinks() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getQipResLinksUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipSurveyLinks() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getQipSurveyLinksUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipPlan() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getQipProgramPlansUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipMont() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getQipMontUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipDev() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getQipDevUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipEylf() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getQipEylfUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getQipElement() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getQipElemetUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> addQip() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_addQipUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveNotes() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveNotesUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveComment() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveCommentUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveIssue() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveIssueUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> addStaff() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_addStaffUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getStaff() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getStaffUrl, this.data);
    var d = await helper.data();
    return d;
  }
  //------------------

  Future<dynamic> getSelfAssesmentList() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getSelfAssesmentUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> addSelfAsses() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_addSelfAssesUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> viewSelfAsses() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_viewSelfAssesUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveSelfAsses() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveSelfAssesmentUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getSelfAssesStaff() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getSelfAssesmentStaffUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> addSelfAssesStaff() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_addSelfAssesmentStaffUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveProgress() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveProgressUrl, this.data);
    var d = await helper.data();
    return d;
  }
}
