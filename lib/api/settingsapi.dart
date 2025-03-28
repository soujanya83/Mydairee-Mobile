import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var updatePinURL = Constants.BASE_URL + 'Settings/changePin';

var updateMailURL = Constants.BASE_URL + 'Settings/changeEmail';

var updatePasswordURL = Constants.BASE_URL + 'Settings/changePassword';

var getModulesURL = Constants.BASE_URL + 'Settings/getModuleSettings';

var getUsersURL = Constants.BASE_URL + 'Settings/getUsersSettings';

var setModulesURL = Constants.BASE_URL + 'Settings/addModuleSettings';

var getUserDataURL = Constants.BASE_URL + 'Settings/getUsersDetails';

var getCenterSettingsURL = Constants.BASE_URL + 'Settings/getCentersSettings';

//var saveCenterSetttingsURL = Constants.BASE_URL + 'Settings/saveCenterDetails';

var getCenterSettingsDetailsURL =
    Constants.BASE_URL + 'Settings/getCenterDetails';

var getParentsUrl = Constants.BASE_URL + 'Settings/getParentSettings';

var getParentDetailsUrl = Constants.BASE_URL + 'Settings/getParentDetails';

var saveParentDetailsUrl = Constants.BASE_URL + 'Settings/saveParentDetails';

var getChildGroupsUrl = Constants.BASE_URL + 'Settings/getChildGroups';

var getGroupDetailsUrl = Constants.BASE_URL + 'Settings/getChildGroupDetails';

var getPermissionsUrl = Constants.BASE_URL + 'Settings/getPermissions';

var setPermissionsUrl = Constants.BASE_URL + 'Settings/savePermissions';

var getDailyJournalUrl = Constants.BASE_URL + 'Settings/dailyJournalTabs';

var setDailyJournalUrl =
    Constants.BASE_URL + 'Settings/saveApplicationSettings';

var getNoticePeriodUrl = Constants.BASE_URL + 'Settings/noticePeriodSettings';

var setNoticePeriodUrl = Constants.BASE_URL + 'Settings/saveNoticeSettings';

class SettingsApiHandler {
  final Map<String, String> data;

  SettingsApiHandler(this.data);

  Future<dynamic> updatePin() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(updatePinURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> updatePassword() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(updatePasswordURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> updateEmail() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(updateMailURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getNoticePeriod() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getNoticePeriodUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> setNoticePeriod() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(setNoticePeriodUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getModules() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getModulesURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> setModules() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(setModulesURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getUsers() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getUsersURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getUsersData() async {
    ServiceWithHeaderDataPost helper = 
        ServiceWithHeaderDataPost(getUserDataURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getCenterSettings() async {
    ServiceWithHeaderDataPost helper =  ServiceWithHeaderDataPost(getCenterSettingsURL, this.data);
    var d = await helper.data();
    return d;
 }

// Future<dynamic> saveCenterSettings() async {
//     ServiceWithHeaderDataPost helper =
//         ServiceWithHeaderDataPost(saveCenterSetttingsURL, this.data);
//     var d = await helper.data();
//     return d;
//}

  Future<dynamic> getCenterDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getCenterSettingsDetailsURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getParents() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getParentsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getParentDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getParentDetailsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveParentDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(saveParentDetailsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getChildGroups() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getChildGroupsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getChildGroupDeatils() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getGroupDetailsUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getPermissions() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getPermissionsUrl, this.data);
    print(this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getDailyJournalData() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getDailyJournalUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> setDailyJournalData() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(setDailyJournalUrl, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> setPermissions() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(setPermissionsUrl, this.data);
    var d = await helper.data();
    return d;
  }
}
