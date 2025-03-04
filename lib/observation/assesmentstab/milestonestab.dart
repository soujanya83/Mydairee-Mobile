import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/observation/addobservation.dart';
import 'package:mykronicle_mobile/observation/obsdata.dart';
import 'package:mykronicle_mobile/services/callbacks.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MilestonesTabs extends StatefulWidget {
  final int count;
  final List data;
  final Map totaldata;
  final IndexCallback changeTab;
  MilestonesTabs({required this.count, required this.data, required this.changeTab, required this.totaldata});

  @override
  _MilestonesTabsState createState() => _MilestonesTabsState();
}

class _MilestonesTabsState extends State<MilestonesTabs>
    with SingleTickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    _controller = new TabController(length: widget.count, vsync: this);
    //  _fill();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var obs = Provider.of<Obsdata>(context);

    return Container(
      child: Column(
        children: <Widget>[
          new Container(
            child: DefaultTabController(
              length: 3,
              child: new TabBar(
                  isScrollable: true,
                  controller: _controller,
                  labelColor: Constants.kMain,
                  unselectedLabelColor: Colors.grey,
                  tabs: List<Tab>.generate(widget.count, (i) {
                    return Tab(
                      text: widget.data[i]['ageGroup'],
                    );
                  })),
            ),
          ),
          new Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: new TabBarView(
              controller: _controller,
              children: List<Widget>.generate(widget.count, (i) {
                return tabData(i);
              }),
            ),
          ),
          if (obs.obsid != 'val')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      width: 80,
                      height: 38,
                      decoration: BoxDecoration(
                        //    color: Constants.kButton,
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'CANCEL',
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
                    var _toSend =
                        Constants.BASE_URL + 'observation/createMilestones';
                    print(_toSend);
                    List<Map<String, dynamic>> ac = [];

                    for (int i = 0; i < widget.count; i++) {
                      for (int j = 0;
                          j < widget.data[i]['subname'].length;
                          j++) {
                        for (int k = 0;
                            k < widget.data[i]['subname'][j]['title'].length;
                            k++) {
                          List<int> ex = [];

                          for (int l = 0;
                              l <
                                  widget
                                      .data[i]['subname'][j]['title'][k]
                                          ['options']
                                      .length;
                              l++) {
                            if (AddObservationState.selectedOptions[i][j][k]
                                [l]) {
                              ex.add(int.parse(
                                  AddObservationState.options[i][j][k][l].id));
                            }
                          }

                          ac.add({
                            "devMilestoneId": int.parse(
                                widget.data[i]['subname'][j]['title'][k]['id']),
                            "assessment": AddObservationState.dropAnsM[i][j][k],
                            "extras": ex
                          });
                        }
                      }
                    }

                    var objToSend = {
                      "userid": int.parse(MyApp.LOGIN_ID_VALUE),
                      "observationId": int.parse(obs.obsid),
                      "milestones": ac
                    };
                    print(jsonEncode(objToSend));
                    final response = await http
                        .post(Uri.parse(_toSend), body: jsonEncode(objToSend), headers: {
                      'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                    });
                    print(response.body);
                    if (response.statusCode == 200) {
                      MyApp.ShowToast("updated", context);
                      widget.changeTab(1);
                    } else if (response.statusCode == 401) {
                      MyApp.Show401Dialog(context);
                    }
                  },
                  child: Container(
                      width: 112,
                      height: 38,
                      decoration: BoxDecoration(
                          color: Constants.kButton,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'SAVE & NEXT',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget tabData(int val) {
    return Container(
      child: ListView.builder(
        itemCount: widget.data[val]['subname'].length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: ListTile(
                    title: Text(
                      widget.data[val]['subname'][index]['name'],
                      style: TextStyle(fontSize: 15),
                    ),
                    trailing: InkWell(
                      onTap: () {
                        if (AddObservationState.emi[val][index]) {
                          AddObservationState.emi[val][index] = false;
                        } else {
                          AddObservationState.emi[val][index] = true;
                        }
                        setState(() {});
                      },
                      child: Container(
                        width: 72,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Constants.kMain,
                            ),
                            Text(
                              'Expand',
                              style: TextStyle(color: Constants.kMain),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: AddObservationState.emi != null
                        ? AddObservationState.emi[val][index]
                        : false,
                    child: Container(
                        height:
                            widget.data[val]['subname'][index]['title'].length *
                                60.0,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget
                              .data[val]['subname'][index]['title'].length,
                          itemBuilder: (BuildContext context, int i) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  child: Column(children: [
                                Row(
                                  children: [
                                    Container(
                                        width: 140,
                                        child: Text(widget.data[val]['subname']
                                            [index]['title'][i]['name'])),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    DropdownButtonHideUnderline(
                                      child: Container(
                                        height: 40,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                180,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Center(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: AddObservationState
                                                  .dropAnsM[val][index][i],
                                              items: <String>[
                                                'Not Observed',
                                                'Not Interested',
                                                'Not Calculated'
                                              ].map((String value) {
                                                return new DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: new Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? value) {
                                                setState(() {
                                                  AddObservationState
                                                          .dropAnsM[val][index]
                                                      [i] = value??'';
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: AddObservationState
                                          .options[val][index][i].length *
                                      60.0,
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: AddObservationState
                                          .options[val][index][i].length,
                                      itemBuilder:
                                          (BuildContext context, int j) {
                                        return CheckboxListTile(
                                            title: Text(AddObservationState
                                                .options[val][index][i][j]
                                                .title),
                                            value: AddObservationState
                                                    .selectedOptions[val][index]
                                                [i][j],
                                            onChanged: (value) {
                                              AddObservationState
                                                      .selectedOptions[val]
                                                  [index][i][j] = value??false;
                                              setState(() {});
                                            });
                                      }),
                                )
                              ])),
                            );
                          },
                        ))),
              ],
            ),
          );
        },
      ),
    );
  }
}
