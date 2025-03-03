import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _getAssesmentSettingsURL =
    Constants.BASE_URL + 'Settings/getAssessmentSettings';

var _saveAssesmentSettingsURL =
    Constants.BASE_URL + 'Settings/saveAsmntSettings/';

var _getMontessoriSettingsURL =
    Constants.BASE_URL + 'Settings/getMontessoriSettings';

var _saveMontessoriActivityURL = Constants.BASE_URL + 'Settings/saveActivity/';

var _saveMontessoriSubActivityURL =
    Constants.BASE_URL + 'Settings/saveSubActivity/';

var _saveMontessoriExtrasURL = Constants.BASE_URL + 'Settings/saveExtras/';

var _delMontessoriActivityURL =
    Constants.BASE_URL + 'Settings/deleteMonActivity/';

var _delMontessoriSubActivityURL =
    Constants.BASE_URL + 'Settings/deleteMonSubActivity/';

var _delMontessoriExtraURL =
    Constants.BASE_URL + 'Settings/deleteMonSubActivityExtras';

class AssesmentAPIHandler {
  final Map<String, String> data;

  AssesmentAPIHandler(this.data);

  Future<dynamic> getAssesments() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getAssesmentSettingsURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveAssesments() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveAssesmentSettingsURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getMontessori() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_getMontessoriSettingsURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveMontessoriActivity() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveMontessoriActivityURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveMontessoriSubActivity() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveMontessoriSubActivityURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> saveMontessoriExtras() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_saveMontessoriExtrasURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> delMontActivity() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_delMontessoriActivityURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> delMontSubActivity() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_delMontessoriSubActivityURL, this.data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> delMontExtra() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(_delMontessoriExtraURL, this.data);
    var d = await helper.data();
    return d;
  }
}
