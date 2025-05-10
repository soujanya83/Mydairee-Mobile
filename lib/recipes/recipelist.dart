import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart' show AntDesign;
import 'package:mykronicle_mobile/api/recipeapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/getUserReflections.dart';
import 'package:mykronicle_mobile/models/recipemodel.dart';
import 'package:mykronicle_mobile/recipes/addrecipe.dart';
import 'package:mykronicle_mobile/recipes/viewrecipe.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class RecipeList extends StatefulWidget {
  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  bool dataFetched = false;
  List<RecipeModel> _lunch = [];
  List<RecipeModel> _breakfast = [];
  List<RecipeModel> _snacks = [];
  List<RecipeModel> _mornTea = [];
  List<RecipeModel> _afternTea = [];

  List<CentersModel> centers = [];

  bool centersFetched = false;
  int currentIndex = 0;

  bool permissionRecipe = false;
  bool addRecipePermission = false;
  bool deleteRecipePermission = false;
  bool loading = true;

  @override
  void initState() {
    _fetchCenters();
    super.initState();
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
      } catch (e, s) {
        print('+++++++++++++++');
        print(e);
        print(s);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  Future<void> _fetchData() async {
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }
    // permission and centers
    RecipeAPIHandler handler =
        RecipeAPIHandler({"centerid": centers[currentIndex].id});
    var data = await handler.getList();
    if (!data.containsKey('error')) {
      print(data.keys);
      var res = data['Recipes'];
      _lunch = [];
      _breakfast = [];
      _snacks = [];
      _mornTea = [];
      _afternTea = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          if (res[i]['type'] == 'LUNCH') {
            _lunch.add(RecipeModel.fromJson(res[i]));
            try {
              _lunch[_lunch.length - 1].media = [
                {"mediaUrl": res[i]['mediaUrl'], "mediaType": "Image"}
              ];
              //  _lunch[_lunch.length-1].media = ["no-image.png"];
            } catch (e, s) {
              print('+++++++stacktrace++++++++++');
              print(e);
              print(s);
            }
          } else if (res[i]['type'] == 'BREAKFAST') {
            _breakfast.add(RecipeModel.fromJson(res[i]));
            try {
              _breakfast[_breakfast.length - 1].media = [
                {"mediaUrl": res[i]['mediaUrl'], "mediaType": "Image"}
              ];
              //  _lunch[_lunch.length-1].media = ["no-image.png"];
            } catch (e, s) {
              print('+++++++stacktrace++++++++++');
              print(e);
              print(s);
            }
          } else if (res[i]['type'] == 'SNACKS') {
            _snacks.add(RecipeModel.fromJson(res[i]));
            try {
              _snacks[_snacks.length - 1].media = [
                {"mediaUrl": res[i]['mediaUrl'], "mediaType": "Image"}
              ];
              //  _lunch[_lunch.length-1].media = ["no-image.png"];
            } catch (e, s) {
              print('+++++++stacktrace++++++++++');
              print(e);
              print(s);
            }
          } else if (res[i]['type'] == 'MORNING_TEA') {
            print('this' + res[i].toString());
            _mornTea.add(RecipeModel.fromJson(res[i]));
            try {
              _mornTea[_mornTea.length - 1].media = [
                {"mediaUrl": res[i]['mediaUrl'], "mediaType": "Image"}
              ];
              //  _lunch[_lunch.length-1].media = ["no-image.png"];
            } catch (e, s) {
              print('+++++++stacktrace++++++++++');
              print(e);
              print(s);
            }
          } else if (res[i]['type'] == 'AFTERNOON_TEA') {
            print('this' + res[i].toString());
            _afternTea.add(RecipeModel.fromJson(res[i]));
            try {
              _afternTea[_afternTea.length - 1].media = [
                {"mediaUrl": res[i]['mediaUrl'], "mediaType": "Image"}
              ];
              //  _lunch[_lunch.length-1].media = ["no-image.png"];
            } catch (e, s) {
              print('+++++++stacktrace++++++++++');
              print(e);
              print(s);
            }
          }
        }
        dataFetched = true;
        if (this.mounted) setState(() {});
      } catch (e, s) {
        print('=================e=================');
        print(e);
        print(s);
      }

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
      } else {
        addRecipePermission = false;
        deleteRecipePermission = false;
      }
      if (MyApp.USER_TYPE_VALUE == 'Parent' ||
          MyApp.USER_TYPE_VALUE == 'Superadmin' ||
          MyApp.USER_TYPE_VALUE == 'Staff' ||
          data['permissions'] != null) {
        permissionRecipe = true;
      } else {
        permissionRecipe = false;
      }
      loading = false;
      setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                        'Recipe',
                        style: Constants.header1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      centersFetched
                          ? DropdownButtonHideUnderline(
                              child: Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Constants.greyColor),
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
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
                                        for (int i = 0;
                                            i < centers.length;
                                            i++) {
                                          if (centers[i].id == value) {
                                            setState(() {
                                              currentIndex = i;
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
                      if (loading || !dataFetched)
                        Container(
                            height: MediaQuery.of(context).size.height*.7,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                    child: Container(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator()))
                              ],
                            )),
                      if (!permissionRecipe && !loading)
                        Container(
                            height: MediaQuery.of(context).size.height * 0.7,
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
                      if (dataFetched && permissionRecipe && !loading)
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Morning Tea',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  if (addRecipePermission)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Addrecipe(
                                              reciepieType: 'MORNING_TEA',
                                              centerid:
                                                  centers[currentIndex].id,
                                              id: '',
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            dataFetched = false;
                                            setState(() {});
                                            _fetchData();
                                          }
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Constants.kButton,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 8, 12, 8),
                                          child: Text(
                                            'Add Item',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                              if (_mornTea != null && _mornTea.length > 0)
                                GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _mornTea.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 8.0 / 9.0,
                                    crossAxisCount: 2,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return RecipeCard(
                                      item: _mornTea[index],
                                      deletePermission: deleteRecipePermission,
                                      onDelete: () async {
                                        RecipeAPIHandler handler =
                                            RecipeAPIHandler({
                                          "userid": MyApp.LOGIN_ID_VALUE,
                                          "id": _mornTea[index].id,
                                        });
                                        var data =
                                            await handler.deleteListItem();
                                        print(data);
                                        dataFetched = false;
                                        _fetchData();
                                        setState(() {});
                                      },
                                      onTap: () {
                                        if (_mornTea[index].createdBy ==
                                            MyApp.LOGIN_ID_VALUE) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Addrecipe(
                                                type: 'edit',
                                                id: _mornTea[index].id,
                                                centerid:
                                                    centers[currentIndex].id,
                                                reciepieType:
                                                    _mornTea[index].type,
                                              ),
                                            ),
                                          ).then((value) {
                                            if (value != null) {
                                              dataFetched = false;
                                              setState(() {});
                                              _fetchData();
                                            }
                                          });
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewRecipe(
                                                id: _mornTea[index].id,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Breakfast',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  if (addRecipePermission)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Addrecipe(
                                                      reciepieType: 'BREAKFAST',
                                                      centerid:
                                                          centers[currentIndex]
                                                              .id,
                                                      id: '',
                                                    ))).then((value) {
                                          if (value != null) {
                                            dataFetched = false;
                                            setState(() {});
                                            _fetchData();
                                          }
                                        });
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
                                              'Add Item',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          )),
                                    )
                                ],
                              ),
                              if (_breakfast != null && _breakfast.length > 0)
                                GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _breakfast.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 8.0 / 9.0,
                                          crossAxisCount: 2),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return RecipeCard(
                                      item: _breakfast[index],
                                      deletePermission: deleteRecipePermission,
                                      onDelete: () async {
                                        RecipeAPIHandler handler =
                                            RecipeAPIHandler({
                                          "userid": MyApp.LOGIN_ID_VALUE,
                                          "id": _breakfast[index].id,
                                        });
                                        var data =
                                            await handler.deleteListItem();
                                        print(data);
                                        dataFetched = false;
                                        _fetchData();
                                        setState(() {});
                                      },
                                      onTap: () {
                                        if (_breakfast[index].createdBy ==
                                            MyApp.LOGIN_ID_VALUE) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Addrecipe(
                                                type: 'edit',
                                                id: _breakfast[index].id,
                                                centerid:
                                                    centers[currentIndex].id,
                                                reciepieType:
                                                    _breakfast[index].type,
                                              ),
                                            ),
                                          ).then((value) {
                                            if (value != null) {
                                              dataFetched = false;
                                              setState(() {});
                                              _fetchData();
                                            }
                                          });
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewRecipe(
                                                  id: _breakfast[index].id),
                                            ),
                                          );
                                        }
                                      },
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  if (addRecipePermission)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Addrecipe(
                                                      reciepieType: 'LUNCH',
                                                      centerid:
                                                          centers[currentIndex]
                                                              .id,
                                                      id: '',
                                                    ))).then((value) {
                                          if (value != null) {
                                            dataFetched = false;
                                            setState(() {});
                                            _fetchData();
                                          }
                                        });
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
                                              'Add Item',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          )),
                                    )
                                ],
                              ),
                              if (_lunch != null && _lunch.length > 0)
                                GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _lunch.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 8.0 / 9.0,
                                          crossAxisCount: 2),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return RecipeCard(
                                      item: _lunch[index],
                                      deletePermission: deleteRecipePermission,
                                      onDelete: () async {
                                        RecipeAPIHandler handler =
                                            RecipeAPIHandler({
                                          "userid": MyApp.LOGIN_ID_VALUE,
                                          "id": _lunch[index].id,
                                        });
                                        var data =
                                            await handler.deleteListItem();
                                        print(data);
                                        dataFetched = false;
                                        _fetchData();
                                        setState(() {});
                                      },
                                      onTap: () {
                                        if (_lunch[index].createdBy ==
                                            MyApp.LOGIN_ID_VALUE) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Addrecipe(
                                                type: 'edit',
                                                id: _lunch[index].id,
                                                centerid:
                                                    centers[currentIndex].id,
                                                reciepieType:
                                                    _breakfast[index].type,
                                              ),
                                            ),
                                          ).then((value) {
                                            if (value != null) {
                                              dataFetched = false;
                                              setState(() {});
                                              _fetchData();
                                            }
                                          });
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewRecipe(
                                                id: _lunch[index].id,
                                              ),
                                            ),
                                          );
                                        }
                                      },
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  if (addRecipePermission)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Addrecipe(
                                                      reciepieType: 'SNACKS',
                                                      centerid:
                                                          centers[currentIndex]
                                                              .id,
                                                      id: '',
                                                    ))).then((value) {
                                          if (value != null) {
                                            dataFetched = false;
                                            setState(() {});
                                            _fetchData();
                                          }
                                        });
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
                                              'Add Item',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          )),
                                    )
                                ],
                              ),
                              if (_snacks != null && _snacks.length > 0)
                                GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _snacks.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 8.0 / 9.0,
                                          crossAxisCount: 2),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return RecipeCard(
                                      item: _snacks[index],
                                      deletePermission: deleteRecipePermission,
                                      onDelete: () async {
                                        RecipeAPIHandler handler =
                                            RecipeAPIHandler({
                                          "userid": MyApp.LOGIN_ID_VALUE,
                                          "id": _snacks[index].id,
                                        });
                                        var data =
                                            await handler.deleteListItem();
                                        print(data);
                                        dataFetched = false;
                                        _fetchData();
                                        setState(() {});
                                      },
                                      onTap: () {
                                        if (_snacks[index].createdBy ==
                                            MyApp.LOGIN_ID_VALUE) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Addrecipe(
                                                type: 'edit',
                                                id: _snacks[index].id,
                                                centerid:
                                                    centers[currentIndex].id,
                                                reciepieType:
                                                    _breakfast[index].type,
                                              ),
                                            ),
                                          ).then((value) {
                                            if (value != null) {
                                              dataFetched = false;
                                              setState(() {});
                                              _fetchData();
                                            }
                                          });
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewRecipe(
                                                id: _snacks[index].id,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Afternoon Tea',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  if (addRecipePermission)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Addrecipe(
                                              reciepieType: 'AFTERNOON_TEA',
                                              centerid:
                                                  centers[currentIndex].id,
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            dataFetched = false;
                                            setState(() {});
                                            _fetchData();
                                          }
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Constants.kButton,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 8, 12, 8),
                                          child: Text(
                                            'Add Item',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                              if (_afternTea != null && _afternTea.length > 0)
                                GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _afternTea.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 8.0 / 9.0,
                                    crossAxisCount: 2,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return RecipeCard(
                                      item: _afternTea[index],
                                      deletePermission: deleteRecipePermission,
                                      onDelete: () async {
                                        RecipeAPIHandler handler =
                                            RecipeAPIHandler({
                                          "userid": MyApp.LOGIN_ID_VALUE,
                                          "id": _afternTea[index].id,
                                        });
                                        var data =
                                            await handler.deleteListItem();
                                        print(data);
                                        dataFetched = false;
                                        _fetchData();
                                        setState(() {});
                                      },
                                      onTap: () {
                                        if (_afternTea[index].createdBy ==
                                            MyApp.LOGIN_ID_VALUE) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Addrecipe(
                                                type: 'edit',
                                                id: _afternTea[index].id,
                                                centerid:
                                                    centers[currentIndex].id,
                                                reciepieType:
                                                    _breakfast[index].type,
                                              ),
                                            ),
                                          ).then((value) {
                                            if (value != null) {
                                              dataFetched = false;
                                              setState(() {});
                                              _fetchData();
                                            }
                                          });
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewRecipe(
                                                id: _afternTea[index].id,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        )
                    ])))));
  }
}

class RecipeCard extends StatelessWidget {
  final dynamic item;
  final bool deletePermission;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const RecipeCard({
    Key? key,
    required this.item,
    required this.deletePermission,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SizedBox(height: 5),
          item.media.isNotEmpty
              ? item.media[0]['mediaType'] == 'Image'
                  ? AspectRatio(
                      aspectRatio: 18.0 / 16.0,
                      child: Image.network(
                        Constants.ImageBaseUrl + item.media[0]['mediaUrl'],
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(child: Icon(Icons.video_collection))
              : AspectRatio(
                  aspectRatio: 18.0 / 16.0,
                  child: Image.network(
                    'https://st4.depositphotos.com/14953852/24787/v/600/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 2, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.23,
                  child: AutoSizeText(
                    item.itemName,
                    minFontSize: 8,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    if (deletePermission)
                      GestureDetector(
                        child: Icon(
                          AntDesign.delete,
                          color: Constants.kMain,
                          size: 14,
                        ),
                        onTap: onDelete,
                      ),
                    SizedBox(width: 10),
                    GestureDetector(
                      child: Icon(
                        item.createdBy == MyApp.LOGIN_ID_VALUE
                            ? Icons.edit
                            : AntDesign.eyeo,
                        color: Constants.kMain,
                        size: 16,
                      ),
                      onTap: onTap,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
