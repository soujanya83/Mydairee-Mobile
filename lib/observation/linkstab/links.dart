import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/getUserReflections.dart';
import 'package:mykronicle_mobile/models/observationmodel.dart';
import 'package:mykronicle_mobile/models/progplanmodel.dart';
import 'package:mykronicle_mobile/models/qiplistmodel.dart';
import 'package:mykronicle_mobile/models/reflectionmodel.dart';
import 'package:mykronicle_mobile/observation/addobservation.dart';
import 'package:mykronicle_mobile/observation/obsdata.dart';
import 'package:mykronicle_mobile/observation/viewobservation.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/removeTags.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Links extends StatefulWidget {
  @override
  _LinksState createState() => _LinksState();
}

class _LinksState extends State<Links> {
  bool childrensFetched = false;
  int loaded = 0;
  bool observationsFetched = false;
  bool qipsFetched = false;
  bool reflectionsFetched = false;
  bool plansFetched = false;

  List<ObservationModel> _allObservations = [];
  List<ReflectionModel> _allReflections = [];
  List<QipListModel> _allQips = [];
  List<ProgPlanModel> _allPlans = [];

  int choose = 0;
  List<bool> _added = [];
  List<bool> _addedRef = [];
  List<bool> _addedQips = [];
  List<bool> _addedPlans = [];
  bool load = false;

  // Future<void> _fetchReflectionsData() async {

  //   ObservationsAPIHandler handler =ObservationsAPIHandler({
  //     "userid":MyApp.LOGIN_ID_VALUE
  //   });
  //   var data=await handler.getLinksReflectionsList();

  //   var res = data['reflections'];
  //   if(!data.containsKey('error')){

  //       print(data);
  //     _allReflections = [];
  //     _added = [];
  //     try {
  //       assert(res is List);
  //       for (int i = 0; i < res.length; i++) {
  //         _allReflections.add(ReflectionModel.fromJson(res[i]));
  //         _added.add(false);
  //       }
  //       reflectionsFetched = true;
  //       load=false;
  //       if(this.mounted) setState(() {});
  //     }
  //     catch (e) {
  //       print(e);
  //     }

  //   }else{
  //       MyApp.Show401Dialog(context);
  //   }

  // }

  // Future<void> _fetchData() async {

  //   ObservationsAPIHandler handler =ObservationsAPIHandler({});
  //   var data=await handler.getLinksObservationList();
  //   var res = data['observations'];
  //   if(!data.containsKey('error')){

  //       print(data);
  //     _allObservations = [];
  //     _added=[];
  //     try {
  //       assert(res is List);
  //       for (int i = 0; i < res.length; i++) {
  //         _allObservations.add(ObservationModel.fromJson(res[i]));
  //         _added.add(false);
  //       }
  //       observationsFetched = true;
  //       load=false;
  //       if(this.mounted) setState(() {});
  //     }
  //     catch (e) {
  //       print(e);
  //     }

  //   }else{
  //       MyApp.Show401Dialog(context);
  //   }

  // }

  initializeEditObservations() {
    linksData = ViewObservationState.displaydata1['linkedData'];
    print(ViewObservationState.displaydata1['linkedData'].toString());
    for (int i = 0; i < _allObservations.length; i++) {
      try {
        for (int linksIndex = 0; linksIndex < linksData.length; linksIndex++) {
          print('Checking link at index $linksIndex: ${linksData[linksIndex]}');

          final linkType =
              linksData[linksIndex]['type']?.toString()?.toLowerCase();
          final linkId = linksData[linksIndex]['data']?['id'];

          print('Link type: $linkType, Link ID: $linkId');

          if (linkType.toString().toLowerCase() == 'observation') {
            if (_allObservations[i].id == linkId) {
              print(
                  'Match found for observation ID: ${_allObservations[i].id}');
              _added[i] = true;
              break;
            }
          }
        }
      } catch (e) {
        print('Error while linking observation at index : $e');
      }
    }
  }

  initializeEditReflection(){
    linksData = ViewObservationState.displaydata1['linkedData'];
    // print(ViewObservationState.displaydata1['linkedData'].toString());
    for (int i = 0; i < _allReflections.length; i++) {
      try {
        for (int linksIndex = 0; linksIndex < linksData.length; linksIndex++) {
          // print('Checking link at index $linksIndex:');

          final linkType =
              linksData[linksIndex]['type']?.toString().toLowerCase();
          final linkId = linksData[linksIndex]['data']?['id'];

          // print('Link type: $linkType, Link ID: $linkId');

          print('${_allReflections[i].id} == $linkId  $linkType');
          if (linkType.toString().toLowerCase() == 'REFLECTION'.toLowerCase()) {
            if (_allReflections[i].id == linkId) {
              print('Match found for REFLECTION ID: ${_allReflections[i].id}');
              _addedRef[i] = true;
              break;
            }
          }
        }
      } catch (e) {
        print('Error while linking observation at index : $e');
      }
    }
  }

  //  initializeEditQip() {
  //   linksData = ViewObservationState.displaydata1['linkedData'];
  //   print(ViewObservationState.displaydata1['linkedData'].toString());
  //   for (int i = 0; i < _allQips.length; i++) {
  //     try {
  //       for (int linksIndex = 0; linksIndex < linksData.length; linksIndex++) {
  //         print('Checking link at index $linksIndex: ${linksData[linksIndex]}');

  //         final linkType =
  //             linksData[linksIndex]['type']?.toString().toLowerCase();
  //         final linkId = linksData[linksIndex]['data']?['id'];

  //         print('Link type: $linkType, Link ID: $linkId');

  //         if (linkType == 'REFLECTION') {
  //           if (_allQips[i] == linkId) {
  //             print('Match found for OIP ID: ${_allQips[i].id}');
  //             _addedQips[i] = true;
  //             break;
  //           }
  //         }
  //       }
  //     } catch(e){
  //       print('Error while linking observation at index : $e');
  //     }
  //   }
  // }

  // initializeEditProgramPlan(){
  //   linksData = ViewObservationState.displaydata1['linkedData'];
  //   print(ViewObservationState.displaydata1['linkedData'].toString());
  //   for (int i = 0; i < _allPlans.length; i++){
  //     try {
  //       for (int linksIndex = 0; linksIndex < linksData.length; linksIndex++) {
  //         print('Checking link at index $linksIndex: ${linksData[linksIndex]}');

  //         final linkType = linksData[linksIndex]['type']?.toString().toLowerCase();
  //         final linkId = linksData[linksIndex]['data']?['id'];

  //         print('Link type: $linkType, Link ID: $linkId');

  //         if (linkType == 'REFLECTION') {
  //           if (_allQips[i] == linkId) {
  //             print('Match found for OIP ID: ${_allQips[i].id}');
  //             _addedQips[i] = true;
  //             break;
  //           }
  //         }
  //       }
  //     } catch(e){
  //       print('Error while linking observation at index : $e');
  //     }
  //   }
  // }

  var linksData;
  Future<void> _fetchData(String id, var di) async {
    try {
      linksData = ViewObservationState.displaydata['linkedData'];
    } catch (e) {
      print(e);
    }
    ObservationsAPIHandler handler = ObservationsAPIHandler({
      "id": id,
    });

    var data = await handler.getLinksList();
    if (!data.containsKey('error')) {
      var res = data['observations'];

      _allObservations = [];
      _added = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          _allObservations.add(ObservationModel.fromJson(res[i]));
          _added.add(false);
          try {
            for (int linksIndex = 0;
                linksIndex < linksData.length;
                linksIndex++) {
              if (linksData[linksIndex]['type'].toString().toLowerCase() ==
                  'OBSERVATION'.toLowerCase()) {
                if (_allObservations[i].id ==
                    linksData[linksIndex]['data']['id']) {
                  _added[i] = true;
                  break;
                }
              }
            }
          } catch (e) {
            _added[i] = false;
          }
        }
        observationsFetched = true;
        load = false;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
      initializeEditObservations();
      var result = data['reflections'];
      _allReflections = [];
      _addedRef = [];
      try {
        assert(result is List);
        for (int i = 0; i < result.length; i++) {
          _allReflections.add(ReflectionModel.fromJson(result[i]));
          _addedRef.add(false);
        }
        reflectionsFetched = true;
        load = false;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
      initializeEditReflection();
    } else {
      MyApp.Show401Dialog(context);
    }

    ObservationsAPIHandler handler2 = ObservationsAPIHandler({});
    var data2 = await handler2.getPublishedQip(AddObservationState.centerid);
    print('heyuu' + data2.toString());
    if (!data2.containsKey('error')) {
      var res2 = data2['qip'];

      _allQips = [];
      _addedQips = [];
      try {
        assert(res2 is List);
        for (int i = 0; i < res2.length; i++) {
          _allQips.add(QipListModel.fromJson(res2[i]));
          _addedQips.add(false);
        }
        qipsFetched = true;
        load = false;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    var data3 =
        await handler2.getPublishedProgPlan(AddObservationState.centerid);
    print('heyuu' + data3.toString());
    if (!data3.containsKey('error')) {
      var res3 = data3['ProgramPlan'];
      print(res3);

      _allPlans = [];
      _addedPlans = [];
      try {
        assert(res3 is List);
        for (int i = 0; i < res3.length; i++) {
          _allPlans.add(ProgPlanModel.fromJson(res3[i]));
          _addedPlans.add(false);
        }
        plansFetched = true;
        load = false;

        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    if (di != null) {
      choose = 1;
      setState(() {});
      print(di['observationLinks']);
      //qipLinks
      //programplanLinks

      print('heyey');
      int k = 0;
      if (di['observationLinks'] != null && di['observationLinks'].length > 0) {
        for (int i = 0; i < _allObservations.length; i++) {
          for (int j = 0; j < di['observationLinks'].length; j++) {
            if (di['observationLinks'][j]['id'].toString() ==
                _allObservations[i].id) {
              _added[i] = true;
              k = k + 1;
              if (k == di['observationLinks'].length) {
                break;
              }
            }
          }
        }
      }
      int l = 0;
      if (di['reflectionLinks'] != null && di['reflectionLinks'].length > 0) {
        for (int i = 0; i < _allReflections.length; i++) {
          for (int j = 0; j < di['reflectionLinks'].length; j++) {
            if (di['reflectionLinks'][j]['id'].toString() ==
                _allReflections[i].id) {
              _addedRef[i] = true;
              l = l + 1;
              if (l == di['reflectionLinks'].length) {
                break;
              }
            }
          }
        }
      }

      //need to check edit part for qips and plans
      print(_addedQips);
      print(di['qipLinks']);
      int m = 0;
      if (di['qipLinks'] != null && di['qipLinks'].length > 0) {
        for (int i = 0; i < _allQips.length; i++) {
          for (int j = 0; j < di['qipLinks'].length; j++) {
            if (di['qipLinks'][j]['linkid'].toString() == _allQips[i].id) {
              _addedQips[i] = true;
              m = m + 1;
              if (m == di['qipLinks'].length) {
                break;
              }
            }
          }
        }
      }

      print(_addedPlans);
      print(di['programplanLinks']);
      int n = 0;
      if (di['programplanLinks'] != null && di['programplanLinks'].length > 0) {
        for (int i = 0; i < _allPlans.length; i++) {
          for (int j = 0; j < di['programplanLinks'].length; j++) {
            if (di['programplanLinks'][j]['linkid'].toString() ==
                _allPlans[i].id) {
              _addedPlans[i] = true;
              n = n + 1;
              if (n == di['programplanLinks'].length) {
                break;
              }
            }
          }
        }
      }
    }
    loaded = 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print(AddObservationState.assesData);
    var obs = Provider.of<Obsdata>(context);
    if (loaded == 0) {
      print(obs.data);
      _fetchData(obs.obsid, obs.data);
    }
//print(obs.data['observationLinks']);
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 15,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Builder(builder: (context) {
                Widget widthPadding = SizedBox(
                  width: 5,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (obs.obsid != 'val') {
                          print(obs.data);
                          load = true;
                          choose = 1;
                          setState(() {});
                        }
                      },
                      child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                              color: Constants.kButton,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.blue[100],
                              ),
                              Text(
                                'Observation ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                    widthPadding,
                    GestureDetector(
                      onTap: () {
                        if (obs.obsid != 'val') {
                          load = true;
                          choose = 2;
                        }
                        setState(() {});
                      },
                      child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                              color: Constants.kButton,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.blue[100],
                              ),
                              Text(
                                'Reflection ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                    widthPadding,
                    GestureDetector(
                      onTap: () {
                        if (obs.obsid != 'val') {
                          print(obs.data);
                          load = true;
                          choose = 3;
                          setState(() {});
                        }
                      },
                      child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                              color: Constants.kButton,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.blue[100],
                              ),
                              Text(
                                'Qip ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                    widthPadding,
                    GestureDetector(
                      onTap: () {
                        if (obs.obsid != 'val') {
                          print(obs.data);
                          load = true;
                          choose = 4;
                          setState(() {});
                        }
                      },
                      child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                              color: Constants.kButton,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.blue[100],
                              ),
                              Text(
                                'Program Plan ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                    widthPadding,
                  ],
                );
              }),
            ),
            if (choose == 0 ||
                (choose == 1 && _allObservations == null) ||
                (choose == 2 && _allReflections == null) ||
                (choose == 3 && _allQips == null) ||
                (choose == 4 && _allPlans == null))
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: SizedBox(
                            height: 120.0,
                            child: Image.asset(Constants.NO_LINKS))),
                    Text('This Observation has no links'),
                    SizedBox(height: 100)
                  ],
                ),
              ),
            if (_allObservations != null && choose == 1)
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                height: MediaQuery.of(context).size.height - 260,
                child: ListView.builder(
                    itemCount: _allObservations.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Container(
                            // height: _allObservations[index].observationsMedia ==
                            //             'null' ||
                            //         _allObservations[index].observationsMedia ==
                            //             ''
                            //     ? 160
                            //     : 280,
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8, 0, 8),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: tagRemove(
                                              _allObservations[index].title,
                                              'heading',
                                              '',
                                              context),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(),
                                      ),
                                      Checkbox(
                                        value: _added[index],
                                        onChanged: (value) {
                                          _added[index] = value!;
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Text('Author:'),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .25,
                                            child: Text(
                                              _allObservations[index]
                                                          .approverName !=
                                                      null
                                                  ? _allObservations[index]
                                                      .approverName
                                                  : '',
                                              style: TextStyle(
                                                  color: Constants.kMain),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Row(
                                        children: [
                                          Text('Approved by:'),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .25,
                                            child: Text(
                                              _allObservations[index]
                                                          .approverName !=
                                                      null
                                                  ? _allObservations[index]
                                                      .approverName
                                                  : '',
                                              style: TextStyle(
                                                  color: Constants.kMain),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _allObservations[index].observationsMedia ==
                                              'null' ||
                                          _allObservations[index]
                                                  .observationsMedia ==
                                              ''
                                      ? Text('')
                                      : _allObservations[index]
                                                  .observationsMediaType ==
                                              'Image'
                                          ? Image.network(
                                              Constants.ImageBaseUrl +
                                                  _allObservations[index]
                                                      .observationsMedia,
                                              height: 150,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              fit: BoxFit.fill,
                                            )
                                          : VideoItem(
                                              height: 150,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              url: Constants.ImageBaseUrl +
                                                  _allObservations[index]
                                                      .observationsMedia),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      _allObservations[index].montessoricount !=
                                              null
                                          ? Text(
                                              'Montessori:' +
                                                  _allObservations[index]
                                                      .montessoricount +
                                                  ' ',
                                              style: TextStyle(
                                                color: Constants.kCount,
                                              ))
                                          : SizedBox(),
                                      _allObservations[index].eylfcount != null
                                          ? Text(
                                              'EYLF:' +
                                                  _allObservations[index]
                                                      .eylfcount,
                                              style: TextStyle(
                                                color: Constants.kCount,
                                              ))
                                          : SizedBox(),
                                      _allObservations[index].milestonecount !=
                                              null
                                          ? Text(
                                              ' DM:' +
                                                  _allObservations[index]
                                                      .milestonecount,
                                              style: TextStyle(
                                                color: Constants.kCount,
                                              ))
                                          : SizedBox(),
                                      Expanded(child: SizedBox()),
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                12, 8, 12, 8),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  _allObservations[index]
                                                              .status !=
                                                          null
                                                      ? _allObservations[index]
                                                          .status
                                                      : '',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            ),
                                          ))
                                    ],
                                  )
                                ],
                              ),
                            )),
                      );
                    }),
              ),
            if (_allReflections != null && choose == 2)
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                height: MediaQuery.of(context).size.height - 260,
                child: ListView.builder(
                    itemCount: _allReflections.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Card(
                          child: Container(
                              height: 170,
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 8, 0, 8),
                                            child: Text(
                                              _allReflections[index].title != null
                                                  ? _allReflections[index].title
                                                  : '',
                                              style: Constants.header3,maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        // Expanded(
                                        //   // flex: 1,
                                        //   child: Container(),
                                        // ),
                                        Checkbox(
                                          value: _addedRef[index],
                                          onChanged: (value) { 
                                            _addedRef[index] = value!;
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          _allReflections[index].about != null
                                              ? _allReflections[index].about
                                              : '',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                      ),
                                    ),
                                    // SizedBox(
                                    //   height: 10,
                                    // ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(child: SizedBox()),
                                        Container(
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 8, 12, 8),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    _allReflections[index]
                                                                .status !=
                                                            null
                                                        ? _allReflections[index]
                                                            .status
                                                        : '',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              )),
                        ),
                      );
                    }),
              ),
            if (_allQips != null && choose == 3)
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                height: MediaQuery.of(context).size.height - 260,
                child: ListView.builder(
                    itemCount: _allQips.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Card(
                          child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 8),
                                          child: Text(
                                            _allQips[index].name != null
                                                ? _allQips[index].name
                                                : '',
                                            style: Constants.header3,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                        Checkbox(
                                          value: _addedQips[index],
                                          onChanged: (value) {
                                            _addedQips[index] = value!;
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          child: Text(
                                            "QIP",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Constants.kMain),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )),
                        ),
                      );
                    }),
              ),
            if (_allPlans != null && choose == 4)
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                height: MediaQuery.of(context).size.height - 260,
                child: ListView.builder(
                    itemCount: _allPlans.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Card(
                          child: Container(
                              height: 110,
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                      child: Row(
                                        children: [
                                          Text(
                                            _allPlans[index].startDate != null
                                                ? _allPlans[index].startDate
                                                : '',
                                            style: Constants.header4,
                                          ),
                                          Text(
                                            ' to ',
                                            style: Constants.header3,
                                          ),
                                          Text(
                                            _allPlans[index].endDate != null
                                                ? _allPlans[index].endDate
                                                : '',
                                            style: Constants.header4,
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(),
                                          ),
                                          Checkbox(
                                            value: _addedPlans[index],
                                            onChanged: (value) {
                                              _addedPlans[index] = value!;
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          child: Text(
                                            "Program Plans",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Constants.kMain),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )),
                        ),
                      );
                    }),
              ),
            if (obs.obsid != 'val')
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        List<int> data = [];
                        List<int> dataRef = [];
                        List<int> dataQip = [];
                        List<int> dataPlan = [];

                        var _toSend =
                            Constants.BASE_URL + "observation/createLinks";
                        if (_allObservations != null) {
                          for (int i = 0; i < _allObservations.length; i++) {
                            if (_added[i]) {
                              data.add(int.parse(_allObservations[i].id));
                            }
                          }
                        }

                        if (_allReflections != null) {
                          for (int i = 0; i < _allReflections.length; i++) {
                            if (_addedRef[i]) {
                              dataRef.add(int.parse(_allReflections[i].id));
                            }
                          }
                        }

                        if (_allQips != null) {
                          for (int i = 0; i < _allQips.length; i++) {
                            if (_addedQips[i]) {
                              dataQip.add(int.parse(_allQips[i].id));
                            }
                          }
                        }

                        if (_allPlans != null) {
                          for (int i = 0; i < _allPlans.length; i++) {
                            if (_addedPlans[i]) {
                              dataPlan.add(int.parse(_allPlans[i].id));
                            }
                          }
                        }

                        var objToSend = {
                          "userid": MyApp.LOGIN_ID_VALUE,
                          "observationId": obs.obsid,
                          "linkType": "OBSERVATION",
                          "obsLinks": data
                        };
                        var objToSend2 = {
                          "userid": MyApp.LOGIN_ID_VALUE,
                          "observationId": obs.obsid,
                          "linkType": "REFLECTION",
                          "obsLinks": dataRef
                        };
                        var objToSend3 = {
                          "userid": MyApp.LOGIN_ID_VALUE,
                          "observationId": obs.obsid,
                          "linkType": "QIP",
                          "obsLinks": dataQip,
                          "centerid": AddObservationState.centerid,
                        };
                        var objToSend4 = {
                          "userid": MyApp.LOGIN_ID_VALUE,
                          "observationId": obs.obsid,
                          "linkType": "PROGRAMPLAN",
                          "obsLinks": dataPlan,
                          "centerid": AddObservationState.centerid,
                        };

                        print(jsonEncode(objToSend));
                        print(jsonEncode(objToSend2));
                        print(jsonEncode(objToSend3));
                        print(jsonEncode(objToSend4));

                        final response = await http.post(Uri.parse(_toSend),
                            body: jsonEncode(objToSend),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });

                        print(response.body);
                        final resp = await http.post(Uri.parse(_toSend),
                            body: jsonEncode(objToSend2),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });
                        print(resp.body);
                        final resp2 = await http.post(Uri.parse(_toSend),
                            body: jsonEncode(objToSend3),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });
                        print(resp2.body);
                        final resp3 = await http.post(Uri.parse(_toSend),
                            body: jsonEncode(objToSend4),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });
                        print(resp3.body);

                        if (response.statusCode == 200 &&
                            resp.statusCode == 200 &&
                            resp2.statusCode == 200 &&
                            resp3.statusCode == 200) {
                          MyApp.ShowToast("updated", context);
                          print('created');
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        } else if (response.statusCode == 401) {
                          MyApp.Show401Dialog(context);
                        }
                      },
                      child: Container(
                          width: 130,
                          height: 38,
                          decoration: BoxDecoration(
                            //    color: Constants.kButton,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'SAVE AS DRAFT',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        List<int> data = [];
                        List<int> dataRef = [];
                        List<int> dataQip = [];
                        List<int> dataPlan = [];

                        var _toSend =
                            Constants.BASE_URL + "observation/createLinks";
                        if (_allObservations != null) {
                          for (int i = 0; i < _allObservations.length; i++) {
                            if (_added[i]) {
                              data.add(int.parse(_allObservations[i].id));
                            }
                          }
                        }

                        if (_allReflections != null) {
                          for (int i = 0; i < _allReflections.length; i++) {
                            if (_addedRef[i]) {
                              dataRef.add(int.parse(_allReflections[i].id));
                            }
                          }
                        }

                        if (_allQips != null) {
                          for (int i = 0; i < _allQips.length; i++) {
                            if (_addedQips[i]) {
                              dataQip.add(int.parse(_allQips[i].id));
                            }
                          }
                        }

                        if (_allPlans != null) {
                          for (int i = 0; i < _allPlans.length; i++) {
                            if (_addedPlans[i]) {
                              dataPlan.add(int.parse(_allPlans[i].id));
                            }
                          }
                        }

                        var objToSend = {
                          "userid": MyApp.LOGIN_ID_VALUE,
                          "observationId": obs.obsid,
                          "linkType": "OBSERVATION",
                          "obsLinks": data
                        };
                        var objToSend2 = {
                          "userid": MyApp.LOGIN_ID_VALUE,
                          "observationId": obs.obsid,
                          "linkType": "REFLECTION",
                          "obsLinks": dataRef
                        };
                        var objToSend3 = {
                          "userid": MyApp.LOGIN_ID_VALUE,
                          "observationId": obs.obsid,
                          "linkType": "QIP",
                          "obsLinks": dataQip,
                          "centerid": AddObservationState.centerid,
                        };
                        var objToSend4 = {
                          "userid": MyApp.LOGIN_ID_VALUE,
                          "observationId": obs.obsid,
                          "linkType": "PROGRAMPLAN",
                          "obsLinks": dataPlan,
                          "centerid": AddObservationState.centerid,
                        };

                        var _toSend2 =
                            Constants.BASE_URL + "Observation/changeObsStatus/";

                        var objToSend5 = {
                          "obsid": obs.obsid,
                          "status": "1",
                          "userid": MyApp.LOGIN_ID_VALUE,
                        };
                        print('========objToSend=========');

                        print(jsonEncode(objToSend));
                        print(jsonEncode(objToSend2));
                        print(jsonEncode(objToSend3));
                        print(jsonEncode(objToSend4));
                        print('=================');
                        final response = await http.post(Uri.parse(_toSend),
                            body: jsonEncode(objToSend),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });
                        print(response.body);
                        final resp = await http.post(Uri.parse(_toSend),
                            body: jsonEncode(objToSend2),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });
                        print(resp.body);
                        final resp2 = await http.post(Uri.parse(_toSend),
                            body: jsonEncode(objToSend3),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });
                        print('=======token===============');
                        print(MyApp.AUTH_TOKEN_VALUE);
                        print(resp2.body);
                        final resp3 = await http.post(Uri.parse(_toSend),
                            body: jsonEncode(objToSend4),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });
                        print('3');
                        print(resp3.body);

                        final resp4 = await http.post(Uri.parse(_toSend2),
                            body: jsonEncode(objToSend5),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });
                        print('4');
                        print(_toSend2);
                        print(objToSend5);
                        print(resp4.body);

                        if (response.statusCode == 200 &&
                            resp.statusCode == 200 &&
                            resp2.statusCode == 200 &&
                            resp3.statusCode == 200 &&
                            resp4.statusCode == 200) {
                          MyApp.ShowToast("updated", context);
                          print('created');
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        } else if (response.statusCode == 401) {
                          MyApp.Show401Dialog(context);
                        }
                      },
                      child: Container(
                          width: 160,
                          height: 38,
                          decoration: BoxDecoration(
                              color: Constants.kButton,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'SAVE AS PUBLISHED',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}
