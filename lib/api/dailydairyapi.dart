import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _getDataURL =
    Constants.BASE_URL+'dailyDiary/getDailyDiary';

var _getItemsURL =
    Constants.BASE_URL+'dailyDiary/getItems/';

var _getHeadChecksDataURL =
    Constants.BASE_URL+'HeadChecks/getHeadChecks';

var _getAccidentsDataURL =
    Constants.BASE_URL+'Accident/getAccidents';

var _getAccidentsInfoURL =
    Constants.BASE_URL+'accident/getAccidentDetails';

var _getSlipChecklistInfoURL =
    Constants.BASE_URL+'HeadChecks/getsleepChecks';
    

var _saveSleepChecklist =
    Constants.BASE_URL+'/HeadChecks/saveSleepChecklist';

var _updateSleepChecklist =
    Constants.BASE_URL+'/HeadChecks/updateSleepChecklist';

var _deleteSleepChecklist =
    Constants.BASE_URL+'/HeadChecks/deleteSleepChecklist';

class DailyDairyAPIHandler {
  final Map<String, String> data;

  DailyDairyAPIHandler(this.data);

  Future<dynamic> getData() async {
    var getDataURL = _getDataURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getDataURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getItems() async {
    var getItemsURL = _getItemsURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getItemsURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getHeadChecksData() async {
    var getHeadChecksDataURL = _getHeadChecksDataURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getHeadChecksDataURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getSlipCheckListsData() async {
    var getSlipChecklistInfoURL = _getSlipChecklistInfoURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getSlipChecklistInfoURL, this.data);
    var d = await helper.data();
    return d;
  }

    Future<dynamic> addSleepChecks() async {
    var saveSleepChecklist = _saveSleepChecklist;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(saveSleepChecklist, this.data);
    var d = await helper.data();
    return d;
  }

    Future<dynamic> updateSleepChecks() async {
    var updateSleepChecklist = _updateSleepChecklist;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(updateSleepChecklist, this.data);
    var d = await helper.data();
    return d;
  }

    Future<dynamic> deleteSleepChecks() async {
    var deleteSleepChecklist = _deleteSleepChecklist;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(deleteSleepChecklist, this.data);
    var d = await helper.data();
    return d;
  }

  

  Future<dynamic> getAccidentsData() async {
    var getAccidentsDataURL = _getAccidentsDataURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getAccidentsDataURL, this.data);
    var d = await helper.data();
    return d;
}
 

Future<dynamic> getAccidentsInfo() async {
    var getAccidentsInfoURL = _getAccidentsInfoURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getAccidentsInfoURL, this.data);  
    var d = await helper.data();
    return d;
  }
}