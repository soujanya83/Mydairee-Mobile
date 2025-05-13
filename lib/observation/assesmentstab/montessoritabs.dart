import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/extrasmodel.dart';
import 'package:mykronicle_mobile/observation/obsdata.dart';
import 'package:mykronicle_mobile/services/callbacks.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:provider/provider.dart';

import 'package:mykronicle_mobile/observation/addobservation.dart';
import 'package:http/http.dart' as http;

class MontessoriTabs extends StatefulWidget {
  final int count;
  final List data;
  final Map totaldata;
  final IndexCallback changeTab;
  MontessoriTabs(
      {required this.count,
      required this.data,
      required this.changeTab,
      required this.totaldata});

  @override
  _MontessoriTabsState createState() => _MontessoriTabsState();
}

class _MontessoriTabsState extends State<MontessoriTabs>
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
                      text: widget.data[i]['name'],
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
                        Constants.BASE_URL + 'observation/createMontessori';

                    List<Map<String, dynamic>> ac = [];

                    for (int i = 0; i < widget.count; i++) {
                      for (int j = 0;
                          j < widget.data[i]['activity'].length;
                          j++) {
                        for (int k = 0;
                            k <
                                widget.data[i]['activity'][j]['SubActivity']
                                    .length;
                            k++) {
                          List<int> ex = [];

                          for (int l = 0;
                              l <
                                  widget
                                      .data[i]['activity'][j]['SubActivity'][k]
                                          ['extras']
                                      .length;
                              l++) {
                            if (AddObservationState.selectedExtras[i][j][k]
                                [l]) {
                              ex.add(int.parse(AddObservationState
                                  .extras[i][j][k][l].idExtra));
                            }
                          }

                          ac.add({
                            "idSubActivity": int.parse(widget.data[i]
                                    ['activity'][j]['SubActivity'][k]
                                ['idSubActivity']),
                            "assessment": AddObservationState.dropAns[i][j][k],
                            "extras": ex
                          });
                        }
                      }
                    }

                    var objToSend = {
                      "userid": int.parse(MyApp.LOGIN_ID_VALUE),
                      "observationId": int.parse(obs.obsid),
                      "montessori": ac
                    };
                    print(jsonEncode(objToSend));
                    final response = await http.post(Uri.parse(_toSend),
                        body: jsonEncode(objToSend),
                        headers: {
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

// montessori
  Widget tabData(int val) {
    return Container(
      child: ListView.builder(
        itemCount: widget.data[val]['activity'].length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Container(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: ListTile(
                      title: Text(widget.data[val]['activity'][index]['title'],
                          // style: TextStyle(fontSize: 15),
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Constants.kBlack,
                              fontWeight: FontWeight.w500)),
                      trailing: InkWell(
                        onTap: () {
                          try {
                            if (widget
                                .data[val]['activity'][index]['SubActivity']
                                .isEmpty) {
                              MyApp.ShowToast('Sub activity Empty!', context);
                              return;
                            }
                          } catch (e) {}
                          print('===============');
                          print(widget.data[val]['activity'][index]);
                          print('-----------');
                          if (AddObservationState.em[val][index]) {
                            AddObservationState.em[val][index] = false;
                          } else {
                            AddObservationState.em[val][index] = true;
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
                      visible: AddObservationState.em != null
                          ? AddObservationState.em[val][index]
                          : false,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget
                            .data[val]['activity'][index]['SubActivity'].length,
                        itemBuilder: (BuildContext context, int i) {
                          return Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                                child: Column(children: [
                              Row(
                                children: [
                                  Container(
                                      width: 140,
                                      child: Text(
                                          widget.data[val]['activity'][index]
                                              ['SubActivity'][i]['title'],
                                          style: TextStyle(
                                              fontSize: 13.0,
                                              color: Constants.kBlack,
                                              fontWeight: FontWeight.w400))),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        AddObservationState.dropAns[val][index]
                                            [i] = 'Not Assesed';
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    splashColor: Colors.grey.withOpacity(0.2),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 15,
                                            child: Radio<String>(
                                              value: 'Not Assesed',
                                              groupValue: AddObservationState
                                                  .dropAns[val][index][i],
                                              onChanged: (String? value) {
                                                setState(() {
                                                  AddObservationState
                                                          .dropAns[val][index]
                                                      [i] = value!;
                                                });
                                              },
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text("N",
                                              style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      width: 12,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        AddObservationState.dropAns[val][index]
                                            [i] = 'Introduced';
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 15,
                                            child: Radio<String>(
                                              value: 'Introduced',
                                              groupValue: AddObservationState
                                                  .dropAns[val][index][i],
                                              onChanged: (String? value) {
                                                setState(() {
                                                  AddObservationState
                                                          .dropAns[val][index]
                                                      [i] = value!;
                                                });
                                              },
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text("I",
                                              style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      width: 12,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        AddObservationState.dropAns[val][index]
                                            [i] = 'Working';
                                      });
                                    },
                                    splashColor: Colors.grey.withOpacity(
                                        0.3), // Custom ripple color
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded ripple effect
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 24, // Larger clickable area
                                            width: 15,
                                            child: Radio<String>(
                                              value: 'Working',
                                              groupValue: AddObservationState
                                                  .dropAns[val][index][i],
                                              onChanged: (String? value) {
                                                setState(() {
                                                  AddObservationState
                                                          .dropAns[val][index]
                                                      [i] = value!;
                                                });
                                              },
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(
                                              width: 8), // Increased spacing
                                          const Text("W",
                                              style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      width: 12,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        AddObservationState.dropAns[val][index]
                                            [i] = 'Completed';
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(
                                        12), // Rounded touch feedback
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 24, // Larger clickable area
                                            width: 15,
                                            child: Radio<String>(
                                              value: 'Completed',
                                              groupValue: AddObservationState
                                                  .dropAns[val][index][i],
                                              onChanged: (String? value) {
                                                setState(() {
                                                  AddObservationState
                                                          .dropAns[val][index]
                                                      [i] = value!;
                                                });
                                              },
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text("C",
                                              style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  )

                                  // DropdownButtonHideUnderline(
                                  //   child: Container(
                                  //     height: 40,
                                  //     width: MediaQuery.of(context)
                                  //             .size
                                  //             .width -
                                  //         180,
                                  //     decoration: BoxDecoration(
                                  //         border: Border.all(
                                  //             color: Colors.grey),
                                  //         color: Colors.white,
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(8))),
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.only(
                                  //           left: 8, right: 8),
                                  //       child: Center(
                                  //         child: DropdownButton<String>(
                                  //           isExpanded: true,
                                  //           value: dropAns[val][index][i],
                                  //           items: <String>[
                                  //             'Not Assesed',
                                  //             'Introduced',
                                  //             'Working',
                                  //             'Completed'
                                  //           ].map((String value) {
                                  //             return new DropdownMenuItem<
                                  //                 String>(
                                  //               value: value,
                                  //               child: new Text(value),
                                  //             );
                                  //           }).toList(),
                                  //            onChanged: (String? value)  {
                                  //             setState(() {
                                  //               dropAns[val][index][i] =
                                  //                   value!;
                                  //             });
                                  //           },
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              Container(
                                height: AddObservationState
                                        .extras[val][index][i].length *
                                    60.0,
                                child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: AddObservationState
                                        .extras[val][index][i].length,
                                    itemBuilder: (BuildContext context, int j) {
                                      return CheckboxListTile(
                                          title: Text(AddObservationState
                                              .extras[val][index][i][j].title),
                                          value: AddObservationState
                                              .selectedExtras[val][index][i][j],
                                          onChanged: (value) {
                                            AddObservationState
                                                    .selectedExtras[val][index]
                                                [i][j] = value!;
                                            setState(() {});
                                          });
                                    }),
                              )
                            ])),
                          );
                        },
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
