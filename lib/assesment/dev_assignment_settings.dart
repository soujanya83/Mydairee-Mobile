import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/devassignmentsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/devmilestonemodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:http/http.dart' as http;

class DevAssignmentSettings extends StatefulWidget {
  @override
  _DevAssignmentSettingsState createState() => _DevAssignmentSettingsState();
}

class _DevAssignmentSettingsState extends State<DevAssignmentSettings>
    with TickerProviderStateMixin {
  TabController? _controller;

  List<DevMilestoneModel>? devData;

  List<CentersModel>? centers;
  bool centersFetched = false;
  int currentIndex = 0;

  @override
  void initState() {
    _controller = new TabController(length: 5, vsync: this);
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
          centers?.add(CentersModel.fromJson(res[i]));
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

  Future<void> _fetchData() async {
    DevAssignAPIHandler hlr = DevAssignAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers?[currentIndex].id??''});
    var dt = await hlr.getData();
    if (!dt.containsKey('error')) {
      print(dt);
      var dData = dt['Milestones'];
      devData = [];
      if (dData != null) {
        for (int a = 0; a < dData.length; a++) {
          DevMilestoneModel devModel = DevMilestoneModel.fromJson(dData[a]);

          List<MainModel> mainModelList = [];
          for (int b = 0; b < dData[a]['activities'].length; b++) {
            MainModel mainModel = MainModel.fromJson(dData[a]['activities'][b]);
            List<SubjectModel> subjects = [];
            if (dData[a]['activities'][b]['subactivity'] != null) {
              for (int c = 0;
                  c < dData[a]['activities'][b]['subactivity'].length;
                  c++) {
                //
                subjects.add(SubjectModel.fromJson(
                    dData[a]['activities'][b]['subactivity'][c]));
                List<MilestoneExtrasModel> milestoneExtrasModel = [];

                if (dData[a]['activities'][b]['subactivity'][c]['extras'] !=
                    null) {
                  for (int d = 0;
                      d <
                          dData[a]['activities'][b]['subactivity'][c]['extras']
                              .length;
                      d++) {
                    print('teurg ' +
                        d.toString() +
                        dData[a]['activities'][b]['subactivity'][c]['extras'][d]
                            .toString());
                    milestoneExtrasModel.add(MilestoneExtrasModel.fromJson(
                        dData[a]['activities'][b]['subactivity'][c]['extras']
                            [d]));
                  }
                }

                subjects[c].extras = milestoneExtrasModel;
                //
              }
            }
            mainModel.subjects = subjects;
            mainModelList.add(mainModel);
          }
          devModel.main = mainModelList;
          devData?.add(devModel);
        }
      }
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assesment Settings',
                  style: Constants.header1,
                ),
                SizedBox(
                  height: 12,
                ),
                if (centersFetched)
                  DropdownButtonHideUnderline(
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Constants.greyColor),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Center(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: centers?[currentIndex].id??'',
                            items: centers?.map((CentersModel value) {
                              return new DropdownMenuItem<String>(
                                value: value.id??'',
                                child: new Text(value.centerName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              for (int i = 0; i < (centers?.length??0); i++) {
                                if ((centers?[i].id??'') == value) {
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
                new Container(
                  // decoration: new BoxDecoration(color: Theme.of(context).primaryColor),
                  child: new TabBar(
                    controller: _controller,
                    labelColor: Constants.kMain,
                    isScrollable: true,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      new Tab(
                        text: 'Birth To 4 Months',
                      ),
                      new Tab(
                        text: '4 to 8 Months',
                      ),
                      new Tab(
                        text: '8 to 12 Months',
                      ),
                      new Tab(
                        text: '1 to 2 Years',
                      ),
                      new Tab(
                        text: '3 to 5 Years',
                      ),
                    ],
                  ),
                ),
                if (devData != null) 
                  new Container(
                      height: MediaQuery.of(context).size.height - 230,
                      child: new TabBarView(
                          controller: _controller,
                          children: List.generate(
                              5,
                              (index) => SingleChildScrollView(
                                      child: Container(
                                          child: Column(children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0),
                                            child: Container(
                                              width: 200,
                                              child: Text(
                                                devData?[index].ageGroup??"",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              TextEditingController controller =
                                                  TextEditingController();
                                              showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              "Add New Activity"),
                                                          content:
                                                              SingleChildScrollView(
                                                            child: Container(
                                                              height: 120,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                              child: ListView(
                                                                children: [
                                                                  Text(
                                                                    'Title',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  TextField(
                                                                    controller:
                                                                        controller,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      enabledBorder:
                                                                          const OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color:
                                                                                Colors.black26,
                                                                            width: 0.0),
                                                                      ),
                                                                      border:
                                                                          new OutlineInputBorder(
                                                                        borderRadius:
                                                                            const BorderRadius.all(
                                                                          const Radius.circular(
                                                                              4),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                if (controller
                                                                        .text !=
                                                                    '') {
                                                                  print(
                                                                      controller
                                                                          .text);

                                                                  DevAssignAPIHandler
                                                                      assesmentEylfAPIHandler =
                                                                      DevAssignAPIHandler({
                                                                    "milestone":
                                                                        devData?[index]
                                                                            .id??'',
                                                                    "activity":
                                                                        "",
                                                                    "centerid":
                                                                        centers?[currentIndex]
                                                                            .id??''??'',
                                                                    "title":
                                                                        controller
                                                                            .text,
                                                                    "userid": MyApp
                                                                        .LOGIN_ID_VALUE
                                                                  });
                                                                  var data =
                                                                      await assesmentEylfAPIHandler
                                                                          .savDevAct();
                                                                  if (data[
                                                                          'Status'] ==
                                                                      'SUCCESS') {
                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                } else {
                                                                  MyApp.ShowToast(
                                                                      'Title should not be empty',
                                                                      context);
                                                                }
                                                              },
                                                              child: Text(
                                                                'ok',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      })
                                                  .then(
                                                      (value) => _fetchData());
                                            },
                                            child: Text('+ Add Activity'))
                                      ],
                                    ),
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: devData?[index].main.length,
                                        itemBuilder: (context, i) {
                                          return Card(
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Transform.translate(
                                                    offset: Offset(-20, 0),
                                                    child: ListTile(
                                                      leading: Checkbox(
                                                        value: devData?[index]
                                                                .main[i]
                                                                .checked ==
                                                            'checked',
                                                        onChanged: (val) {
                                                          if(val==null)return;
                                                          if (val) {
                                                            devData?[index]
                                                                    .main[i]
                                                                    .checked =
                                                                'checked';
                                                          } else {
                                                            devData?[index]
                                                                .main[i]
                                                                .checked = '';
                                                          }
                                                          setState(() {});
                                                        },
                                                      ),
                                                      title:
                                                          Transform.translate(
                                                        offset: Offset(-10, 0),
                                                        child: Text(
                                                            devData?[index]
                                                                .main[i]
                                                                .name??''),
                                                      ),
                                                      trailing:
                                                          MyApp.LOGIN_ID_VALUE ==
                                                                  devData?[index]
                                                                      .main[i]
                                                                      .addedBy
                                                              ? Container(
                                                                  width: 75,
                                                                  child: Row(
                                                                    children: [
                                                                      GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            TextEditingController
                                                                                titleController =
                                                                                TextEditingController();

                                                                            TextEditingController
                                                                                subController =
                                                                                TextEditingController();
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    title: Text("Add Sub Activity"),
                                                                                    content: SingleChildScrollView(
                                                                                      child: Container(
                                                                                        height: 220,
                                                                                        width: MediaQuery.of(context).size.width * 0.7,
                                                                                        child: ListView(
                                                                                          children: [
                                                                                            Text(
                                                                                              'Title',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 15,
                                                                                            ),
                                                                                            TextField(
                                                                                              controller: titleController,
                                                                                              decoration: InputDecoration(
                                                                                                enabledBorder: const OutlineInputBorder(
                                                                                                  borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                                ),
                                                                                                border: new OutlineInputBorder(
                                                                                                  borderRadius: const BorderRadius.all(
                                                                                                    const Radius.circular(4),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 15,
                                                                                            ),
                                                                                            Text(
                                                                                              'Subject',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 15,
                                                                                            ),
                                                                                            TextField(
                                                                                              maxLines: 2,
                                                                                              controller: subController,
                                                                                              decoration: InputDecoration(
                                                                                                enabledBorder: const OutlineInputBorder(
                                                                                                  borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                                ),
                                                                                                border: new OutlineInputBorder(
                                                                                                  borderRadius: const BorderRadius.all(
                                                                                                    const Radius.circular(4),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    actions: <Widget>[
                                                                                      TextButton(
                                                                                        onPressed: () async {
                                                                                          if (titleController.text != '' && subController.text != '') {
                                                                                            DevAssignAPIHandler assesmentAPIHandler = DevAssignAPIHandler({
                                                                                              "activity": devData?[index].main[i].id??'',
                                                                                              "subactivity": "",
                                                                                              "centerid": centers?[currentIndex].id??'',
                                                                                              "title": titleController.text,
                                                                                              "subject": subController.text,
                                                                                              "userid": MyApp.LOGIN_ID_VALUE
                                                                                            });
                                                                                            var data = await assesmentAPIHandler.savDevSubAct();
                                                                                            if (data['Status'] == 'SUCCESS') {
                                                                                              Navigator.pop(context);
                                                                                            } else {
                                                                                              MyApp.ShowToast('Some issue occured please try after some time', context);
                                                                                            }
                                                                                          } else {
                                                                                            MyApp.ShowToast('Enter all fields', context);
                                                                                          }
                                                                                        },
                                                                                        child: Text(
                                                                                          'ok',
                                                                                          style: TextStyle(fontSize: 18),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                }).then((value) => _fetchData());
                                                                          },
                                                                          child:
                                                                              Icon(Icons.add)),
                                                                      GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            TextEditingController
                                                                                controller =
                                                                                TextEditingController(text: devData?[index].main[i].name);
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    title: Text("Edit Activity"),
                                                                                    content: SingleChildScrollView(
                                                                                      child: Container(
                                                                                        height: 120,
                                                                                        width: MediaQuery.of(context).size.width * 0.7,
                                                                                        child: ListView(
                                                                                          children: [
                                                                                            Text(
                                                                                              'Title',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 15,
                                                                                            ),
                                                                                            TextField(
                                                                                              controller: controller,
                                                                                              decoration: InputDecoration(
                                                                                                enabledBorder: const OutlineInputBorder(
                                                                                                  borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                                ),
                                                                                                border: new OutlineInputBorder(
                                                                                                  borderRadius: const BorderRadius.all(
                                                                                                    const Radius.circular(4),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    actions: <Widget>[
                                                                                      TextButton(
                                                                                        onPressed: () async {
                                                                                          if (controller.text != '') {
                                                                                            print(controller.text);

                                                                                            DevAssignAPIHandler assesmentEylfAPIHandler = DevAssignAPIHandler({
                                                                                              "milestone": devData?[index].id??'',
                                                                                              "activity": devData?[index].main[i].id??'',
                                                                                              "centerid": centers?[currentIndex].id??'',
                                                                                              "title": controller.text,
                                                                                              "userid": MyApp.LOGIN_ID_VALUE
                                                                                            });
                                                                                            var data = await assesmentEylfAPIHandler.savDevAct();
                                                                                            if (data['Status'] == 'SUCCESS') {
                                                                                              Navigator.pop(context);
                                                                                            } else {
                                                                                              MyApp.ShowToast('Some issue occured please try after some time', context);
                                                                                            }
                                                                                          } else {
                                                                                            MyApp.ShowToast('Title should not be empty', context);
                                                                                          }
                                                                                        },
                                                                                        child: Text(
                                                                                          'ok',
                                                                                          style: TextStyle(fontSize: 18),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                }).then((value) => _fetchData());
                                                                          },
                                                                          child:
                                                                              Icon(Icons.edit)),
                                                                      GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            DevAssignAPIHandler
                                                                                assignmentEylfAPIHandler =
                                                                                DevAssignAPIHandler({
                                                                              "id": devData?[index].main[i].id??'',
                                                                              "centerid": centers?[currentIndex].id??'',
                                                                              "userid": MyApp.LOGIN_ID_VALUE
                                                                            });
                                                                            var data =
                                                                                await assignmentEylfAPIHandler.delDevAct();
                                                                            if (data['Status'] ==
                                                                                'SUCCESS') {
                                                                              MyApp.ShowToast('Successfully Deleted', context);
                                                                              _fetchData();
                                                                            }
                                                                          },
                                                                          child:
                                                                              Icon(Icons.delete)),
                                                                    ],
                                                                  ),
                                                                )
                                                              : null,
                                                    ),
                                                  ),
                                                  ListView.builder(
                                                      itemCount: devData?[index]
                                                          .main[i]
                                                          .subjects
                                                          .length,
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, j) {
                                                        return Column(
                                                          children: [
                                                            ListTile(
                                                              title: Text(
                                                                  devData?[index]
                                                                      .main[i]
                                                                      .subjects[
                                                                          j]
                                                                      .name??""),
                                                              leading: Checkbox(
                                                                value: devData?[
                                                                            index]
                                                                        .main[i]
                                                                        .subjects[
                                                                            j]
                                                                        .checked ==
                                                                    'checked',
                                                                onChanged:
                                                                    (val) {
                                                                      if(val==null)return;
                                                                  if (val) {
                                                                    
                                                                    devData?[index]
                                                                        .main[i]
                                                                        .subjects[
                                                                            j]
                                                                        .checked = 'checked';
                                                                  } else {
                                                                    devData?[index]
                                                                        .main[i]
                                                                        .subjects[
                                                                            j]
                                                                        .checked = '';
                                                                  }
                                                                  setState(
                                                                      () {});
                                                                },
                                                              ),
                                                              trailing:
                                                                  Container(
                                                                width: 75,
                                                                child: devData?[index]
                                                                            .main[
                                                                                i]
                                                                            .subjects[
                                                                                j]
                                                                            .addedBy ==
                                                                        MyApp
                                                                            .LOGIN_ID_VALUE
                                                                    ? Row(
                                                                        children: [
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              TextEditingController controller = TextEditingController();
                                                                              showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return AlertDialog(
                                                                                      title: Text("Add Extra"),
                                                                                      content: SingleChildScrollView(
                                                                                        child: Container(
                                                                                          height: 120,
                                                                                          width: MediaQuery.of(context).size.width * 0.7,
                                                                                          child: ListView(
                                                                                            children: [
                                                                                              Text(
                                                                                                'Title',
                                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: 15,
                                                                                              ),
                                                                                              TextField(
                                                                                                controller: controller,
                                                                                                decoration: InputDecoration(
                                                                                                  enabledBorder: const OutlineInputBorder(
                                                                                                    borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                                  ),
                                                                                                  border: new OutlineInputBorder(
                                                                                                    borderRadius: const BorderRadius.all(
                                                                                                      const Radius.circular(4),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      actions: <Widget>[
                                                                                        TextButton(
                                                                                          onPressed: () async {
                                                                                            if (controller.text != '') {
                                                                                              print(controller.text);

                                                                                              DevAssignAPIHandler assesmentAPIHandler = DevAssignAPIHandler({
                                                                                                "extra": "",
                                                                                                "subactivity": devData?[index].main[i].subjects[j].id??'',
                                                                                                "centerid": centers?[currentIndex].id??'',
                                                                                                "title": controller.text,
                                                                                                "userid": MyApp.LOGIN_ID_VALUE
                                                                                              });
                                                                                              var data = await assesmentAPIHandler.savDevExtra();
                                                                                              if (data['Status'] == 'SUCCESS') {
                                                                                                Navigator.pop(context);
                                                                                              } else {
                                                                                                MyApp.ShowToast('Some issue occured please try after some time', context);
                                                                                              }
                                                                                            } else {
                                                                                              MyApp.ShowToast('Title should not be empty', context);
                                                                                            }
                                                                                          },
                                                                                          child: Text(
                                                                                            'ok',
                                                                                            style: TextStyle(fontSize: 18),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  }).then((value) => _fetchData());
                                                                            },
                                                                            child:
                                                                                Icon(Icons.add),
                                                                          ),
                                                                          GestureDetector(
                                                                              onTap: () async {
                                                                                TextEditingController titleController = TextEditingController(text: devData?[index].main[i].subjects[j].name);

                                                                                TextEditingController subController = TextEditingController(text: devData?[index].main[i].subjects[j].subject);
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        title: Text("Edit Sub Activity"),
                                                                                        content: SingleChildScrollView(
                                                                                          child: Container(
                                                                                            height: 220,
                                                                                            width: MediaQuery.of(context).size.width * 0.7,
                                                                                            child: ListView(
                                                                                              children: [
                                                                                                Text(
                                                                                                  'Title',
                                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height: 15,
                                                                                                ),
                                                                                                TextField(
                                                                                                  controller: titleController,
                                                                                                  decoration: InputDecoration(
                                                                                                    enabledBorder: const OutlineInputBorder(
                                                                                                      borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                                    ),
                                                                                                    border: new OutlineInputBorder(
                                                                                                      borderRadius: const BorderRadius.all(
                                                                                                        const Radius.circular(4),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height: 15,
                                                                                                ),
                                                                                                Text(
                                                                                                  'Subject',
                                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height: 15,
                                                                                                ),
                                                                                                TextField(
                                                                                                  maxLines: 2,
                                                                                                  controller: subController,
                                                                                                  decoration: InputDecoration(
                                                                                                    enabledBorder: const OutlineInputBorder(
                                                                                                      borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                                    ),
                                                                                                    border: new OutlineInputBorder(
                                                                                                      borderRadius: const BorderRadius.all(
                                                                                                        const Radius.circular(4),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        actions: <Widget>[
                                                                                          TextButton(
                                                                                            onPressed: () async {
                                                                                              if (titleController.text != '' && subController.text != '') {
                                                                                                DevAssignAPIHandler assesmentAPIHandler = DevAssignAPIHandler({
                                                                                                  "activity": devData?[index].main[i].id??'',
                                                                                                  "subactivity": devData?[index].main[i].subjects[j].id??'',
                                                                                                  "centerid": centers?[currentIndex].id??'',
                                                                                                  "title": titleController.text,
                                                                                                  "subject": subController.text,
                                                                                                  "userid": MyApp.LOGIN_ID_VALUE
                                                                                                });
                                                                                                var data = await assesmentAPIHandler.savDevSubAct();
                                                                                                if (data['Status'] == 'SUCCESS') {
                                                                                                  Navigator.pop(context);
                                                                                                } else {
                                                                                                  MyApp.ShowToast('Some issue occured please try after some time', context);
                                                                                                }
                                                                                              } else {
                                                                                                MyApp.ShowToast('Enter all fields', context);
                                                                                              }
                                                                                            },
                                                                                            child: Text(
                                                                                              'ok',
                                                                                              style: TextStyle(fontSize: 18),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    }).then((value) => _fetchData());
                                                                              },
                                                                              child: Icon(Icons.edit)),
                                                                          GestureDetector(
                                                                              onTap: () async {
                                                                                DevAssignAPIHandler assignmentEylfAPIHandler = DevAssignAPIHandler({
                                                                                  "id": devData?[index].main[i].subjects[j].id??'',
                                                                                  "centerid": centers?[currentIndex].id??'',
                                                                                  "userid": MyApp.LOGIN_ID_VALUE
                                                                                });
                                                                                var data = await assignmentEylfAPIHandler.delDevSubAct();
                                                                                if (data['Status'] == 'SUCCESS') {
                                                                                  MyApp.ShowToast('Successfully Deleted', context);
                                                                                  _fetchData();
                                                                                }
                                                                              },
                                                                              child: Icon(Icons.delete))
                                                                        ],
                                                                      )
                                                                    : null,
                                                              ),
                                                            ),
                                                            ListView.builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount: devData?[
                                                                        index]
                                                                    .main[i]
                                                                    .subjects[j]
                                                                    .extras
                                                                    .length,
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                itemBuilder:
                                                                    (context,
                                                                        k) {
                                                                  return Transform
                                                                      .translate(
                                                                    offset:
                                                                        Offset(
                                                                            15,
                                                                            0),
                                                                    child:
                                                                        ListTile(
                                                                      trailing:
                                                                          Container(
                                                                        width:
                                                                            60,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                TextEditingController controller = TextEditingController(text: devData?[index].main[i].subjects[j].extras[k].title);
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        title: Text("Edit Extra"),
                                                                                        content: SingleChildScrollView(
                                                                                          child: Container(
                                                                                            height: 120,
                                                                                            width: MediaQuery.of(context).size.width * 0.7,
                                                                                            child: ListView(
                                                                                              children: [
                                                                                                Text(
                                                                                                  'Title',
                                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height: 15,
                                                                                                ),
                                                                                                TextField(
                                                                                                  controller: controller,
                                                                                                  decoration: InputDecoration(
                                                                                                    enabledBorder: const OutlineInputBorder(
                                                                                                      borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                                    ),
                                                                                                    border: new OutlineInputBorder(
                                                                                                      borderRadius: const BorderRadius.all(
                                                                                                        const Radius.circular(4),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        actions: <Widget>[
                                                                                          TextButton(
                                                                                            onPressed: () async {
                                                                                              if (controller.text != '') {
                                                                                                print(controller.text);

                                                                                                DevAssignAPIHandler assesmentAPIHandler = DevAssignAPIHandler({
                                                                                                  "extra": devData?[index].main[i].subjects[j].extras[k].id??'',
                                                                                                  "subactivity": devData?[index].main[i].subjects[j].id??'',
                                                                                                  "centerid": centers?[currentIndex].id??'',
                                                                                                  "title": controller.text,
                                                                                                  "userid": MyApp.LOGIN_ID_VALUE
                                                                                                });
                                                                                                var data = await assesmentAPIHandler.savDevExtra();
                                                                                                if (data['Status'] == 'SUCCESS') {
                                                                                                  Navigator.pop(context);
                                                                                                } else {
                                                                                                  MyApp.ShowToast('Some issue occured please try after some time', context);
                                                                                                }
                                                                                              } else {
                                                                                                MyApp.ShowToast('Title should not be empty', context);
                                                                                              }
                                                                                            },
                                                                                            child: Text(
                                                                                              'ok',
                                                                                              style: TextStyle(fontSize: 18),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    }).then((value) => _fetchData());
                                                                              },
                                                                              child: Icon(Icons.edit),
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () async {
                                                                                DevAssignAPIHandler assesmentAPIHandler = DevAssignAPIHandler({
                                                                                  "id": devData?[index].main[i].subjects[j].extras[k].id??'',
                                                                                  "centerid": centers?[currentIndex].id??'',
                                                                                  "userid": MyApp.LOGIN_ID_VALUE
                                                                                });
                                                                                var data = await assesmentAPIHandler.delDevExtra();

                                                                                if (data['Status'] == 'SUCCESS') {
                                                                                  _fetchData();
                                                                                  MyApp.ShowToast('Deleted Successfully', context);
                                                                                }
                                                                              },
                                                                              child: Icon(Icons.delete),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      leading:
                                                                          Checkbox(
                                                                        value: devData?[index].main[i].subjects[j].extras[k].checked ==
                                                                            'checked',
                                                                        onChanged:
                                                                            (val) {
                                                                        if(val==null)
                                                                        return;
                                                                          if (val) {
                                                                            devData?[index].main[i].subjects[j].extras[k].checked =
                                                                                'checked';
                                                                          } else {
                                                                            devData?[index].main[i].subjects[j].extras[k].checked =
                                                                                '';
                                                                          }
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                      title: Transform
                                                                          .translate(
                                                                        offset: Offset(
                                                                            -10,
                                                                            0),
                                                                        child: Text(devData?[index]
                                                                            .main[i]
                                                                            .subjects[j]
                                                                            .extras[k]
                                                                            .title??''),
                                                                      ),
                                                                    ),
                                                                  );
                                                                })
                                                          ],
                                                        );
                                                      })
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              List ids = [];
                                              List subIds = [];
                                              List extraIds = [];
                                              for (int i = 0;
                                                  i <
                                                      (devData?[index]
                                                          .main
                                                          .length??0);
                                                  i++) {
                                                if (devData?[index]
                                                        .main[i]
                                                        .checked ==
                                                    'checked') {
                                                  ids.add(devData?[index]
                                                      .main[i]
                                                      .id??'');
                                                }

                                                for (int j = 0;
                                                    j <
                                                        (devData?[index]
                                                            .main[i]
                                                            .subjects
                                                            .length??0);
                                                    j++) {
                                                  if (devData?[index]
                                                          .main[i]
                                                          .subjects[j]
                                                          .checked ==
                                                      'checked') {
                                                    subIds.add(devData?[index]
                                                        .main[i]
                                                        .subjects[j]
                                                        .id??'');
                                                  }

                                                  for (int k = 0;
                                                      k <
                                                          (devData?[index]
                                                              .main[i]
                                                              .subjects[j]
                                                              .extras
                                                              .length??0);
                                                      k++) {
                                                    if (devData?[index]
                                                            .main[i]
                                                            .subjects[j]
                                                            .extras[k]
                                                            .checked ==
                                                        'checked') {
                                                      extraIds.add(
                                                          devData?[index]
                                                              .main[i]
                                                              .subjects[j]
                                                              .extras[k]
                                                              .id??'');
                                                    }
                                                  }
                                                }
                                              }
                                              var objToSend = {
                                                "centerid":
                                                    centers?[currentIndex].id??'',
                                                "activity": ids,
                                                "subactivity": subIds,
                                                "extras": extraIds,
                                                "userid": MyApp.LOGIN_ID_VALUE
                                              };

                                              var _toSend = Constants.BASE_URL +
                                                  'Settings/saveDevMileList';
                                              print(jsonEncode(objToSend));
                                              final response = await http.post(
                                                  Uri.parse(_toSend),
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

                                                Navigator.pop(context);
                                              } else if (response.statusCode ==
                                                  401) {
                                                MyApp.Show401Dialog(context);
                                              }
                                            },
                                            child: Text("Save"))
                                      ],
                                    )
                                  ]))))))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
