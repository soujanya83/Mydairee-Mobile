import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/menuapi.dart';
import 'package:mykronicle_mobile/api/recipeapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/recipemodel.dart';
import 'package:mykronicle_mobile/recipes/viewrecipe.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MenuList extends StatefulWidget {
  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> with TickerProviderStateMixin {
 late TabController _controller;
DateTime? currentCreateDate;
List<CentersModel> centers = [];
bool centersFetched = false;
int currentIndex = 0;
List<bool> selected = [];

bool recipedataFetched = false;
List<RecipeModel> _lunch = [];
List<RecipeModel> _breakfast = [];
List<RecipeModel> _snacks = [];
String? choose;

  var menuData;
  bool loading =true;
  bool menuDataFetched = false;
  bool permissionMenu = false;
  bool permissionRecipe = false;
  bool addRecipePermission = false;
  bool deleteRecipePermission = false;

  @override
  void initState() {
    currentCreateDate = _getDay();
    _controller = new TabController(length: 5, vsync: this);
    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchData() async {
    RecipeAPIHandler handler =
        RecipeAPIHandler({"centerid": centers[currentIndex].id});
    var data = await handler.getList();
    if (!data.containsKey('error')) {
      print(data.keys);

      if (data['permissions'] != null ||
          MyApp.USER_TYPE_VALUE == 'Superadmin') {
        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            data['permissions']['addRecipe'] == '1') {
          addRecipePermission = true;
        } else {
          addRecipePermission = false;
        }

        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            data['permissions']['deleteRecipe'] == '1') {
          deleteRecipePermission = true;
        } else {
          deleteRecipePermission = false;
        }

        var res = data['Recipes'];
       _lunch = [];
_breakfast = [];
_snacks = [];

        try {
          assert(res is List);
          for (int i = 0; i < res.length; i++) {
            if (res[i]['type'] == 'LUNCH') {
              _lunch.add(RecipeModel.fromJson(res[i]));
            } else if (res[i]['type'] == 'BREAKFAST') {
              _breakfast.add(RecipeModel.fromJson(res[i]));
            } else if (res[i]['type'] == 'SNACKS') {
              print('this'+res[i].toString());
              _snacks.add(RecipeModel.fromJson(res[i]));
            }
          }
          recipedataFetched = true;
          permissionRecipe = true;
          if (this.mounted) setState(() {});
        } catch (e) {
          print(e);
        }
      } else {
        permissionRecipe = false;
        addRecipePermission = false;
        deleteRecipePermission = false;
      }
      setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }

//add list code
    MenuAPIHandler apiHandler = MenuAPIHandler({
      'url': centers[currentIndex].id +
          '/' +
          DateFormat("yyyy-MM-dd").format(currentCreateDate!).toString() +
          '/' +
          DateFormat("yyyy-MM-dd")
              .format(currentCreateDate!.add(Duration(days: 4)))
              .toString()
    });

    var d = await apiHandler.getMenuList();
    if (!d.containsKey('error')) {
      if (data['permissions'] != null ||
          MyApp.USER_TYPE_VALUE == 'Superadmin' || MyApp.USER_TYPE_VALUE == 'Parent' ) {
        print('hawala');
        print(d.keys);
        menuData = d;
        menuDataFetched = true;
        permissionMenu = true;
      } else {
        permissionMenu = false;
      }
      loading=false;
      if (this.mounted) setState(() {});
    }
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    if (!dt.containsKey('error')) {
      print('dataa' + dt.toString());
      var res = dt['Centers'];
      centers = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          centers.add(CentersModel.fromJson(res[i]));
        }
        centersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  DateTime _getDay() {
    var monday = 1;
    DateTime now = new DateTime.now();

    while (now.weekday != monday) {
      now = now.subtract(new Duration(days: 1));
    }
    return now;
  }

  Widget getEndDrawer() {
    return Drawer(
      child: Column(
        children: [
          choose != null && choose == 'lunch'
              ? Container(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            'Recipes',
                            style: TextStyle(
                              color: Constants.kMain,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height - 100,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _lunch.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(_lunch[index].itemName),
                                  trailing: Checkbox(
                                    value: selected[index],
                                    onChanged: (v) {
                                      if(v==null)return;
                                      selected[index] = v;
                                      setState(() {});
                                    },
                                  ),
                                );
                              }),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var dt = DateFormat("yyyy-MM-dd")
                                      .format(currentCreateDate! .add(Duration(
                                          days: int.parse(
                                              _controller.index.toString()))))
                                      .toString();

                                  List<String> ids = [];
                                  for (int i = 0; i < selected.length; i++) {
                                    if (selected[i] == true) {
                                      ids.add(_lunch[i].id);
                                    }
                                  }

                                  String _toSend =
                                      Constants.BASE_URL + 'Recipes/addToMenu';
                                  var objToSend = {
                                    "mealType": "LUNCH",
                                    "recipe": ids,
                                    "centerid": centers[currentIndex].id,
                                    "addedBy": MyApp.LOGIN_ID_VALUE,
                                    "userid": MyApp.LOGIN_ID_VALUE,
                                    "currentDate": dt
                                  };

                                  print(objToSend);
                                  final response = await http.post(Uri.parse(_toSend),
                                      body: jsonEncode(objToSend),
                                      headers: {
                                        'X-DEVICE-ID':
                                            await MyApp.getDeviceIdentity(),
                                        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                      });
                                  print(response.body);
                                  if (response.statusCode == 200) {
                                    MyApp.ShowToast("updated", context);
                                    _lunch = [];
_breakfast = [];
_snacks = [];

                                    recipedataFetched = false;
                                    choose = null;
                                    _fetchData();
                                    Navigator.pop(context);
                                  } else if (response.statusCode == 401) {
                                    MyApp.Show401Dialog(context);
                                  }
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Constants.kButton,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 8, 12, 8),
                                      child: Text(
                                        'SAVE',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    )),
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          choose != null && choose == 'breakfast'
              ? Container(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            'Recipes',
                            style: TextStyle(
                              color: Constants.kMain,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height - 100,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _breakfast.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(_breakfast[index].itemName),
                                  trailing: Checkbox(
                                    value: selected[index],
                                    onChanged: (v) {
                                      if(v==null)return;
                                      selected[index] = v;
                                      setState(() {});
                                    },
                                  ),
                                );
                              }),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var dt = DateFormat("yyyy-MM-dd")
                                      .format(currentCreateDate!.add(Duration(
                                          days: int.parse(
                                              _controller.index.toString()))))
                                      .toString();

                                  List<String> ids = [];
                                  for (int i = 0; i < selected.length; i++) {
                                    if (selected[i] == true) {
                                      ids.add(_breakfast[i].id);
                                    }
                                  }

                                  String _toSend =
                                      Constants.BASE_URL + 'Recipes/addToMenu';
                                  var objToSend = {
                                    "mealType": "BREAKFAST",
                                    "recipe": ids,
                                    "centerid": centers[currentIndex].id,
                                    "addedBy": MyApp.LOGIN_ID_VALUE,
                                    "userid": MyApp.LOGIN_ID_VALUE,
                                    "currentDate": dt
                                  };

                                  print(objToSend);
                                  final response = await http.post(Uri.parse(_toSend),
                                      body: jsonEncode(objToSend),
                                      headers: {
                                        'X-DEVICE-ID':
                                            await MyApp.getDeviceIdentity(),
                                        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                      });
                                  print(response.body);
                                  if (response.statusCode == 200) {
                                    MyApp.ShowToast("updated", context);
                                    _lunch = [];
_breakfast = [];
_snacks = [];

                                    recipedataFetched = false;
                                    choose = null;
                                    _fetchData();
                                    Navigator.pop(context);
                                  } else if (response.statusCode == 401) {
                                    MyApp.Show401Dialog(context);
                                  }
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Constants.kButton,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 8, 12, 8),
                                      child: Text(
                                        'SAVE',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    )),
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          choose != null && choose == 'snacks'
              ? Container(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            'Recipes',
                            style: TextStyle(
                              color: Constants.kMain,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height - 100,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _snacks.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(_snacks[index].itemName),
                                  trailing: Checkbox(
                                    value: selected[index],
                                    onChanged: (v) {
                                      if(v==null)return;
                                      selected[index] = v;
                                      setState(() {});
                                    },
                                  ),
                                );
                              }),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var dt = DateFormat("yyyy-MM-dd")
                                      .format(currentCreateDate!.add(Duration(
                                          days: int.parse(
                                              _controller.index.toString()))))
                                      .toString();

                                  List<String> ids = [];
                                  for (int i = 0; i < selected.length; i++) {
                                    if (selected[i] == true) {
                                      ids.add(_snacks[i].id);
                                    }
                                  }

                                  String _toSend =
                                      Constants.BASE_URL + 'Recipes/addToMenu';
                                  var objToSend = {
                                    "mealType": "SNACKS",
                                    "recipe": ids,
                                    "centerid": centers[currentIndex].id,
                                    "addedBy": MyApp.LOGIN_ID_VALUE,
                                    "userid": MyApp.LOGIN_ID_VALUE,
                                    "currentDate": dt
                                  };

                                  print(objToSend);
                                  final response = await http.post(Uri.parse(_toSend),
                                      body: jsonEncode(objToSend),
                                      headers: {
                                        'X-DEVICE-ID':
                                            await MyApp.getDeviceIdentity(),
                                        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                      });
                                  print(response.body);
                                  if (response.statusCode == 200) {
                                    MyApp.ShowToast("updated", context);
                                    _lunch = [];
_breakfast = [];
_snacks = [];

                                    recipedataFetched = false;
                                    choose = null;
                                    _fetchData();
                                    Navigator.pop(context);
                                  } else if (response.statusCode == 401) {
                                    MyApp.Show401Dialog(context);
                                  }
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Constants.kButton,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 8, 12, 8),
                                      child: Text(
                                        'SAVE',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    )),
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        drawer: GetDrawer(),
        endDrawer: getEndDrawer(),
        appBar: Header.appBar(),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Text(
                          'Healthy Eating - Menu',
                          style: Constants.header1,
                        ),
                        Spacer(),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Constants.greyColor)),
                          height: 35,
                          width: 120,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Text(
                                  currentCreateDate != null
                                      ? DateFormat("dd-MM-yyyy")
                                          .format(currentCreateDate!)
                                      : '',
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                ),
                                Spacer(),
                                GestureDetector(
                                    onTap: () async {
                                      DateTime? monday = await _selectDate(
                                          context, currentCreateDate!);
                                      if (monday != null) {
                                        setState(() {
                                          currentCreateDate = monday;
                                        });
                                        _fetchData();
                                      }
                                    },
                                    child: Icon(
                                      AntDesign.calendar,
                                      color: Colors.grey[400],
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  centersFetched
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: centers[currentIndex].id,
                                  items: centers.map((CentersModel value) {
                                    return new DropdownMenuItem<String>(
                                      value: value.id,
                                      child: new Text(value.centerName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    for (int i = 0; i < centers.length; i++) {
                                      if (centers[i].id == value) {
                                        setState(() {
                                          currentIndex = i;
                                          _lunch = [];
_breakfast = [];
_snacks = [];

                                          recipedataFetched = false;
                                          choose = null;
                                          _fetchData();
                                        });
                                        break;
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  new Container(
                    // decoration: new BoxDecoration(color: Theme.of(context).primaryColor),
                    child: new TabBar(
                      controller: _controller,
                      labelColor: Constants.kMain,
                      isScrollable: true,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        new Tab(
                          text: 'Mon',
                        ),
                        new Tab(
                          text: 'Tue',
                        ),
                        new Tab(
                          text: 'Wed',
                        ),
                        new Tab(
                          text: 'Thu',
                        ),
                        new Tab(
                          text: 'Fri',
                        ),
                      ],
                    ),
                  ),
                  if(loading)
                   Expanded(
                      child: Container(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator())
                          )
                        ],
                      )),
                    ),
                  if (!permissionMenu && !loading)
                    Expanded(
                      child: Container(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                                "You don't have permission for this center"),
                          )
                        ],
                      )),
                    ),
                  menuDataFetched && permissionMenu && !loading
                      ? Expanded(
                          child: new TabBarView(
                              controller: _controller,
                              children: <Widget>[
                              for (int j = 0; j < menuData['Menu'].length; j++)
                                SingleChildScrollView(
                                  // physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Breakfast',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            if (addRecipePermission)
                                              GestureDetector(
                                                onTap: () {
                                                  selected = [];
                                                  for (var i = 0;
                                                      i < _breakfast.length;
                                                      i++) {
                                                    selected.add(false);
                                                  }
                                                  key.currentState
                                                     !.openEndDrawer();
                                                  choose = 'breakfast';
                                                  setState(() {});
                                                  // Navigator.push(context,MaterialPageRoute(
                                                  //   builder: (context) =>Addrecipe(type: 'SNACK',)));
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Constants.kButton,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          12, 8, 12, 8),
                                                      child: Text(
                                                        'Add Item',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ),
                                                    )),
                                              )
                                          ],
                                        ),
                                        if (menuData['Menu'][j][0].length > 0)
                                          GridView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:
                                                menuData['Menu'][j][0].length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: 8.0 / 9.0,
                                                    crossAxisCount: 2),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Card(
                                                child: Column(
                                                  children: [
                                                 //   Text(menuData['Menu'][j][0][index]['recipeDetails'].toString()),
                                                   menuData['Menu'][j][0][index]['recipeDetails']!=null&& menuData['Menu'][j][0][index]
                                                                        ['recipeDetails']
                                                                    ['media'] !=
                                                                null &&
                                                            menuData['Menu'][j][0][index]['recipeDetails'][
                                                                        'media']
                                                                    .length >
                                                                0
                                                        ? 
                                                       menuData['Menu'][j][0][index]
                                                                        ['recipeDetails']['media'][0]
                                                                    ['mediaType'] ==
                                                                'Image'
                                                            ? AspectRatio(
                                                                aspectRatio:
                                                                    18.0 / 16.0,
                                                                child: Image.network(Constants
                                                                        .ImageBaseUrl +
                                                                    menuData['Menu'][j][0][index]['recipeDetails']
                                                                            [
                                                                            'media'][0]
                                                                        [
                                                                        'mediaUrl']),
                                                              )
                                                            : 
                                                            Center(child: Icon(Icons.video_collection))
                                                        : AspectRatio(aspectRatio: 18.0 / 16.0, child: Image.network('https://st4.depositphotos.com/14953852/24787/v/600/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg')), //just for testing, will fill with image later
                                                   
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 2,
                                                              left: 2),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.23,
                                                              child:
                                                                  AutoSizeText(menuData['Menu'][j][0]
                                                                            [
                                                                            index]
                                                                        [
                                                                        'recipeDetails']!=null?
                                                                menuData['Menu'][j][0]
                                                                            [
                                                                            index]
                                                                        [
                                                                        'recipeDetails']
                                                                    [
                                                                    'itemName']:''
                                                                    ,
                                                                minFontSize: 8,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                          Row(
                                                            children: [
                                                              if (deleteRecipePermission)
                                                                GestureDetector(
                                                                  child: Icon(
                                                                    AntDesign
                                                                        .delete,
                                                                    color: Constants
                                                                        .kMain,
                                                                    size: 14,
                                                                  ),
                                                                  onTap:
                                                                      () async {
                                                                       
                                                                    MenuAPIHandler
                                                                        handler =
                                                                        MenuAPIHandler({
                                                                      "userid":
                                                                          MyApp
                                                                              .LOGIN_ID_VALUE,
                                                                      "id": menuData['Menu'][j][0][index]
                                                                              [
                                                                              'id'],
                                                                    });
                                                                    var data =
                                                                        await handler
                                                                            .deleteListItem();
                                                                    print(data);
                                                                    if (!data
                                                                        .containsKey(
                                                                            'error')) {
                                                                      menuDataFetched =
                                                                          false;
                                                                      _fetchData();
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  },
                                                                ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              GestureDetector(
                                                                child: Icon(
                                                                  AntDesign
                                                                      .eyeo,
                                                                  color:
                                                                      Constants
                                                                          .kMain,
                                                                  size: 16,
                                                                ),
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ViewRecipe(
                                                                                id: menuData['Menu'][j][0][index]['recipeDetails']['id'],
                                                                              )));
                                                                },
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Lunch',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            if (addRecipePermission)
                                              GestureDetector(
                                                onTap: () {
                                                  selected = [];
                                                  for (var i = 0;
                                                      i < _lunch.length;
                                                      i++) {
                                                    selected.add(false);
                                                  }
                                                  key.currentState
                                                      !.openEndDrawer();
                                                  choose = 'lunch';
                                                  setState(() {});
                                                  // Navigator.push(context,MaterialPageRoute(
                                                  //   builder: (context) =>Addrecipe(type: 'SNACK',)));
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Constants.kButton,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          12, 8, 12, 8),
                                                      child: Text(
                                                        'Add Item',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ),
                                                    )),
                                              )
                                          ],
                                        ),
                                        if (menuData['Menu'][j][1].length > 0)
                                          GridView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:
                                                menuData['Menu'][j][1].length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 8.0 / 9.0,
                                            ),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              print(menuData['Menu'][j][1]
                                                          [index]
                                                      ['recipeDetails']['media']
                                                  .toString());
                                              return Card(
                                                child: Column(
                                                  children: [
                                                    menuData['Menu'][j][1][index]
                                                                        ['recipeDetails']
                                                                    ['media'] !=
                                                                null &&
                                                            menuData['Menu'][j][1][index]['recipeDetails'][
                                                                        'media']
                                                                    .length >
                                                                0
                                                        ? menuData['Menu'][j][1][index]
                                                                        ['recipeDetails']['media'][0]
                                                                    ['mediaType'] ==
                                                                'Image'
                                                            ? AspectRatio(
                                                                aspectRatio:
                                                                    18.0 / 16.0,
                                                                child: Image.network(Constants
                                                                        .ImageBaseUrl +
                                                                    menuData['Menu'][j][1][index]['recipeDetails']
                                                                            [
                                                                            'media'][0]
                                                                        [
                                                                        'mediaUrl']),
                                                              )
                                                            : Center(child: Icon(Icons.video_collection))
                                                        : AspectRatio(aspectRatio: 18.0 / 16.0, child: Image.network('https://st4.depositphotos.com/14953852/24787/v/600/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg')), //just for testing, will fill with image later
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 2.0,
                                                              right: 2),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.23,
                                                              child:
                                                                  AutoSizeText(
                                                                menuData['Menu'][j][1]
                                                                            [
                                                                            index]
                                                                        [
                                                                        'recipeDetails']
                                                                    [
                                                                    'itemName'],
                                                                minFontSize: 8,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                          Row(
                                                            children: [
                                                              if (deleteRecipePermission)
                                                                GestureDetector(
                                                                  child: Icon(
                                                                    AntDesign
                                                                        .delete,
                                                                    color: Constants
                                                                        .kMain,
                                                                    size: 14,
                                                                  ),
                                                                  onTap:
                                                                      () async {
                                                                    MenuAPIHandler
                                                                        handler =
                                                                        MenuAPIHandler({
                                                                      "userid":
                                                                          MyApp
                                                                              .LOGIN_ID_VALUE,
                                                                      "id": menuData['Menu'][j][1][index]
                                                                              [
                                                                              'id'],
                                                                    });
                                                                    var data =
                                                                        await handler
                                                                            .deleteListItem();
                                                                    print(data);
                                                                    if (!data
                                                                        .containsKey(
                                                                            'error')) {
                                                                      menuDataFetched =
                                                                          false;
                                                                      _fetchData();
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  },
                                                                ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              GestureDetector(
                                                                child: Icon(
                                                                  AntDesign
                                                                      .eyeo,
                                                                  color:
                                                                      Constants
                                                                          .kMain,
                                                                  size: 16,
                                                                ),
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ViewRecipe(
                                                                                id: menuData['Menu'][j][1][index]['recipeDetails']['id'],
                                                                              )));
                                                                },
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Snacks',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            if (addRecipePermission)
                                              GestureDetector(
                                                onTap: () {
                                                  selected = [];
                                                  for (var i = 0;
                                                      i < _snacks.length;
                                                      i++) {
                                                    selected.add(false);
                                                  }
                                                  key.currentState
                                                      !.openEndDrawer();
                                                  choose = 'snacks';
                                                  setState(() {});
                                                  // Navigator.push(context,MaterialPageRoute(
                                                  //   builder: (context) =>Addrecipe(type: 'SNACK',)));
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Constants.kButton,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          12, 8, 12, 8),
                                                      child: Text(
                                                        'Add Item',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ),
                                                    )),
                                              )
                                          ],
                                        ),
                                        menuData['Menu'][j][2].length > 0
                                            ? GridView.builder(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: menuData['Menu'][j]
                                                        [2]
                                                    .length,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                        childAspectRatio:
                                                            8.0 / 9.0,
                                                        crossAxisCount: 2),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return new Card(
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
      
                                                          menuData['Menu'][j][2][index]['recipeDetails']['media'] !=
                                                                  null && menuData['Menu'][j][2][index]['recipeDetails']['media'].length>0
                                                              ? menuData['Menu'][j][2][index]['recipeDetails']['media'][0]['mediaType'] ==
                                                                      'Image'
                                                                  ? AspectRatio(
                                                                      aspectRatio:
                                                                          18.0 /
                                                                              16.0,
                                                                      child: Image.network(Constants
                                                                              .ImageBaseUrl +
                                                                          menuData['Menu'][j][2][index]['recipeDetails']['media'][0]
                                                                              [
                                                                              'mediaUrl']),
                                                                    )
                                                                  : Center(
                                                                      child: Icon(
                                                                          Icons
                                                                              .video_collection))
                                                              : AspectRatio(
                                                                  aspectRatio:
                                                                      18.0 /
                                                                          16.0,
                                                                  child: Image.network('https://st4.depositphotos.com/14953852/24787/v/600/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg')), //just for testing, will fill with image later
                                                           Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 2.0,
                                                                    right: 2),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.23,
                                                                    child:
                                                                        AutoSizeText(
                                                                      menuData['Menu'][j][2][index]
                                                                              [
                                                                              'recipeDetails']
                                                                          [
                                                                          'itemName'],
                                                                      minFontSize:
                                                                          8,
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    )),
                                                                Row(
                                                                  children: [
                                                                    if (deleteRecipePermission)
                                                                      GestureDetector(
                                                                        child:
                                                                            Icon(
                                                                          AntDesign
                                                                              .delete,
                                                                          color:
                                                                              Constants.kMain,
                                                                          size:
                                                                              14,
                                                                        ),
                                                                        onTap:
                                                                            () async {
                                                                          MenuAPIHandler
                                                                              handler =
                                                                              MenuAPIHandler({
                                                                            "userid":
                                                                                MyApp.LOGIN_ID_VALUE,
                                                                            "id":
                                                                                menuData['Menu'][j][2][index]['id'],
                                                                          });
                                                                          var data =
                                                                              await handler.deleteListItem();
                                                                          print(
                                                                              data);
                                                                          if (!data
                                                                              .containsKey('error')) {
                                                                            menuDataFetched =
                                                                                false;
                                                                            _fetchData();
                                                                            setState(() {});
                                                                          }
                                                                        },
                                                                      ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    GestureDetector(
                                                                      child:
                                                                          Icon(
                                                                        AntDesign
                                                                            .eyeo,
                                                                        color: Constants
                                                                            .kMain,
                                                                        size:
                                                                            16,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => ViewRecipe(
                                                                                      id: menuData['Menu'][j][2][index]['recipeDetails']['id'],
                                                                                    )));
                                                                      },
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ]),
                                                  );
                                                },
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                            ]))
                      : Container(),
                ]))));
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime dateTime) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: new DateTime(1800),
        lastDate: new DateTime(2100),
        selectableDayPredicate: (DateTime val) {
          return val.weekday == 1;
        });
    return picked;
  }
}
