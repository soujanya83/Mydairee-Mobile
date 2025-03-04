import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mykronicle_mobile/api/lessonplanapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/lessonmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/downloader.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class LessonPlan extends StatefulWidget {
  @override
  _LessonPlanState createState() => _LessonPlanState();
}

class _LessonPlanState extends State<LessonPlan> {
  bool dataFetched = false;
  List<LessonChildSubModel> child =[];
  List<CentersModel> centers=[];
  bool centersFetched = false;
  int currentIndex = 0;
  String dirloc = '';

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _fetchCenters();
    _downloadListener();
  }

  _downloadListener() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (status.toString() == "DownloadTaskStatus(3)" &&
          progress == 100 &&
          id != null) {
        String query = "SELECT * FROM task WHERE task_id='" + id + "'";
        var tasks = FlutterDownloader.loadTasksWithRawQuery(query: query);
        //if the task exists, open it
        if (tasks != null) FlutterDownloader.open(taskId: id);
      }
    });
    FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
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
    _load();
  }

  void _load() async {
    LessonPlanApiHandler progressPlan = LessonPlanApiHandler({
      "usertype": MyApp.USER_TYPE_VALUE,
      "userid": MyApp.LOGIN_ID_VALUE,
      "centerid": centers[currentIndex].id
    });
    var data = await progressPlan.getLessonPlan();
    child = [];
    if (!data.containsKey('error')) {
      var processData = data['new_process'];
      for (var i = 0; i < processData.length; i++) {
        LessonChildSubModel subModel =
            LessonChildSubModel.fromJson(processData[i]);
        List<LessonChildProcessModel> list = [];
        for (int j = 0; j < processData[i]['child_process'].length; j++) {
          list.add(LessonChildProcessModel.fromJson(
              processData[i]['child_process'][j]));
        }
        subModel.lessonProcess = list;
        child.add(subModel);
      }
    }

    dataFetched = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floating(context),
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Montessori Lesson Plan',
                        style: Constants.header1,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            var obj = {
                              "usertype": MyApp.USER_TYPE_VALUE,
                              "userid": MyApp.LOGIN_ID_VALUE,
                              "centerid": centers[currentIndex].id,
                            };
                            LessonPlanApiHandler handler =
                                LessonPlanApiHandler(obj);
                            var data = await handler.printPlan();
                            print(data);
                            if (!data.containsKey('error')) {
                              downloadFile(data['path'] + data['file'],
                                  data['file'], context);
                            } else {
                              print('failed');
                            }
                          },
                          child: Text("Print"))
                    ],
                  )),
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
                    )
                  : Container(),
              dataFetched
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: child.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(child[index].childName),
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        child[index].lessonProcess.length,
                                    itemBuilder: (context, i) {
                                      return ListTile(
                                        leading: Checkbox(
                                          value: false,
                                          onChanged: (val) async {
                                            var obj = {
                                              "usertype": MyApp.USER_TYPE_VALUE,
                                              "userid": MyApp.LOGIN_ID_VALUE,
                                              // "created_by":
                                              //     MyApp.LOGIN_ID_VALUE,
                                              "centerid":
                                                  centers[currentIndex].id,
                                              "status": "Introduced",
                                              "childid": child[index].childId,
                                              "activityid": child[index]
                                                  .lessonProcess[i]
                                                  .activity,
                                              "subid": child[index]
                                                  .lessonProcess[i]
                                                  .subactivity,
                                              "updated_by":
                                                  MyApp.LOGIN_ID_VALUE,
                                              "updated_at":
                                                  DateTime.now().toString()
                                            };
                                            LessonPlanApiHandler handler =
                                                LessonPlanApiHandler(obj);
                                            var data = await handler.setPlan();
                                            print(data);
                                            _load();
                                          },
                                        ),
                                        title: Text(child[index]
                                            .lessonProcess[i]
                                            .subTitle),
                                      );
                                    })
                              ],
                            ),
                          ),
                        );
                      })
                  : Container()
            ],
          ),
        ),
      )),
    );
  }
}
