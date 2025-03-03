import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _getDataURL = Constants.BASE_URL + 'Settings/getDevMileSettings/';

var _saveDevActDataURL = Constants.BASE_URL + 'Settings/saveDevMileActivity/';

var _delDevActDataURL = Constants.BASE_URL + 'Settings/deleteMileMain';

var _saveDevSubActDataURL =
    Constants.BASE_URL + 'Settings/saveDevMileSubActivity';

var _delDevSubActDataURL =
    Constants.BASE_URL + 'Settings/deleteMileSubActivity';

var _saveDevExtraURL = Constants.BASE_URL + 'Settings/saveDevMileExtras';

var _delDevExtraURL = Constants.BASE_URL + 'Settings/deleteMileSubActExtras';

class DevAssignAPIHandler {
  final Map<String, String> data;

  DevAssignAPIHandler(this.data);

  Future<dynamic> getData() async {
    var getDataURL = _getDataURL;
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getDataURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> savDevAct() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveDevActDataURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> delDevAct() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_delDevActDataURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> savDevSubAct() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveDevSubActDataURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> delDevSubAct() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_delDevSubActDataURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> savDevExtra() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveDevExtraURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> delDevExtra() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_delDevExtraURL, this.data);
    var d = await helper.data();
    return d;
  }
}
