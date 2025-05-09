import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _getCalendarDetailsURL = Constants.BASE_URL+'Dashboard/getCalendarDetails/';

var _getDashboardDetailsURL = Constants.BASE_URL+'dashboard/getDashboardDetails/';

class DashboardAPIHandler {

  final Map<String, String> data;

  DashboardAPIHandler(this.data);

Future<dynamic> getDashboardDetails() async {
  print('000000000000000');
    var getDetailsURL = _getDashboardDetailsURL+MyApp.LOGIN_ID_VALUE+'/';
    ServiceWithHeader helper = ServiceWithHeader(getDetailsURL);
    var d = await helper.data();
    return d;
  }
  

Future<dynamic> getCalendarDetails() async {
  
    var now = new DateTime.now();
    var getDetailsURL = _getCalendarDetailsURL+MyApp.LOGIN_ID_VALUE+'/'+now.month.toString()+'/'+now.year.toString();
    ServiceWithHeader helper = ServiceWithHeader(getDetailsURL);
    var d = await helper.data();
    return d;
  }
  
}