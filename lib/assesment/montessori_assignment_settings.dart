import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/assesmentsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/extrasmodel.dart';
import 'package:mykronicle_mobile/models/montessorimodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:http/http.dart' as http;

class MontessoriAssignmentSettings extends StatefulWidget {
  @override
  _MontessoriAssignmentSettingsState createState() =>
      _MontessoriAssignmentSettingsState();
}

class _MontessoriAssignmentSettingsState
    extends State<MontessoriAssignmentSettings> with TickerProviderStateMixin {
  TabController _controller;

  List<MontessoriModel> montessoriData;

  List<CentersModel> centers;
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

  Future<void> _fetchData() async {
    AssesmentAPIHandler hlr = AssesmentAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var dt = await hlr.getMontessori();
    if (!dt.containsKey('error')) {
      print(dt);
      var montData = dt['Subjects'];
      montessoriData = [];
      if (montData != null) {
        for (int a = 0; a < montData.length; a++) {
          MontessoriModel montessoriModel =
              MontessoriModel.fromJson(montData[a]);
          List<MontessoriActivityModel> activityModel = [];
          for (int b = 0; b < montData[a]['activities'].length; b++) {
            MontessoriActivityModel act =
                MontessoriActivityModel.fromJson(montData[a]['activities'][b]);
            List<MontessoriSubActivityModel> subActivityModel = [];
            for (int c = 0;
                c < montData[a]['activities'][b]['subactivity'].length;
                c++) {
              MontessoriSubActivityModel subAct =
                  MontessoriSubActivityModel.fromJson(
                      montData[a]['activities'][b]['subactivity'][c]);
              List<ExtrasModel> extrasModel = [];
              for (int d = 0;
                  d <
                      montData[a]['activities'][b]['subactivity'][c]['extras']
                          .length;
                  d++) {
                extrasModel.add(ExtrasModel.fromJson(montData[a]['activities']
                    [b]['subactivity'][c]['extras'][d]));
              }
              subAct.extrasModel = extrasModel;
              subActivityModel.add(subAct);
            }
            act.subActivity = subActivityModel;
            activityModel.add(act);
          }
          montessoriModel.activity = activityModel;
          montessoriData.add(montessoriModel);
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
                        border: Border.all(color: Colors.grey[300]),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
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
                      text: 'Practical Life',
                    ),
                    new Tab(
                      text: 'Sensorial',
                    ),
                    new Tab(
                      text: 'Language',
                    ),
                    new Tab(
                      text: 'Maths',
                    ),
                    new Tab(
                      text: 'Cultural',
                    ),
                  ],
                ),
              ),
              if (montessoriData != null)
                new Container(
                    height: MediaQuery.of(context).size.height - 210,
                    child: new TabBarView(
                        controller: _controller,
                        children: List.generate(
                            5,
                            (index) => SingleChildScrollView(
                                    child: Container(
                                        child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            montessoriData[index].name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
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
                                                              height:
                                                                  //  MediaQuery.of(
                                                                  //             context)
                                                                  //         .size
                                                                  //         .height *
                                                                  120,
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

                                                                  AssesmentAPIHandler
                                                                      assesmentAPIHandler =
                                                                      AssesmentAPIHandler({
                                                                    "subject": montessoriData[
                                                                            index]
                                                                        .idSubject,
                                                                    "activity":
                                                                        "",
                                                                    "centerid":
                                                                        centers[currentIndex]
                                                                            .id,
                                                                    "title":
                                                                        controller
                                                                            .text,
                                                                    "userid": MyApp
                                                                        .LOGIN_ID_VALUE
                                                                  });
                                                                  var data =
                                                                      await assesmentAPIHandler
                                                                          .saveMontessoriActivity();
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
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: montessoriData[index]
                                            .activity
                                            .length,
                                        itemBuilder: (context, i) {
                                          return Card(
                                              child: Column(
                                            children: [
                                              ListTile(
                                                leading: Transform.translate(
                                                  offset: Offset(-10, 0),
                                                  child: Checkbox(
                                                    value: montessoriData[index]
                                                            .activity[i]
                                                            .checked ==
                                                        'checked',
                                                    onChanged: (val) {
                                                      if (val) {
                                                        montessoriData[index]
                                                                .activity[i]
                                                                .checked =
                                                            'checked';
                                                      } else {
                                                        montessoriData[index]
                                                            .activity[i]
                                                            .checked = '';
                                                      }
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                                title: Transform.translate(
                                                  offset: Offset(-20, 0),
                                                  child: Text(
                                                      montessoriData[index]
                                                          .activity[i]
                                                          .title),
                                                ),
                                                trailing:
                                                    MyApp.LOGIN_ID_VALUE ==
                                                            montessoriData[
                                                                    index]
                                                                .activity[i]
                                                                .addedBy
                                                        ? Container(
                                                            width: 75,
                                                            child: Row(
                                                              children: [
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      TextEditingController
                                                                          titleController =
                                                                          TextEditingController();

                                                                      TextEditingController
                                                                          subController =
                                                                          TextEditingController();
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
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
                                                                                      AssesmentAPIHandler assesmentAPIHandler = AssesmentAPIHandler({
                                                                                        "subactivity": "",
                                                                                        "activity": montessoriData[index].activity[i].idActivity,
                                                                                        "centerid": centers[currentIndex].id,
                                                                                        "title": titleController.text,
                                                                                        "subject": subController.text,
                                                                                        "userid": MyApp.LOGIN_ID_VALUE
                                                                                      });
                                                                                      var data = await assesmentAPIHandler.saveMontessoriSubActivity();
                                                                                      if (data['Status'] == 'SUCCESS') {
                                                                                        Navigator.pop(context);
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
                                                                    child: Icon(
                                                                        Icons
                                                                            .add)),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    TextEditingController
                                                                        controller =
                                                                        TextEditingController(
                                                                            text:
                                                                                montessoriData[index].activity[i].title);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Edit Activity"),
                                                                            content:
                                                                                SingleChildScrollView(
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
                                                                                    AssesmentAPIHandler assesmentAPIHandler = AssesmentAPIHandler({
                                                                                      "subject": montessoriData[index].idSubject,
                                                                                      "activity": montessoriData[index].activity[i].idActivity,
                                                                                      "centerid": centers[currentIndex].id,
                                                                                      "title": controller.text,
                                                                                      "userid": MyApp.LOGIN_ID_VALUE
                                                                                    });
                                                                                    var data = await assesmentAPIHandler.saveMontessoriActivity();
                                                                                    if (data['Status'] == 'SUCCESS') {
                                                                                      Navigator.pop(context);
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
                                                                  child: Icon(
                                                                      Icons
                                                                          .edit),
                                                                ),
                                                                GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      AssesmentAPIHandler
                                                                          assesmentAPIHandler =
                                                                          AssesmentAPIHandler({
                                                                        "id": montessoriData[index]
                                                                            .activity[i]
                                                                            .idActivity,
                                                                        "centerid":
                                                                            centers[currentIndex].id,
                                                                        "userid":
                                                                            MyApp.LOGIN_ID_VALUE
                                                                      });
                                                                      var data =
                                                                          await assesmentAPIHandler
                                                                              .delMontActivity();
                                                                      if (data[
                                                                              'Status'] ==
                                                                          'SUCCESS') {
                                                                        _fetchData();
                                                                      }
                                                                    },
                                                                    child: Icon(
                                                                        Icons
                                                                            .delete))
                                                              ],
                                                            ),
                                                          )
                                                        : null,
                                              ),
                                              ListView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      montessoriData[index]
                                                          .activity[i]
                                                          .subActivity
                                                          .length,
                                                  shrinkWrap: true,
                                                  itemBuilder: (context, j) {
                                                    return Column(
                                                      children: [
                                                        ListTile(
                                                          leading: Checkbox(
                                                            value: montessoriData[
                                                                        index]
                                                                    .activity[i]
                                                                    .subActivity[
                                                                        j]
                                                                    .checked ==
                                                                'checked',
                                                            onChanged: (val) {
                                                              if (val) {
                                                                montessoriData[
                                                                        index]
                                                                    .activity[i]
                                                                    .subActivity[
                                                                        j]
                                                                    .checked = 'checked';
                                                              } else {
                                                                montessoriData[
                                                                        index]
                                                                    .activity[i]
                                                                    .subActivity[
                                                                        j]
                                                                    .checked = '';
                                                              }
                                                              setState(() {});
                                                            },
                                                          ),
                                                          trailing: Container(
                                                            width: 75,
                                                            child: MyApp.LOGIN_ID_VALUE ==
                                                                    montessoriData[
                                                                            index]
                                                                        .activity[
                                                                            i]
                                                                        .subActivity[
                                                                            j]
                                                                        .addedBy
                                                                ? Row(
                                                                    children: [
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          TextEditingController
                                                                              controller =
                                                                              TextEditingController();
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: Text("Add Extra"),
                                                                                  content: SingleChildScrollView(
                                                                                    child: Container(
                                                                                      height:
                                                                                          //  MediaQuery.of(
                                                                                          //             context)
                                                                                          //         .size
                                                                                          //         .height *
                                                                                          120,
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

                                                                                          AssesmentAPIHandler assesmentAPIHandler = AssesmentAPIHandler({
                                                                                            "extra": "",
                                                                                            "subactivity": montessoriData[index].activity[i].subActivity[j].idSubActivity,
                                                                                            "centerid": centers[currentIndex].id,
                                                                                            "title": controller.text,
                                                                                            "userid": MyApp.LOGIN_ID_VALUE
                                                                                          });
                                                                                          var data = await assesmentAPIHandler.saveMontessoriExtras();
                                                                                          if (data['Status'] == 'SUCCESS') {
                                                                                            Navigator.pop(context);
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
                                                                        child: Icon(
                                                                            Icons.add),
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          TextEditingController
                                                                              titleController =
                                                                              TextEditingController(text: montessoriData[index].activity[i].subActivity[j].title);

                                                                          TextEditingController
                                                                              subController =
                                                                              TextEditingController(text: montessoriData[index].activity[i].subActivity[j].subject);
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: Text("Edit Activity"),
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
                                                                                          AssesmentAPIHandler assesmentAPIHandler = AssesmentAPIHandler({
                                                                                            "subactivity": montessoriData[index].activity[i].subActivity[j].idSubActivity,
                                                                                            "activity": montessoriData[index].activity[i].idActivity,
                                                                                            "centerid": centers[currentIndex].id,
                                                                                            "title": titleController.text,
                                                                                            "subject": subController.text,
                                                                                            "userid": MyApp.LOGIN_ID_VALUE
                                                                                          });
                                                                                          var data = await assesmentAPIHandler.saveMontessoriSubActivity();
                                                                                          if (data['Status'] == 'SUCCESS') {
                                                                                            MyApp.ShowToast('Edited Successfully', context);
                                                                                            Navigator.pop(context);
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
                                                                        child: Icon(
                                                                            Icons.edit),
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          AssesmentAPIHandler
                                                                              assesmentAPIHandler =
                                                                              AssesmentAPIHandler({
                                                                            "id":
                                                                                montessoriData[index].activity[i].subActivity[j].idSubActivity,
                                                                            "centerid":
                                                                                centers[currentIndex].id,
                                                                            "userid":
                                                                                MyApp.LOGIN_ID_VALUE
                                                                          });
                                                                          var data =
                                                                              await assesmentAPIHandler.delMontSubActivity();

                                                                          if (data['Status'] ==
                                                                              'SUCCESS') {
                                                                            _fetchData();
                                                                            MyApp.ShowToast('Deleted Successfully',
                                                                                context);
                                                                          }
                                                                        },
                                                                        child: Icon(
                                                                            Icons.delete),
                                                                      )
                                                                    ],
                                                                  )
                                                                : null,
                                                          ),
                                                          title: Transform
                                                              .translate(
                                                            offset:
                                                                Offset(-20, 0),
                                                            child: Text(
                                                                montessoriData[
                                                                        index]
                                                                    .activity[i]
                                                                    .subActivity[
                                                                        j]
                                                                    .title),
                                                          ),
                                                        ),
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                montessoriData[
                                                                        index]
                                                                    .activity[i]
                                                                    .subActivity[
                                                                        j]
                                                                    .extrasModel
                                                                    .length,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemBuilder:
                                                                (context, k) {
                                                              return Transform
                                                                  .translate(
                                                                offset: Offset(
                                                                    15, 0),
                                                                child: ListTile(
                                                                  trailing:
                                                                      Container(
                                                                    width: 60,
                                                                    child: Row(
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            TextEditingController
                                                                                controller =
                                                                                TextEditingController(text: montessoriData[index].activity[i].subActivity[j].extrasModel[k].title);
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

                                                                                            AssesmentAPIHandler assesmentAPIHandler = AssesmentAPIHandler({
                                                                                              "extra": montessoriData[index].activity[i].subActivity[j].extrasModel[k].idExtra,
                                                                                              "subactivity": montessoriData[index].activity[i].subActivity[j].idSubActivity,
                                                                                              "centerid": centers[currentIndex].id,
                                                                                              "title": controller.text,
                                                                                              "userid": MyApp.LOGIN_ID_VALUE
                                                                                            });
                                                                                            var data = await assesmentAPIHandler.saveMontessoriExtras();
                                                                                            if (data['Status'] == 'SUCCESS') {
                                                                                              Navigator.pop(context);
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
                                                                              Icon(Icons.edit),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            AssesmentAPIHandler
                                                                                assesmentAPIHandler =
                                                                                AssesmentAPIHandler({
                                                                              "id": montessoriData[index].activity[i].subActivity[j].extrasModel[k].idExtra,
                                                                              "centerid": centers[currentIndex].id,
                                                                              "userid": MyApp.LOGIN_ID_VALUE
                                                                            });
                                                                            var data =
                                                                                await assesmentAPIHandler.delMontExtra();

                                                                            if (data['Status'] ==
                                                                                'SUCCESS') {
                                                                              _fetchData();
                                                                              MyApp.ShowToast('Deleted Successfully', context);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Icon(Icons.delete),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  leading:
                                                                      Checkbox(
                                                                    value: montessoriData[index]
                                                                            .activity[i]
                                                                            .subActivity[j]
                                                                            .extrasModel[k]
                                                                            .checked ==
                                                                        'checked',
                                                                    onChanged:
                                                                        (val) {
                                                                      if (val) {
                                                                        montessoriData[index]
                                                                            .activity[i]
                                                                            .subActivity[j]
                                                                            .extrasModel[k]
                                                                            .checked = 'checked';
                                                                      } else {
                                                                        montessoriData[index]
                                                                            .activity[i]
                                                                            .subActivity[j]
                                                                            .extrasModel[k]
                                                                            .checked = '';
                                                                      }
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                  title: Transform
                                                                      .translate(
                                                                    offset:
                                                                        Offset(
                                                                            -10,
                                                                            0),
                                                                    child: Text(montessoriData[
                                                                            index]
                                                                        .activity[
                                                                            i]
                                                                        .subActivity[
                                                                            j]
                                                                        .extrasModel[
                                                                            k]
                                                                        .title),
                                                                  ),
                                                                ),
                                                              );
                                                            })
                                                      ],
                                                    );
                                                  }),
                                            ],
                                          ));
                                        }),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    if (montessoriData[index].activity.length >
                                        0)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () async {
                                                List ids = [];
                                                List subIds = [];
                                                List extraIds = [];
                                                for (int i = 0;
                                                    i <
                                                        montessoriData[index]
                                                            .activity
                                                            .length;
                                                    i++) {
                                                  if (montessoriData[index]
                                                          .activity[i]
                                                          .checked ==
                                                      'checked') {
                                                    ids.add(
                                                        montessoriData[index]
                                                            .activity[i]
                                                            .idActivity);
                                                  }

                                                  for (int j = 0;
                                                      j <
                                                          montessoriData[index]
                                                              .activity[i]
                                                              .subActivity
                                                              .length;
                                                      j++) {
                                                    if (montessoriData[index]
                                                            .activity[i]
                                                            .subActivity[j]
                                                            .checked ==
                                                        'checked') {
                                                      subIds.add(
                                                          montessoriData[index]
                                                              .activity[i]
                                                              .subActivity[j]
                                                              .idSubActivity);
                                                    }

                                                    for (int k = 0;
                                                        k <
                                                            montessoriData[
                                                                    index]
                                                                .activity[i]
                                                                .subActivity[j]
                                                                .extrasModel
                                                                .length;
                                                        k++) {
                                                      if (montessoriData[index]
                                                              .activity[i]
                                                              .subActivity[j]
                                                              .extrasModel[k]
                                                              .checked ==
                                                          'checked') {
                                                        extraIds.add(
                                                            montessoriData[
                                                                    index]
                                                                .activity[i]
                                                                .subActivity[j]
                                                                .extrasModel[k]
                                                                .idExtra);
                                                      }
                                                    }
                                                  }
                                                }
                                                var objToSend = {
                                                  "centerid":
                                                      centers[currentIndex].id,
                                                  "activity": ids,
                                                  "subactivity": subIds,
                                                  "extras": extraIds,
                                                  "userid": MyApp.LOGIN_ID_VALUE
                                                };

                                                var _toSend = Constants
                                                        .BASE_URL +
                                                    'Settings/saveMontessoriList';
                                                print(jsonEncode(objToSend));
                                                final response = await http
                                                    .post(_toSend,
                                                        body: jsonEncode(
                                                            objToSend),
                                                        headers: {
                                                      'X-DEVICE-ID': await MyApp
                                                          .getDeviceIdentity(),
                                                      'X-TOKEN': MyApp
                                                          .AUTH_TOKEN_VALUE,
                                                    });
                                                print(response.body);
                                                if (response.statusCode ==
                                                    200) {
                                                  MyApp.ShowToast(
                                                      "updated", context);

                                                  Navigator.pop(context);
                                                } else if (response
                                                        .statusCode ==
                                                    401) {
                                                  MyApp.Show401Dialog(context);
                                                }
                                              },
                                              child: Text('Save'))
                                        ],
                                      )
                                  ],
                                )))))),
            ],
          ),
        ),
      )),
    );
  }
}
