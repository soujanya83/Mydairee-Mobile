import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/areamodel.dart';
import 'package:mykronicle_mobile/models/devmilestonemodel.dart';
import 'package:mykronicle_mobile/models/eylfmodel.dart';
import 'package:mykronicle_mobile/models/montessorimodel.dart';
import 'package:mykronicle_mobile/models/observationmodel.dart';
import 'package:mykronicle_mobile/models/planstandmodel.dart';
import 'package:mykronicle_mobile/models/progplanmodel.dart';
import 'package:mykronicle_mobile/models/reflectionmodel.dart';
import 'package:mykronicle_mobile/models/resourcemodel.dart';
import 'package:mykronicle_mobile/models/standardsmodel.dart';
import 'package:mykronicle_mobile/models/surveymodel.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/qip/editstandard.dart';
import 'package:mykronicle_mobile/qip/viewElememt.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';
import 'package:http/http.dart' as http;

class Standards extends StatefulWidget {
  final List<AreaModel> areas;
  final int areaIndex;
  final String qipid;
  final String centerid;

  Standards(this.areas, this.areaIndex, this.qipid, this.centerid);

  @override
  _StandardsState createState() => _StandardsState();
}

class _StandardsState extends State<Standards> {
  bool discuss = true;
  TextEditingController add = TextEditingController();
  var comments = [];
  int currentIndex;
  List<StandardsModel> standards;

  @override
  void initState() {
    currentIndex = widget.areaIndex;
    _load();
    super.initState();
  }

  void _load() async {
    var objToSend = {
      "userid": MyApp.LOGIN_ID_VALUE,
      "areaid": widget.areas[currentIndex].id,
      "qipid": widget.qipid
    };

    QipAPIHandler qipAPIHandler = QipAPIHandler(objToSend);
    var data = await qipAPIHandler.viewQipList();
    comments = data['Comments'];

    var sd = await qipAPIHandler.getStandards();
    var standardsData = sd['Standards'];
    print('here');
    print(standardsData);
    standards = [];
    try {
      assert(standardsData is List);
      for (int i = 0; i < standardsData.length; i++) {
        StandardsModel standardsModel =
            StandardsModel.fromJson(standardsData[i]);
        List<StandardElementModel> standardElementModels = [];
        for (int j = 0; j < standardsData[i]['elements'].length; j++) {
          StandardElementModel elementModel =
              StandardElementModel.fromJson(standardsData[i]['elements'][j]);
          List<UserModel> users = [];
          for (int k = 0;
              k < standardsData[i]['elements'][j]['users'].length;
              k++) {
            users.add(UserModel.fromJson(
                standardsData[i]['elements'][j]['users'][k]));
          }
          elementModel.users = users;
          standardElementModels.add(elementModel);
        }
        standardsModel.elements = standardElementModels;
        standards.add(standardsModel);
      }
    } catch (e) {
      print(e);
    }

    print(standards);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(left: 3.0, right: 3, bottom: 3),
              child: DropdownButtonHideUnderline(
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Center(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: widget.areas[currentIndex].id,
                        items: widget.areas.map((AreaModel value) {
                          return new DropdownMenuItem<String>(
                            value: value.id,
                            child: new Text(value.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          for (int i = 0; i < widget.areas.length; i++) {
                            if (widget.areas[i].id == value) {
                              setState(() {
                                currentIndex = i;
                                //   details = null;
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            discuss ? Constants.kMain : Colors.white)),
                    onPressed: () {
                      discuss = true;
                      setState(() {});
                    },
                    child: Text(
                      'Discussion Boards',
                      style: TextStyle(
                          color: discuss ? Colors.white : Colors.black),
                    )),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            discuss ? Colors.white : Constants.kMain)),
                    onPressed: () {
                      discuss = false;
                      setState(() {});
                    },
                    child: Text(
                      'Standard & Elements',
                      style: TextStyle(
                          color: discuss ? Colors.black : Colors.white),
                    )),
              ],
            ),
            discuss
                ? Card(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 75,
                              child: TextField(
                                controller: add,
                                decoration: InputDecoration(
                                    disabledBorder: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: ' add comment'),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 20,
                              child: GestureDetector(
                                  onTap: () async {
                                    var objToSend = {
                                      "userid": MyApp.LOGIN_ID_VALUE,
                                      "areaid": widget.areas[currentIndex].id,
                                      "qipid": widget.qipid,
                                      "commentText": add.text
                                    };

                                    QipAPIHandler qipAPIHandler =
                                        QipAPIHandler(objToSend);
                                    var data =
                                        await qipAPIHandler.addQipComment();
                                    add.clear();
                                    comments = [];
                                    _load();
                                  },
                                  child: Icon(Icons.send)),
                            ),
                            Container(
                              width: 10,
                            )
                          ],
                        ),
                        Container(
                          height: 10,
                        ),
                        if (comments != null)
                          Container(
                            height: size.height * 0.7,
                            child: ListView.builder(
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Container(
                                      height: 60,
                                      width: 60,
                                      padding: EdgeInsets.all(8),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.primaries[Random()
                                                  .nextInt(
                                                      Colors.primaries.length)]
                                              .withOpacity(0.5)),
                                      child: Text(
                                        comments[index]['name'][0]
                                            .toUpperCase(),
                                        style: TextStyle(fontSize: 18).copyWith(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(comments[index]['name']),
                                    subtitle:
                                        Text(comments[index]['commentText']),
                                  );
                                }),
                          )
                      ],
                    ),
                  )
                : Container(
                    height: size.height * 0.75,
                    child: Column(
                      children: [
                        if (standards != null && standards.length > 0)
                          Container(
                            height: size.height * 0.7,
                            child: ListView.builder(
                                itemCount: standards.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Card(
                                        child: ListTile(
                                          title: Text(standards[index].name),
                                          trailing: Container(
                                            width: 140,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 16,
                                                  ),
                                                  onTap: () {
                                                    print(index);

                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditStandard(
                                                                    widget
                                                                        .areas,
                                                                    index,
                                                                    currentIndex,
                                                                    standards,
                                                                    widget.qipid
                                                                    )));
                                                  },
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  child: standards[index].expand
                                                      ? Icon(
                                                          AntDesign.up,
                                                          size: 16,
                                                        )
                                                      : Icon(
                                                          AntDesign.down,
                                                          size: 16,
                                                        ),
                                                  onTap: () {
                                                    standards[index].expand =
                                                        !standards[index]
                                                            .expand;
                                                    setState(() {});
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (standards[index].expand)
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: ListView.builder(
                                              itemCount: standards[index]
                                                  .elements
                                                  .length,
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, i) {
                                                return Card(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          standards[index]
                                                              .elements[i]
                                                              .elementName,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(standards[index]
                                                            .elements[i]
                                                            .name),
                                                        standards[index]
                                                                    .elements[i]
                                                                    .users
                                                                    .length >
                                                                0
                                                            ? Row(
                                                                children: [
                                                                  Container(
                                                                    height: 60,
                                                                    child: ListView
                                                                        .builder(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      shrinkWrap:
                                                                          true,
                                                                      itemCount: standards[index].elements[i].users.length >
                                                                              3
                                                                          ? 3
                                                                          : standards[index]
                                                                              .elements[i]
                                                                              .users
                                                                              .length,
                                                                      itemBuilder:
                                                                          (context, j) =>
                                                                              Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(2.0),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              40,
                                                                          width:
                                                                              40,
                                                                          padding:
                                                                              EdgeInsets.all(8),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(0.5)),
                                                                          child:
                                                                              Text(
                                                                            standards[index].elements[i].users[j].name[0].toUpperCase(),
                                                                            style:
                                                                                TextStyle(fontSize: 18).copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (standards[
                                                                              index]
                                                                          .elements[
                                                                              i]
                                                                          .users
                                                                          .length >
                                                                      3)
                                                                    Text((standards[index].elements[i].users.length -
                                                                                3)
                                                                            .toString() +
                                                                        " more")
                                                                ],
                                                              )
                                                            : SizedBox(
                                                                height: 10,
                                                              ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            GestureDetector(
                                                              child: Icon(
                                                                  AntDesign
                                                                      .antdesign),
                                                              onTap: () async {
                                                                QipAPIHandler
                                                                    qipAPIHandler =
                                                                    QipAPIHandler(
                                                                        {});
                                                                var data = await qipAPIHandler
                                                                    .getQipObsLinks(
                                                                        widget
                                                                            .centerid,
                                                                        widget
                                                                            .qipid);

                                                                var obsLinks = data[
                                                                    'observations'];

                                                                List<ObservationModel>
                                                                    _allObservations;
                                                                _allObservations =
                                                                    [];
                                                                try {
                                                                  assert(obsLinks
                                                                      is List);
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          obsLinks
                                                                              .length;
                                                                      i++) {
                                                                    _allObservations.add(
                                                                        ObservationModel.fromJson(
                                                                            obsLinks[i]));
                                                                  }
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                } catch (e) {
                                                                  print(e);
                                                                }
                                                                if (obsLinks !=
                                                                        null &&
                                                                    _allObservations
                                                                            .length >
                                                                        0) {
                                                                  showGeneralDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    pageBuilder: (BuildContext buildContext,
                                                                        Animation<double>
                                                                            animation,
                                                                        Animation<double>
                                                                            secondaryAnimation) {
                                                                      return StatefulBuilder(builder:
                                                                          (context,
                                                                              setState) {
                                                                        Size
                                                                            size =
                                                                            MediaQuery.of(context).size;
                                                                        return Scaffold(
                                                                          appBar:
                                                                              AppBar(
                                                                            centerTitle:
                                                                                true,
                                                                            title:
                                                                                Text("Link Observation"),
                                                                          ),
                                                                          body:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Container(
                                                                              child: Column(
                                                                                children: [
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: NeverScrollableScrollPhysics(),
                                                                                      itemCount: _allObservations.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        return Padding(
                                                                                          padding: const EdgeInsets.all(3.0),
                                                                                          child: Card(
                                                                                            child: Container(
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: size.width,
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Container(
                                                                                                            width: size.width * 0.8,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                                                                                                              child: Text(
                                                                                                                _allObservations[index].title,
                                                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                              ),
                                                                                                            )),
                                                                                                        Checkbox(
                                                                                                            value: _allObservations[index].boolCheck,
                                                                                                            onChanged: (val) {
                                                                                                              _allObservations[index].boolCheck = val;
                                                                                                              setState(() {});
                                                                                                            })
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  _allObservations[index].observationsMedia == 'null' || _allObservations[index].observationsMedia == ''
                                                                                                      ? Text('')
                                                                                                      : _allObservations[index].observationsMediaType == 'Image'
                                                                                                          ? Image.network(
                                                                                                              Constants.ImageBaseUrl + _allObservations[index].observationsMedia,
                                                                                                              height: 150,
                                                                                                              width: MediaQuery.of(context).size.width,
                                                                                                              fit: BoxFit.fill,
                                                                                                            )
                                                                                                          : VideoItem(url: Constants.ImageBaseUrl + _allObservations[index].observationsMedia),
                                                                                                  // _allObservations[index].observationChildrens.length > 0
                                                                                                  //     ? Row(
                                                                                                  //         children: [
                                                                                                  //           Container(
                                                                                                  //             height: 60,
                                                                                                  //             child: ListView.builder(
                                                                                                  //               scrollDirection: Axis.horizontal,
                                                                                                  //               shrinkWrap: true,
                                                                                                  //               itemCount: _allObservations[index].observationChildrens.length > 3 ? 3 : _allObservations[index].observationChildrens.length,
                                                                                                  //               itemBuilder: (context, j) => Padding(
                                                                                                  //                 padding: const EdgeInsets.all(2.0),
                                                                                                  //                 child: Container(
                                                                                                  //                   height: 40,
                                                                                                  //                   width: 40,
                                                                                                  //                   padding: EdgeInsets.all(8),
                                                                                                  //                   alignment: Alignment.center,
                                                                                                  //                   decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(0.5)),
                                                                                                  //                   child: Text(
                                                                                                  //                     _allObservations[index].observationChildrens[j]['name'][0],
                                                                                                  //                     style: TextStyle(fontSize: 18).copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                                                                                                  //                   ),
                                                                                                  //                 ),
                                                                                                  //               ),
                                                                                                  //             ),
                                                                                                  //           ),
                                                                                                  //           if (_allObservations[index].observationChildrens.length > 3) Text((_allObservations[index].observationChildrens.length - 3).toString() + " more")
                                                                                                  //         ],
                                                                                                  //       )
                                                                                                  //     : SizedBox(
                                                                                                  //         height: 10,
                                                                                                  //       ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.all(8),
                                                                                                    child: Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                      children: [
                                                                                                        Row(
                                                                                                          children: [
                                                                                                            Text(
                                                                                                              'Author: ',
                                                                                                              style: TextStyle(fontWeight: FontWeight.w600),
                                                                                                            ),
                                                                                                            Text(_allObservations[index].userName)
                                                                                                          ],
                                                                                                        ),
                                                                                                        Row(
                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                          children: [
                                                                                                            Text(
                                                                                                              'Date: ',
                                                                                                              style: TextStyle(fontWeight: FontWeight.w600),
                                                                                                            ),
                                                                                                            Text(_allObservations[index].dateAdded)
                                                                                                          ],
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      }),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        ElevatedButton(
                                                                                            onPressed: () async {
                                                                                              var linkids = [];
                                                                                              for (int i = 0; i < _allObservations.length; i++) {
                                                                                                if (_allObservations[i].boolCheck) {
                                                                                                  linkids.add(_allObservations[i].id);
                                                                                                }
                                                                                              }

                                                                                              var _toSend = 'https://stage.todquest.com/mykronicle101/api/Qip/saveQipLinks/';

                                                                                              var _objToSend = {
                                                                                                "linktype": "OBSERVATION",
                                                                                                "linkids": linkids,
                                                                                                "qipid": widget.qipid,
                                                                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                                                                 "elementid":standards[index].elements[i].id,     
                                                                                              };
                                                                                              print(jsonEncode(_objToSend));
                                                                                              final response = await http.post(_toSend, body: jsonEncode(_objToSend), headers: {
                                                                                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                                              });
                                                                                              print(response.body);
                                                                                              if (response.statusCode == 200) {
                                                                                                MyApp.ShowToast("updated", context);
                                                                                                print('created');
                                                                                                Navigator.pop(context);
                                                                                              } else if (response.statusCode == 401) {
                                                                                                MyApp.Show401Dialog(context);
                                                                                              }
                                                                                            },
                                                                                            child: Text('Save'))
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            GestureDetector(
                                                              child: Icon(
                                                                  AntDesign
                                                                      .retweet),
                                                              onTap: () async {
                                                                QipAPIHandler
                                                                    qipAPIHandler =
                                                                    QipAPIHandler(
                                                                        {});
                                                                var data = await qipAPIHandler
                                                                    .getQipRefLinks(
                                                                        widget
                                                                            .centerid,
                                                                        widget
                                                                            .qipid);

                                                                var refLinks = data[
                                                                    'reflections'];

                                                                List<ReflectionModel>
                                                                    _allReflections;
                                                                _allReflections =
                                                                    [];
                                                                try {
                                                                  assert(refLinks
                                                                      is List);
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          refLinks
                                                                              .length;
                                                                      i++) {
                                                                    _allReflections.add(
                                                                        ReflectionModel.fromJson(
                                                                            refLinks[i]));
                                                                  }
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                } catch (e) {
                                                                  print(e);
                                                                }
                                                                if (refLinks !=
                                                                        null &&
                                                                    _allReflections
                                                                            .length >
                                                                        0) {
                                                                  showGeneralDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    pageBuilder: (BuildContext buildContext,
                                                                        Animation<double>
                                                                            animation,
                                                                        Animation<double>
                                                                            secondaryAnimation) {
                                                                      return StatefulBuilder(builder:
                                                                          (context,
                                                                              setState) {
                                                                        Size
                                                                            size =
                                                                            MediaQuery.of(context).size;
                                                                        return Scaffold(
                                                                          appBar:
                                                                              AppBar(
                                                                            centerTitle:
                                                                                true,
                                                                            title:
                                                                                Text("Link Reflection"),
                                                                          ),
                                                                          body:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Container(
                                                                              child: Column(
                                                                                children: [
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: NeverScrollableScrollPhysics(),
                                                                                      itemCount: _allReflections.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        return Padding(
                                                                                          padding: const EdgeInsets.all(3.0),
                                                                                          child: Card(
                                                                                            child: Container(
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: size.width,
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Container(
                                                                                                            width: size.width * 0.8,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                                              child: Text(
                                                                                                                _allReflections[index].title,
                                                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                              ),
                                                                                                            )),
                                                                                                        Checkbox(
                                                                                                            value: _allReflections[index].boolCheck,
                                                                                                            onChanged: (val) {
                                                                                                              _allReflections[index].boolCheck = val;
                                                                                                              setState(() {});
                                                                                                            })
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                                                                                    child: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      children: [
                                                                                                        Row(
                                                                                                          children: [
                                                                                                            Text(
                                                                                                              'Created By: ',
                                                                                                              style: TextStyle(fontWeight: FontWeight.w600),
                                                                                                            ),
                                                                                                            Text(_allReflections[index].createdBy)
                                                                                                          ],
                                                                                                        ),
                                                                                                        SizedBox(
                                                                                                          height: 12,
                                                                                                        ),
                                                                                                        Text(
                                                                                                          _allReflections[index].about,
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          'Status: ',
                                                                                                          style: TextStyle(fontWeight: FontWeight.w600),
                                                                                                        ),
                                                                                                        Text(_allReflections[index].status)
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      }),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        ElevatedButton(
                                                                                            onPressed: () async {
                                                                                              var linkids = [];
                                                                                              for (int i = 0; i < _allReflections.length; i++) {
                                                                                                if (_allReflections[i].boolCheck) {
                                                                                                  linkids.add(_allReflections[i].id);
                                                                                                }
                                                                                              }

                                                                                              var _toSend = 'https://stage.todquest.com/mykronicle101/api/Qip/saveQipLinks/';

                                                                                              var _objToSend = {
                                                                                                "linktype": "REFLECTION",
                                                                                                "linkids": linkids,
                                                                                                "qipid": widget.qipid,
                                                                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                                                                 "elementid":standards[index].elements[i].id,     
                                                                                              };
                                                                                              print(jsonEncode(_objToSend));
                                                                                              final response = await http.post(_toSend, body: jsonEncode(_objToSend), headers: {
                                                                                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                                              });
                                                                                              print(response.body);
                                                                                              if (response.statusCode == 200) {
                                                                                                MyApp.ShowToast("updated", context);
                                                                                                print('created');
                                                                                                Navigator.pop(context);
                                                                                              } else if (response.statusCode == 401) {
                                                                                                MyApp.Show401Dialog(context);
                                                                                              }
                                                                                            },
                                                                                            child: Text('Save'))
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            GestureDetector(
                                                              child: Icon(
                                                                  AntDesign
                                                                      .inbox),
                                                              onTap: () async {
                                                                var _objToSend =
                                                                    {
                                                                  "userid": MyApp
                                                                      .LOGIN_ID_VALUE,
                                                                  "centerid": widget
                                                                      .centerid,
                                                                  "qipid":
                                                                      widget
                                                                          .qipid,
                                                                  "elementid":standards[index]
                                                            .elements[i].id,        
                                                                };
                                                                QipAPIHandler
                                                                    qipAPIHandler =
                                                                    QipAPIHandler(
                                                                        _objToSend);
                                                                var data =
                                                                    await qipAPIHandler
                                                                        .getQipResLinks();

                                                                var resLinks = data[
                                                                    'Resources'];

                                                                List<ResourceModel>
                                                                    _allResources;
                                                                _allResources =
                                                                    [];
                                                                try {
                                                                  assert(resLinks
                                                                      is List);
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          resLinks
                                                                              .length;
                                                                      i++) {
                                                                    _allResources.add(
                                                                        ResourceModel.fromJson(
                                                                            resLinks[i]));
                                                                  }
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                } catch (e) {
                                                                  print(e);
                                                                }
                                                                if (resLinks !=
                                                                        null &&
                                                                    _allResources
                                                                            .length >
                                                                        0) {
                                                                  showGeneralDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    pageBuilder: (BuildContext buildContext,
                                                                        Animation<double>
                                                                            animation,
                                                                        Animation<double>
                                                                            secondaryAnimation) {
                                                                      return StatefulBuilder(builder:
                                                                          (context,
                                                                              setState) {
                                                                        Size
                                                                            size =
                                                                            MediaQuery.of(context).size;
                                                                        return Scaffold(
                                                                          appBar:
                                                                              AppBar(
                                                                            centerTitle:
                                                                                true,
                                                                            title:
                                                                                Text("Link Resources"),
                                                                          ),
                                                                          body:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Container(
                                                                              child: Column(
                                                                                children: [
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: NeverScrollableScrollPhysics(),
                                                                                      itemCount: _allResources.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        return Padding(
                                                                                          padding: const EdgeInsets.all(3.0),
                                                                                          child: Card(
                                                                                            child: Container(
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: size.width,
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Container(
                                                                                                            width: size.width * 0.8,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                                              child: Text(
                                                                                                                _allResources[index].title,
                                                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                              ),
                                                                                                            )),
                                                                                                        Checkbox(
                                                                                                            value: _allResources[index].boolCheck,
                                                                                                            onChanged: (val) {
                                                                                                              _allResources[index].boolCheck = val;
                                                                                                              setState(() {});
                                                                                                            })
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                                                                                    child: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      children: [
                                                                                                        Row(
                                                                                                          children: [
                                                                                                            Text(
                                                                                                              'Created By: ',
                                                                                                              style: TextStyle(fontWeight: FontWeight.w600),
                                                                                                            ),
                                                                                                            Text(_allResources[index].createdBy)
                                                                                                          ],
                                                                                                        ),
                                                                                                        SizedBox(
                                                                                                          height: 12,
                                                                                                        ),
                                                                                                        // Text(
                                                                                                        //   _allResources[index].description,
                                                                                                        // ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      }),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        ElevatedButton(
                                                                                            onPressed: () async {
                                                                                              var linkids = [];
                                                                                              for (int i = 0; i < _allResources.length; i++) {
                                                                                                if (_allResources[i].boolCheck) {
                                                                                                  linkids.add(_allResources[i].id);
                                                                                                }
                                                                                              }

                                                                                              var _toSend = 'https://stage.todquest.com/mykronicle101/api/Qip/saveQipLinks/';

                                                                                              var _objToSend = {
                                                                                                "linktype": "RESOURCES",
                                                                                                "linkids": linkids,
                                                                                                "qipid": widget.qipid,
                                                                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                                                                 "elementid":standards[index].elements[i].id,     
                                                                                              };
                                                                                              print(jsonEncode(_objToSend));
                                                                                              final response = await http.post(_toSend, body: jsonEncode(_objToSend), headers: {
                                                                                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                                              });
                                                                                              print(response.body);
                                                                                              if (response.statusCode == 200) {
                                                                                                MyApp.ShowToast("updated", context);
                                                                                                print('created');
                                                                                                Navigator.pop(context);
                                                                                              } else if (response.statusCode == 401) {
                                                                                                MyApp.Show401Dialog(context);
                                                                                              }
                                                                                            },
                                                                                            child: Text('Save'))
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            GestureDetector(
                                                              child: Icon(
                                                                  MaterialCommunityIcons
                                                                      .map_search_outline),
                                                              onTap: () async {
                                                                var _objToSend =
                                                                    {
                                                                  "userid": MyApp
                                                                      .LOGIN_ID_VALUE,
                                                                  "centerid": widget
                                                                      .centerid,
                                                                  "qipid":
                                                                      widget
                                                                          .qipid,
                                                                   "elementid":standards[index]
                                                            .elements[i].id,            
                                                                };
                                                                QipAPIHandler
                                                                    qipAPIHandler =
                                                                    QipAPIHandler(
                                                                        _objToSend);
                                                                var data =
                                                                    await qipAPIHandler
                                                                        .getQipSurveyLinks();

                                                                var surveyLinks =
                                                                    data[
                                                                        'Surveys'];

                                                                List<SurveyModel>
                                                                    _allSurveys;
                                                                _allSurveys =
                                                                    [];
                                                                try {
                                                                  assert(surveyLinks
                                                                      is List);
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          surveyLinks
                                                                              .length;
                                                                      i++) {
                                                                    _allSurveys.add(
                                                                        SurveyModel.fromJson(
                                                                            surveyLinks[i]));
                                                                  }
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                } catch (e) {
                                                                  print(e);
                                                                }
                                                                if (surveyLinks !=
                                                                        null &&
                                                                    _allSurveys
                                                                            .length >
                                                                        0) {
                                                                  showGeneralDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    pageBuilder: (BuildContext buildContext,
                                                                        Animation<double>
                                                                            animation,
                                                                        Animation<double>
                                                                            secondaryAnimation) {
                                                                      return StatefulBuilder(builder:
                                                                          (context,
                                                                              setState) {
                                                                        Size
                                                                            size =
                                                                            MediaQuery.of(context).size;
                                                                        return Scaffold(
                                                                          appBar:
                                                                              AppBar(
                                                                            centerTitle:
                                                                                true,
                                                                            title:
                                                                                Text("Link Survey"),
                                                                          ),
                                                                          body:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Container(
                                                                              child: Column(
                                                                                children: [
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: NeverScrollableScrollPhysics(),
                                                                                      itemCount: _allSurveys.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        return Padding(
                                                                                          padding: const EdgeInsets.all(3.0),
                                                                                          child: Card(
                                                                                            child: Container(
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: size.width,
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Container(
                                                                                                            width: size.width * 0.8,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                                              child: Text(
                                                                                                                _allSurveys[index].title,
                                                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                              ),
                                                                                                            )),
                                                                                                        Checkbox(
                                                                                                            value: _allSurveys[index].boolCheck,
                                                                                                            onChanged: (val) {
                                                                                                              _allSurveys[index].boolCheck = val;
                                                                                                              setState(() {});
                                                                                                            })
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                                                                                    child: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      children: [
                                                                                                        Row(
                                                                                                          children: [
                                                                                                            Text(
                                                                                                              'Created By: ',
                                                                                                              style: TextStyle(fontWeight: FontWeight.w600),
                                                                                                            ),
                                                                                                            Text(_allSurveys[index].createdBy)
                                                                                                          ],
                                                                                                        ),
                                                                                                        SizedBox(
                                                                                                          height: 12,
                                                                                                        ),
                                                                                                        Text(
                                                                                                          _allSurveys[index].description,
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      }),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        ElevatedButton(
                                                                                            onPressed: () async {
                                                                                              var linkids = [];
                                                                                              for (int i = 0; i < _allSurveys.length; i++) {
                                                                                                if (_allSurveys[i].boolCheck) {
                                                                                                  linkids.add(_allSurveys[i].id);
                                                                                                }
                                                                                              }

                                                                                              var _toSend = 'https://stage.todquest.com/mykronicle101/api/Qip/saveQipLinks/';

                                                                                              var _objToSend = {
                                                                                                "linktype": "SURVEY",
                                                                                                "linkids": linkids,
                                                                                                "qipid": widget.qipid,
                                                                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                                                                 "elementid":standards[index].elements[i].id,     
                                                                                              };
                                                                                              print(jsonEncode(_objToSend));
                                                                                              final response = await http.post(_toSend, body: jsonEncode(_objToSend), headers: {
                                                                                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                                              });
                                                                                              print(response.body);
                                                                                              if (response.statusCode == 200) {
                                                                                                MyApp.ShowToast("updated", context);
                                                                                                print('created');
                                                                                                Navigator.pop(context);
                                                                                              } else if (response.statusCode == 401) {
                                                                                                MyApp.Show401Dialog(context);
                                                                                              }
                                                                                            },
                                                                                            child: Text('Save'))
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            GestureDetector(
                                                              child: Icon(
                                                                  MaterialIcons
                                                                      .graphic_eq),
                                                              onTap: () async {
                                                                var _objToSend =
                                                                    {
                                                                  "userid": MyApp
                                                                      .LOGIN_ID_VALUE,
                                                                  "centerid": widget
                                                                      .centerid,
                                                                  "qipid":
                                                                      widget
                                                                          .qipid,
                                                                   "elementid":standards[index]
                                                            .elements[i].id,            
                                                                };
                                                                QipAPIHandler
                                                                    qipAPIHandler =
                                                                    QipAPIHandler(
                                                                        _objToSend);
                                                                var data =
                                                                    await qipAPIHandler
                                                                        .getQipPlan();

                                                                var plans = data[
                                                                    'ProgramPlans'];

                                                                List<PlanStandModel>
                                                                    _allPlans;
                                                                _allPlans = [];
                                                                try {
                                                                  assert(plans
                                                                      is List);
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          plans
                                                                              .length;
                                                                      i++) {
                                                                    _allPlans.add(
                                                                        PlanStandModel.fromJson(
                                                                            plans[i]));
                                                                  }
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                } catch (e) {
                                                                  print(e);
                                                                }
                                                                if (plans !=
                                                                        null &&
                                                                    plans.length >
                                                                        0) {
                                                                  showGeneralDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    pageBuilder: (BuildContext buildContext,
                                                                        Animation<double>
                                                                            animation,
                                                                        Animation<double>
                                                                            secondaryAnimation) {
                                                                      return StatefulBuilder(builder:
                                                                          (context,
                                                                              setState) {
                                                                        Size
                                                                            size =
                                                                            MediaQuery.of(context).size;
                                                                        return Scaffold(
                                                                          appBar:
                                                                              AppBar(
                                                                            centerTitle:
                                                                                true,
                                                                            title:
                                                                                Text("Link Program Plan"),
                                                                          ),
                                                                          body:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Container(
                                                                              child: Column(
                                                                                children: [
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: NeverScrollableScrollPhysics(),
                                                                                      itemCount: _allPlans.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        return Padding(
                                                                                          padding: const EdgeInsets.all(3.0),
                                                                                          child: Card(
                                                                                            child: Container(
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: size.width,
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Column(
                                                                                                          children: [
                                                                                                            Container(
                                                                                                                width: size.width * 0.8,
                                                                                                                child: Padding(
                                                                                                                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                                                  child: Text(
                                                                                                                    '${_allPlans[index].startDate}/${_allPlans[index].endDate}',
                                                                                                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                                                                                                  ),
                                                                                                                )),
                                                                                                            Container(
                                                                                                                width: size.width * 0.8,
                                                                                                                child: Padding(
                                                                                                                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                                                  child: Text(
                                                                                                                    _allPlans[index].roomid,
                                                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                                  ),
                                                                                                                )),
                                                                                                          ],
                                                                                                        ),
                                                                                                        Checkbox(
                                                                                                            value: _allPlans[index].boolCheck,
                                                                                                            onChanged: (val) {
                                                                                                              _allPlans[index].boolCheck = val;
                                                                                                              setState(() {});
                                                                                                            })
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          'Created By: ',
                                                                                                          style: TextStyle(fontWeight: FontWeight.w600),
                                                                                                        ),
                                                                                                        Text(_allPlans[index].createdBy)
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      }),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        ElevatedButton(
                                                                                            onPressed: () async {
                                                                                              var linkids = [];
                                                                                              for (int i = 0; i < _allPlans.length; i++) {
                                                                                                if (_allPlans[i].boolCheck) {
                                                                                                  linkids.add(_allPlans[i].id);
                                                                                                }
                                                                                              }

                                                                                              var _toSend = 'https://stage.todquest.com/mykronicle101/api/Qip/saveQipLinks/';

                                                                                              var _objToSend = {
                                                                                                "linktype": "PROGRAMPLAN",
                                                                                                "linkids": linkids,
                                                                                                "qipid": widget.qipid,
                                                                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                                                                 "elementid":standards[index].elements[i].id,     
                                                                                              };
                                                                                              print(jsonEncode(_objToSend));
                                                                                              final response = await http.post(_toSend, body: jsonEncode(_objToSend), headers: {
                                                                                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                                              });
                                                                                              print(response.body);
                                                                                              if (response.statusCode == 200) {
                                                                                                MyApp.ShowToast("updated", context);
                                                                                                print('created');
                                                                                                Navigator.pop(context);
                                                                                              } else if (response.statusCode == 401) {
                                                                                                MyApp.Show401Dialog(context);
                                                                                              }
                                                                                            },
                                                                                            child: Text('Save'))
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            GestureDetector(
                                                              child: Icon(
                                                                  Octicons
                                                                      .graph),
                                                              onTap: () async {
                                                                var _objToSend =
                                                                    {
                                                                  "userid": MyApp
                                                                      .LOGIN_ID_VALUE,
                                                                  "centerid": widget
                                                                      .centerid,
                                                                  "qipid":
                                                                      widget
                                                                          .qipid,
                                                                   "elementid":standards[index]
                                                            .elements[i].id,            
                                                                };
                                                                QipAPIHandler
                                                                    qipAPIHandler =
                                                                    QipAPIHandler(
                                                                        _objToSend);
                                                                var dataMont =
                                                                    await qipAPIHandler
                                                                        .getQipMont();
                                                                var dataMileStone =
                                                                    await qipAPIHandler
                                                                        .getQipDev();
                                                                var dataEylf =
                                                                    await qipAPIHandler
                                                                        .getQipEylf();

                                                                var monts =
                                                                    dataMont[
                                                                        'Records'];

                                                                List<MontessoriActivityModel>
                                                                    _allMonts;
                                                                _allMonts = [];
                                                                try {
                                                                  assert(monts
                                                                      is List);
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          monts
                                                                              .length;
                                                                      i++) {
                                                                    _allMonts.add(
                                                                        MontessoriActivityModel.fromJson(
                                                                            monts[i]));
                                                                  }
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                } catch (e) {
                                                                  print(e);
                                                                }

                                                                var milestones =
                                                                    dataMileStone[
                                                                        'Records'];

                                                                List<SubjectModel>
                                                                    _allMilestones;
                                                                _allMilestones =
                                                                    [];
                                                                try {
                                                                  assert(milestones
                                                                      is List);
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          milestones
                                                                              .length;
                                                                      i++) {
                                                                    _allMilestones.add(
                                                                        SubjectModel.fromJson(
                                                                            milestones[i]));
                                                                  }
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                } catch (e) {
                                                                  print(e);
                                                                }

                                                                var eylf =
                                                                    dataEylf[
                                                                        'Records'];

                                                                List<EylfActivityModel>
                                                                    _allEylf;
                                                                _allEylf = [];
                                                                try {
                                                                  assert(eylf
                                                                      is List);
                                                                  for (int i =
                                                                          0;
                                                                      i < eylf.length;
                                                                      i++) {
                                                                    _allEylf.add(
                                                                        EylfActivityModel.fromJson(
                                                                            eylf[i]));
                                                                  }
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                } catch (e) {
                                                                  print(e);
                                                                }
                                                                int pg = 0;
                                                                showGeneralDialog(
                                                                  barrierDismissible:
                                                                      false,
                                                                  context:
                                                                      context,
                                                                  pageBuilder: (BuildContext buildContext,
                                                                      Animation<
                                                                              double>
                                                                          animation,
                                                                      Animation<
                                                                              double>
                                                                          secondaryAnimation) {
                                                                    return StatefulBuilder(builder:
                                                                        (context,
                                                                            setState) {
                                                                      Size
                                                                          size =
                                                                          MediaQuery.of(context)
                                                                              .size;
                                                                      return Scaffold(
                                                                        appBar:
                                                                            AppBar(
                                                                          centerTitle:
                                                                              true,
                                                                          title:
                                                                              Text("Link Assesment"),
                                                                        ),
                                                                        body:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                  children: [
                                                                                    ElevatedButton(
                                                                                        onPressed: () {
                                                                                          pg = 0;
                                                                                          setState(() {});
                                                                                        },
                                                                                        child: Text('Montessori')),
                                                                                    ElevatedButton(
                                                                                        onPressed: () {
                                                                                          pg = 1;
                                                                                          setState(() {});
                                                                                        },
                                                                                        child: Text('Dev Milestone')),
                                                                                    ElevatedButton(
                                                                                        onPressed: () {
                                                                                          pg = 2;
                                                                                          setState(() {});
                                                                                        },
                                                                                        child: Text('Eylf')),
                                                                                  ],
                                                                                ),
                                                                                if (pg == 0)
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: NeverScrollableScrollPhysics(),
                                                                                      itemCount: _allMonts.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        return Padding(
                                                                                          padding: const EdgeInsets.all(3.0),
                                                                                          child: Card(
                                                                                            child: Container(
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: size.width,
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Container(
                                                                                                            width: size.width * 0.8,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                                              child: Text(
                                                                                                                _allMonts[index].title,
                                                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                              ),
                                                                                                            )),
                                                                                                        Checkbox(
                                                                                                            value: _allMonts[index].boolCheck,
                                                                                                            onChanged: (val) {
                                                                                                              _allMonts[index].boolCheck = val;
                                                                                                              setState(() {});
                                                                                                            })
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    width: size.width * 0.9,
                                                                                                    child: Text(
                                                                                                      _allMonts[index].subject,
                                                                                                    ),
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: 12,
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      })
                                                                                else if (pg == 1)
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: NeverScrollableScrollPhysics(),
                                                                                      itemCount: _allMilestones.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        return Padding(
                                                                                          padding: const EdgeInsets.all(3.0),
                                                                                          child: Card(
                                                                                            child: Container(
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: size.width,
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Container(
                                                                                                            width: size.width * 0.8,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                                              child: Text(
                                                                                                                _allMilestones[index].name,
                                                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                              ),
                                                                                                            )),
                                                                                                        Checkbox(
                                                                                                            value: _allMilestones[index].boolCheck,
                                                                                                            onChanged: (val) {
                                                                                                              _allMilestones[index].boolCheck = val;
                                                                                                              setState(() {});
                                                                                                            })
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    width: size.width * 0.9,
                                                                                                    child: Text(
                                                                                                      _allMilestones[index].subject,
                                                                                                    ),
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: 12,
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      })
                                                                                else
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: NeverScrollableScrollPhysics(),
                                                                                      itemCount: _allEylf.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        return Padding(
                                                                                          padding: const EdgeInsets.all(3.0),
                                                                                          child: Card(
                                                                                            child: Container(
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: size.width,
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Container(
                                                                                                            width: size.width * 0.8,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                                              child: Text(
                                                                                                                _allEylf[index].title,
                                                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                              ),
                                                                                                            )),
                                                                                                        Checkbox(
                                                                                                            value: _allEylf[index].boolCheck,
                                                                                                            onChanged: (val) {
                                                                                                              _allEylf[index].boolCheck = val;
                                                                                                              setState(() {});
                                                                                                            })
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: 12,
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      }),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      ElevatedButton(
                                                                                          onPressed: () async {
                                                                                            if (pg == 0) {
                                                                                              var linkids = [];
                                                                                              for (int i = 0; i < _allMonts.length; i++) {
                                                                                                if (_allMonts[i].boolCheck) {
                                                                                                  linkids.add(_allMonts[i].idActivity);
                                                                                                }
                                                                                              }

                                                                                              var _toSend = 'https://stage.todquest.com/mykronicle101/api/Qip/saveQipLinks/';

                                                                                              var _objToSend = {
                                                                                                "linktype": "MONTESSORI",
                                                                                                "linkids": linkids,
                                                                                                "qipid": widget.qipid,
                                                                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                                                                 "elementid":standards[index].elements[i].id,     
                                                                                              };
                                                                                              print(jsonEncode(_objToSend));
                                                                                              final response = await http.post(_toSend, body: jsonEncode(_objToSend), headers: {
                                                                                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                                              });
                                                                                              print(response.body);
                                                                                              if (response.statusCode == 200) {
                                                                                                MyApp.ShowToast("updated", context);
                                                                                                print('created');
                                                                                                Navigator.pop(context);
                                                                                              } else if (response.statusCode == 401) {
                                                                                                MyApp.Show401Dialog(context);
                                                                                              }
                                                                                            } else if (pg == 1) {
                                                                                              var linkids = [];
                                                                                              for (int i = 0; i < _allMilestones.length; i++) {
                                                                                                if (_allMilestones[i].boolCheck) {
                                                                                                  linkids.add(_allMilestones[i].id);
                                                                                                }
                                                                                              }

                                                                                              var _toSend = 'https://stage.todquest.com/mykronicle101/api/Qip/saveQipLinks/';

                                                                                              var _objToSend = {
                                                                                                "linktype": "MILESTONE",
                                                                                                "linkids": linkids,
                                                                                                "qipid": widget.qipid,
                                                                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                                                                 "elementid":standards[index].elements[i].id,     
                                                                                              };
                                                                                              print(jsonEncode(_objToSend));
                                                                                              final response = await http.post(_toSend, body: jsonEncode(_objToSend), headers: {
                                                                                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                                              });
                                                                                              print(response.body);
                                                                                              if (response.statusCode == 200) {
                                                                                                MyApp.ShowToast("updated", context);
                                                                                                print('created');
                                                                                                Navigator.pop(context);
                                                                                              } else if (response.statusCode == 401) {
                                                                                                MyApp.Show401Dialog(context);
                                                                                              }
                                                                                            } else {
                                                                                              var linkids = [];
                                                                                              for (int i = 0; i < _allEylf.length; i++) {
                                                                                                if (_allEylf[i].boolCheck) {
                                                                                                  linkids.add(_allEylf[i].id);
                                                                                                }
                                                                                              }

                                                                                              var _toSend = 'https://stage.todquest.com/mykronicle101/api/Qip/saveQipLinks/';

                                                                                              var _objToSend = {
                                                                                                "linktype": "EYLF",
                                                                                                "linkids": linkids,
                                                                                                "qipid": widget.qipid,
                                                                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                                                                 "elementid":standards[index].elements[i].id,     
                                                                                              };
                                                                                              print(jsonEncode(_objToSend));
                                                                                              final response = await http.post(_toSend, body: jsonEncode(_objToSend), headers: {
                                                                                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                                              });
                                                                                              print(response.body);
                                                                                              if (response.statusCode == 200) {
                                                                                                MyApp.ShowToast("updated", context);
                                                                                                print('created');
                                                                                                Navigator.pop(context);
                                                                                              } else if (response.statusCode == 401) {
                                                                                                MyApp.Show401Dialog(context);
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                          child: Text('Save'))
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            GestureDetector(
                                                              child: Icon(
                                                                  AntDesign
                                                                      .right),
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            ViewElement(
                                                                              qipId: widget.qipid,
                                                                              areas: widget.areas,
                                                                              standards: standards,
                                                                              areaIndex: currentIndex,
                                                                              standardIndex: index,
                                                                              elementIndex: i,
                                                                            )));
                                                              },
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        )
                                    ],
                                  );
                                }),
                          )
                      ],
                    ),
                  )
          ]),
        ),
      )),
    );
  }
}
