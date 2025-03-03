import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _listAnnouncementsURL =
    Constants.BASE_URL + 'announcements/announcementsList/';

var _saveAnnouncementURL =
    Constants.BASE_URL + 'announcements/createAnnouncement/';

var _updateAnnouncementURL =
    Constants.BASE_URL + 'announcements/updateAnnouncement';

var _detailAnnouncementURL =
    Constants.BASE_URL + 'announcements/getAnnouncement/';

class AnnouncementsAPIHandler {
  final Map<String, String> data;

  AnnouncementsAPIHandler(this.data);

  Future<dynamic> getList(String centerid) async {
    var listAnnouncementsURL = _listAnnouncementsURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(listAnnouncementsURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveAnnouncement() async {
    var saveAnnouncementURL = _saveAnnouncementURL;
    print(saveAnnouncementURL);
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(saveAnnouncementURL, data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getAnnouncementsDetails() async {
    var detailAnnouncementURL =
        _detailAnnouncementURL + MyApp.LOGIN_ID_VALUE + '/' + data['id'] + '/';
    print(detailAnnouncementURL);
    ServiceWithHeader helper = ServiceWithHeader(detailAnnouncementURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> updateAnnouncement() async {
    var updateAnnouncementURL = _updateAnnouncementURL;
    print(updateAnnouncementURL);
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(updateAnnouncementURL, data);
    var d = await helper.data();
    return d;
  }
}
