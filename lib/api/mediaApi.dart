import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _getMediaURL = Constants.BASE_URL + 'media/index/';

var _getMediaTagsURL = Constants.BASE_URL + 'Media/getTagsArr';

var _deleteMediaURL = Constants.BASE_URL + 'Media/deleteMedia/';

class MediaAPIHandler {
  final Map<String, String> data;

  MediaAPIHandler(this.data);

  Future<dynamic> getMedia() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getMediaURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> deleteMedia() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_deleteMediaURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getMediaTags() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getMediaTagsURL, this.data);
    var d = await helper.data();
    return d;
  }
}
