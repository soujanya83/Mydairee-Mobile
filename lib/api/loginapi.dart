import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _loginURL = Constants.BASE_URL+'login/getUserValidation';

var _forgotpwdURL = Constants.BASE_URL+'Auth/forgotPassword';

class LoginAPIHandler {

  final Map<String, String> body;

  LoginAPIHandler(this.body);

  Future<dynamic> login () async {
    try{
      print('enter in login');
 var loginURL = _loginURL;
    Service loginHelper = Service(loginURL, body);
    var loginData = await loginHelper.data();
    return loginData;
    } catch (e,s){
      print('++++++++login error++++++++');
       print(e);
       print(s);
    }
   
  }

Future<dynamic> forgotpwd() async {
    var forgotpwdURL = _forgotpwdURL;
    Service loginHelper   = Service(forgotpwdURL, body);
    var loginData = await loginHelper.data();
    return loginData;
  } 
}