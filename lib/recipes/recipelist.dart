import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
  List<RecipeModel> _lunch;
  List<RecipeModel> _breakfast;
  List<RecipeModel> _snacks;
  List<RecipeModel> _tea;

  List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;

  bool permissionRecipe = false;
  bool addRecipePermission = false;
  bool deleteRecipePermission = false;
  bool loading=true;

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
      centers = new List();
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

  Future<void> _fetchData() async {
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
        _tea = [];
        try {
          assert(res is List);
          for (int i = 0; i < res.length; i++) {
            if (res[i]['type'] == 'LUNCH') {
              _lunch.add(RecipeModel.fromJson(res[i]));
            } else if (res[i]['type'] == 'BREAKFAST') {
              _breakfast.add(RecipeModel.fromJson(res[i]));
            } else if (res[i]['type'] == 'SNACKS') {
              _snacks.add(RecipeModel.fromJson(res[i]));
            }
          }
          dataFetched = true;
          if (this.mounted) setState(() {});
        } catch (e) {
          print(e);
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
      if( MyApp.USER_TYPE_VALUE == 'Parent' || MyApp.USER_TYPE_VALUE == 'Superadmin' || data['permissions'] != null) {
        permissionRecipe=true;
      }else{
        permissionRecipe=false;
      }
      loading=false;
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
                                    border: Border.all(color: Colors.grey[300]),
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
                      if(loading)
                   Container(
                     height: MediaQuery.of(context).size.height,
                     width: MediaQuery.of(context).size.width,
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
                      // if (dataFetched && permissionRecipe && !loading)
                      //   Container(
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         SizedBox(
                      //           height: 10,
                      //         ),
                      //         Row(
                      //           children: [
                      //             Text(
                      //               'Breakfast',
                      //               style:
                      //                   TextStyle(fontWeight: FontWeight.bold),
                      //             ),
                      //             Expanded(
                      //               child: Container(),
                      //             ),
                      //             if (addRecipePermission)
                      //               GestureDetector(
                      //                 onTap: () {
                      //                   Navigator.push(
                      //                       context,
                      //                       MaterialPageRoute(
                      //                           builder: (context) => Addrecipe(
                      //                                 type: 'BREAKFAST',
                      //                                 centerid:
                      //                                     centers[currentIndex]
                      //                                         .id,
                      //                               ))).then((value) {
                      //                     if (value != null) {
                      //                       dataFetched = false;
                      //                       setState(() {});
                      //                       _fetchData();
                      //                     }
                      //                   });
                      //                 },
                      //                 child: Container(
                      //                     decoration: BoxDecoration(
                      //                         color: Constants.kButton,
                      //                         borderRadius: BorderRadius.all(
                      //                             Radius.circular(8))),
                      //                     child: Padding(
                      //                       padding: const EdgeInsets.fromLTRB(
                      //                           12, 8, 12, 8),
                      //                       child: Text(
                      //                         'Add Item',
                      //                         style: TextStyle(
                      //                             color: Colors.white,
                      //                             fontSize: 12),
                      //                       ),
                      //                     )),
                      //               )
                      //           ],
                      //         ),
                      //         if (_breakfast != null && _breakfast.length > 0)
                      //           GridView.builder(
                      //             physics: NeverScrollableScrollPhysics(),
                      //             shrinkWrap: true,
                      //             itemCount: _breakfast.length,
                      //             gridDelegate:
                      //                 SliverGridDelegateWithFixedCrossAxisCount(
                      //                     childAspectRatio: 8.0 / 9.0,
                      //                     crossAxisCount: 2),
                      //             itemBuilder:
                      //                 (BuildContext context, int index) {
                      //               return Card(
                      //                 child: Column(children: [
                      //                   _breakfast[index].media.length > 0
                      //                       ? _breakfast[index].media[0]
                      //                                   ['mediaType'] ==
                      //                               'Image'
                      //                           ? AspectRatio(
                      //                               aspectRatio: 18.0 / 16.0,
                      //                               child: Image.network(
                      //                                   Constants.ImageBaseUrl +
                      //                                       _breakfast[index]
                      //                                               .media[0]
                      //                                           ['mediaUrl']),
                      //                             )
                      //                           : Center(
                      //                               child: Icon(
                      //                                   Icons.video_collection))
                      //                       : AspectRatio(
                      //                           aspectRatio: 18.0 / 16.0,
                      //                           child: Image.network(
                      //                               'https://st4.depositphotos.com/14953852/24787/v/600/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg'),
                      //                         ), //just for testing, will fill with image later

                      //                   Padding(
                      //                     padding: const EdgeInsets.only(
                      //                         left: 2.0, right: 2),
                      //                     child: Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.spaceBetween,
                      //                       children: [
                      //                         Container(
                      //                             width: MediaQuery.of(context)
                      //                                     .size
                      //                                     .width *
                      //                                 0.23,
                      //                             child: AutoSizeText(
                      //                               _breakfast[index].itemName,
                      //                               minFontSize: 8,
                      //                               maxLines: 2,
                      //                               overflow:
                      //                                   TextOverflow.ellipsis,
                      //                             )),
                      //                         Row(
                      //                           children: [
                      //                             if (deleteRecipePermission)
                      //                               GestureDetector(
                      //                                 child: Icon(
                      //                                   AntDesign.delete,
                      //                                   color: Constants.kMain,
                      //                                   size: 14,
                      //                                 ),
                      //                                 onTap: () async {
                      //                                   RecipeAPIHandler
                      //                                       handler =
                      //                                       RecipeAPIHandler({
                      //                                     "userid": MyApp
                      //                                         .LOGIN_ID_VALUE,
                      //                                     "id":
                      //                                         _breakfast[index]
                      //                                             .id,
                      //                                   });
                      //                                   var data = await handler
                      //                                       .deleteListItem();
                      //                                   print(data);
                      //                                   dataFetched = false;
                      //                                   _fetchData();
                      //                                   setState(() {});
                      //                                 },
                      //                               ),
                      //                             SizedBox(
                      //                               width: 10,
                      //                             ),
                      //                             GestureDetector(
                      //                               child: Icon(
                      //                                 _breakfast[index]
                      //                                             .createdBy ==
                      //                                         MyApp
                      //                                             .LOGIN_ID_VALUE
                      //                                     ? Icons.edit
                      //                                     : AntDesign.eyeo,
                      //                                 color: Constants.kMain,
                      //                                 size: 16,
                      //                               ),
                      //                               onTap: () {
                      //                                 if (_breakfast[index]
                      //                                         .createdBy ==
                      //                                     MyApp
                      //                                         .LOGIN_ID_VALUE) {
                      //                                   Navigator.push(
                      //                                       context,
                      //                                       MaterialPageRoute(
                      //                                           builder:
                      //                                               (context) =>
                      //                                                   Addrecipe(
                      //                                                     type:
                      //                                                         'edit',
                      //                                                     id: _breakfast[index]
                      //                                                         .id,
                      //                                                   ))).then(
                      //                                       (value) {
                      //                                     if (value != null) {
                      //                                       dataFetched = false;
                      //                                       setState(() {});
                      //                                       _fetchData();
                      //                                     }
                      //                                   });
                      //                                 } else {
                      //                                   Navigator.push(
                      //                                       context,
                      //                                       MaterialPageRoute(
                      //                                           builder:
                      //                                               (context) =>
                      //                                                   ViewRecipe(
                      //                                                     id: _breakfast[index]
                      //                                                         .id,
                      //                                                   )));
                      //                                 }
                      //                               },
                      //                             ),
                      //                           ],
                      //                         )
                      //                       ],
                      //                     ),
                      //                   )
                      //                 ]),
                      //               );
                      //             },
                      //           ),
                      //         SizedBox(
                      //           height: 10,
                      //         ),
                      //         Row(
                      //           children: [
                      //             Text(
                      //               'Lunch',
                      //               style:
                      //                   TextStyle(fontWeight: FontWeight.bold),
                      //             ),
                      //             Expanded(
                      //               child: Container(),
                      //             ),
                      //             if (addRecipePermission)
                      //               GestureDetector(
                      //                 onTap: () {
                      //                   Navigator.push(
                      //                       context,
                      //                       MaterialPageRoute(
                      //                           builder: (context) => Addrecipe(
                      //                                 type: 'LUNCH',
                      //                                 centerid:
                      //                                     centers[currentIndex]
                      //                                         .id,
                      //                               ))).then((value) {
                      //                     if (value != null) {
                      //                       dataFetched = false;
                      //                       setState(() {});
                      //                       _fetchData();
                      //                     }
                      //                   });
                      //                 },
                      //                 child: Container(
                      //                     decoration: BoxDecoration(
                      //                         color: Constants.kButton,
                      //                         borderRadius: BorderRadius.all(
                      //                             Radius.circular(8))),
                      //                     child: Padding(
                      //                       padding: const EdgeInsets.fromLTRB(
                      //                           12, 8, 12, 8),
                      //                       child: Text(
                      //                         'Add Item',
                      //                         style: TextStyle(
                      //                             color: Colors.white,
                      //                             fontSize: 12),
                      //                       ),
                      //                     )),
                      //               )
                      //           ],
                      //         ),
                      //         if (_lunch != null && _lunch.length > 0)
                      //           GridView.builder(
                      //             physics: NeverScrollableScrollPhysics(),
                      //             shrinkWrap: true,
                      //             itemCount: _lunch.length,
                      //             gridDelegate:
                      //                 SliverGridDelegateWithFixedCrossAxisCount(
                      //                     childAspectRatio: 8.0 / 9.0,
                      //                     crossAxisCount: 2),
                      //             itemBuilder:
                      //                 (BuildContext context, int index) {
                      //               return Card(
                      //                 child: Column(
                      //                   children: [
                      //                     _lunch[index].media.length > 0
                      //                         ? _lunch[index].media[0]
                      //                                     ['mediaType'] ==
                      //                                 'Image'
                      //                             ? AspectRatio(
                      //                                 aspectRatio: 18.0 / 16.0,
                      //                                 child: Image.network(
                      //                                     Constants
                      //                                             .ImageBaseUrl +
                      //                                         _lunch[index]
                      //                                                 .media[0]
                      //                                             ['mediaUrl']),
                      //                               )
                      //                             : Card(
                      //                                 child: Center(
                      //                                     child: Icon(Icons
                      //                                         .video_collection)))
                      //                         : AspectRatio(
                      //                             aspectRatio: 18.0 / 16.0,
                      //                             child: Image.network(
                      //                                 'https://st4.depositphotos.com/14953852/24787/v/600/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg'),
                      //                           ), //just for testing, will fill with image later

                      //                     Padding(
                      //                       padding: const EdgeInsets.only(
                      //                           left: 2.0, right: 2),
                      //                       child: Row(
                      //                         mainAxisAlignment:
                      //                             MainAxisAlignment
                      //                                 .spaceBetween,
                      //                         children: [
                      //                           Container(
                      //                               width:
                      //                                   MediaQuery.of(context)
                      //                                           .size
                      //                                           .width *
                      //                                       0.23,
                      //                               child: AutoSizeText(
                      //                                 _lunch[index].itemName,
                      //                                 minFontSize: 8,
                      //                                 maxLines: 2,
                      //                                 overflow:
                      //                                     TextOverflow.ellipsis,
                      //                               )),
                      //                           Row(
                      //                             children: [
                      //                               if (deleteRecipePermission)
                      //                                 GestureDetector(
                      //                                   child: Icon(
                      //                                     AntDesign.delete,
                      //                                     color:
                      //                                         Constants.kMain,
                      //                                     size: 14,
                      //                                   ),
                      //                                   onTap: () async {
                      //                                     RecipeAPIHandler
                      //                                         handler =
                      //                                         RecipeAPIHandler({
                      //                                       "userid": MyApp
                      //                                           .LOGIN_ID_VALUE,
                      //                                       "id": _lunch[index]
                      //                                           .id,
                      //                                     });
                      //                                     var data = await handler
                      //                                         .deleteListItem();
                      //                                     print(data);
                      //                                     dataFetched = false;
                      //                                     _fetchData();
                      //                                     setState(() {});
                      //                                   },
                      //                                 ),
                      //                               SizedBox(
                      //                                 width: 10,
                      //                               ),
                      //                               GestureDetector(
                      //                                 child: Icon(
                      //                                   _lunch[index]
                      //                                               .createdBy ==
                      //                                           MyApp
                      //                                               .LOGIN_ID_VALUE
                      //                                       ? Icons.edit
                      //                                       : AntDesign.eyeo,
                      //                                   color: Constants.kMain,
                      //                                   size: 16,
                      //                                 ),
                      //                                 onTap: () {
                      //                                   if (_lunch[index]
                      //                                           .createdBy ==
                      //                                       MyApp
                      //                                           .LOGIN_ID_VALUE) {
                      //                                     Navigator.push(
                      //                                         context,
                      //                                         MaterialPageRoute(
                      //                                             builder: (context) =>
                      //                                                 Addrecipe(
                      //                                                   type:
                      //                                                       'edit',
                      //                                                   id: _lunch[index]
                      //                                                       .id,
                      //                                                 ))).then(
                      //                                         (value) {
                      //                                       if (value != null) {
                      //                                         dataFetched =
                      //                                             false;
                      //                                         setState(() {});
                      //                                         _fetchData();
                      //                                       }
                      //                                     });
                      //                                   } else {
                      //                                     Navigator.push(
                      //                                         context,
                      //                                         MaterialPageRoute(
                      //                                             builder:
                      //                                                 (context) =>
                      //                                                     ViewRecipe(
                      //                                                       id: _lunch[index].id,
                      //                                                     )));
                      //                                   }
                      //                                 },
                      //                               ),
                      //                             ],
                      //                           )
                      //                         ],
                      //                       ),
                      //                     )
                      //                   ],
                      //                 ),
                      //               );
                      //             },
                      //           ),
                      //         SizedBox(
                      //           height: 10,
                      //         ),
                      //         Row(
                      //           children: [
                      //             Text(
                      //               'Snacks',
                      //               style:
                      //                   TextStyle(fontWeight: FontWeight.bold),
                      //             ),
                      //             Expanded(
                      //               child: Container(),
                      //             ),
                      //             if (addRecipePermission)
                      //               GestureDetector(
                      //                 onTap: () {
                      //                   Navigator.push(
                      //                       context,
                      //                       MaterialPageRoute(
                      //                           builder: (context) => Addrecipe(
                      //                                 type: 'SNACKS',
                      //                                 centerid:
                      //                                     centers[currentIndex]
                      //                                         .id,
                      //                               ))).then((value) {
                      //                     if (value != null) {
                      //                       dataFetched = false;
                      //                       setState(() {});
                      //                       _fetchData();
                      //                     }
                      //                   });
                      //                 },
                      //                 child: Container(
                      //                     decoration: BoxDecoration(
                      //                         color: Constants.kButton,
                      //                         borderRadius: BorderRadius.all(
                      //                             Radius.circular(8))),
                      //                     child: Padding(
                      //                       padding: const EdgeInsets.fromLTRB(
                      //                           12, 8, 12, 8),
                      //                       child: Text(
                      //                         'Add Item',
                      //                         style: TextStyle(
                      //                             color: Colors.white,
                      //                             fontSize: 12),
                      //                       ),
                      //                     )),
                      //               )
                      //           ],
                      //         ),
                      //         if (_snacks != null && _snacks.length > 0)
                      //           GridView.builder(
                      //             physics: NeverScrollableScrollPhysics(),
                      //             shrinkWrap: true,
                      //             itemCount: _snacks.length,
                      //             gridDelegate:
                      //                 SliverGridDelegateWithFixedCrossAxisCount(
                      //                     childAspectRatio: 8.0 / 9.0,
                      //                     crossAxisCount: 2),
                      //             itemBuilder:
                      //                 (BuildContext context, int index) {
                      //               return Card(
                      //                 child: Column(
                      //                   children: [
                      //                     _snacks[index].media.length > 0
                      //                         ? _snacks[index].media[0]
                      //                                     ['mediaType'] ==
                      //                                 'Image'
                      //                             ? AspectRatio(
                      //                                 aspectRatio: 18.0 / 16.0,
                      //                                 child: Image.network(
                      //                                     Constants
                      //                                             .ImageBaseUrl +
                      //                                         _snacks[index]
                      //                                                 .media[0]
                      //                                             ['mediaUrl']),
                      //                               )
                      //                             : Card(
                      //                                 child: Center(
                      //                                     child: Icon(Icons
                      //                                         .video_collection)))
                      //                         : AspectRatio(
                      //                             aspectRatio: 18.0 / 16.0,
                      //                             child: Image.network(
                      //                                 'https://st4.depositphotos.com/14953852/24787/v/600/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg'),
                      //                           ),
                      //                     Padding(
                      //                       padding: const EdgeInsets.only(
                      //                           left: 2.0, right: 2),
                      //                       child: Row(
                      //                         mainAxisAlignment:
                      //                             MainAxisAlignment
                      //                                 .spaceBetween,
                      //                         children: [
                      //                           Container(
                      //                               width:
                      //                                   MediaQuery.of(context)
                      //                                           .size
                      //                                           .width *
                      //                                       0.23,
                      //                               child: AutoSizeText(
                      //                                 _snacks[index].itemName,
                      //                                 minFontSize: 8,
                      //                                 maxLines: 2,
                      //                                 overflow:
                      //                                     TextOverflow.ellipsis,
                      //                               )),
                      //                           Row(
                      //                             children: [
                      //                               if (deleteRecipePermission)
                      //                                 GestureDetector(
                      //                                   child: Icon(
                      //                                     AntDesign.delete,
                      //                                     color:
                      //                                         Constants.kMain,
                      //                                     size: 14,
                      //                                   ),
                      //                                   onTap: () async {
                      //                                     RecipeAPIHandler
                      //                                         handler =
                      //                                         RecipeAPIHandler({
                      //                                       "userid": MyApp
                      //                                           .LOGIN_ID_VALUE,
                      //                                       "id": _snacks[index]
                      //                                           .id,
                      //                                     });
                      //                                     var data = await handler
                      //                                         .deleteListItem();
                      //                                     print(data);
                      //                                     dataFetched = false;
                      //                                     _fetchData();
                      //                                     setState(() {});
                      //                                   },
                      //                                 ),
                      //                               SizedBox(
                      //                                 width: 10,
                      //                               ),
                      //                               GestureDetector(
                      //                                 child: Icon(
                      //                                   _snacks[index]
                      //                                               .createdBy ==
                      //                                           MyApp
                      //                                               .LOGIN_ID_VALUE
                      //                                       ? Icons.edit
                      //                                       : AntDesign.eyeo,
                      //                                   color: Constants.kMain,
                      //                                   size: 16,
                      //                                 ),
                      //                                 onTap: () {
                      //                                   if (_snacks[index]
                      //                                           .createdBy ==
                      //                                       MyApp
                      //                                           .LOGIN_ID_VALUE) {
                      //                                     Navigator.push(
                      //                                         context,
                      //                                         MaterialPageRoute(
                      //                                             builder: (context) =>
                      //                                                 Addrecipe(
                      //                                                   type:
                      //                                                       'edit',
                      //                                                   id: _snacks[index]
                      //                                                       .id,
                      //                                                 ))).then(
                      //                                         (value) {
                      //                                       if (value != null) {
                      //                                         dataFetched =
                      //                                             false;
                      //                                         setState(() {});
                      //                                         _fetchData();
                      //                                       }
                      //                                     });
                      //                                   } else {
                      //                                     Navigator.push(
                      //                                         context,
                      //                                         MaterialPageRoute(
                      //                                             builder:
                      //                                                 (context) =>
                      //                                                     ViewRecipe(
                      //                                                       id: _snacks[index].id,
                      //                                                     )));
                      //                                   }
                      //                                 },
                      //                               ),
                      //                             ],
                      //                           )
                      //                         ],
                      //                       ),
                      //                     )
                      //                   ],
                      //                 ),
                      //               );
                      //             },
                      //           ),
                      //         SizedBox(
                      //           height: 10,
                      //         ),
                      //       ],
                      //     ),
                      //   )
                   
                    ])))));
  }
}
