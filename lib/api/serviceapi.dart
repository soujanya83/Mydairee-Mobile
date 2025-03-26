
import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _saveServiceURL = Constants.BASE_URL+'serviceDetails/createServiceDetails';

var _serviceDetailsURL =Constants.BASE_URL+'serviceDetails/getServiceDetails/';

class ServiceAPIHandler {

  final Map<String, String> data;

  ServiceAPIHandler(this.data);

  Future<dynamic> saveService() async {
    var saveServiceURL = _saveServiceURL;
    print(saveServiceURL);
    ServiceWithHeaderDataPost helper = ServiceWithHeaderDataPost(saveServiceURL,data);
    var d = await helper.data();
    return d;
  }

 Future<dynamic> getServiceDetails() async {
    var getDetailsURL = _serviceDetailsURL+MyApp.LOGIN_ID_VALUE+'/'+'${data['centerid']}'+'/';
    ServiceWithHeader helper = ServiceWithHeader(getDetailsURL);
    var d = await helper.data();
    return d;
  }
}