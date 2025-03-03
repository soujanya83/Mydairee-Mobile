import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _listSurveyURL =
    Constants.BASE_URL+'surveys/surveysList';

var _surveyDataURL =
    Constants.BASE_URL+'surveys/getSurveyData';

var _deleteItemUrl =
    Constants.BASE_URL+'Surveys/DeleteSurvey/' ;

var _deleteQueItemUrl =
    Constants.BASE_URL+'Surveys/deleteSurveyElement/' ;

var _getResponseUrl =
    Constants.BASE_URL+'surveys/getSurveyData';

class SurveyAPIHandler {
  final Map<String, String> data;

  SurveyAPIHandler(this.data);

  Future<dynamic> getList() async {
    var listSurveyURL = _listSurveyURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(listSurveyURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getData() async {
    var getResponseUrl = _getResponseUrl;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getResponseUrl, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getSurveyResponse() async {
    var surveyDataURL = _surveyDataURL;
    print(this.data);
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(surveyDataURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> deleteListItem() async {
    var deleteItemUrl = _deleteItemUrl +MyApp.LOGIN_ID_VALUE+'/'+ data['id'];
    ServiceWithHeader helper = ServiceWithHeader(deleteItemUrl);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> deleteQueItem() async {
    var deleteQueItemUrl = _deleteQueItemUrl+MyApp.LOGIN_ID_VALUE+'/' + data['url'];
    ServiceWithHeader helper = ServiceWithHeader(deleteQueItemUrl);
    var d = await helper.data();
    return d;
  }
}
