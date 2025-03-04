import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/programplanapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/programplans/addplan.dart';
import 'package:mykronicle_mobile/programplans/viewplan.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class PlansList extends StatefulWidget {
  @override
  _PlansListState createState() => _PlansListState();
}

class _PlansListState extends State<PlansList> {
  List<CentersModel> centers;
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
      "usertype": MyApp.USER_TYPE_VALUE,
      "userid": MyApp.LOGIN_ID_VALUE,
      "centerid": centers[currentIndex].id
    };
    ProgramPlanApiHandler planApiHandler = ProgramPlanApiHandler(_objToSend);
    var data = await planApiHandler.getProgramPlanList();
    planList = data['get_program_details'];
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
                         if(MyApp.USER_TYPE_VALUE!='Parent' ) 
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddPlan(
                                          'add',
                                          centers[currentIndex].id,
                                          ''))).then((value) {
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
                                      border:
                                          Border.all(color: Constants.greyColor),
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
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 8),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          planList[index]['startdate'],
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Row(
                                          children: [
                                           if(MyApp.USER_TYPE_VALUE=='Superadmin') 
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => AddPlan(
                                                              'edit',
                                                              centers[currentIndex]
                                                                  .id,
                                                              planList[index][
                                                                  'id']))).then(
                                                      (value) {
                                                    _fetchData();
                                                  });
                                                },
                                                icon: Icon(Icons.edit)),
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ViewPlan(
                                                                  centers[currentIndex]
                                                                      .id,
                                                                  planList[
                                                                          index]
                                                                      ['id'])));
                                                },
                                                icon: Icon(AntDesign.eyeo)),
                                           if(MyApp.USER_TYPE_VALUE!='Parent') 
                                            IconButton(
                                                onPressed: () async {
                                                  Map<String, String>
                                                      _objToSend = {
                                                    "usertype":
                                                        MyApp.USER_TYPE_VALUE,
                                                    "userid":
                                                        MyApp.LOGIN_ID_VALUE,
                                                    "centerid":
                                                        centers[currentIndex]
                                                            .id,
                                                    "delete_id": planList[index]
                                                            ['id']
                                                        .toString(),
                                                  };
                                                  print(_objToSend);
                                                  ProgramPlanApiHandler
                                                      programPlanApiHandler =
                                                      ProgramPlanApiHandler(
                                                          _objToSend);
                                                  await programPlanApiHandler
                                                      .deletePlan()
                                                      .then((value) =>
                                                          _fetchData());
                                                },
                                                icon: Icon(AntDesign.delete)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })
                    ])))));
  }
}
