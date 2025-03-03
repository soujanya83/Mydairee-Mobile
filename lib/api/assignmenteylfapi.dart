import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _getEylfURL = Constants.BASE_URL + 'Settings/getEylfSettings/';

var _saveEylfURL = Constants.BASE_URL + 'Settings/saveEylfActivity/';

var _saveEylfSubURL = Constants.BASE_URL + 'Settings/saveEylfSubActivity';

var _delEylfURL = Constants.BASE_URL + 'Settings/deleteEylfActivity';

var _delEylfSubURL = Constants.BASE_URL + 'Settings/deleteEylfSubActivity';

class AssignmentEylfAPIHandler {
  final Map<String, String> data;

  AssignmentEylfAPIHandler(this.data);

  Future<dynamic> getEylfData() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getEylfURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveEylfActivityData() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveEylfURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveEylfSubActivityData() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveEylfSubURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> delEylfActivityData() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_delEylfURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> delEylfSubActivityData() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_delEylfSubURL, this.data);
    var d = await helper.data();
    return d;
  }
}
