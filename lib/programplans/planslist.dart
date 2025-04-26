import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/programplanapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/programplans/addplan.dart';
import 'package:mykronicle_mobile/programplans/createplan.dart';
import 'package:mykronicle_mobile/programplans/viewplan.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class PlansList extends StatefulWidget {
  @override
  _PlansListState createState() => _PlansListState();
}

class _PlansListState extends State<PlansList> {
  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;
  var planList;
  List progHead = [];

  @override
  void initState() {
    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    print(dt);
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

    _fetchData();
  }

  void _fetchData() async {
    var _objToSend = {
      // "usertype": MyApp.USER_TYPE_VALUE,
      "userid": MyApp.LOGIN_ID_VALUE,
      "centerid": centers[currentIndex].id
    };
    ProgramPlanApiHandler planApiHandler = ProgramPlanApiHandler(_objToSend);
    var data = await planApiHandler.getProgramPlanList();
    print('+++++++++++++mfkdmkfmdkfmkdfmkf++++++++');
    print(data);
    planList = data['data'];
    print('==========data========');
    print(data);
    //  progHead=data['get_details']['']
    setState(() {});
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'Program Plan',
                            style: Constants.header1,
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          if (MyApp.USER_TYPE_VALUE != 'Parent')
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddPlan(
                                            'add',
                                            centers[currentIndex].id,
                                            '',
                                            null))).then((value) {
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
                                      'Add Plan',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  )),
                            )
                        ],
                      ),
                      centersFetched
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: DropdownButtonHideUnderline(
                                child: Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Constants.greyColor),
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Center(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: centers[currentIndex].id,
                                        items:
                                            centers.map((CentersModel value) {
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
                              ),
                            )
                          : Container(),
                      if (planList != null)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: planList.length,
                          itemBuilder: (context, index) {
                            final plan = planList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Month and Year
                                      Text(
                                        "${_getMonthName(plan['months'])} ${plan['years']}",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 10),

                                      // Room Name
                                      Row(
                                        children: [
                                          Icon(Icons.meeting_room_outlined,
                                              size: 18, color: Colors.black),
                                          SizedBox(width: 6),
                                          Text(
                                            plan['room_name'] ?? '-',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),

                                      // Created By
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline,
                                              size: 18, color: Colors.black),
                                          SizedBox(width: 6),
                                          Text(
                                            "Created by ${plan['creator_name'] ?? '-'}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),

                                      // Inquiry Topic
                                      if ((plan['inquiry_topic'] ?? '')
                                          .isNotEmpty) ...[
                                        Row(
                                          children: [
                                            Icon(Icons.lightbulb_outline,
                                                size: 18, color: Colors.black),
                                            SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                "Inquiry Topic: ${plan['inquiry_topic']}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                      ],

                                      // Special Events
                                      if ((plan['special_events'] ?? '')
                                          .isNotEmpty) ...[
                                        Row(
                                          children: [
                                            Icon(Icons.event_outlined,
                                                size: 18, color: Colors.black),
                                            SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                "Special Events: ${plan['special_events']}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                      ],

                                      Divider(
                                          color: Colors.grey.shade300,
                                          height: 30),

                                      // Dates
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Created: ${_formatDate(plan['created_at'])}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            "Updated: ${_formatDate(plan['updated_at'])}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),

                                      // Action Buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (MyApp.USER_TYPE_VALUE ==
                                              'Superadmin')
                                            IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddPlan(
                                                      'edit',
                                                      centers[currentIndex].id,
                                                      plan['id'],
                                                      null,
                                                    ),
                                                  ),
                                                ).then((value) {
                                                  _fetchData();
                                                });
                                              },
                                              icon: Icon(Icons.edit,
                                                  color: Colors.black),
                                            ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewPlan(
                                                    centers[currentIndex].id,
                                                    plan['id'],
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.visibility,
                                                color: Colors.black),
                                          ),
                                          if (MyApp.USER_TYPE_VALUE != 'Parent')
                                            IconButton(
                                              onPressed: () async {
                                                Map<String, String> _objToSend =
                                                    {
                                                  "usertype":
                                                      MyApp.USER_TYPE_VALUE,
                                                  "userid":
                                                      MyApp.LOGIN_ID_VALUE,
                                                  "centerid":
                                                      centers[currentIndex].id,
                                                  "delete_id":
                                                      plan['id'].toString(),
                                                };
                                                ProgramPlanApiHandler
                                                    programPlanApiHandler =
                                                    ProgramPlanApiHandler(
                                                        _objToSend);
                                                await programPlanApiHandler
                                                    .deletePlan()
                                                    .then((value) =>
                                                        _fetchData());
                                              },
                                              icon: Icon(Icons.delete,
                                                  color: Colors.black),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                    ])))));
  }
}

String _getMonthName(String? monthNumber) {
  if (monthNumber == null) return '-';
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  int index = int.tryParse(monthNumber) ?? 0;
  if (index >= 1 && index <= 12) {
    return months[index - 1];
  }
  return '-';
}

String _formatDate(String? dateTimeString) {
  if (dateTimeString == null) return '-';
  try {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  } catch (e) {
    return '-';
  }
}
