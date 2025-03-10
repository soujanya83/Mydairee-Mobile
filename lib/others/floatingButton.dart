import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/childtablemodel.dart';
import 'package:mykronicle_mobile/observation/childdetails.dart';
import 'package:mykronicle_mobile/observation/viewobservation.dart';
import 'package:mykronicle_mobile/progress_notes/progressote.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class FloatingButton extends StatefulWidget {
  @override
  _FloatingButtonState createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> {
  List<CentersModel> centers=[];
  List<ChildTableModel> childData=[];
  bool centersFetched = false;
  bool childrensFetched = false;
  int currentIndex = 0;
  var childTable;
  String searchString = '';
  bool reverse = false;

  final DateFormat formatter = DateFormat('dd-MM-yy');

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
      MyApp.Show401Dialog(context);
    }
    _load();
  }

  void _load() async {
    UtilsAPIHandler utilsAPIHandler = UtilsAPIHandler({
      "usertype": MyApp.USER_TYPE_VALUE,
      "userid": MyApp.LOGIN_ID_VALUE,
      "centerid": centers[currentIndex].id
    });

    var data = await utilsAPIHandler.getChildTableDetails();
    if (!data.containsKey('error')) {
      childTable = data['Child_table'];
      childData = [];
      try {
        assert(childTable is List);
        for (int i = 0; i < childTable.length; i++) {
          if (childTable[i]['id'] != null)
            childData.add(ChildTableModel.fromJson(childTable[i]));
        }
        childrensFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
      print(childTable);
      setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Child Table',
                      style: Constants.header1,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        reverse = !reverse;
                        setState(() {});

                        // showDialog(
                        //   context: context,
                        //   builder: (BuildContext context) {
                        //     return AlertDialog(
                        //       title: Text('Filter'),
                        //       content: Container(
                        //         height: 100,
                        //         child: Column(
                        //           children: [
                        //             Wrap(
                        //               children: [
                        //                 GestureDetector(
                        //                     onTap: () {
                        //                       // childTable =
                        //                       //     new SplayTreeMap.from(
                        //                       //         childTable,
                        //                       //         (a, b) => a.value['name']
                        //                       //             .compareTo(
                        //                       //                 b.value['name']));

                        //                       // childData.sort((a, b) => b
                        //                       //     .childName
                        //                       //     .compareTo(a.childName));

                        //                       Navigator.pop(context);
                        //                     },
                        //                     child:
                        //                         Chip(label: Text('Sort Names')))
                        //               ],
                        //             )
                        //           ],
                        //         ),
                        //       ),
                        //     );
                        //    },
                        //  ).then((value) => setState(() {}));
                      },
                      icon: Icon(Entypo.select_arrows))
                ],
              ),
              centersFetched
                  ? Padding(
                      padding:
                          const EdgeInsets.only(left: 3.0, right: 3, bottom: 3),
                      child: DropdownButtonHideUnderline(
                        child: Container(
                          height: 40,
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
                                        childTable = null;
                                        _load();
                                      });
                                      break;
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                  color: Colors.white,
                ),
                height: 33.0,
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  decoration: new InputDecoration(
                    //  hintText: 'Search list data',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 3.0),
                    border: new OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchString = value!;
                    });
                  },
                ),
              ),
              if (childrensFetched)
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    reverse: reverse,
                    itemCount: childData.length,
                    itemBuilder: (context, index) {
                      return childData[index]
                              .childName
                              .toString()
                              .toLowerCase()
                              .contains(searchString.toLowerCase())
                          ? Card(
                              color: Colors.blueGrey[50],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          childData[index].image != '' &&
                                                  childData[index].image != null
                                              ? CircleAvatar(
                                                  radius: 30.0,
                                                  backgroundImage: NetworkImage(
                                                      Constants.ImageBaseUrl +
                                                          childData[index]
                                                              .image),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                )
                                              : CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: Colors.grey,
                                                ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    120,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ViewObservation(
                                                                            id: childData[index].obsId, montCount: '', eylfCount: '', devCount: '',
                                                                          )));
                                                        },
                                                        child: Text(
                                                          childData[index]
                                                              .childName,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ChildDetails(
                                                                          childId:
                                                                              childData[index].childId,
                                                                          centerId:
                                                                              childData[index].centerid,
                                                                        )));
                                                      },
                                                      child: Card(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            childData[index]
                                                                .obsCount),
                                                      )),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              // SizedBox(
                                              //   height: 10,
                                              // ),
                                              Text("Last Obs: " +
                                                  formatter.format(
                                                      DateTime.parse(
                                                          childData[index]
                                                              .obsDate))),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container();
                    })
            ],
          ),
        ),
      )),
    );
  }
}
