import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _listResourceURL = Constants.BASE_URL + 'resources/getPublishedResources/';

var _deleteResourceURL = Constants.BASE_URL + 'resources/deleteResource/';

var _addLikeURL = Constants.BASE_URL + 'resources/addLike';

var _removeLikeURL = Constants.BASE_URL + 'resources/removeLike';

var _getCommentsListURL = Constants.BASE_URL + 'resources/getComments';

var _addCommentURL = Constants.BASE_URL + 'resources/addComment';

class ResourceAPIHandler {
  final Map<String, String> data;

  ResourceAPIHandler(this.data);

  Future<dynamic> getList() async {
    var listResourceURL = _listResourceURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(listResourceURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getCommentsList() async {
    var getCommentsListURL = _getCommentsListURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getCommentsListURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> addComment() async {
    var addCommentURL = _addCommentURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(addCommentURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> addLike() async {
    var addLikeURL = _addLikeURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(addLikeURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> removeLike() async {
    var removeLikeURL = _removeLikeURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(removeLikeURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> deleteResource() async {
    var deleteResourceURL = _deleteResourceURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(deleteResourceURL, this.data);
    var d = await helper.data();
    return d;
  }
}
