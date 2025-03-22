import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _getMenuListURL = Constants.BASE_URL+'recipes/getMenuList/';

var _saveMenuURL=Constants.BASE_URL+'Recipes/addToMenu';

var _deleteItemUrl=Constants.BASE_URL+'Recipes/deleteMenuItem/';


class MenuAPIHandler {

  final Map<String, String> data;

  MenuAPIHandler(this.data);


Future<dynamic> getMenuList() async {
  
    var getMenuListURL = _getMenuListURL+MyApp.LOGIN_ID_VALUE+'/'+'${data['url']??""}';
    print(getMenuListURL);
    ServiceWithHeader helper = ServiceWithHeader(getMenuListURL);
    var d = await helper.data();
    return d;
  }

Future<dynamic> saveMenuItem() async {
    var saveMenuURL = _saveMenuURL;
    print(saveMenuURL);
    ServiceWithHeaderDataPost helper = ServiceWithHeaderDataPost(saveMenuURL,data);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> deleteListItem() async {
    var deleteItemUrl = _deleteItemUrl+MyApp.LOGIN_ID_VALUE+'/'+'${data['id']??''}';
    ServiceWithHeader helper = ServiceWithHeader(deleteItemUrl);
    var d = await helper.data();
    return d;
  }
}