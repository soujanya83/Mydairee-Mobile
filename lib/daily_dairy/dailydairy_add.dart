import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mykronicle_mobile/api/dailydairyapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/recipemodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/hexconversion.dart';
import 'package:http/http.dart' as http;

class DailyDairyAdd extends StatefulWidget {
  final List<String> child;
  final Map showPermissions;

  final Map details;

  DailyDairyAdd(this.child, this.details, this.showPermissions);

  @override
  _DailyDairyAddState createState() => _DailyDairyAddState();
}

class _DailyDairyAddState extends State<DailyDairyAdd> {
  bool showPop = false;
  String type;

  String hour = '1h';
  String min = '0m';

  String hour2 = '1h';
  String min2 = '0m';

  List<String> hours;
  List<String> minutes;
  var details;
  int currentItemIndex = 0;

  List<RecipeModel> recipes;
  bool recipesFetched = false;

  TextEditingController quant, cal, comments, nappy, potty, toilet, signature;

  @override
  void initState() {
    quant = new TextEditingController();
    cal = new TextEditingController();

    nappy = new TextEditingController();
    potty = new TextEditingController();
    toilet = new TextEditingController();
    signature = new TextEditingController();

    comments = new TextEditingController();

    hours = List<String>.generate(12, (counter) => "${counter + 1}h");
    minutes = List<String>.generate(60, (counter) => "${counter}m");

    super.initState();
  }

  Future<void> _getItems(String type) async {
    DailyDairyAPIHandler hlr =
        DailyDairyAPIHandler({'userid': MyApp.LOGIN_ID_VALUE, "type": type});
    var dt = await hlr.getItems();
    if (!dt.containsKey('error')) {
      print(dt);
      var res = dt['items'];
      recipes = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          recipes.add(RecipeModel.fromJson(res[i]));
        }
        recipesFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //  drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: Stack(children: [
          SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          'Daily Dairy',
                          style: Constants.header1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: HexColor(widget.details['roomcolor']),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(
                                  widget.details['roomname'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              if (widget.showPermissions['breakfast'] == '1')
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        color: Color(0xffFFECB3),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.breakfast_dining,
                                                color: Colors.black,
                                              ),
                                              onPressed: null,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'Breakfast',
                                                  style: TextStyle(
                                                      //      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                type = 'Breakfast';
                                                _getItems('BREAKFAST');
                                                showPop = true;
                                                setState(() {});
                                              },
                                              child: Container(
                                                  width: 60,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                      color: Constants.kButton,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'ADD',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              if (widget.showPermissions['morningtea'] == '1')
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        color: Color(0xffC0CCD9),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                MaterialIcons.free_breakfast,
                                                color: Colors.black,
                                              ),
                                              onPressed: null,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'Morning Tea',
                                                  style: TextStyle(
                                                      //      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                type = 'MorningTea';
                                                _getItems('MORNINGTEA');
                                                showPop = true;
                                                setState(() {});
                                              },
                                              child: Container(
                                                  width: 60,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                      color: Constants.kButton,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'ADD',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              if (widget.showPermissions['lunch'] == '1')
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        color: Color(0xff136DF6),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                MaterialCommunityIcons.food,
                                                color: Colors.black,
                                              ),
                                              onPressed: null,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'LUNCH',
                                                  style: TextStyle(
                                                      //      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                type = 'Lunch';
                                                _getItems('LUNCH');
                                                showPop = true;
                                                setState(() {});
                                              },
                                              child: Container(
                                                  width: 60,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                      color: Constants.kButton,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'ADD',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              if (widget.showPermissions['sleep'] == '1')
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        color: Color(0xffEFCE4A),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                MaterialCommunityIcons.sleep,
                                                color: Colors.black,
                                              ),
                                              onPressed: null,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'SLEEP',
                                                  style: TextStyle(
                                                      //      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                type = 'Sleep';
                                                print('sleep');
                                                showPop = true;
                                                setState(() {});
                                              },
                                              child: Container(
                                                  width: 60,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                      color: Constants.kButton,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'ADD',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              if (widget.showPermissions['afternoontea'] == '1')
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        color: Color(0xffF0CDFF),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                MaterialCommunityIcons
                                                    .tea_outline,
                                                color: Colors.black,
                                              ),
                                              onPressed: null,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'Afternoon Tea',
                                                  style: TextStyle(
                                                      //      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                type = 'AfternoonTea';
                                                _getItems('AFTERNOONTEA');
                                                showPop = true;
                                                setState(() {});
                                              },
                                              child: Container(
                                                  width: 60,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                      color: Constants.kButton,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'ADD',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              if (widget.showPermissions['latesnacks'] == '1')
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        color: Color(0xffFEC093),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                MaterialCommunityIcons
                                                    .tea_outline,
                                                color: Colors.black,
                                              ),
                                              onPressed: null,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'Late Snacks',
                                                  style: TextStyle(
                                                      //      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                type = 'Snacks';
                                                _getItems('SNACKS');
                                                showPop = true;
                                                setState(() {});
                                              },
                                              child: Container(
                                                  width: 60,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                      color: Constants.kButton,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'ADD',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              if (widget.showPermissions['sunscreen'] == '1')
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        color: Color(0xffE07F7F),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Feather.sun,
                                                color: Colors.black,
                                              ),
                                              onPressed: null,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'SunScreen',
                                                  style: TextStyle(
                                                      //      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                type = 'SunScreen';
                                                showPop = true;
                                                setState(() {});
                                              },
                                              child: Container(
                                                  width: 60,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                      color: Constants.kButton,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'ADD',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              if (widget.showPermissions['toileting'] == '1')
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        color: Color(0xffD1FFCD),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Entypo.man,
                                                color: Colors.black,
                                              ),
                                              onPressed: null,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  'Toileting',
                                                  style: TextStyle(
                                                      //      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                type = 'Toileting';
                                                showPop = true;
                                                setState(() {});
                                              },
                                              child: Container(
                                                  width: 60,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                      color: Constants.kButton,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'ADD',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        )
                      ])))),
          if (type == 'SunScreen' && showPop)
            Center(
                child: SingleChildScrollView(
              child: Container(
                  color: Colors.white,
                  height: 300,
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          //  width: MediaQuery.of(context).size.width,
                          color: HexColor(widget.details['roomcolor']),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                'Add ' + type,
                                style: TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showPop = false;
                                    comments.clear();
                                    hour = '1h';
                                    min = '0m';
                                    setState(() {});
                                  })
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height: 235,
                                child: ListView(children: [
                                  Text('Time'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      hours != null
                                          ? DropdownButtonHideUnderline(
                                              child: Container(
                                                height: 40,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]),
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Center(
                                                    child:
                                                        DropdownButton<String>(
                                                      //  isExpanded: true,
                                                      value: hour,
                                                      items: hours
                                                          .map((String value) {
                                                        return new DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child:
                                                              new Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String value) {
                                                        hour = value;
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      Container(
                                        width: 20,
                                      ),
                                      minutes != null
                                          ? DropdownButtonHideUnderline(
                                              child: Container(
                                                height: 40,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]),
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Center(
                                                    child:
                                                        DropdownButton<String>(
                                                      //  isExpanded: true,
                                                      value: min,
                                                      items: minutes
                                                          .map((String value) {
                                                        return new DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child:
                                                              new Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String value) {
                                                        min = value;
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Comments'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: 60,
                                    child: TextField(
                                        maxLines: 2,
                                        controller: comments,
                                        decoration: new InputDecoration(
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.black26,
                                                width: 0.0),
                                          ),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              const Radius.circular(4),
                                            ),
                                          ),
                                        )),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            var _toSend = Constants.BASE_URL +
                                                'dailyDiary/addSunscreenRecord';

                                            var objToSend = {
                                              "userid": MyApp.LOGIN_ID_VALUE,
                                              "startTime": hour + ":" + min,
                                              "comments":
                                                  comments.text.toString(),
                                              "createdAt":
                                                  DateTime.now().toString(),
                                              "type": type.toUpperCase(),
                                              "childids": widget.child
                                            };

                                            print(jsonEncode(objToSend));
                                            final response = await http.post(
                                                _toSend,
                                                body: jsonEncode(objToSend),
                                                headers: {
                                                  'X-DEVICE-ID': await MyApp
                                                      .getDeviceIdentity(),
                                                  'X-TOKEN':
                                                      MyApp.AUTH_TOKEN_VALUE,
                                                });
                                            print(response.body);
                                            if (response.statusCode == 200) {
                                              MyApp.ShowToast(
                                                  "updated", context);
                                              Navigator.pop(context, 'kill');
                                            } else if (response.statusCode ==
                                                401) {
                                              MyApp.Show401Dialog(context);
                                            }
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Constants.kButton,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        12, 8, 12, 8),
                                                child: Text(
                                                  'SAVE',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              )),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        )
                                      ],
                                    ),
                                  ),
                                ])))
                      ])),
            )),
          if (type == 'Sleep' && showPop)
            Center(
                child: SingleChildScrollView(
              child: Container(
                  color: Colors.white,
                  height: 370,
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          //  width: MediaQuery.of(context).size.width,
                          color: HexColor(widget.details['roomcolor']),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                'Add ' + type,
                                style: TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showPop = false;
                                    comments.clear();
                                    hour = '1h';
                                    min = '0m';
                                    hour2 = '1h';
                                    min2 = '0m';
                                    setState(() {});
                                  })
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height: 305,
                                child: ListView(children: [
                                  Text('Time'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      hours != null
                                          ? DropdownButtonHideUnderline(
                                              child: Container(
                                                height: 40,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]),
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Center(
                                                    child:
                                                        DropdownButton<String>(
                                                      //  isExpanded: true,
                                                      value: hour,
                                                      items: hours
                                                          .map((String value) {
                                                        return new DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child:
                                                              new Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String value) {
                                                        hour = value;
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      Container(
                                        width: 20,
                                      ),
                                      minutes != null
                                          ? DropdownButtonHideUnderline(
                                              child: Container(
                                                height: 40,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]),
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Center(
                                                    child:
                                                        DropdownButton<String>(
                                                      //  isExpanded: true,
                                                      value: min,
                                                      items: minutes
                                                          .map((String value) {
                                                        return new DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child:
                                                              new Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String value) {
                                                        min = value;
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('To'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      hours != null
                                          ? DropdownButtonHideUnderline(
                                              child: Container(
                                                height: 40,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]),
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Center(
                                                    child:
                                                        DropdownButton<String>(
                                                      //  isExpanded: true,
                                                      value: hour2,
                                                      items: hours
                                                          .map((String value) {
                                                        return new DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child:
                                                              new Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String value) {
                                                        hour2 = value;
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      Container(
                                        width: 20,
                                      ),
                                      minutes != null
                                          ? DropdownButtonHideUnderline(
                                              child: Container(
                                                height: 40,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]),
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Center(
                                                    child:
                                                        DropdownButton<String>(
                                                      //  isExpanded: true,
                                                      value: min2,
                                                      items: minutes
                                                          .map((String value) {
                                                        return new DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child:
                                                              new Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String value) {
                                                        min2 = value;
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text('Comments'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: 60,
                                    child: TextField(
                                        maxLines: 2,
                                        controller: comments,
                                        decoration: new InputDecoration(
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.black26,
                                                width: 0.0),
                                          ),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              const Radius.circular(4),
                                            ),
                                          ),
                                        )),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            var _toSend = Constants.BASE_URL +
                                                'dailyDiary/addSleepRecord';

                                            var objToSend = {
                                              "userid": MyApp.LOGIN_ID_VALUE,
                                              "startTime": hour + ":" + min,
                                              "endTime": hour2 + ":" + min2,
                                              "comments":
                                                  comments.text.toString(),
                                              "createdAt":
                                                  DateTime.now().toString(),
                                              "type": type.toUpperCase(),
                                              "childids": widget.child
                                            };

                                            print(jsonEncode(objToSend));
                                            final response = await http.post(
                                                _toSend,
                                                body: jsonEncode(objToSend),
                                                headers: {
                                                  'X-DEVICE-ID': await MyApp
                                                      .getDeviceIdentity(),
                                                  'X-TOKEN':
                                                      MyApp.AUTH_TOKEN_VALUE,
                                                });
                                            print(response.body);
                                            if (response.statusCode == 200) {
                                              MyApp.ShowToast(
                                                  "updated", context);
                                              Navigator.pop(context, 'kill');
                                            } else if (response.statusCode ==
                                                401) {
                                              MyApp.Show401Dialog(context);
                                            }
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Constants.kButton,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        12, 8, 12, 8),
                                                child: Text(
                                                  'SAVE',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              )),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        )
                                      ],
                                    ),
                                  ),
                                ])))
                      ])),
            )),
          if (type == 'Toileting' && showPop)
            Center(
              child: SingleChildScrollView(
                child: Container(
                    color: Colors.white,
                    height: 420,
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          //  width: MediaQuery.of(context).size.width,
                          color: HexColor(widget.details['roomcolor']),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                'Add ' + type,
                                style: TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showPop = false;
                                    nappy.clear();
                                    potty.clear();
                                    toilet.clear();
                                    signature.clear();
                                    comments.clear();
                                    hour = '1h';
                                    min = '0m';
                                    setState(() {});
                                  })
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 355,
                            child: ListView(
                              children: [
                                Text('Time'),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    hours != null
                                        ? DropdownButtonHideUnderline(
                                            child: Container(
                                              height: 40,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[300]),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, right: 8),
                                                child: Center(
                                                  child: DropdownButton<String>(
                                                    //  isExpanded: true,
                                                    value: hour,
                                                    items: hours
                                                        .map((String value) {
                                                      return new DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: new Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String value) {
                                                      hour = value;
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    Container(
                                      width: 20,
                                    ),
                                    minutes != null
                                        ? DropdownButtonHideUnderline(
                                            child: Container(
                                              height: 40,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[300]),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, right: 8),
                                                child: Center(
                                                  child: DropdownButton<String>(
                                                    //  isExpanded: true,
                                                    value: min,
                                                    items: minutes
                                                        .map((String value) {
                                                      return new DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: new Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String value) {
                                                      min = value;
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Nappy'),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 30,
                                  child: TextField(
                                      maxLines: 1,
                                      controller: nappy,
                                      decoration: new InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black26,
                                              width: 0.0),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(4),
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Potty'),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 30,
                                  child: TextField(
                                      maxLines: 1,
                                      controller: potty,
                                      decoration: new InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black26,
                                              width: 0.0),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(4),
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Signature'),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 30,
                                  child: TextField(
                                      maxLines: 1,
                                      controller: signature,
                                      decoration: new InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black26,
                                              width: 0.0),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(4),
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Toilet'),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 30,
                                  child: TextField(
                                      maxLines: 1,
                                      controller: toilet,
                                      decoration: new InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black26,
                                              width: 0.0),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(4),
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Comments'),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 60,
                                  child: TextField(
                                      maxLines: 2,
                                      controller: comments,
                                      decoration: new InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black26,
                                              width: 0.0),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(4),
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          var _toSend = Constants.BASE_URL +
                                              'dailyDiary/addToiletingRecord';

                                          var objToSend = {
                                            "userid": MyApp.LOGIN_ID_VALUE,
                                            "startTime": hour + ":" + min,
                                            "nappy": nappy.text.toString(),
                                            "potty": potty.text.toString(),
                                            "toilet": toilet.text.toString(),
                                            "signature":
                                                signature.text.toString(),
                                            "comments":
                                                comments.text.toString(),
                                            "createdAt":
                                                DateTime.now().toString(),
                                            "type": type.toUpperCase(),
                                            "childids": widget.child
                                          };

                                          print(jsonEncode(objToSend));
                                          final response = await http.post(
                                              _toSend,
                                              body: jsonEncode(objToSend),
                                              headers: {
                                                'X-DEVICE-ID': await MyApp
                                                    .getDeviceIdentity(),
                                                'X-TOKEN':
                                                    MyApp.AUTH_TOKEN_VALUE,
                                              });
                                          print(response.body);
                                          if (response.statusCode == 200) {
                                            MyApp.ShowToast("updated", context);
                                            Navigator.pop(context, 'kill');
                                          } else if (response.statusCode ==
                                              401) {
                                            MyApp.Show401Dialog(context);
                                          }
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Constants.kButton,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 8, 12, 8),
                                              child: Text(
                                                'SAVE',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
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
                      ],
                    )),
              ),
            ),
          if ((type == 'Breakfast' ||
                  type == 'MorningTea' ||
                  type == 'Lunch' ||
                  type == 'AfternoonTea' ||
                  type == 'Snacks') &&
              showPop)
            Center(
              child: SingleChildScrollView(
                child: Container(
                    color: Colors.white,
                    height: 420,
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          //  width: MediaQuery.of(context).size.width,
                          color: HexColor(widget.details['roomcolor']),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                'Add ' + type,
                                style: TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    print('called');
                                    showPop = false;
                                    quant.clear();
                                    cal.clear();
                                    comments.clear();
                                    hour = '1h';
                                    min = '0m';
                                    currentItemIndex = 0;
                                    setState(() {});
                                  })
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 355,
                            child: ListView(
                              children: [
                                Text('Time'),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    hours != null
                                        ? DropdownButtonHideUnderline(
                                            child: Container(
                                              height: 40,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[300]),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, right: 8),
                                                child: Center(
                                                  child: DropdownButton<String>(
                                                    //  isExpanded: true,
                                                    value: hour,
                                                    items: hours
                                                        .map((String value) {
                                                      return new DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: new Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String value) {
                                                      hour = value;
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    Container(
                                      width: 20,
                                    ),
                                    minutes != null
                                        ? DropdownButtonHideUnderline(
                                            child: Container(
                                              height: 40,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[300]),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, right: 8),
                                                child: Center(
                                                  child: DropdownButton<String>(
                                                    //  isExpanded: true,
                                                    value: min,
                                                    items: minutes
                                                        .map((String value) {
                                                      return new DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: new Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String value) {
                                                      min = value;
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Item'),
                                SizedBox(
                                  height: 5,
                                ),
                                recipesFetched && recipes.length > 0
                                    ? DropdownButtonHideUnderline(
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey[300]),
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, right: 8),
                                            child: Center(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: recipes[currentItemIndex]
                                                    .id,
                                                items: recipes
                                                    .map((RecipeModel value) {
                                                  return new DropdownMenuItem<
                                                      String>(
                                                    value: value.id,
                                                    child: new Text(
                                                        value.itemName),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  for (int i = 0;
                                                      i < recipes.length;
                                                      i++) {
                                                    if (recipes[i].id ==
                                                        value) {
                                                      setState(() {
                                                        currentItemIndex = i;
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
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Quantity'),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 30,
                                  child: TextField(
                                      maxLines: 1,
                                      controller: quant,
                                      decoration: new InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black26,
                                              width: 0.0),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(4),
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Calories'),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 30,
                                  child: TextField(
                                      maxLines: 1,
                                      controller: cal,
                                      decoration: new InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black26,
                                              width: 0.0),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(4),
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Comments'),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 60,
                                  child: TextField(
                                      maxLines: 2,
                                      controller: comments,
                                      decoration: new InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black26,
                                              width: 0.0),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(4),
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          var _toSend = Constants.BASE_URL +
                                              'dailyDiary/addFoodRecord';

                                          var objToSend = {
                                            "userid": MyApp.LOGIN_ID_VALUE,
                                            "startTime": hour + ":" + min,
                                            "item": recipes[currentItemIndex]
                                                .itemName,
                                            "qty": quant.text.toString(),
                                            "comments":
                                                comments.text.toString(),
                                            "createdAt":
                                                DateTime.now().toString(),
                                            "type": type.toUpperCase(),
                                            "calories": cal.text.toString(),
                                            "childids": widget.child
                                          };

                                          print(jsonEncode(objToSend));
                                          final response = await http.post(
                                              _toSend,
                                              body: jsonEncode(objToSend),
                                              headers: {
                                                'X-DEVICE-ID': await MyApp
                                                    .getDeviceIdentity(),
                                                'X-TOKEN':
                                                    MyApp.AUTH_TOKEN_VALUE,
                                              });
                                          print(response.body);
                                          if (response.statusCode == 200) {
                                            MyApp.ShowToast("updated", context);
                                            Navigator.pop(context, 'kill');
                                          } else if (response.statusCode ==
                                              401) {
                                            MyApp.Show401Dialog(context);
                                          }
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Constants.kButton,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 8, 12, 8),
                                              child: Text(
                                                'SAVE',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
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
                      ],
                    )),
              ),
            )
        ]));
  }
}
