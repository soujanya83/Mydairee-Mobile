import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childsubmodel.dart';
import 'package:mykronicle_mobile/models/devmilestonemodel.dart';
import 'package:mykronicle_mobile/models/eylfmodel.dart';
import 'package:mykronicle_mobile/models/montessorimodel.dart';
import 'package:mykronicle_mobile/models/observationmodel.dart';
import 'package:mykronicle_mobile/observation/addobservation.dart';
import 'package:mykronicle_mobile/observation/childdetails.dart';
import 'package:mykronicle_mobile/observation/obsdata.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:mykronicle_mobile/utils/removeTags.dart';
import 'package:provider/provider.dart';

class ViewObservation extends StatefulWidget {
  final String id;
  final String montCount;
  final String eylfCount;
  final String devCount;
  ViewObservation({ required this.id,required this.montCount,required this.eylfCount,required this.devCount});
  @override
  _ViewObservationState createState() => _ViewObservationState();
}

class _ViewObservationState extends State<ViewObservation> {
  List<ChildSubModel> _allChildrens;
  TextEditingController comment;
  ObservationModel _observation;
  bool obsFetched = false;
  bool expandeylf = false;
  bool expandmontessori = false;
  bool expandmilestones = false;
  var displaydata;
  var displaydata1;
  List media;
  final DateFormat formatter = DateFormat('dd-MM-yyyy – kk:mm');

  List<EylfOutcomeModel> eylfData;
  List<MontessoriModel> montessoriData;
  List<DevMilestoneModel> devData;

  bool childrensFetched = false;
  bool permission = true;

  List<Map<String, dynamic>> mentionUser;
  List<Map<String, dynamic>> mentionMont;
  bool mChildFetched = false;
  bool mMontFetched = false;

  static GlobalKey<FlutterMentionsState> cmntX =
      GlobalKey<FlutterMentionsState>();

  var unescape = new HtmlUnescape();

  @override
  void initState() {
    _fetchData();
    comment = TextEditingController();
    super.initState();
  }

  Future<void> _fetchData() async {
    ObservationsAPIHandler handler = ObservationsAPIHandler({"id": widget.id});
    var data = await handler.getObservationDetails();
    if (!data.containsKey('error')) {
      displaydata = data;
    } else {
      MyApp.Show401Dialog(context);
    }
    
    ObservationsAPIHandler handler1 = ObservationsAPIHandler({
      "userid": MyApp.LOGIN_ID_VALUE,
      "observationId": widget.id,
    });
    var data1 = await handler1.getObservationDataDetails();
   
    if (!data1.containsKey('error')) {
      if ((data1['permission'] != null &&
              data1['permission']['updateObservation'] == '1') ||
          MyApp.USER_TYPE_VALUE == 'Superadmin') {
        permission = true;
      } else {
        permission = false;
      }
      displaydata1 = data1;

      print('dashhhh');

      print(displaydata1['observation']['status']);
      eylfData = [];
      if (displaydata1['outcomes'] != null) {
        for (int a = 0; a < displaydata1['outcomes'].length; a++) {
          EylfOutcomeModel eylfOutcomeModel =
              EylfOutcomeModel.fromJson(displaydata1['outcomes'][a]);
          List<EylfActivityModel> activityModel = [];
          for (int b = 0;
              b < displaydata1['outcomes'][a]['Activity'].length;
              b++) {
            EylfActivityModel act = EylfActivityModel.fromJson(
                displaydata1['outcomes'][a]['Activity'][b]);
            List<EylfSubActivityModel> subActivityModel = [];
            for (int c = 0;
                c <
                    displaydata1['outcomes'][a]['Activity'][b]['subActivity']
                        .length;
                c++) {
              subActivityModel.add(EylfSubActivityModel.fromJson(
                  displaydata1['outcomes'][a]['Activity'][b]['subActivity']
                      [c]));
            }
            act.subActivity = subActivityModel;
            activityModel.add(act);
          }
          eylfOutcomeModel.activity = activityModel;
          //for loops
          eylfData.add(eylfOutcomeModel);
        }
      }

      //dev
      print("dev");
      print(displaydata1['devMilestone']);
      devData = [];
      if (displaydata1['devMilestone'] != null) {
        for (int a = 0; a < displaydata1['devMilestone'].length; a++) {
          DevMilestoneModel devModel =
              DevMilestoneModel.fromJson(displaydata1['devMilestone'][a]);
           if(displaydata1['devMilestone'][a]['Main']!=null){

          List<MainModel> mainModelList = [];
          for (int b = 0;
              b < displaydata1['devMilestone'][a]['Main'].length;
              b++) {
            MainModel mainModel =
                MainModel.fromJson(displaydata1['devMilestone'][a]['Main'][b]);
            List<SubjectModel> subjects = [];
            if (displaydata1['devMilestone'][a]['Main'][b]['Subjects'] !=
                null) {
              for (int c = 0;
                  c <
                      displaydata1['devMilestone'][a]['Main'][b]['Subjects']
                          .length;
                  c++) {
                //
                subjects.add(SubjectModel.fromJson(
                    displaydata1['devMilestone'][a]['Main'][b]['Subjects'][c]));
                List<MilestoneExtrasModel> milestoneExtrasModel = [];
                if (displaydata1['devMilestone'][a]['Main'][b]['Subjects'][c]
                        ['extras'] !=
                    null) {
                  for (int d = 0;
                      d <
                          displaydata1['devMilestone'][a]['Main'][b]['Subjects']
                                  [c]['extras']
                              .length;
                      d++) {
                    milestoneExtrasModel.add(MilestoneExtrasModel.fromJson(
                        displaydata1['devMilestone'][a]['Main'][b]['Subjects']
                            [c]['extras'][d]));
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
          devData.add(devModel);
           }
        }
      }
      print(devData);

      montessoriData = [];
      if (displaydata1['montessoriSubjects'] != null) {
        for (int a = 0; a < displaydata1['montessoriSubjects'].length; a++) {
          MontessoriModel montessoriModel =
              MontessoriModel.fromJson(displaydata1['montessoriSubjects'][a]);
          List<MontessoriActivityModel> activityModel = [];
          for (int b = 0;
              b < displaydata1['montessoriSubjects'][a]['Activity'].length;
              b++) {
            MontessoriActivityModel act = MontessoriActivityModel.fromJson(
                displaydata1['montessoriSubjects'][a]['Activity'][b]);
            List<MontessoriSubActivityModel> subActivityModel = [];
            for (int c = 0;
                c <
                    displaydata1['montessoriSubjects'][a]['Activity'][b]
                            ['subActivity']
                        .length;
                c++) {
              subActivityModel.add(MontessoriSubActivityModel.fromJson(
                  displaydata1['montessoriSubjects'][a]['Activity'][b]
                      ['subActivity'][c]));
            }
            act.subActivity = subActivityModel;
            activityModel.add(act);
          }
          montessoriModel.activity = activityModel;
          montessoriData.add(montessoriModel);
        }
      }

      var child = data1['childrens'];
      print('heyuuu'+data1['childrens'].toString());
      _allChildrens = [];
      try {
        assert(child is List);
        for (int i = 0; i < child.length; i++) {
          _allChildrens.add(ChildSubModel.fromJson(child[i]));
        }
        childrensFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }

      var observation = data1['observation'];
      try {
        _observation = ObservationModel.fromJson(observation);
        media = data1['Media'];
        obsFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    ObservationsAPIHandler handlerX =
        ObservationsAPIHandler({"userid": MyApp.LOGIN_ID_VALUE});

    var users = await handlerX.getUsersList();
    print('hereee users');
    print(users);
    var usersList = users['UsersList'];
    mentionUser = [];
    try {
      assert(usersList is List);
      for (int i = 0; i < usersList.length; i++) {
        Map<String, dynamic> mChild = usersList[i];
        mChild['display'] = usersList[i]['name'];
        if (mChild['type'] == 'Staff') {
          mentionUser.add(mChild);
        }
      }
      mChildFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    var dataMont = await handlerX.getAllMont();
    print('hereee');
    print(dataMont.keys);
    var mont = dataMont['TagsList'];
    mentionMont = [];
    try {
      assert(mont is List);
      for (int i = 0; i < mont.length; i++) {
        Map<String, dynamic> mMont = mont[i];
        mMont['display'] = mont[i]['title'];
        mMont['id'] = mont[i]['id'].toString();
        mentionMont.add(mMont);
      }
      mMontFetched = true;
      print('hereMontFetched');
      print(mMontFetched);
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    print("hj" + data1.toString());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Row(children: <Widget>[
                        if (_observation != null)
                          Container(
                            width: size.width * 0.8,
                            child: _observation.title != null
                                ? tagRemove(
                                    _observation.title,
                                    'heading',
                                    displaydata1['observation']['centerid'],
                                    context)
                                : null,
                          ),
                        Expanded(
                          child: Container(),
                        ),
                        // if (permission &&
                        //     displaydata1 != null &&
                        //     displaydata1['observation']['status'] !=
                        //         'Published' &&
                        //     MyApp.USER_TYPE_VALUE != 'Parent')
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider(
                                              create: (context) => Obsdata(),
                                              child: AddObservation(
                                                type: "edit",
                                                data: _observation,
                                                selecChildrens: _allChildrens,
                                                media: media,
                                                totaldata: displaydata,
                                                centerid:
                                                    displaydata['observation']
                                                        ['centerid'],
                                              ))));
                            },
                          )
                      ]),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            'Application > ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text('Observation')
                        ],
                      ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width,
                      //   decoration: BoxDecoration(
                      //    color: Color(0xffE1E9FF),
                      //             borderRadius: BorderRadius.all(Radius.circular(8))
                      //           ),
                      //   child: Center(child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Text('This Observation is only visible to staff',style: TextStyle(color: Colors.grey,)),
                      //   )),
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      if (obsFetched)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Author:'),
                                Text(
                                  _observation.userName != null
                                      ? _observation.userName
                                      : '',
                                  style: TextStyle(color: Constants.kMain),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(''),
                             Row(
                                                            children: [
                                                              Text(
                                                                'Created on:',
                                                               
                                                              ),
                                                              Text(
                                                              _observation.dateAdded
                                                                           !=
                                                                        null
                                                                    ? formatter.format(DateTime.parse(_observation
                                                                            .dateAdded))
                                                                    : '',
                                                                style: TextStyle(
                                                                    color: Constants
                                                                        .kMain,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ],
                                                          ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text('Approved by:'),
                                Text(
                                  _observation.approverName != null
                                      ? _observation.approverName
                                      : '',
                                  style: TextStyle(color: Constants.kMain),
                                )
                              ],
                            ),
                           SizedBox(height: 8,),
                           Row(
                                                        children: [
                                                          widget.montCount!=null
                                                              ? Text(
                                                                  'Montessori: ' +
                                                                     widget.montCount.toString()+
                                                                      '  ,',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Constants
                                                                        .kCount,
                                                                  ))
                                                              : SizedBox(),
                                                          widget.eylfCount!=
                                                                  null
                                                              ? Text(
                                                                  'EYLF: ' +
                                                                     widget.eylfCount.toString()+"  ,",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Constants
                                                                        .kCount,
                                                                  ))
                                                              : SizedBox(),
                                                           widget.devCount!=
                                                                  null
                                                              ? Text(
                                                                  'Milestone: ' +
                                                                    widget.devCount.toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Constants
                                                                        .kCount,
                                                                  ))
                                                              : SizedBox(),    
                                                              ]),

                            SizedBox(
                              height: 10,
                            ),
                            if (childrensFetched)
                              Wrap(
                                  spacing: 8.0, // gap between adjacent chips
                                  runSpacing: 4.0, // gap between lines
                                  children: List<Widget>.generate(
                                      _allChildrens.length, (int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChildDetails(
                                                      childId:
                                                          _allChildrens[index]
                                                              .childId,
                                                      centerId: displaydata1[
                                                              'observation']
                                                          ['centerid'],
                                                    )));
                                      },
                                      child: Chip(
                                        avatar: CircleAvatar(
                                          radius: 50.0,
                                          backgroundImage: NetworkImage(
                                              _allChildrens[index]
                                                              .imageUrl !=
                                                          null &&
                                                      _allChildrens[index]
                                                              .imageUrl !=
                                                          '' &&
                                                      _allChildrens[index]
                                                              .imageUrl !=
                                                          'null'
                                                  ? Constants.ImageBaseUrl +
                                                      _allChildrens[index]
                                                          .imageUrl
                                                  : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                                          backgroundColor: Colors.transparent,
                                        ),
                                        label: Text(
                                            _allChildrens[index].childName !=
                                                    null
                                                ? _allChildrens[index].childName
                                                : ''),
                                      ),
                                    );
                                  })),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Notes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            _observation.notes != null
                                ? tagRemove(
                                    _observation.notes,
                                    'title',
                                    displaydata1['observation']['centerid'],
                                    context)
                                : null,
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Reflection',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            _observation.reflection != null
                                ? tagRemove(
                                    _observation.reflection,
                                    'title',
                                    displaydata1['observation']['centerid'],
                                    context)
                                : null,
                          ],
                        ),

                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: ListTile(
                          title: Text(
                            'Early Years Learning Framework',
                            style: TextStyle(fontSize: 15),
                          ),
                          leading: GestureDetector(
                            onTap: () {
                              expandeylf = !expandeylf;
                              setState(() {});
                            },
                            child: Icon(
                              expandeylf
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_right,
                              color: Constants.kMain,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                          visible: eylfData != null && expandeylf,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      eylfData != null ? eylfData.length : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        ListTile(
                                            leading: GestureDetector(
                                              onTap: () {
                                                eylfData[index].choosen =
                                                    !eylfData[index].choosen;
                                                setState(() {});
                                              },
                                              child: Icon(
                                                eylfData[index].choosen
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons
                                                        .keyboard_arrow_right,
                                                color: Constants.kMain,
                                              ),
                                            ),
                                            title: Text(eylfData[index].title)),
                                        Visibility(
                                            visible: eylfData[index].choosen,
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: eylfData[index]
                                                                .activity !=
                                                            null
                                                        ? eylfData[index]
                                                            .activity
                                                            .length
                                                        : 0,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int p) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 12.0),
                                                        child: Column(
                                                          children: [
                                                            ListTile(
                                                                leading:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    eylfData[
                                                                            index]
                                                                        .activity[
                                                                            p]
                                                                        .choosen = !eylfData[
                                                                            index]
                                                                        .activity[
                                                                            p]
                                                                        .choosen;
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Icon(
                                                                    eylfData[index]
                                                                            .activity[
                                                                                p]
                                                                            .choosen
                                                                        ? Icons
                                                                            .keyboard_arrow_down
                                                                        : Icons
                                                                            .keyboard_arrow_right,
                                                                    color: Constants
                                                                        .kMain,
                                                                  ),
                                                                ),
                                                                title: Text(eylfData[
                                                                        index]
                                                                    .activity[p]
                                                                    .title)),
                                                            Visibility(
                                                                visible: eylfData[
                                                                        index]
                                                                    .activity[p]
                                                                    .choosen,
                                                                child: Container(
                                                                    width: MediaQuery.of(context).size.width * 0.9,
                                                                    child: ListView.builder(
                                                                        shrinkWrap: true,
                                                                        physics: NeverScrollableScrollPhysics(),
                                                                        itemCount: eylfData[index].activity[p].subActivity != null ? eylfData[index].activity[p].subActivity.length : 0,
                                                                        itemBuilder: (BuildContext context, int k) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 12.0),
                                                                            child:
                                                                                Card(
                                                                              child: ListTile(
                                                                                title: Text(eylfData[index].activity[p].subActivity[k].title),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }))),
                                                          ],
                                                        ),
                                                      );
                                                    }))),
                                      ],
                                    );
                                  }))),

                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: ListTile(
                          title: Text(
                            'Montessori Activities',
                            style: TextStyle(fontSize: 15),
                          ),
                          leading: GestureDetector(
                            onTap: () {
                              expandmontessori = !expandmontessori;
                              setState(() {});
                            },
                            child: Icon(
                              expandmontessori
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_right,
                              color: Constants.kMain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),

                      Visibility(
                          visible: montessoriData != null && expandmontessori,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: montessoriData != null
                                      ? montessoriData.length
                                      : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        ListTile(
                                            leading: GestureDetector(
                                              onTap: () {
                                                montessoriData[index].choosen =
                                                    !montessoriData[index]
                                                        .choosen;
                                                setState(() {});
                                              },
                                              child: Icon(
                                                montessoriData[index].choosen
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons
                                                        .keyboard_arrow_right,
                                                color: Constants.kMain,
                                              ),
                                            ),
                                            title: Text(
                                                montessoriData[index].name)),
                                        Visibility(
                                            visible:
                                                montessoriData[index].choosen,
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: montessoriData[
                                                                    index]
                                                                .activity !=
                                                            null
                                                        ? montessoriData[index]
                                                            .activity
                                                            .length
                                                        : 0,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int p) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 12.0),
                                                        child: Column(
                                                          children: [
                                                            ListTile(
                                                                leading:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    montessoriData[
                                                                            index]
                                                                        .activity[
                                                                            p]
                                                                        .choosen = !montessoriData[
                                                                            index]
                                                                        .activity[
                                                                            p]
                                                                        .choosen;
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Icon(
                                                                    montessoriData[index]
                                                                            .activity[
                                                                                p]
                                                                            .choosen
                                                                        ? Icons
                                                                            .keyboard_arrow_down
                                                                        : Icons
                                                                            .keyboard_arrow_right,
                                                                    color: Constants
                                                                        .kMain,
                                                                  ),
                                                                ),
                                                                title: Text(
                                                                    montessoriData[
                                                                            index]
                                                                        .activity[
                                                                            p]
                                                                        .title)),
                                                            Visibility(
                                                                visible: montessoriData[
                                                                        index]
                                                                    .activity[p]
                                                                    .choosen,
                                                                child: Container(
                                                                    width: MediaQuery.of(context).size.width * 0.9,
                                                                    child: ListView.builder(
                                                                        shrinkWrap: true,
                                                                        physics: NeverScrollableScrollPhysics(),
                                                                        itemCount: montessoriData[index].activity[p].subActivity != null ? montessoriData[index].activity[p].subActivity.length : 0,
                                                                        itemBuilder: (BuildContext context, int k) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 12.0),
                                                                            child:
                                                                                Card(
                                                                              child: ListTile(
                                                                                title: Text(montessoriData[index].activity[p].subActivity[k].title),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }))),
                                                          ],
                                                        ),
                                                      );
                                                    }))),
                                      ],
                                    );
                                  }))),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: ListTile(
                          title: Text(
                            'Developmental Milestones',
                            style: TextStyle(fontSize: 15),
                          ),
                          leading: InkWell(
                            onTap: () {
                              expandmilestones = !expandmilestones;
                              setState(() {});
                            },
                            child: Icon(
                              expandmilestones
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_right,
                              color: Constants.kMain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Visibility(
                          visible: devData != null && expandmilestones,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      devData != null ? devData.length : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        ListTile(
                                            leading: GestureDetector(
                                              onTap: () {
                                                devData[index].choosen =
                                                    !devData[index].choosen;
                                                setState(() {});
                                              },
                                              child: Icon(
                                                devData[index].choosen
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons
                                                        .keyboard_arrow_right,
                                                color: Constants.kMain,
                                              ),
                                            ),
                                            title:
                                                Text(devData[index].ageGroup)),
                                        Visibility(
                                            visible: devData[index].choosen,
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        devData[index].main !=
                                                                null
                                                            ? devData[index]
                                                                .main
                                                                .length
                                                            : 0,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int p) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 12.0),
                                                        child: Column(
                                                          children: [
                                                            ListTile(
                                                                leading:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    devData[index]
                                                                        .main[p]
                                                                        .choosen = !devData[
                                                                            index]
                                                                        .main[p]
                                                                        .choosen;
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Icon(
                                                                    devData[index]
                                                                            .main[
                                                                                p]
                                                                            .choosen
                                                                        ? Icons
                                                                            .keyboard_arrow_down
                                                                        : Icons
                                                                            .keyboard_arrow_right,
                                                                    color: Constants
                                                                        .kMain,
                                                                  ),
                                                                ),
                                                                title: Text(
                                                                    devData[index]
                                                                        .main[p]
                                                                        .name)),
                                                            Visibility(
                                                                visible: devData[
                                                                        index]
                                                                    .main[p]
                                                                    .choosen,
                                                                child: Container(
                                                                    width: MediaQuery.of(context).size.width * 0.9,
                                                                    child: ListView.builder(
                                                                        shrinkWrap: true,
                                                                        physics: NeverScrollableScrollPhysics(),
                                                                        itemCount: devData[index].main[p].subjects != null ? devData[index].main[p].subjects.length : 0,
                                                                        itemBuilder: (BuildContext context, int k) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 12.0),
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                ListTile(
                                                                                    leading: GestureDetector(
                                                                                      onTap: () {
                                                                                        devData[index].main[p].subjects[k].choosen = !devData[index].main[p].subjects[k].choosen;
                                                                                        setState(() {});
                                                                                      },
                                                                                      child: Icon(
                                                                                        devData[index].main[p].subjects[k].choosen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                                                                                        color: Constants.kMain,
                                                                                      ),
                                                                                    ),
                                                                                    title: Text(devData[index].main[p].subjects[k].name)),
                                                                                Visibility(
                                                                                    visible: devData[index].main[p].subjects[k].choosen,
                                                                                    child: ListView.builder(
                                                                                        shrinkWrap: true,
                                                                                        physics: NeverScrollableScrollPhysics(),
                                                                                        itemCount: devData[index].main[p].subjects[k].extras.length,
                                                                                        itemBuilder: (context, g) {
                                                                                          return Padding(
                                                                                            padding: const EdgeInsets.only(left: 8.0),
                                                                                            child: Card(
                                                                                              child: ListTile(
                                                                                                title: Text(devData[index].main[p].subjects[k].extras[g].title),
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        }))
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }))),
                                                          ],
                                                        ),
                                                      );
                                                    }))),
                                      ],
                                    );
                                  }))),

                      SizedBox(
                        height: 10,
                      ),

                      Text('Comments'),
                      SizedBox(
                        height: 5,
                      ),
                      if (displaydata1 != null && obsFetched)
                        Container(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: displaydata1['Comments'].length != 0
                                  ? displaydata1['Comments'].length
                                  : 0,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: ListTile(
                                    title: Text(displaydata1['Comments'][index]['userName'].toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                   trailing: Text(DateFormat.jm().format(DateTime.parse(displaydata1['Comments'][index]['date_added'].toString())),style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: tagRemove(
                                        displaydata1['Comments'][index]
                                            ['comments'],
                                        'heading',
                                        displaydata1['observation']['centerid'],
                                        context),
                                  ),
                                );
                              }),
                        ),
                      SizedBox(
                        height: 5,
                      ),
                      if (mMontFetched && mChildFetched)
                        Container(
                          // height: 40,
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blueAccent)),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: FlutterMentions(
                              key: cmntX,
                              suggestionPosition: SuggestionPosition.Top,
                              maxLines: 5,
                              minLines: 3,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              onMentionAdd: (Map<String, dynamic> _map) {
                                print(_map);
                              },
                              mentions: [
                                Mention(
                                    trigger: '@',
                                    style: TextStyle(
                                      color: Colors.amber,
                                    ),
                                    data: mentionUser,
                                    disableMarkup: true,
                                    matchAll: false,
                                    suggestionBuilder: (data) {
                                      return Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Row(
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                Text(data['name']),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                                Mention(
                                  trigger: '#',
                                  disableMarkup: true,
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                  data: mentionMont,
                                  matchAll: true,
                                )
                              ],
                            ),
                          ),
                        ),
                      // Container(
                      //   height: 40,
                      //   child: TextField(
                      //       controller: comment,
                      //       decoration: new InputDecoration(
                      //         hintText: 'add comment here',
                      //         hintStyle: TextStyle(color: Colors.grey),
                      //         enabledBorder: const OutlineInputBorder(
                      //           borderSide: const BorderSide(
                      //               color: Colors.black26, width: 0.0),
                      //         ),
                      //         border: new OutlineInputBorder(
                      //           borderRadius: const BorderRadius.all(
                      //             const Radius.circular(4),
                      //           ),
                      //         ),
                      //       )),
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                    if (mMontFetched && mChildFetched)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                String comment =
                                    cmntX.currentState.controller.markupText;

                                if (comment != '') {
                                  for (int i = 0; i < mentionUser.length; i++) {
                                    if (comment
                                        .contains(mentionUser[i]['name'])) {
                                      comment = comment.replaceAll(
                                          "@" + mentionUser[i]['name'],
                                          '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                    }
                                  }
                                  for (int i = 0; i < mentionMont.length; i++) {
                                    if (comment
                                        .contains(mentionMont[i]['display'])) {
                                      comment = comment.replaceAll(
                                          "#" + mentionMont[i]['display'],
                                          '<a href="tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                    }
                                  }
                                  print(comment);

                                  ObservationsAPIHandler handler =
                                      ObservationsAPIHandler({
                                    "comment": comment,
                                    "userid": MyApp.LOGIN_ID_VALUE,
                                    "id": widget.id
                                  });

                                  var data = await handler.createComment();
                                  if (!data.containsKey('error')) {
                                    cmntX.currentState.controller.clear();

                                    _fetchData();
                                  } else {
                                    MyApp.Show401Dialog(context);
                                  }
                                } else {
                                  MyApp.ShowToast('Enter comment', context);
                                }
                              },
                              child: Container(
                                  width: 75,
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
                                          'SUBMIT',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  )
                                ),
                            ),
                          ]),
                    ])))));
  }
}
