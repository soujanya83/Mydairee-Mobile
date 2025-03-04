import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _listRoomsURL = Constants.BASE_URL+'room/getRooms/' ;

var _getRoomDetailsURL =
    Constants.BASE_URL+'room/getRoomDetails/';

var _getDataURL =
    Constants.BASE_URL+'room/getRoomsExcept/' ;

var _moveURL = Constants.BASE_URL+'Children/moveChildren/';

var _getChildUrl = Constants.BASE_URL+'Room/getChildForm/';

class RoomAPIHandler {
  final Map<String, String> data;

  RoomAPIHandler(this.data);

  Future<dynamic> getList() async {
    var listRoomsURL = _listRoomsURL+MyApp.LOGIN_ID_VALUE +'/' + '${data['centerid']??''}' + '/';
    ServiceWithHeader helper = ServiceWithHeader(listRoomsURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getChid() async {
    var getChildUrl =
        _getChildUrl  +
    MyApp.LOGIN_ID_VALUE +
    '/'+ '${data['roomid']??''}' + '/' + '${data['childid']??""}' + '/';
    ServiceWithHeader helper = ServiceWithHeader(getChildUrl);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> moveChild() async {
    var moveURL = _moveURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(moveURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getOtherList() async {
    var getDataURL = _getDataURL +
        MyApp.LOGIN_ID_VALUE +
        '/' + '${data['roomid']??''}' + '/';
    ServiceWithHeader helper = ServiceWithHeader(getDataURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getRoomDetails() async {
    var getRoomDetailsURL = _getRoomDetailsURL +
        MyApp.LOGIN_ID_VALUE +
        '/';
    if (data['id'] != '') {
      getRoomDetailsURL = getRoomDetailsURL + '${data['id']??""}' + '/';
    }
    ServiceWithHeader helper = ServiceWithHeader(getRoomDetailsURL);
    var d = await helper.data();
    return d;
  }
}
