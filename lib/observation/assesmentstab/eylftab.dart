import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/observation/addobservation.dart';
import 'package:mykronicle_mobile/observation/obsdata.dart';
import 'package:mykronicle_mobile/services/callbacks.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EylfTabs extends StatefulWidget {
  final int count;
  final List data;
  final Map totaldata;
  final IndexCallback changeTab;
  EylfTabs({required this.count, required this.data, required this.changeTab, required this.totaldata});

  @override
  _EylfTabsState createState() => _EylfTabsState();
}

class _EylfTabsState extends State<EylfTabs>
    with SingleTickerProviderStateMixin {
  TabController? _controller;
  @override
  void initState() {
    _controller = new TabController(length: widget.count, vsync: this);
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
                      text: widget.data[i]['title'],
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
                    var _toSend = widget.totaldata == null
                        ? Constants.BASE_URL + 'observation/createEylf'
                        : Constants.BASE_URL + 'observation/editEylf';
                    var eylfData = {};

                    for (int i = 0; i < widget.count; i++) {
                      for (int j = 0;
                          j < widget.data[i]['activity'].length;
                          j++) {
                        List<int> inc = [];
                        for (int k = 0;
                            k <
                                widget.data[i]['activity'][j]['subActivity']
                                    .length;
                            k++) {
                          if (AddObservationState.checkValue[i][j][k] == true) {
                            inc.add(int.parse(widget.data[i]['activity'][j]
                                ['subActivity'][k]['id']));
                          }
                        }
                        eylfData[widget.data[i]['activity'][j]['id']] = inc;
                      }
                    }

                    var objToSend = {
                      "userid": int.parse(MyApp.LOGIN_ID_VALUE),
                      "observationId": int.parse(obs.obsid),
                      "eylf": eylfData
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
                      widget.changeTab(2);
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
      height: 200,
      child: ListView.builder(
        itemCount: widget.data[val]['activity'].length,
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
                      widget.data[val]['activity'][index]['title'],
                      style: TextStyle(fontSize: 15),
                    ),
                    trailing: InkWell(
                      onTap: () {
                        if (AddObservationState.e[val][index]) {
                          AddObservationState.e[val][index] = false;
                        } else {
                          AddObservationState.e[val][index] = true;
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
                    visible: AddObservationState.e != null
                        ? AddObservationState.e[val][index]
                        : false,
                    child: Container(
                        height: widget
                                .data[val]['activity'][index]['subActivity']
                                .length *
                            64.0,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget
                              .data[val]['activity'][index]['subActivity']
                              .length,
                          itemBuilder: (BuildContext context, int i) {
                            return ListTile(
                              title: Text(widget.data[val]['activity'][index]
                                  ['subActivity'][i]['title'],maxLines: 2,),
                              leading: Checkbox(
                                onChanged: (value) {
                                  AddObservationState.checkValue[val][index]
                                      [i] = value!;
                                  setState(() {});
                                },
                                value: AddObservationState.checkValue[val]
                                    [index][i],
                              ),
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
