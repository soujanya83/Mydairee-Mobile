import 'package:mykronicle_mobile/api/networking.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';

var _getIngredientsURL = Constants.BASE_URL + 'Recipes/getIngredients/';

var _getListURL = Constants.BASE_URL + 'recipes/getRecipesList/';

var _getRecipeURL = Constants.BASE_URL + 'recipes/getRecipe/';

var _deleteItemUrl = Constants.BASE_URL + 'recipes/deleteRecipe/';

var _deleteMediaURL = Constants.BASE_URL + 'recipes/deleteRecipeFile/';

class RecipeAPIHandler {
  final Map<String, String> data;

  RecipeAPIHandler(this.data);

  Future<dynamic> getIngredients() async {
    var getIngredientsURL = _getIngredientsURL + MyApp.LOGIN_ID_VALUE + '/';
    ServiceWithHeader helper = ServiceWithHeader(getIngredientsURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getList() async {
    var getListURL =
        _getListURL + MyApp.LOGIN_ID_VALUE + '/' + data['centerid'];
    ServiceWithHeader helper = ServiceWithHeader(getListURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> getRecipeDetails() async {
    var getListURL = _getRecipeURL + MyApp.LOGIN_ID_VALUE + '/' + data['rid'];
    ServiceWithHeader helper = ServiceWithHeader(getListURL);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> deleteListItem() async {
    var deleteItemUrl =
        _deleteItemUrl + MyApp.LOGIN_ID_VALUE + '/' + data['id'];
    ServiceWithHeader helper = ServiceWithHeader(deleteItemUrl);
    var d = await helper.data();
    return d;
  }

  Future<dynamic> deleteMedia() async {
    var deleteMediaURL =
        _deleteMediaURL + MyApp.LOGIN_ID_VALUE + '/' + data['mediaid'];
    ServiceWithHeader helper = ServiceWithHeader(deleteMediaURL);
    var d = await helper.data();
    print(d);
    return d;
  }
}
