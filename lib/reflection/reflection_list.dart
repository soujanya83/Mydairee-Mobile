import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/reflectionapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/getUserReflections.dart';
import 'package:mykronicle_mobile/models/reflectionmodel.dart';
import 'package:mykronicle_mobile/reflection/add_reflection.dart';
import 'package:mykronicle_mobile/reflection/edit_reflection.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:http/http.dart' as http;

class ReflectionList extends StatefulWidget {
  @override
  _ReflectionListState createState() => _ReflectionListState();
}

class _ReflectionListState extends State<ReflectionList> {
  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;

  List<Reflections> _reflection = [];
  bool reflectionFetched = false;

  var details;

  @override
  void initState() {
    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    if (!dt.containsKey('error')) {
      print(dt);
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
      //MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  Future<void> _fetchData() async {
    Map<String, String> data = {
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': centers[currentIndex].id,
    };
    ReflectionApiHandler hlr = ReflectionApiHandler(data);
    var adt = await hlr.getDetails();

    if (!adt.containsKey('error')) {
      details = adt;

      var resreflection = adt['Reflections'];
      _reflection = [];
      try {
        assert(resreflection is List);
        for (int i = 0; i < resreflection.length; i++) {
          _reflection.add(Reflections.fromJson(resreflection[i]));
        }
        reflectionFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
      // var resmedia = adt['Reflections']['media'];
      // _media = [];
      // try {
      //   assert(resmedia is List);
      //   for (int i = 0; i < resmedia.length; i++) {
      //     _media.add(Media.fromJson(resmedia[i]));
      //   }
      //   mediaFetched = true;
      //   if (this.mounted) setState(() {});
      // } catch (e) {
      //   print(e);
      // }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reflection',
                        style: Constants.header1,
                      ),
                      if (MyApp.USER_TYPE_VALUE != 'Parent')
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddReflection(
                                          centerid: centers[currentIndex].id,
                                        ))).then((value) {
                              details = null;
                              _fetchData();
                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Constants.kButton,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                child: Text(
                                  'Add New',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              )),
                        )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
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
                  details != null
                      ? reflectionFetched
                          ? Container(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _reflection.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _reflection[index].title,
                                                      style: Constants.header7,
                                                    ),
                                                    Text(
                                                      DateFormat('dd/MM/yyyy')
                                                          .format(DateTime.parse(
                                                              _reflection[index]
                                                                  .createdAt
                                                                  .toString())),
                                                      style: TextStyle(
                                                          fontSize: 12.0,
                                                          color:
                                                              Constants.kMain,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(child: Container()),
                                                if (MyApp.USER_TYPE_VALUE !=
                                                    'Parent')
                                                  IconButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      iconSize: 20,
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: new Text(
                                                                  "Delete Reflection"),
                                                              content: new Text(
                                                                  "Are you sure you want to delete Reflection"),
                                                              actions: <Widget>[
                                                                new TextButton(
                                                                  child: new Text(
                                                                      "Cancel"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                                new TextButton(
                                                                  child:
                                                                      new Text(
                                                                          "Ok"),
                                                                  onPressed:
                                                                      () async {
                                                                    var _toSend =
                                                                        Constants.BASE_URL +
                                                                            'Reflections/deleteReflection';
                                                                    var objTOSend =
                                                                        {
                                                                      "userid":
                                                                          MyApp
                                                                              .LOGIN_ID_VALUE,
                                                                      "reflectionid":
                                                                          _reflection[index]
                                                                              .id,
                                                                    };
                                                                    final response = await http.post(
                                                                        Uri.parse(
                                                                            _toSend),
                                                                        body: jsonEncode(
                                                                            objTOSend),
                                                                        headers: {
                                                                          "X-DEVICE-ID":
                                                                              await MyApp.getDeviceIdentity(),
                                                                          "X-TOKEN":
                                                                              MyApp.AUTH_TOKEN_VALUE,
                                                                        });

                                                                    if (response
                                                                            .statusCode ==
                                                                        200) {
                                                                      details =
                                                                          null;
                                                                      setState(
                                                                          () {});
                                                                      details =
                                                                          null;
                                                                      _fetchData();
                                                                      Navigator.pop(
                                                                          context);
                                                                      MyApp.ShowToast(
                                                                          "deleted",
                                                                          context);
                                                                    } else if (response
                                                                            .statusCode ==
                                                                        401) {
                                                                      MyApp.Show401Dialog(
                                                                          context);
                                                                    }
                                                                  },
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      )),
                                                if (MyApp.USER_TYPE_VALUE !=
                                                    'Parent')
                                                  IconButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      iconSize: 20,
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        EditReflection(
                                                                          centerid:
                                                                              centers[currentIndex].id,
                                                                          reflectionid:
                                                                              _reflection[index].id,
                                                                        ))).then(
                                                            (value) {
                                                          details = null;
                                                          _fetchData();
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                      )),
                                                _reflection[index].status ==
                                                        'PUBLISHED'
                                                    ? GestureDetector(
                                                        onTap: () {},
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .green,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      12,
                                                                      8,
                                                                      12,
                                                                      8),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.check,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 10,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    _reflection[index].status !=
                                                                            null
                                                                        ? _reflection[index]
                                                                            .status
                                                                        : '',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .white),
                                                                  )
                                                                ],
                                                              ),
                                                            )),
                                                      )
                                                    : GestureDetector(
                                                        onTap: () {
                                                          // Navigator.push(context,MaterialPageRoute(
                                                          //   builder: (context) =>AddObservation()));
                                                        },
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Color(
                                                                    0xffFFEFB8),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      12,
                                                                      8,
                                                                      12,
                                                                      8),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .drafts,
                                                                    color: Color(
                                                                        0xffCC9D00),
                                                                    size: 10,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    _reflection[index].status !=
                                                                            null
                                                                        ? _reflection[index]
                                                                            .status
                                                                        : '',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Color(
                                                                            0xffCC9D00)),
                                                                  )
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                              ],
                                            ),
                                            _reflection[index].childs.length !=
                                                    0
                                                ? new Container(
                                                    height: 50,
                                                    child: Row(
                                                      children: [
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount: _reflection[
                                                                            index]
                                                                        .childs
                                                                        .length >=
                                                                    2
                                                                ? 2
                                                                : _reflection[
                                                                        index]
                                                                    .childs
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    indexs) {
                                                              return Container(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left: 8.0,
                                                                      right:
                                                                          8.0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      _reflection[index].childs[indexs]['imageUrl'] != '' &&
                                                                              _reflection[index].childs[indexs]['imageUrl'] != null
                                                                          ? CircleAvatar(
                                                                              radius: 10.0,
                                                                              backgroundImage: NetworkImage(Constants.ImageBaseUrl + _reflection[index].childs[indexs]['imageUrl']),
                                                                              backgroundColor: Colors.transparent,
                                                                            )
                                                                          : CircleAvatar(
                                                                              radius: 10,
                                                                              backgroundColor: Colors.grey,
                                                                            ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        _reflection[index].childs[indexs]
                                                                            [
                                                                            'name'],
                                                                        style: Constants
                                                                            .header3,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                        _reflection[index]
                                                                    .childs
                                                                    .length >
                                                                2
                                                            ? Container(
                                                                height: 25,
                                                                width: 25,
                                                                color: Colors
                                                                    .grey[200],
                                                                child: Center(
                                                                  child: Text("+" +
                                                                      '${_reflection[index].childs.length - 2}'),
                                                                ),
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _reflection[index]
                                                            .media
                                                            .length !=
                                                        0
                                                    ? Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        height: 200,
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              _reflection[index]
                                                                  .media
                                                                  .length,
                                                          itemBuilder: (context,
                                                              indexs) {
                                                            return _reflection[index].media[indexs]
                                                                            [
                                                                            'mediaUrl'] !=
                                                                        null &&
                                                                    _reflection[index].media[indexs]
                                                                            [
                                                                            'mediaUrl'] !=
                                                                        ''
                                                                ? Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        2,
                                                                    height: 500,
                                                                    decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage(
                                                                              Constants.ImageBaseUrl + _reflection[index].media[indexs]['mediaUrl'],
                                                                            ),
                                                                            fit: BoxFit.cover)),
                                                                  )
                                                                : Container(
                                                                    color: Colors
                                                                        .grey,
                                                                  );
                                                          },
                                                        ),
                                                      )
                                                    : Container(),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                    child: Text(
                                                  _reflection[index].about,
                                                  style: TextStyle(
                                                      fontSize: 12.0,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                )),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          : Container()
                      : Container()
                ],
              ),
            ),
          )),
    );
  }
}
