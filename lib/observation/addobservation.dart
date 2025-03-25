import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:mime/mime.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/childsubmodel.dart';
import 'package:mykronicle_mobile/models/extrasmodel.dart';
import 'package:mykronicle_mobile/models/observationmodel.dart';
import 'package:mykronicle_mobile/models/obsmediamodel.dart';
import 'package:mykronicle_mobile/models/optionsmodel.dart';
import 'package:mykronicle_mobile/models/staffmodel.dart';
import 'package:mykronicle_mobile/observation/assesmentstab/assesmentsmaintab.dart';
import 'package:mykronicle_mobile/observation/childdetails.dart';
import 'package:mykronicle_mobile/observation/linkstab/links.dart';
import 'package:mykronicle_mobile/observation/obsdata.dart';
import 'package:mykronicle_mobile/observation/preview.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:mykronicle_mobile/utils/removeTags.dart';
import 'package:mykronicle_mobile/utils/video_item_local.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:http/http.dart' as http;

class AddObservation extends StatefulWidget {
  final String type;
  final ObservationModel? data;
  final List<ChildSubModel> selecChildrens;
  final Map totaldata;
  final List media;
  final String centerid;
  AddObservation(
      {required this.type,
      this.data,
      required this.selecChildrens,
      required this.media,
      required this.totaldata,
      required this.centerid});

  @override
  AddObservationState createState() => AddObservationState();
}

class AddObservationState extends State<AddObservation>
    with TickerProviderStateMixin {
  TabController? _controller;
  int _radioValue = 0;
  bool childrensFetched = false;
  List<ChildModel> _allChildrens = [];
  List<StaffModel> _allEductarors = [];

  List<List<StaffModel>> _editEducators = [];

  static List<ChildModel> selectedChildrens = [];
  List<List<ChildModel>> _editChildren = [];
  List<TextEditingController> captions = [];
  //String textData = '';

  List<List<ChildModel>> _editMediaFileChildren = [];
  List<TextEditingController> mediaFilecaptions = [];
  List<List<StaffModel>> _editMediaFileEducators = [];

  bool groupsFetched = false;
  bool staffFetched = false;

  Map groups = {};
  bool all = false;
  List<File> files = [];
  List<ObsMediaModel> media = [];
  String obsid = '';
  Map<String, bool> childValues = {};

  Map<String, bool> boolValues = {};

  Map viewData = {};
  static Map assesData = {};
  static String centerid = '';
  static String previewnotes = '';
  static String previewtitle = '';
  static String previewRef = '';
  static String previewChildVoice = '';
  static String previewFuturePlan = '';
  static String type = '';

  Widget assetmentWidget = Container();
  // static TextEditingController title;
//  static TextEditingController reflection;
  static GlobalKey<FlutterMentionsState> mentionTitle =
      GlobalKey<FlutterMentionsState>();
  static GlobalKey<FlutterMentionsState> mentionNotes =
      GlobalKey<FlutterMentionsState>();
  static GlobalKey<FlutterMentionsState> mentionRef =
      GlobalKey<FlutterMentionsState>();

  static GlobalKey<FlutterMentionsState> mentionChildVoice =
      GlobalKey<FlutterMentionsState>();
  static GlobalKey<FlutterMentionsState> mentionFuturePlan =
      GlobalKey<FlutterMentionsState>();

  List mediaFiles = [];

// assesment data
  static List<List<List<bool>>> checkValue = [];
  static List<List<bool>> e = [];

// montessori data
  static List<List<bool>> em = [];
  static List<List<List<List<ExtrasModel>>>> extras = [];
  static List<List<List<String>>> dropAns = [];
  static List<List<List<List<bool>>>> selectedExtras = [];

// milestone data
  static List<List<bool>> emi = [];
  static List<List<List<List<OptionsModel>>>> options = [];
  static List<List<List<String>>> dropAnsM = [];
  static List<List<List<List<bool>>>> selectedOptions = [];

  List<Map<String, dynamic>> mentionUser = [];
  List<Map<String, dynamic>> mentionMont = [];

  bool mChildFetched = false;
  bool mMontFetched = false;

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radioValue = value!;

      switch (_radioValue) {
        case 0:
          break;
        case 1:
          break;
      }
    });
  }

  @override
  void initState() {
    _controller = new TabController(
        length: MyApp.USER_TYPE_VALUE == 'Parent' ? 1 : 3, vsync: this);
    //  title = new TextEditingController();
    // reflection = new TextEditingController();
    centerid = widget.centerid;
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    ObservationsAPIHandler handler = ObservationsAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": widget.centerid});
    var data = await handler.getChildList();
    selectedChildrens = [];
    var child = data['records'];
    _allChildrens = [];
    print(child);
    try {
      assert(child is List);
      for (int i = 0; i < child.length; i++) {
        _allChildrens.add(ChildModel.fromJson(child[i]));
        childValues[_allChildrens[i]?.childid ?? ''] = false;
      }
      childrensFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    UtilsAPIHandler utilsApiHandler = UtilsAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": widget.centerid});
    var staffData = await utilsApiHandler.getStaff();

    var staff = staffData['educators'];
    _allEductarors = [];
    try {
      assert(staff is List);
      for (int i = 0; i < staff.length; i++) {
        _allEductarors.add(StaffModel.fromJson(staff[i]));
      }
      staffFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    var users = await handler.getUsersList();
    print('hereee users');
    print(users);
    var usersList = users['UsersList'];
    mentionUser = [];
    try {
      assert(usersList is List);
      for (int i = 0; i < usersList.length; i++) {
        Map<String, dynamic> mChild = usersList[i];
        mChild['display'] = usersList[i]['name'];
        mentionUser.add(mChild);
      }
      mChildFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    var viewD = await handler.viewTabs();
    viewData = viewD['Settings'];
    print(viewData.toString() + 'ViB');

    var dataMont = await handler.getAllMont();
    print('hereee');
    print(dataMont);
    var mont = dataMont['TagsList'];
    mentionMont = [];
    try {
      assert(mont is List);
      for (int i = 0; i < mont.length; i++) {
        Map<String, dynamic> mMont = mont[i];
        mMont['display'] = mont[i]['title'];
        mMont['type'] = mont[i]['type'];
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

    var d = await handler.getListGroup();
    groups = d;
    for (var i = 0; i < (groups.keys.length ?? 0); i++) {
      String key = groups.keys.elementAt(i);
      boolValues[key] = false;
    }
    print('called');
    print(groups?.keys);
    print('herooooo' + d.toString());
    groupsFetched = true;
    if (this.mounted) setState(() {});

    if (widget.type == 'edit') {
      type = 'edit';
      mentionTitle.currentState?.controller?.text =
          removeHtmlData(widget.data?.title ?? '');
      previewtitle = removeHtmlData(widget.data?.title ?? '');

      mentionNotes.currentState?.controller?.text =
          removeHtmlData(widget.data?.notes ?? '');
      previewnotes = removeHtmlData(widget.data?.notes ?? '');

      mentionRef.currentState?.controller?.text =
          removeHtmlData(widget.data?.reflection ?? '');
      previewRef = removeHtmlData(widget.data?.reflection ?? '');

      mentionChildVoice.currentState?.controller?.text =
          removeHtmlData(widget.data?.childVoice ?? '');
      previewChildVoice = removeHtmlData(widget.data?.childVoice ?? '');

      mentionFuturePlan.currentState?.controller?.text =
          removeHtmlData(widget.data?.futurePlan ?? '');
      previewFuturePlan = removeHtmlData(widget.data?.futurePlan ?? '');

      for (int i = 0; i < widget.selecChildrens.length; i++) {
        if (widget.selecChildrens[i].childId != null) {
          selectedChildrens.add(ChildModel(
              id: widget.selecChildrens[i].childId,
              name: widget.selecChildrens[i].childName,
              dob: widget.selecChildrens[i].dob,
              imageUrl: widget.selecChildrens[i].imageUrl,
              morningtea: {},
              lunch: {},
              sleep: [],
              afternoontea: {},
              snacks: {},
              sunscreen: [],
              toileting: {}));
          childValues[selectedChildrens[i].id ?? ''] = true;
        }
      }
      for (int i = 0; i < widget.media.length; i++) {
        media.add(ObsMediaModel.fromJson(widget.media[i]));
        h = h + 100;
      }
      setState(() {});
    } else {
      type = 'add';
    }

    ObservationsAPIHandler handling = ObservationsAPIHandler({
      "userid": MyApp.LOGIN_ID_VALUE,
      "obsid": '',
      "centerid": widget.centerid
    });
    assesData = await handling.getAssesmentsData();
    //eylf
    for (int i = 0; i < assesData['EYLF']['outcome'].length; i++) {
      List<List<bool>> ex1 = [];
      e.add(List<bool>.generate(
          assesData['EYLF']['outcome'][i]['activity'].length, (i) => false));
      for (int j = 0;
          j < assesData['EYLF']['outcome'][i]['activity'].length;
          j++) {
        ex1.add(List<bool>.generate(
            assesData['EYLF']['outcome'][i]['activity'][j]['subActivity']
                .length,
            (index) => false));
        print(widget.totaldata);
        if (widget.totaldata != null) {
          for (int k = 0;
              k <
                  assesData['EYLF']['outcome'][i]['activity'][j]['subActivity']
                      .length;
              k++) {
            for (int m = 0;
                m <
                    (widget.totaldata['observationEylf'] == null
                        ? 0
                        : widget.totaldata['observationEylf'].length);
                m++) {
              if (widget.totaldata['observationEylf'][m]['eylfSubactivityId'] ==
                  assesData['EYLF']['outcome'][i]['activity'][j]['subActivity']
                      [k]['id']) {
                ex1[j][k] = true;
              }
            }
          }
        }
      }
      checkValue.add(ex1);
    }
    // montesssori
    for (int i = 0; i < assesData['Montessori']['Subjects'].length; i++) {
      AddObservationState.em.add(List<bool>.generate(
          assesData['Montessori']['Subjects'][i]['activity'].length,
          (i) => false));
      List<List<List<ExtrasModel>>> in3 = [];
      List<List<List<bool>>> inx3 = [];
      List<List<String>> cur2 = [];
      for (int j = 0;
          j < assesData['Montessori']['Subjects'][i]['activity'].length;
          j++) {
        List<List<ExtrasModel>> in2 = [];
        List<List<bool>> inx2 = [];
        List<String> cur1 = [];
        for (int k = 0;
            k <
                assesData['Montessori']['Subjects'][i]['activity'][j]
                        ['SubActivity']
                    .length;
            k++) {
          List<ExtrasModel> in1 = [];
          List<bool> inx1 = [];
          for (int l = 0;
              l <
                  assesData['Montessori']['Subjects'][i]['activity'][j]
                          ['SubActivity'][k]['extras']
                      .length;
              l++) {
            in1.add(ExtrasModel.fromJson(assesData['Montessori']['Subjects'][i]
                ['activity'][j]['SubActivity'][k]['extras'][l]));
            inx1.add(false);

            if (widget.totaldata != null) {
              print('niaaaa' + widget.totaldata['obsMontessori'].toString());
              //edit purpose code
              for (int g = 0;
                  g < widget.totaldata['obsMontessori'].length;
                  g++) {
                for (int z = 0;
                    z < widget.totaldata['obsMontessori'][g]['idExtra'].length;
                    z++) {
                  if (in1[l].idExtra ==
                      widget.totaldata['obsMontessori'][g]['idExtra'][z]) {
                    inx1[l] = true;
                  }
                }
              }
            }
          }
          in2.add(in1);
          inx2.add(inx1);
          if (widget.totaldata != null &&
              (widget.totaldata['obsMontessori'] == null
                      ? 0
                      : widget.totaldata['obsMontessori'].length) >
                  k) {
            //edit purpose
            cur1.add(
                widget.totaldata['obsMontessori'][k]['assesment'].toString());
          } else {
            cur1.add('Not Assesed');
          }
        }
        in3.add(in2);
        inx3.add(inx2);
        cur2.add(cur1);
      }
      dropAns.add(cur2);
      extras.add(in3);
      selectedExtras.add(inx3);
    }

    //milest

    for (int i = 0;
        i < assesData['DevelopmentalMilestones']['ageGroups'].length;
        i++) {
      emi.add(List<bool>.generate(
          assesData['DevelopmentalMilestones']['ageGroups'][i]['subname']
              .length,
          (i) => false));

      List<List<List<OptionsModel>>> in3 = [];
      List<List<List<bool>>> inx3 = [];
      List<List<String>> cur2 = [];

      for (int j = 0;
          j <
              assesData['DevelopmentalMilestones']['ageGroups'][i]['subname']
                  .length;
          j++) {
        List<List<OptionsModel>> in2 = [];
        List<List<bool>> inx2 = [];
        List<String> cur1 = [];

        for (int k = 0;
            k <
                assesData['DevelopmentalMilestones']['ageGroups'][i]['subname']
                        [j]['title']
                    .length;
            k++) {
          List<OptionsModel> in1 = [];
          List<bool> inx1 = [];

          for (int l = 0;
              l <
                  assesData['DevelopmentalMilestones']['ageGroups'][i]
                          ['subname'][j]['title'][k]['options']
                      .length;
              l++) {
            in1.add(OptionsModel.fromJson(assesData['DevelopmentalMilestones']
                ['ageGroups'][i]['subname'][j]['title'][k]['options'][l]));
            inx1.add(false);

            if (widget.totaldata != null) {
              for (int g = 0;
                  g < widget.totaldata['observationMilestones'].length;
                  g++) {
                for (int z = 0;
                    z <
                        widget.totaldata['observationMilestones'][g]['idExtras']
                            .length;
                    z++) {
                  if (in1[l].id ==
                      widget.totaldata['observationMilestones'][g]['idExtras']
                          [z]) {
                    inx1[l] = true;
                  }
                }
              }
            }
          }

          in2.add(in1);
          inx2.add(inx1);
          print('hey');
          if (widget.totaldata['observationMilestones'] != null &&
              (widget.totaldata['observationMilestones']).length > k) {
            print(widget.totaldata['observationMilestones'][k].toString());
            //edit purpose
            cur1.add(widget.totaldata['observationMilestones'][k]['assessment']
                .toString());
          } else {
            cur1.add('Not Observed');
          }
        }
        in3.add(in2);
        inx3.add(inx2);
        cur2.add(cur1);
      }
      dropAnsM.add(cur2);
      options.add(in3);
      selectedOptions.add(inx3);
    }

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  Widget childrenWidget(
    String key,
  ) {
    return Container(
      height: groups[key].length * 60.0,
      child:
          // Text(key),
          ListView.builder(
              itemCount: groups[key].length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return groups[key][index]['child_id'] != null &&
                        groups[key][index]['child_name']
                            .toLowerCase()
                            .contains(searchString.toLowerCase())
                    ? Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: CheckboxListTile(
                            onChanged: (value) {
                              childValues[groups[key][index]['child_id']] =
                                  value!;
                              int s = _allChildrens.indexWhere((element) =>
                                  element.childid ==
                                  groups[key][index]['child_id']);
                              if ((!selectedChildrens
                                      .contains(_allChildrens[s])) &&
                                  value == true) {
                                selectedChildrens.add(_allChildrens[s]);
                              } else if (selectedChildrens
                                      .contains(_allChildrens[s]) &&
                                  value == false) {
                                selectedChildrens.remove(_allChildrens[s]);
                              }
                              setState(() {});
                            },
                            value: childValues[groups[key][index]
                                        ['child_id']] !=
                                    null
                                ? childValues[groups[key][index]['child_id']]
                                : false,
                            title: Text(groups[key][index]['child_name'] != null
                                ? groups[key][index]['child_name']
                                : ''),
                          ),
                        ),
                      )
                    : Container();
              }),
    );
  }

  String searchString = "";

  Widget getEndDrawer(BuildContext context) {
    return Drawer(
        child: Container(
            child: ListView(children: <Widget>[
      SizedBox(
        height: 5,
      ),
      ListTile(
        title: Text(
          'Select Children',
          style: Constants.header2,
        ),
        trailing: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // onTap: (){
        //     key.currentState?.openEndDrawer();
        // },
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 5),
        child: Theme(
          data: new ThemeData(
            primaryColor: Colors.grey,
            primaryColorDark: Colors.grey,
          ),
          child: Container(
            height: 33.0,
            width: MediaQuery.of(context).size.width,
            child: TextFormField(
              style: TextStyle(color: Colors.black),
              keyboardType: TextInputType.text,
              //validator: validatePassword,
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  labelStyle: new TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.grey)),
                  hintStyle: new TextStyle(
                    inherit: true,
                    color: Colors.grey,
                  ),
                  hintText: 'Search By Name'),
              onChanged: (String val) {
                searchString = val;
                print(searchString);
                setState(() {});
              },
            ),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          new Radio(
            value: 0,
            groupValue: _radioValue,
            onChanged: _handleRadioValueChange,
          ),
          new Text(
            'Children',
            style: new TextStyle(fontSize: 16.0),
          ),
          new Radio(
            value: 1,
            groupValue: _radioValue,
            onChanged: _handleRadioValueChange,
          ),
          new Text(
            'Sort By Room',
            style: new TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      _radioValue == 0 && searchString == ''
          ? ListTile(
              title: Text(
                'Select All',
                style: TextStyle(fontSize: 16),
              ),
              trailing: Checkbox(
                  value: all,
                  onChanged: (value) {
                    all = value!;
                    for (var i = 0; i < childValues.length; i++) {
                      String key = childValues.keys.elementAt(i);
                      childValues[key] = value!;
                      if (value == true) {
                        if (!selectedChildrens.contains(_allChildrens[i])) {
                          selectedChildrens.add(_allChildrens[i]);
                        }
                      } else {
                        if (selectedChildrens.contains(_allChildrens[i])) {
                          selectedChildrens.remove(_allChildrens[i]);
                        }
                      }
                    }
                    setState(() {});
                  }),
            )
          : Container(),
      _radioValue == 0
          ? Container(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _allChildrens != null ? _allChildrens.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    return _allChildrens[index]
                            .name
                            .toLowerCase()
                            .contains(searchString.toLowerCase())
                        ? ListTile(
                            title: Text(_allChildrens[index].name),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(_allChildrens[index]
                                          .imageUrl !=
                                      ""
                                  ? Constants.ImageBaseUrl +
                                      _allChildrens[index].imageUrl
                                  : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                            ),
                            trailing: Checkbox(
                                value:
                                    childValues[_allChildrens[index].childid],
                                onChanged: (value) {
                                  if (all) {
                                    all = !all;
                                  }
                                  print(_allChildrens[index].childid);
                                  if (value == true) {
                                    if (!selectedChildrens
                                        .contains(_allChildrens[index])) {
                                      selectedChildrens
                                          .add(_allChildrens[index]);
                                    }
                                  } else {
                                    if (selectedChildrens
                                        .contains(_allChildrens[index])) {
                                      selectedChildrens
                                          .remove(_allChildrens[index]);
                                    }
                                  }

                                  childValues[_allChildrens[index].childid ??
                                      ''] = value!;
                                  setState(() {});
                                }),
                          )
                        : Container();
                  }),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child:
                  //searchString==''?
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: groups != null ? groups.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        String key = groups.keys.elementAt(index);
                        print(boolValues[key]);

                        return key != 'Status'
                            ? Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12.0, 6, 0, 6),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (searchString == '')
                                        ListTile(
                                          title: Text(
                                            key,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          trailing: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Select All',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  Checkbox(
                                                    value: boolValues[key],
                                                    onChanged: (value) {
                                                      boolValues[key] = value!;
                                                      for (int i = 0;
                                                          i <
                                                              groups[key]
                                                                  .length;
                                                          i++) {
                                                        childValues[groups[key]
                                                                    [i]
                                                                ['child_id']] =
                                                            value!;
                                                        int s = _allChildrens
                                                            .indexWhere((element) =>
                                                                element
                                                                    .childid ==
                                                                groups[key][i][
                                                                    'child_id']);
                                                        if ((!selectedChildrens
                                                                .contains(
                                                                    _allChildrens[
                                                                        s])) &&
                                                            value == true) {
                                                          selectedChildrens.add(
                                                              _allChildrens[s]);
                                                        } else if (selectedChildrens
                                                                .contains(
                                                                    _allChildrens[
                                                                        s]) &&
                                                            value == false) {
                                                          selectedChildrens
                                                              .remove(
                                                                  _allChildrens[
                                                                      s]);
                                                        }
                                                      }
                                                      setState(() {});
                                                    },
                                                  ),
                                                ],
                                              )),
                                        ),
                                      childrenWidget(key),
                                    ],
                                  ),
                                ),
                              )
                            : Container();
                      })
              // :ListView.builder(
              //   itemCount: _allChildrens!=null?_allChildrens.length:0,
              //   itemBuilder: (BuildContext context,int index){
              //   return _allChildrens[index].name.toLowerCase().contains(searchString.toLowerCase())?  ListTile(
              //     title: Text(_allChildrens[index].name),
              //     trailing: Checkbox(value: false, onChanged: null),
              //   ):Container();
              // })
              ,
            ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Constants.kButton,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Text(
                      'SAVE',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
      )
    ])));
  }

  GlobalKey<ScaffoldState> key = GlobalKey();
  double h = 0;
  int uploadObs = 0;

  @override
  Widget build(BuildContext context) {
    var obs = Provider.of<Obsdata>(context);
    if (uploadObs == 0) {
      obs.data = widget.totaldata;
      if (widget.type == 'edit') {
        obs.obsid = widget.totaldata['observation']['id'].toString();
      }
      uploadObs = 1;
    }

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: key,
      endDrawer: getEndDrawer(context),
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: _controller == null
          ? SizedBox()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Observation',
                            style: Constants.header1,
                          ),
                          if (MyApp.USER_TYPE_VALUE != 'Parent')
                            Container(
                                height: 30,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.blueGrey),
                                    ),
                                    onPressed: () {
                                      // mentionTitle.currentState?.controller?.text =
                                      //     '@[__asfgasga41__](__markT__) #javascript hey';
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Preview()));
                                    },
                                    child: Text("Preview")))
                        ],
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
                              text: 'Add Observation',
                            ),
                            if (MyApp.USER_TYPE_VALUE != 'Parent')
                              new Tab(
                                text: 'Assesments',
                              ),
                            if (MyApp.USER_TYPE_VALUE != 'Parent')
                              new Tab(
                                text: 'Links',
                              ),
                          ],
                        ),
                      ),
                      new Container(
                        height: MediaQuery.of(context).size.height + 150 + h,
                        child: new TabBarView(
                          controller: _controller,
                          children: <Widget>[
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                    child: Text('Children'),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      key.currentState?.openEndDrawer();
                                    },
                                    child: Container(
                                        width: 160,
                                        height: 38,
                                        decoration: BoxDecoration(
                                            color: Constants.kButton,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Row(
                                          children: <Widget>[
                                            IconButton(
                                              onPressed: () {
                                                print(widget
                                                    .selecChildrens.length);
                                                key.currentState
                                                    ?.openEndDrawer();
                                              },
                                              icon: Icon(
                                                Icons.add_circle,
                                                color: Colors.blue[100],
                                              ),
                                            ),
                                            Text(
                                              'Select Childredn',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        )),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  selectedChildrens.length > 0
                                      ? Wrap(
                                          spacing:
                                              8.0, // gap between adjacent chips
                                          runSpacing: 4.0, // gap between lines
                                          children: List<Widget>.generate(
                                              selectedChildrens.length,
                                              (int index) {
                                            return selectedChildrens[index]
                                                        .id !=
                                                    null
                                                ? GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ChildDetails(
                                                                    childId:
                                                                        selectedChildrens[index].id ??
                                                                            '',
                                                                    centerId: widget
                                                                        .centerid,
                                                                  )));
                                                    },
                                                    child: Chip(
                                                        label: Text(
                                                            selectedChildrens[
                                                                        index]
                                                                    .name ??
                                                                ''),
                                                        onDeleted: () {
                                                          setState(() {
                                                            childValues[
                                                                selectedChildrens[
                                                                            index]
                                                                        .id ??
                                                                    ''] = false;
                                                            selectedChildrens
                                                                .removeAt(
                                                                    index);
                                                          });
                                                        }),
                                                  )
                                                : Container();
                                          }))
                                      : Container(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Title'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  if (mMontFetched && mChildFetched)
                                    Container(
                                      // height: 40,
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Colors.blueAccent)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: FlutterMentions(
                                          // onChanged: (txt) {
                                          //   print('$txt');
                                          // },
                                          key: mentionTitle,
                                          suggestionPosition:
                                              SuggestionPosition.Top,
                                          // maxLines: 5,
                                          minLines: 1,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
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
                                                  print(data);
                                                  return Container(
                                                    padding:
                                                        EdgeInsets.all(10.0),
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Notes'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  if (mMontFetched && mChildFetched)
                                    Container(
                                      // height: 40,
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Colors.blueAccent)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: FlutterMentions(
                                          key: mentionNotes,
                                          suggestionPosition:
                                              SuggestionPosition.Top,
                                          maxLines: 5,
                                          minLines: 3,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          onMentionAdd:
                                              (Map<String, dynamic> _map) {
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
                                                    padding:
                                                        EdgeInsets.all(10.0),
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (MyApp.USER_TYPE_VALUE != 'Parent')
                                    Text('Reflection'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  if (mMontFetched &&
                                      mChildFetched &&
                                      MyApp.USER_TYPE_VALUE != 'Parent')
                                    Container(
                                      // height: 40,
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Colors.blueAccent)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: FlutterMentions(
                                          key: mentionRef,
                                          suggestionPosition:
                                              SuggestionPosition.Top,
                                          maxLines: 3,
                                          minLines: 2,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
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
                                                    padding:
                                                        EdgeInsets.all(10.0),
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (MyApp.USER_TYPE_VALUE != 'Parent')
                                    Text('Child Voice'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  if (mMontFetched &&
                                      mChildFetched &&
                                      MyApp.USER_TYPE_VALUE != 'Parent')
                                    Container(
                                      // height: 40,
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Colors.blueAccent)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: FlutterMentions(
                                          key: mentionChildVoice,
                                          suggestionPosition:
                                              SuggestionPosition.Top,
                                          maxLines: 3,
                                          minLines: 2,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
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
                                                    padding:
                                                        EdgeInsets.all(10.0),
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (MyApp.USER_TYPE_VALUE != 'Parent')
                                    Text('Future Plan'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  if (mMontFetched &&
                                      mChildFetched &&
                                      MyApp.USER_TYPE_VALUE != 'Parent')
                                    Container(
                                      // height: 40,
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Colors.blueAccent)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: FlutterMentions(
                                          key: mentionFuturePlan,
                                          suggestionPosition:
                                              SuggestionPosition.Top,
                                          maxLines: 3,
                                          minLines: 2,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
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
                                                    padding:
                                                        EdgeInsets.all(10.0),
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
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text('Media'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Choose'),
                                                content: Container(
                                                  color: Colors.white,
                                                  height: 100,
                                                  width: size.width * 0.8,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        width: size.width * 0.7,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            Navigator.pop(
                                                                context);
                                                            FilePickerResult?
                                                                result =
                                                                await FilePicker
                                                                    .platform
                                                                    .pickFiles();

                                                            if (result !=
                                                                null) {
                                                              File? file = File(
                                                                  result
                                                                          .files
                                                                          .single
                                                                          .path ??
                                                                      '');
                                                              var fileSizeInBytes =
                                                                  file.length();
                                                              var fileSizeInKB =
                                                                  await fileSizeInBytes /
                                                                      1024;
                                                              var fileSizeInMB =
                                                                  fileSizeInKB /
                                                                      1024;
                                                              String mimeStr =
                                                                  lookupMimeType(result
                                                                              .files
                                                                              .single
                                                                              .path ??
                                                                          '') ??
                                                                      '';
                                                              var fileType =
                                                                  mimeStr.split(
                                                                      '/');

                                                              if (fileSizeInMB >
                                                                      2 &&
                                                                  fileType[0]
                                                                          .toString() ==
                                                                      'image') {
                                                                MyApp.ShowToast(
                                                                    'file size greater than 2 mb so image is being compressed',
                                                                    context);

                                                                final filePath =
                                                                    file.absolute
                                                                        .path;
                                                                final lastIndex =
                                                                    filePath.lastIndexOf(
                                                                        new RegExp(
                                                                            r'.jp'));
                                                                final splitted =
                                                                    filePath.substring(
                                                                        0,
                                                                        lastIndex);
                                                                final outPath =
                                                                    "${splitted}_out${filePath.substring(lastIndex)}";

                                                                File cFile =
                                                                    await compressAndGetFile(
                                                                        file,
                                                                        outPath);
                                                                files
                                                                    .add(cFile);
                                                              } else {
                                                                files.add(file);
                                                              }
                                                              captions.add(
                                                                  TextEditingController());
                                                              _editChildren
                                                                  .add([]);
                                                              _editEducators
                                                                  .add([]);
                                                              h = h + 100.0;
                                                              setState(() {});
                                                            } else {
                                                              // User canceled the picker
                                                            }
                                                          },
                                                          child:
                                                              Text("Gallery"),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              size.width * 0.7,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              ObservationsAPIHandler
                                                                  handler =
                                                                  ObservationsAPIHandler(
                                                                      {});

                                                              var data =
                                                                  await handler
                                                                      .getMediaImages();

                                                              _dialog(
                                                                  context,
                                                                  data[
                                                                      'uploadedMediaList']);

                                                              print(data);
                                                            },
                                                            child:
                                                                Text("Media"),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).then((value) => setState(() {}));
                                      },
                                      child: rectBorderWidget(size, context)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  files.length > 0
                                      ? ReorderableWrap(
                                          spacing:
                                              8.0, // gap between adjacent chips
                                          runSpacing: 4.0, //
                                          onReorder:
                                              (int oldIndex, int newIndex) {
                                            print(oldIndex);
                                            print(newIndex);
                                            File file1 = files[oldIndex];
                                            File file2 = files[newIndex];
                                            files[oldIndex] = file2;
                                            files[newIndex] = file1;

                                            String caption1 = captions[oldIndex]
                                                .text
                                                .toString();
                                            String caption2 = captions[newIndex]
                                                .text
                                                .toString();
                                            captions[oldIndex].text = caption2;
                                            captions[newIndex].text = caption1;

                                            List<ChildModel> child1 =
                                                _editChildren[oldIndex];
                                            List<ChildModel> child2 =
                                                _editChildren[newIndex];

                                            _editChildren[oldIndex] = child2;
                                            _editChildren[newIndex] = child1;

                                            List<StaffModel> edu1 =
                                                _editEducators[oldIndex];
                                            List<StaffModel> edu2 =
                                                _editEducators[newIndex];

                                            _editEducators[oldIndex] = edu2;
                                            _editEducators[newIndex] = edu1;
                                            setState(() {});
                                          },
                                          children: List<Widget>.generate(
                                              files.length, (int index) {
                                            String mimeStr = lookupMimeType(
                                                    files[index].path) ??
                                                '';
                                            var fileType = mimeStr.split('/');
                                            if (fileType[0].toString() ==
                                                'image') {
                                              return Stack(
                                                children: [
                                                  Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration:
                                                          new BoxDecoration(
                                                        //  borderRadius: BorderRadius.circular(15.0),
                                                        shape:
                                                            BoxShape.rectangle,
                                                        image:
                                                            new DecorationImage(
                                                          image: new FileImage(
                                                              files[index]),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          showDeleteDialog(
                                                              context,
                                                              () async {
                                                            files.removeAt(
                                                                index);
                                                            _editChildren
                                                                .removeAt(
                                                                    index);
                                                            _editEducators
                                                                .removeAt(
                                                                    index);
                                                            captions.removeAt(
                                                                index);
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 22,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Edit Image"),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.6,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.7,
                                                                      child:
                                                                          ListView(
                                                                        children: [
                                                                          Container(
                                                                              width: size.height / 8,
                                                                              height: size.height / 8,
                                                                              decoration: new BoxDecoration(
                                                                                //  borderRadius: BorderRadius.circular(15.0),
                                                                                shape: BoxShape.rectangle,
                                                                                image: new DecorationImage(
                                                                                  image: new FileImage(files[index]),
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              )),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Children'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          MultiSelectDialogField(
                                                                            items:
                                                                                _allChildrens.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                            initialValue:
                                                                                _editChildren[index],
                                                                            listType:
                                                                                MultiSelectListType.CHIP,
                                                                            onConfirm:
                                                                                (values) {
                                                                              _editChildren[index] = values;
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Educators'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          MultiSelectDialogField(
                                                                            items:
                                                                                _allEductarors.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                            initialValue:
                                                                                _editEducators[index],
                                                                            listType:
                                                                                MultiSelectListType.CHIP,
                                                                            onConfirm:
                                                                                (values) {
                                                                              _editEducators[index] = values;
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Caption'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                30,
                                                                            child: TextField(
                                                                                maxLines: 1,
                                                                                controller: captions[index],
                                                                                decoration: new InputDecoration(
                                                                                  enabledBorder: const OutlineInputBorder(
                                                                                    borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                  ),
                                                                                  border: new OutlineInputBorder(
                                                                                    borderRadius: const BorderRadius.all(
                                                                                      const Radius.circular(4),
                                                                                    ),
                                                                                  ),
                                                                                )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          'ok'),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                      ))
                                                ],
                                              );
                                            } else {
                                              return Stack(
                                                children: [
                                                  VideoItemLocal(
                                                      width: 100,
                                                      height: 100,
                                                      file: files[index]),
                                                  Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          showDeleteDialog(
                                                              context, () {
                                                            files.removeAt(
                                                                index);
                                                            _editChildren
                                                                .removeAt(
                                                                    index);
                                                            _editEducators
                                                                .removeAt(
                                                                    index);
                                                            captions.removeAt(
                                                                index);
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 22,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Edit Image"),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.6,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.7,
                                                                      child:
                                                                          ListView(
                                                                        children: [
                                                                          VideoItemLocal(
                                                                              width: size.width / 8,
                                                                              height: size.height / 8,
                                                                              file: files[index]),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Children'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          MultiSelectDialogField(
                                                                            items:
                                                                                _allChildrens.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                            initialValue:
                                                                                _editChildren[index],
                                                                            listType:
                                                                                MultiSelectListType.CHIP,
                                                                            onConfirm:
                                                                                (values) {
                                                                              _editChildren[index] = values;
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Educators'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          MultiSelectDialogField(
                                                                            items:
                                                                                _allEductarors.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                            initialValue:
                                                                                _editEducators[index],
                                                                            listType:
                                                                                MultiSelectListType.CHIP,
                                                                            onConfirm:
                                                                                (values) {
                                                                              _editEducators[index] = values;
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Caption'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                30,
                                                                            child: TextField(
                                                                                maxLines: 1,
                                                                                controller: captions[index],
                                                                                decoration: new InputDecoration(
                                                                                  enabledBorder: const OutlineInputBorder(
                                                                                    borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                  ),
                                                                                  border: new OutlineInputBorder(
                                                                                    borderRadius: const BorderRadius.all(
                                                                                      const Radius.circular(4),
                                                                                    ),
                                                                                  ),
                                                                                )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          'ok'),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                      ))
                                                ],
                                              );
                                            }
                                          }),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  mediaFiles.length > 0
                                      ? ReorderableWrap(
                                          spacing:
                                              8.0, // gap between adjacent chips
                                          runSpacing: 4.0, //
                                          onReorder:
                                              (int oldIndex, int newIndex) {
                                            print(oldIndex);
                                            print(newIndex);
                                            var file1 = mediaFiles[oldIndex];
                                            var file2 = mediaFiles[newIndex];
                                            mediaFiles[oldIndex] = file2;
                                            mediaFiles[newIndex] = file1;

                                            String caption1 =
                                                mediaFilecaptions[oldIndex]
                                                    .text
                                                    .toString();
                                            String caption2 =
                                                mediaFilecaptions[newIndex]
                                                    .text
                                                    .toString();
                                            mediaFilecaptions[oldIndex].text =
                                                caption2;
                                            mediaFilecaptions[newIndex].text =
                                                caption1;

                                            List<ChildModel> child1 =
                                                _editMediaFileChildren[
                                                    oldIndex];
                                            List<ChildModel> child2 =
                                                _editMediaFileChildren[
                                                    newIndex];

                                            _editMediaFileChildren[oldIndex] =
                                                child2;
                                            _editMediaFileChildren[newIndex] =
                                                child1;

                                            List<StaffModel> edu1 =
                                                _editMediaFileEducators[
                                                    oldIndex];
                                            List<StaffModel> edu2 =
                                                _editMediaFileEducators[
                                                    newIndex];

                                            _editMediaFileEducators[oldIndex] =
                                                edu2;
                                            _editMediaFileEducators[newIndex] =
                                                edu1;
                                            setState(() {});
                                          },
                                          children: List<Widget>.generate(
                                              mediaFiles.length, (int index) {
                                            if (mediaFiles[index]['type'] ==
                                                'Image') {
                                              return Stack(
                                                children: [
                                                  Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration:
                                                          new BoxDecoration(
                                                        //  borderRadius: BorderRadius.circular(15.0),
                                                        shape:
                                                            BoxShape.rectangle,
                                                        image:
                                                            new DecorationImage(
                                                          image: new NetworkImage(
                                                              Constants
                                                                      .ImageBaseUrl +
                                                                  mediaFiles[
                                                                          index]
                                                                      [
                                                                      'filename']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          showDeleteDialog(
                                                              context, () {
                                                            mediaFiles.removeAt(
                                                                index);
                                                            _editMediaFileChildren
                                                                .removeAt(
                                                                    index);
                                                            _editMediaFileEducators
                                                                .removeAt(
                                                                    index);
                                                            mediaFilecaptions
                                                                .removeAt(
                                                                    index);
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 22,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Edit Image"),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.6,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.7,
                                                                      child:
                                                                          ListView(
                                                                        children: [
                                                                          Container(
                                                                              width: size.height / 8,
                                                                              height: size.height / 8,
                                                                              decoration: new BoxDecoration(
                                                                                //  borderRadius: BorderRadius.circular(15.0),
                                                                                shape: BoxShape.rectangle,
                                                                                image: new DecorationImage(
                                                                                  image: new NetworkImage(Constants.ImageBaseUrl + mediaFiles[index]['filename']),
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              )),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Children'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          MultiSelectDialogField(
                                                                            items:
                                                                                _allChildrens.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                            initialValue:
                                                                                _editMediaFileChildren[index],
                                                                            listType:
                                                                                MultiSelectListType.CHIP,
                                                                            onConfirm:
                                                                                (values) {
                                                                              _editMediaFileChildren[index] = values;
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Educators'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          MultiSelectDialogField(
                                                                            items:
                                                                                _allEductarors.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                            initialValue:
                                                                                _editMediaFileEducators[index],
                                                                            listType:
                                                                                MultiSelectListType.CHIP,
                                                                            onConfirm:
                                                                                (values) {
                                                                              _editMediaFileEducators[index] = values;
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Caption'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                30,
                                                                            child: TextField(
                                                                                maxLines: 1,
                                                                                controller: mediaFilecaptions[index],
                                                                                decoration: new InputDecoration(
                                                                                  enabledBorder: const OutlineInputBorder(
                                                                                    borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                  ),
                                                                                  border: new OutlineInputBorder(
                                                                                    borderRadius: const BorderRadius.all(
                                                                                      const Radius.circular(4),
                                                                                    ),
                                                                                  ),
                                                                                )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          'ok'),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                      ))
                                                ],
                                              );
                                            } else {
                                              return Stack(
                                                children: [
                                                  VideoItem(
                                                      width: 100,
                                                      height: 100,
                                                      url: Constants
                                                              .ImageBaseUrl +
                                                          mediaFiles[index]
                                                              ['filename']),
                                                  Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          showDeleteDialog(
                                                              context, () {
                                                            mediaFiles.removeAt(index);
                                                            _editMediaFileChildren
                                                                .removeAt(
                                                                    index);
                                                            _editMediaFileEducators
                                                                .removeAt(
                                                                    index);
                                                            mediaFilecaptions
                                                                .removeAt(
                                                                    index);
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 22,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Edit Image"),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.6,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.7,
                                                                      child:
                                                                          ListView(
                                                                        children: [
                                                                          VideoItem(
                                                                              width: size.width / 8,
                                                                              height: size.height / 8,
                                                                              url: Constants.ImageBaseUrl + mediaFiles[index]['filename']),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Children'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          MultiSelectDialogField(
                                                                            items:
                                                                                _allChildrens.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                            initialValue:
                                                                                _editMediaFileChildren[index],
                                                                            listType:
                                                                                MultiSelectListType.CHIP,
                                                                            onConfirm:
                                                                                (values) {
                                                                              _editMediaFileChildren[index] = values;
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Educators'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          MultiSelectDialogField(
                                                                            items:
                                                                                _allEductarors.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                            initialValue:
                                                                                _editMediaFileEducators[index],
                                                                            listType:
                                                                                MultiSelectListType.CHIP,
                                                                            onConfirm:
                                                                                (values) {
                                                                              _editMediaFileEducators[index] = values;
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                              'Caption'),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                30,
                                                                            child: TextField(
                                                                                maxLines: 1,
                                                                                controller: mediaFilecaptions[index],
                                                                                decoration: new InputDecoration(
                                                                                  enabledBorder: const OutlineInputBorder(
                                                                                    borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                  ),
                                                                                  border: new OutlineInputBorder(
                                                                                    borderRadius: const BorderRadius.all(
                                                                                      const Radius.circular(4),
                                                                                    ),
                                                                                  ),
                                                                                )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          'ok'),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                      ))
                                                ],
                                              );
                                            }
                                          }),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  media.length > 0
                                      ? ReorderableWrap(
                                          spacing: 8.0,
                                          runSpacing: 4.0,
                                          onReorder:
                                              (int oldIndex, int newIndex) {
                                            print(oldIndex);
                                            print(newIndex);
                                            ObsMediaModel mediaModel1 =
                                                media[oldIndex];
                                            ObsMediaModel mediaModel2 =
                                                media[newIndex];
                                            media[oldIndex] = mediaModel2;
                                            media[newIndex] = mediaModel1;
                                            setState(() {});
                                          },
                                          children: List<Widget>.generate(
                                              media.length, (int index) {
                                            Timer(Duration(seconds: 4), () {
                                              print(
                                                  "${media[0].id}-${media[0].mediaType}-${media[0].observationId}-${media[0].mediaUrl}");
                                            });

                                            if (media[index].mediaType ==
                                                'Image') {
                                              return Stack(
                                                children: [
                                                  Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration:
                                                          new BoxDecoration(
                                                        //  borderRadius: BorderRadius.circular(15.0),
                                                        shape:
                                                            BoxShape.rectangle,
                                                        image:
                                                            new DecorationImage(
                                                          image: new NetworkImage(
                                                              Constants
                                                                      .ImageBaseUrl +
                                                                  media[index]
                                                                      .mediaUrl),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: GestureDetector(
                                                        child:
                                                            Icon(Icons.clear),
                                                        onTap: () {
                                                          showDeleteDialog(
                                                              context, () {
                                                            ObservationsAPIHandler
                                                                handler =
                                                                ObservationsAPIHandler({
                                                              "mediaid":
                                                                  media[index]
                                                                      .id
                                                            });
                                                            handler
                                                                .deleteMedia()
                                                                .then((value) {
                                                              print(value);
                                                              media.removeAt(
                                                                  index);
                                                              setState(() {});
                                                              Navigator.pop(
                                                                  context);
                                                            });
                                                          });
                                                        },
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 22,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          print(
                                                              media[index].id);
                                                          ObservationsAPIHandler
                                                              handler =
                                                              ObservationsAPIHandler({
                                                            "mediaid":
                                                                media[index].id,
                                                            "userid": MyApp
                                                                .LOGIN_ID_VALUE
                                                          });
                                                          handler
                                                              .getMedia()
                                                              .then((value) {
                                                            if (value[
                                                                    'Status'] ==
                                                                'SUCCESS') {
                                                              TextEditingController
                                                                  caption =
                                                                  TextEditingController(
                                                                      text: value[
                                                                              'MediaInfo']
                                                                          [
                                                                          'caption']);
                                                              List<ChildModel>
                                                                  editChild =
                                                                  [];
                                                              List<StaffModel>
                                                                  editEducator =
                                                                  [];
                                                              String mediaId =
                                                                  value['MediaInfo']
                                                                      ['id'];

                                                              for (int i = 0;
                                                                  i <
                                                                      value['ChildTags']
                                                                          .length;
                                                                  i++) {
                                                                var childID =
                                                                    value['ChildTags']
                                                                            [i][
                                                                        'childId'];
                                                                for (int j = 0;
                                                                    j <
                                                                        _allChildrens
                                                                            .length;
                                                                    j++) {
                                                                  if (_allChildrens[
                                                                              j]
                                                                          .childid ==
                                                                      childID) {
                                                                    editChild.add(
                                                                        _allChildrens[
                                                                            j]);
                                                                  }
                                                                }
                                                              }
                                                              for (int i = 0;
                                                                  i <
                                                                      value['EducatorTags']
                                                                          .length;
                                                                  i++) {
                                                                var userID =
                                                                    value['EducatorTags']
                                                                            [i][
                                                                        'userId'];
                                                                for (int j = 0;
                                                                    j <
                                                                        _allEductarors
                                                                            .length;
                                                                    j++) {
                                                                  if (_allEductarors[
                                                                              j]
                                                                          .id ==
                                                                      userID) {
                                                                    editEducator.add(
                                                                        _allEductarors[
                                                                            j]);
                                                                  }
                                                                }
                                                              }
                                                              print(value[
                                                                  'EducatorTags']);
                                                              print(
                                                                  'editttttt');
                                                              print('yee');
                                                              print('hry' +
                                                                  editEducator
                                                                      .toString());
                                                              print('hr' +
                                                                  editChild
                                                                      .toString());
                                                              print('hj');
                                                              //below also you need to add the same code

                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          "Edit Image"),
                                                                      content:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height * 0.6,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.7,
                                                                          child:
                                                                              ListView(
                                                                            children: [
                                                                              Container(
                                                                                  width: size.height / 8,
                                                                                  height: size.height / 8,
                                                                                  decoration: new BoxDecoration(
                                                                                    //  borderRadius: BorderRadius.circular(15.0),
                                                                                    shape: BoxShape.rectangle,
                                                                                    image: new DecorationImage(
                                                                                      image: new NetworkImage(Constants.ImageBaseUrl + media[index].mediaUrl),
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  )),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text('Children'),
                                                                              SizedBox(
                                                                                height: 3,
                                                                              ),
                                                                              MultiSelectDialogField(
                                                                                items: _allChildrens.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                                initialValue: editChild,
                                                                                listType: MultiSelectListType.CHIP,
                                                                                onConfirm: (values) {
                                                                                  editChild = values;
                                                                                  print(editChild[0].childid);
                                                                                },
                                                                              ),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text('Educators'),
                                                                              SizedBox(
                                                                                height: 3,
                                                                              ),
                                                                              MultiSelectDialogField(
                                                                                items: _allEductarors.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                                initialValue: editEducator,
                                                                                listType: MultiSelectListType.CHIP,
                                                                                onConfirm: (values) {
                                                                                  editEducator = values;
                                                                                },
                                                                              ),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text('Caption'),
                                                                              SizedBox(
                                                                                height: 3,
                                                                              ),
                                                                              Container(
                                                                                height: 30,
                                                                                child: TextField(
                                                                                    maxLines: 1,
                                                                                    controller: caption,
                                                                                    decoration: new InputDecoration(
                                                                                      enabledBorder: const OutlineInputBorder(
                                                                                        borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                      ),
                                                                                      border: new OutlineInputBorder(
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          const Radius.circular(4),
                                                                                        ),
                                                                                      ),
                                                                                    )),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          onPressed:
                                                                              () async {
                                                                            var _toSend =
                                                                                'https://stage.todquest.com/mykronicle101/api/Observation/saveImageTags/';
                                                                            print(editChild);
                                                                            List
                                                                                childIds =
                                                                                [];
                                                                            List
                                                                                educatorIds =
                                                                                [];
                                                                            for (int i = 0;
                                                                                i < editChild.length;
                                                                                i++) {
                                                                              childIds.add(editChild[i].childid);
                                                                            }
                                                                            for (int i = 0;
                                                                                i < editEducator.length;
                                                                                i++) {
                                                                              educatorIds.add(editEducator[i].id);
                                                                            }
                                                                            var _objToSend =
                                                                                {
                                                                              "obsId": widget.data?.id,
                                                                              "childIds": childIds,
                                                                              "emediaId": media[index].id,
                                                                              "imgCaption": caption.text.toString(),
                                                                              "educatorIds": educatorIds,
                                                                              "userid": MyApp.LOGIN_ID_VALUE,
                                                                            };
                                                                            print('educatoridsss');
                                                                            print(_objToSend);

                                                                            var resp =
                                                                                await http.post(Uri.parse(_toSend), body: jsonEncode(_objToSend), headers: {
                                                                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                            });
                                                                            print('this');
                                                                            print(resp.body.toString());
                                                                            var data =
                                                                                jsonDecode(resp.body);
                                                                            if (data['Status'] ==
                                                                                'SUCCESS') {
                                                                              Navigator.pop(context);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Text('ok'),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            } else {
                                                              MyApp.ShowToast(
                                                                  value[
                                                                      'Status'],
                                                                  context);
                                                            }
                                                          });
                                                        },
                                                      ))
                                                ],
                                              );
                                            } else {
                                              Timer(Duration(seconds: 10), () {
                                                print(Constants.ImageBaseUrl +
                                                    media[index].mediaUrl);
                                              });
                                              return Stack(
                                                children: [
                                                  // VideoItem(
                                                  //     width: 100,
                                                  //     height: 100,
                                                  //     url:  Constants
                                                  //             .ImageBaseUrl +
                                                  //         mediaFiles[index]
                                                  //             ['filename']),
                                                  VideoItem(
                                                      width: 100,
                                                      height: 100,
                                                      url: Constants
                                                              .ImageBaseUrl +
                                                          media[index]
                                                              .mediaUrl),
                                                  Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: GestureDetector(
                                                        child:
                                                            Icon(Icons.clear),
                                                        onTap: () {
                                                          showDeleteDialog(
                                                              context, () {
                                                            ObservationsAPIHandler
                                                                handler =
                                                                ObservationsAPIHandler({
                                                              "mediaid":
                                                                  media[index]
                                                                      .id,
                                                              "userid": MyApp
                                                                  .LOGIN_ID_VALUE
                                                            });
                                                            handler
                                                                .deleteMedia()
                                                                .then((value) {
                                                              var data =
                                                                  jsonDecode(
                                                                      value
                                                                          .body);
                                                              if (data[
                                                                      'Status'] ==
                                                                  'SUCCESS') {
                                                                media.removeAt(
                                                                    index);
                                                                setState(() {});
                                                              } else {
                                                                MyApp.ShowToast(
                                                                    data[
                                                                        'Status'],
                                                                    context);
                                                              }
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 22,
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                        ),
                                                        onTap: () {
                                                          print(
                                                              media[index].id);
                                                          ObservationsAPIHandler
                                                              handler =
                                                              ObservationsAPIHandler({
                                                            "mediaid":
                                                                media[index].id,
                                                            "userid": MyApp
                                                                .LOGIN_ID_VALUE
                                                          });
                                                          handler
                                                              .getMedia()
                                                              .then((value) {
                                                            if (value[
                                                                    'Status'] ==
                                                                'SUCCESS') {
                                                              TextEditingController
                                                                  caption =
                                                                  TextEditingController(
                                                                      text: value[
                                                                              'MediaInfo']
                                                                          [
                                                                          'caption']);
                                                              List<ChildModel>
                                                                  editChild =
                                                                  [];
                                                              List<StaffModel>
                                                                  editEducator =
                                                                  [];
                                                              String mediaId =
                                                                  value['MediaInfo']
                                                                      ['id'];

                                                              for (int i = 0;
                                                                  i <
                                                                      value['ChildTags']
                                                                          .length;
                                                                  i++) {
                                                                var childID =
                                                                    value['ChildTags']
                                                                            [i][
                                                                        'childId'];
                                                                for (int j = 0;
                                                                    j <
                                                                        _allChildrens
                                                                            .length;
                                                                    j++) {
                                                                  if (_allChildrens[
                                                                              j]
                                                                          .childid ==
                                                                      childID) {
                                                                    editChild.add(
                                                                        _allChildrens[
                                                                            j]);
                                                                  }
                                                                }
                                                              }
                                                              for (int i = 0;
                                                                  i <
                                                                      value['EducatorTags']
                                                                          .length;
                                                                  i++) {
                                                                var userID =
                                                                    value['EducatorTags']
                                                                            [i][
                                                                        'userId'];
                                                                for (int j = 0;
                                                                    j <
                                                                        _allEductarors
                                                                            .length;
                                                                    j++) {
                                                                  if (_allEductarors[
                                                                              j]
                                                                          .id ==
                                                                      userID) {
                                                                    editEducator.add(
                                                                        _allEductarors[
                                                                            j]);
                                                                  }
                                                                }
                                                              }
                                                              print('yee');
                                                              print('hry' +
                                                                  editEducator
                                                                      .toString());
                                                              print('hr' +
                                                                  editChild
                                                                      .toString());
                                                              print('hj');
                                                              //below also you need to add the same code

                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          "Edit Image"),
                                                                      content:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height * 0.6,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.7,
                                                                          child:
                                                                              ListView(
                                                                            children: [
                                                                              VideoItem(width: size.width / 8, height: size.height / 8, url: Constants.ImageBaseUrl + mediaFiles[index]['filename']),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text('Children'),
                                                                              SizedBox(
                                                                                height: 3,
                                                                              ),
                                                                              MultiSelectDialogField(
                                                                                items: _allChildrens.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                                initialValue: editChild,
                                                                                listType: MultiSelectListType.CHIP,
                                                                                onConfirm: (values) {
                                                                                  editChild = values;
                                                                                  print(editChild[0].id);
                                                                                },
                                                                              ),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text('Educators'),
                                                                              SizedBox(
                                                                                height: 3,
                                                                              ),
                                                                              MultiSelectDialogField(
                                                                                items: _allEductarors.map((e) => MultiSelectItem(e, e.name)).toList(),
                                                                                initialValue: editEducator,
                                                                                listType: MultiSelectListType.CHIP,
                                                                                onConfirm: (values) {
                                                                                  editEducator = values;
                                                                                },
                                                                              ),
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                              Text('Caption'),
                                                                              SizedBox(
                                                                                height: 3,
                                                                              ),
                                                                              Container(
                                                                                height: 30,
                                                                                child: TextField(
                                                                                    maxLines: 1,
                                                                                    controller: caption,
                                                                                    decoration: new InputDecoration(
                                                                                      enabledBorder: const OutlineInputBorder(
                                                                                        borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                      ),
                                                                                      border: new OutlineInputBorder(
                                                                                        borderRadius: const BorderRadius.all(
                                                                                          const Radius.circular(4),
                                                                                        ),
                                                                                      ),
                                                                                    )),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          onPressed:
                                                                              () async {
                                                                            var _toSend =
                                                                                'https://stage.todquest.com/mykronicle101/api/Observation/saveImageTags/';

                                                                            List
                                                                                childIds =
                                                                                [];
                                                                            List
                                                                                educatorIds =
                                                                                [];
                                                                            for (int i = 0;
                                                                                i < editChild.length;
                                                                                i++) {
                                                                              childIds.add(editChild[i].childid);
                                                                            }
                                                                            for (int i = 0;
                                                                                i < editEducator.length;
                                                                                i++) {
                                                                              educatorIds.add(editEducator[i].id);
                                                                            }
                                                                            var _objToSend =
                                                                                {
                                                                              "obsId": widget.data?.id,
                                                                              "childIds": childIds,
                                                                              "emediaId": media[index].id,
                                                                              "imgCaption": caption.text.toString(),
                                                                              "educatorIds": educatorIds,
                                                                              "userid": MyApp.LOGIN_ID_VALUE,
                                                                            };
                                                                            print(_objToSend);

                                                                            var resp =
                                                                                await http.post(Uri.parse(_toSend), body: jsonEncode(_objToSend), headers: {
                                                                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                                                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                                                            });
                                                                            var data =
                                                                                jsonDecode(resp.body);
                                                                            if (data['Status'] ==
                                                                                'SUCCESS') {
                                                                              Navigator.pop(context);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Text('ok'),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            } else {
                                                              MyApp.ShowToast(
                                                                  value[
                                                                      'Status'],
                                                                  context);
                                                            }
                                                          });
                                                        },
                                                      ))
                                                ],
                                              );
                                            }
                                          }),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 10,
                                  ),
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
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    'CANCEL',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      if (MyApp.USER_TYPE_VALUE == 'Parent')
                                        GestureDetector(
                                          onTap: () async {
                                            if (selectedChildrens.length > 0) {
                                              String title = mentionTitle
                                                      .currentState
                                                      ?.controller
                                                      ?.markupText ??
                                                  '';
                                              previewtitle = title;
                                              for (int i = 0;
                                                  i < mentionUser.length;
                                                  i++) {
                                                if (title.contains(
                                                    mentionUser[i]['name'])) {
                                                  title = title.replaceAll(
                                                      "@" +
                                                          mentionUser[i]
                                                              ['name'],
                                                      '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                                }
                                              }
                                              for (int i = 0;
                                                  i < mentionMont.length;
                                                  i++) {
                                                if (title.contains(
                                                    mentionMont[i]
                                                        ['display'])) {
                                                  title = title.replaceAll(
                                                      "#" +
                                                          mentionMont[i]
                                                              ['display'],
                                                      '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                                }
                                              }
                                              print(title);

                                              String notes = mentionNotes
                                                      .currentState
                                                      ?.controller
                                                      ?.markupText ??
                                                  "";
                                              previewnotes = notes;
                                              for (int i = 0;
                                                  i < mentionUser.length;
                                                  i++) {
                                                if (notes.contains(
                                                    mentionUser[i]['name'])) {
                                                  notes = notes.replaceAll(
                                                      "@" +
                                                          mentionUser[i]
                                                              ['name'],
                                                      '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                                }
                                              }
                                              for (int i = 0;
                                                  i < mentionMont.length;
                                                  i++) {
                                                if (notes.contains(
                                                    mentionMont[i]
                                                        ['display'])) {
                                                  notes = notes.replaceAll(
                                                      "#" +
                                                          mentionMont[i]
                                                              ['display'],
                                                      '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                                }
                                              }

                                              print(notes);
                                              String ref = '';
                                              if (MyApp.USER_TYPE_VALUE !=
                                                  'Parent') {
                                                ref = mentionRef
                                                        .currentState
                                                        ?.controller
                                                        ?.markupText ??
                                                    '';
                                                previewRef = ref;
                                                for (int i = 0;
                                                    i < mentionUser.length;
                                                    i++) {
                                                  if (ref.contains(
                                                      mentionUser[i]['name'])) {
                                                    ref = ref.replaceAll(
                                                        "@" +
                                                            mentionUser[i]
                                                                ['name'],
                                                        '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                                  }
                                                }
                                                for (int i = 0;
                                                    i < mentionMont.length;
                                                    i++) {
                                                  if (ref.contains(
                                                      mentionMont[i]
                                                          ['display'])) {
                                                    ref = ref.replaceAll(
                                                        "#" +
                                                            mentionMont[i]
                                                                ['display'],
                                                        '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                                  }
                                                }
                                                print(ref);
                                              }

                                              String child_voice = '';
                                              if (MyApp.USER_TYPE_VALUE !=
                                                  'Parent') {
                                                child_voice = mentionChildVoice
                                                        .currentState
                                                        ?.controller
                                                        ?.markupText ??
                                                    '';
                                                previewChildVoice = child_voice;
                                                for (int i = 0;
                                                    i < mentionUser.length;
                                                    i++) {
                                                  if (child_voice.contains(
                                                      mentionUser[i]['name'])) {
                                                    child_voice =
                                                        child_voice.replaceAll(
                                                            "@" +
                                                                mentionUser[i]
                                                                    ['name'],
                                                            '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                                  }
                                                }
                                                for (int i = 0;
                                                    i < mentionMont.length;
                                                    i++) {
                                                  if (child_voice.contains(
                                                      mentionMont[i]
                                                          ['display'])) {
                                                    child_voice =
                                                        child_voice.replaceAll(
                                                            "#" +
                                                                mentionMont[i]
                                                                    ['display'],
                                                            '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                                  }
                                                }
                                                print(child_voice);
                                              }

                                              String future_plan = '';
                                              if (MyApp.USER_TYPE_VALUE !=
                                                  'Parent') {
                                                future_plan = mentionFuturePlan
                                                        .currentState
                                                        ?.controller
                                                        ?.markupText ??
                                                    '';
                                                previewFuturePlan = future_plan;
                                                for (int i = 0;
                                                    i < mentionUser.length;
                                                    i++) {
                                                  if (future_plan.contains(
                                                      mentionUser[i]['name'])) {
                                                    future_plan =
                                                        future_plan.replaceAll(
                                                            "@" +
                                                                mentionUser[i]
                                                                    ['name'],
                                                            '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                                  }
                                                }
                                                for (int i = 0;
                                                    i < mentionMont.length;
                                                    i++) {
                                                  if (future_plan.contains(
                                                      mentionMont[i]
                                                          ['display'])) {
                                                    future_plan =
                                                        future_plan.replaceAll(
                                                            "#" +
                                                                mentionMont[i]
                                                                    ['display'],
                                                            '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                                  }
                                                }
                                                print(future_plan);
                                              }

                                              List child = [];
                                              for (int i = 0;
                                                  i < selectedChildrens.length;
                                                  i++) {
                                                child.add(
                                                    selectedChildrens[i].id);
                                              }

                                              Map<String, dynamic> mp;
                                              if (widget.type == 'edit') {
                                                mp = {
                                                  "childrens":
                                                      jsonEncode(child),
                                                  "title": title,
                                                  "notes": notes,
                                                  "userid":
                                                      MyApp.LOGIN_ID_VALUE,
                                                  "observationId":
                                                      widget.data?.id,
                                                  "status": "Draft",
                                                  "centerid": widget.centerid
                                                };

                                                if (MyApp.USER_TYPE_VALUE !=
                                                    'Parent') {
                                                  mp['reflection'] = ref;
                                                }
                                                if (MyApp.USER_TYPE_VALUE !=
                                                    'Parent') {
                                                  mp['child_voice'] = ref;
                                                }
                                                if (MyApp.USER_TYPE_VALUE !=
                                                    'Parent') {
                                                  mp['future_plan'] = ref;
                                                }

                                                List priorities = [];
                                                List origin = [];
                                                List mediaApi = [];

                                                if (files.length > 0) {
                                                  for (int p = 0;
                                                      p < files.length;
                                                      p++) {
                                                    priorities.add(p);
                                                    origin.add("NEW");
                                                  }
                                                  mp['fileno'] = jsonEncode(
                                                      List.generate(
                                                          files.length,
                                                          (index) => index));
                                                }

                                                if (mediaFiles.length > 0) {
                                                  for (int k = 0;
                                                      k < mediaFiles.length;
                                                      k++) {
                                                    priorities.add(
                                                        mediaFiles[k]['id']);
                                                    origin.add("UPLOADED");
                                                    mediaApi.add(
                                                        mediaFiles[k]['id']);
                                                  }
                                                }

                                                if (media.length > 0) {
                                                  for (int k = 0;
                                                      k < media.length;
                                                      k++) {
                                                    priorities.add(media[k].id);
                                                    origin.add("OBSERVED");
                                                    mediaApi.add(media[k].id);
                                                  }
                                                }

                                                if (files.length > 0 ||
                                                    mediaFiles.length > 0 ||
                                                    media.length > 0) {
                                                  mp['priority'] =
                                                      jsonEncode(priorities);
                                                  mp['origin'] =
                                                      jsonEncode(origin);
                                                  mp['mediaid'] =
                                                      jsonEncode(mediaApi);
                                                }
                                              } else {
                                                mp = {
                                                  "childrens":
                                                      jsonEncode(child),
                                                  "title": title,
                                                  "notes": notes,
                                                  "status": "Draft",
                                                  "userid":
                                                      MyApp.LOGIN_ID_VALUE,
                                                  "centerid": widget.centerid
                                                };

                                                if (MyApp.USER_TYPE_VALUE !=
                                                    'Parent') {
                                                  mp['reflection'] = ref;
                                                }
                                                if (MyApp.USER_TYPE_VALUE !=
                                                    'Parent') {
                                                  mp['child_voice'] = ref;
                                                }
                                                if (MyApp.USER_TYPE_VALUE !=
                                                    'Parent') {
                                                  mp['future_plan'] = ref;
                                                }

                                                List priorities = [];
                                                List origin = [];
                                                if (files.length > 0) {
                                                  for (int p = 0;
                                                      p < files.length;
                                                      p++) {
                                                    priorities.add(p);
                                                    origin.add("NEW");
                                                  }
                                                  mp['fileno'] = jsonEncode(
                                                      List.generate(
                                                          files.length,
                                                          (index) => index));
                                                }
                                                if (mediaFiles.length > 0) {
                                                  for (int k = 0;
                                                      k < mediaFiles.length;
                                                      k++) {
                                                    priorities.add(
                                                        mediaFiles[k]['id']);
                                                    origin.add("UPLOADED");
                                                  }
                                                  mp['mediaid'] = jsonEncode(
                                                      List.generate(
                                                          mediaFiles.length,
                                                          (index) =>
                                                              mediaFiles[index]
                                                                  ['id']));
                                                }

                                                if (files.length > 0 ||
                                                    mediaFiles.length > 0) {
                                                  mp['priority'] =
                                                      jsonEncode(priorities);
                                                  mp['origin'] =
                                                      jsonEncode(origin);
                                                }
                                              }

                                              for (int i = 0;
                                                  i < mediaFiles.length;
                                                  i++) {
                                                String p =
                                                    'upl-media-tags-child' +
                                                        mediaFiles[i]['id'];
                                                List ch = [];
                                                if (_editMediaFileChildren[i]
                                                        .length >
                                                    0) {
                                                  for (int j = 0;
                                                      j <
                                                          _editMediaFileChildren[
                                                                  i]
                                                              .length;
                                                      j++) {
                                                    ch.add(int.parse(
                                                        _editMediaFileChildren[
                                                                i][j]
                                                            .id));
                                                  }
                                                }
                                                mp[p] = jsonEncode(ch);

                                                String u =
                                                    'upl-media-tags-educator' +
                                                        mediaFiles[i]['id'];
                                                List ed = [];
                                                if (_editMediaFileEducators[i]
                                                        .length >
                                                    0) {
                                                  for (int j = 0;
                                                      j <
                                                          _editMediaFileEducators[
                                                                  i]
                                                              .length;
                                                      j++) {
                                                    ed.add(int.parse(
                                                        _editMediaFileEducators[
                                                                i][j]
                                                            .id));
                                                  }
                                                }
                                                mp[u] = jsonEncode(ed);

                                                String k =
                                                    'upl-media-tags-caption' +
                                                        mediaFiles[i]['id'];
                                                mp[k] = mediaFilecaptions[i]
                                                    .text
                                                    .toString();
                                              }

                                              for (int i = 0;
                                                  i < files.length;
                                                  i++) {
                                                File file = files[i];
                                                String p =
                                                    'obsImage_' + i.toString();
                                                List ch = [];
                                                if (_editChildren[i].length >
                                                    0) {
                                                  for (int j = 0;
                                                      j <
                                                          _editChildren[i]
                                                              .length;
                                                      j++) {
                                                    ch.add(int.parse(
                                                        _editChildren[i][j]
                                                            .id));
                                                  }
                                                }
                                                mp[p] = jsonEncode(ch);

                                                String u = 'obsEducator_' +
                                                    i.toString();
                                                List ed = [];
                                                if (_editEducators[i].length >
                                                    0) {
                                                  for (int j = 0;
                                                      j <
                                                          _editEducators[i]
                                                              .length;
                                                      j++) {
                                                    ed.add(int.parse(
                                                        _editEducators[i][j]
                                                            .id));
                                                  }
                                                }
                                                mp[u] = jsonEncode(ed);

                                                String k = 'obsCaption_' +
                                                    i.toString();
                                                mp[k] =
                                                    captions[i].text.toString();

                                                String m =
                                                    'obsMedia' + i.toString();
                                                mp[m] = await MultipartFile
                                                    .fromFile(file.path,
                                                        filename: basename(
                                                            file.path));
                                              }

                                              print(mp);
                                              print(Constants.BASE_URL +
                                                  "Observation/editObservation");
                                              FormData formData =
                                                  FormData.fromMap(mp);

                                              print(formData.fields.toString());
                                              Dio dio = new Dio();
                                              print(formData);

                                              Response? response = await dio
                                                  .post(
                                                      widget.type == 'edit'
                                                          ? Constants.BASE_URL +
                                                              "Observation/editObservation"
                                                          : Constants.BASE_URL +
                                                              "observation/createObservation",
                                                      data: formData,
                                                      options:
                                                          Options(headers: {
                                                        'X-DEVICE-ID': await MyApp
                                                            .getDeviceIdentity(),
                                                        'X-TOKEN': MyApp
                                                            .AUTH_TOKEN_VALUE,
                                                      }))
                                                  .then((value) {
                                                print(
                                                    'happ' + value.toString());
                                                var v = jsonDecode(
                                                    value.toString());
                                                obsid = v['id'].toString();
                                                if (v['Status'] == 'SUCCESS') {
                                                  if (MyApp.USER_TYPE_VALUE !=
                                                      'Parent') {
                                                    obs.obsid =
                                                        v['id'].toString();
                                                    print(obs.obsid +
                                                        'val' +
                                                        obsid);
                                                    print(obs.data.toString() +
                                                        'val');
                                                    _controller!.index = 1;
                                                  } else {
                                                    MyApp.ShowToast(
                                                        "Saved Successfully",
                                                        context);
                                                  }
                                                } else {
                                                  MyApp.ShowToast(
                                                      "error", context);
                                                }
                                              }).catchError(
                                                      (error) => print(error));
                                            } else {
                                              MyApp.ShowToast(
                                                  "select children", context);
                                            }
                                          },
                                          child: Container(
                                              width: 65,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                  color: Constants.kButton,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      'DRAFT',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (selectedChildrens.length > 0) {
                                            String title = mentionTitle
                                                .currentState!
                                                .controller!
                                                .markupText;
                                            for (int i = 0;
                                                i < mentionUser.length;
                                                i++) {
                                              if (title.contains(
                                                  mentionUser[i]['name'])) {
                                                title = title.replaceAll(
                                                    "@" +
                                                        mentionUser[i]['name'],
                                                    '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                              }
                                            }
                                            for (int i = 0;
                                                i < mentionMont.length;
                                                i++) {
                                              if (title.contains(
                                                  mentionMont[i]['display'])) {
                                                title = title.replaceAll(
                                                    "#" +
                                                        mentionMont[i]
                                                            ['display'],
                                                    '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                              }
                                            }
                                            print(title);

                                            String notes = mentionNotes
                                                .currentState!
                                                .controller!
                                                .markupText;
                                            for (int i = 0;
                                                i < mentionUser.length;
                                                i++) {
                                              if (notes.contains(
                                                  mentionUser[i]['name'])) {
                                                notes = notes.replaceAll(
                                                    "@" +
                                                        mentionUser[i]['name'],
                                                    '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                              }
                                            }
                                            for (int i = 0;
                                                i < mentionMont.length;
                                                i++) {
                                              if (notes.contains(
                                                  mentionMont[i]['display'])) {
                                                notes = notes.replaceAll(
                                                    "#" +
                                                        mentionMont[i]
                                                            ['display'],
                                                    '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                              }
                                            }
                                            print(notes);
                                            String ref = '';
                                            if (MyApp.USER_TYPE_VALUE !=
                                                'Parent') {
                                              ref = mentionRef.currentState!
                                                  .controller!.markupText;
                                              for (int i = 0;
                                                  i < mentionUser.length;
                                                  i++) {
                                                if (ref.contains(
                                                    mentionUser[i]['name'])) {
                                                  ref = ref.replaceAll(
                                                      "@" +
                                                          mentionUser[i]
                                                              ['name'],
                                                      '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                                }
                                              }
                                              for (int i = 0;
                                                  i < mentionMont.length;
                                                  i++) {
                                                if (ref.contains(mentionMont[i]
                                                    ['display'])) {
                                                  ref = ref.replaceAll(
                                                      "#" +
                                                          mentionMont[i]
                                                              ['display'],
                                                      '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                                }
                                              }
                                              print(ref);
                                            }

                                            String child_voice = '';
                                            if (MyApp.USER_TYPE_VALUE !=
                                                'Parent') {
                                              child_voice = mentionChildVoice
                                                  .currentState!
                                                  .controller!
                                                  .markupText;
                                              for (int i = 0;
                                                  i < mentionUser.length;
                                                  i++) {
                                                if (child_voice.contains(
                                                    mentionUser[i]['name'])) {
                                                  child_voice = ref.replaceAll(
                                                      "@" +
                                                          mentionUser[i]
                                                              ['name'],
                                                      '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                                }
                                              }
                                              for (int i = 0;
                                                  i < mentionMont.length;
                                                  i++) {
                                                if (child_voice.contains(
                                                    mentionMont[i]
                                                        ['display'])) {
                                                  child_voice =
                                                      child_voice.replaceAll(
                                                          "#" +
                                                              mentionMont[i]
                                                                  ['display'],
                                                          '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                                }
                                              }
                                              print(child_voice);
                                            }

                                            String future_plan = '';
                                            if (MyApp.USER_TYPE_VALUE !=
                                                'Parent') {
                                              future_plan = mentionFuturePlan
                                                  .currentState!
                                                  .controller!
                                                  .markupText;
                                              for (int i = 0;
                                                  i < mentionUser.length;
                                                  i++) {
                                                if (future_plan.contains(
                                                    mentionUser[i]['name'])) {
                                                  child_voice =
                                                      future_plan.replaceAll(
                                                          "@" +
                                                              mentionUser[i]
                                                                  ['name'],
                                                          '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                                }
                                              }
                                              for (int i = 0;
                                                  i < mentionMont.length;
                                                  i++) {
                                                if (future_plan.contains(
                                                    mentionMont[i]
                                                        ['display'])) {
                                                  future_plan =
                                                      future_plan.replaceAll(
                                                          "#" +
                                                              mentionMont[i]
                                                                  ['display'],
                                                          '<a data-tagid="${mentionMont[i]['id']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="#tags_${mentionMont[i]['id']}" link="#tags_${mentionMont[i]['id']}">#${mentionMont[i]['display']}</a>');
                                                }
                                              }
                                              print(future_plan);
                                            }

                                            List child = [];
                                            for (int i = 0;
                                                i < selectedChildrens.length;
                                                i++) {
                                              child
                                                  .add(selectedChildrens[i].id);
                                            }

                                            Map<String, dynamic> mp;
                                            if (widget.type == 'edit') {
                                              mp = {
                                                "childrens": jsonEncode(child),
                                                "title": title,
                                                "notes": notes,
                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                "observationId":
                                                    widget.data?.id,
                                                "status": "Published",
                                                "centerid": widget.centerid,
                                              };

                                              if (MyApp.USER_TYPE_VALUE !=
                                                  'Parent') {
                                                mp['reflection'] = ref;
                                              }
                                              if (MyApp.USER_TYPE_VALUE !=
                                                  'Parent') {
                                                mp['child_voice'] = child_voice;
                                              }
                                              if (MyApp.USER_TYPE_VALUE !=
                                                  'Parent') {
                                                mp['future_plan'] = future_plan;
                                              }

                                              List priorities = [];
                                              List origin = [];
                                              List mediaApi = [];

                                              if (files.length > 0) {
                                                for (int p = 0;
                                                    p < files.length;
                                                    p++) {
                                                  priorities.add(p);
                                                  origin.add("NEW");
                                                }
                                                mp['fileno'] = jsonEncode(
                                                    List.generate(files.length,
                                                        (index) => index));
                                              }

                                              if (mediaFiles.length > 0) {
                                                for (int k = 0;
                                                    k < mediaFiles.length;
                                                    k++) {
                                                  priorities
                                                      .add(mediaFiles[k]['id']);
                                                  origin.add("UPLOADED");
                                                  mediaApi.add(mediaFiles[k]['id']);
                                                }
                                              }

                                              if (media.length > 0) {
                                                for (int k = 0;
                                                    k < media.length;
                                                    k++) {
                                                  priorities.add(media[k].id);
                                                  origin.add("OBSERVED");
                                                  mediaApi.add(media[k].id);
                                                }
                                              }

                                              if (files.length > 0 ||
                                                  mediaFiles.length > 0 ||
                                                  media.length > 0) {
                                                mp['priority'] =
                                                    jsonEncode(priorities);
                                                mp['origin'] =
                                                    jsonEncode(origin);
                                                mp['mediaid'] =
                                                    jsonEncode(mediaApi);
                                              }
                                            } else {
                                              mp = {
                                                "childrens": jsonEncode(child),
                                                "title": title,
                                                "notes": notes,
                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                "centerid": widget.centerid
                                              };

                                              if (MyApp.USER_TYPE_VALUE !=
                                                  'Parent') {
                                                mp['reflection'] = ref;
                                              } else {
                                                mp['status'] = "Published";
                                              }
                                              if (MyApp.USER_TYPE_VALUE !=
                                                  'Parent') {
                                                mp['child_voice'] = child_voice;
                                              }
                                              if (MyApp.USER_TYPE_VALUE !=
                                                  'Parent') {
                                                mp['future_plan'] = future_plan;
                                              }

                                              List priorities = [];
                                              List origin = [];
                                              if (files.length > 0) {
                                                for (int p = 0;
                                                    p < files.length;
                                                    p++) {
                                                  priorities.add(p);
                                                  origin.add("NEW");
                                                }
                                                mp['fileno'] = jsonEncode(
                                                    List.generate(files.length,
                                                        (index) => index));
                                              }
                                              if (mediaFiles.length > 0) {
                                                for (int k = 0;
                                                    k < mediaFiles.length;
                                                    k++) {
                                                  priorities
                                                      .add(mediaFiles[k]['id']);
                                                  origin.add("UPLOADED");
                                                }
                                                mp['mediaid'] = jsonEncode(
                                                    List.generate(
                                                        mediaFiles.length,
                                                        (index) =>
                                                            mediaFiles[index]
                                                                ['id']));
                                              }

                                              if (files.length > 0 ||
                                                  mediaFiles.length > 0) {
                                                mp['priority'] =
                                                    jsonEncode(priorities);
                                                mp['origin'] =
                                                    jsonEncode(origin);
                                              }
                                            }

                                            for (int i = 0;
                                                i < mediaFiles.length;
                                                i++){
                                              String p = 
                                                  'upl-media-tags-child' +
                                                      mediaFiles[i]['id'];
                                              List ch = [];
                                              if (_editMediaFileChildren[i]
                                                      .length >
                                                  0) {
                                                for (int j = 0;
                                                    j <
                                                        _editMediaFileChildren[
                                                                i]
                                                            .length;
                                                    j++) {
                                                  ch.add(int.parse(
                                                      _editMediaFileChildren[i]
                                                              [j]
                                                          .id));
                                                }
                                              }
                                              mp[p] = jsonEncode(ch);

                                              String u =
                                                  'upl-media-tags-educator' +
                                                      mediaFiles[i]['id'];
                                              List ed = [];
                                              if (_editMediaFileEducators[i]
                                                      .length >
                                                  0) {
                                                for (int j = 0;
                                                    j <
                                                        _editMediaFileEducators[
                                                                i]
                                                            .length;
                                                    j++) {
                                                  ed.add(int.parse(
                                                      _editMediaFileEducators[i]
                                                              [j]
                                                          .id));
                                                }
                                              }
                                              mp[u] = jsonEncode(ed);

                                              String k =
                                                  'upl-media-tags-caption' +
                                                      mediaFiles[i]['id'];
                                              mp[k] = mediaFilecaptions[i]
                                                  .text
                                                  .toString();
                                            }

                                            for (int i = 0;
                                                i < files.length;
                                                i++) {
                                              File file = files[i];
                                              String p =
                                                  'obsImage_' + i.toString();
                                              List ch = [];
                                              if (_editChildren[i].length > 0) {
                                                for (int j = 0;
                                                    j < _editChildren[i].length;
                                                    j++) {
                                                  ch.add(int.parse(
                                                      _editChildren[i][j].id));
                                                }
                                              }
                                              mp[p] = jsonEncode(ch);

                                              String u =
                                                  'obsEducator_' + i.toString();
                                              List ed = [];
                                              if (_editEducators[i].length >
                                                  0) {
                                                for (int j = 0;
                                                    j <
                                                        _editEducators[i]
                                                            .length;
                                                    j++) {
                                                  ed.add(int.parse(
                                                      _editEducators[i][j].id));
                                                }
                                              }
                                              mp[u] = jsonEncode(ed);

                                              String k =
                                                  'obsCaption_' + i.toString();
                                              mp[k] =
                                                  captions[i].text.toString();

                                              String m =
                                                  'obsMedia' + i.toString();
                                              mp[m] =
                                                  await MultipartFile.fromFile(
                                                      file.path,
                                                      filename:
                                                          basename(file.path));
                                            }

                                            print(mp);

                                            FormData formData =
                                                FormData.fromMap(mp);

                                            print(formData.fields.toString());
                                            Dio dio = new Dio();
                                            print('fields');
                                            print(formData.fields);
                                            print(Constants.BASE_URL +
                                                "observation/createObservation");
                                            print(await MyApp
                                                .getDeviceIdentity());
                                            print(MyApp.AUTH_TOKEN_VALUE);
                                            Response? response = await dio.post(
                                                    widget.type == 'edit'
                                                        ? Constants.BASE_URL +
                                                            "Observation/editObservation"
                                                        : Constants.BASE_URL +
                                                            "observation/createObservation",
                                                    data: formData,
                                                    options: Options(headers: {
                                                      'X-DEVICE-ID': await MyApp
                                                          .getDeviceIdentity(),
                                                      'X-TOKEN': MyApp
                                                          .AUTH_TOKEN_VALUE,
                                                    }))
                                                .then((value) {
                                              print('happ' + value.toString());
                                              var v =
                                                  jsonDecode(value.toString());
                                              obsid = v['id'].toString();
                                              if (v['Status'] == 'SUCCESS') {
                                                obs.obsid = v['id'].toString();
                                                print(
                                                    obs.obsid + 'val' + obsid);
                                                print(obs.data.toString() +
                                                    'val');
                                                _controller!.index = 1;
                                              } else {
                                                MyApp.ShowToast(
                                                    "error", context);
                                              }
                                            }).catchError((error, stacktrace) {
                                              print('here================');
                                              print(error);
                                              print(stacktrace);
                                            });
                                          } else {
                                            MyApp.ShowToast(
                                                "select children", context);
                                          }
                                        },
                                        child: Container(
                                            width: MyApp.USER_TYPE_VALUE ==
                                                    'Parent'
                                                ? 80
                                                : 112,
                                            height: 38,
                                            decoration: BoxDecoration(
                                                color: Constants.kButton,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    MyApp.USER_TYPE_VALUE !=
                                                            'Parent'
                                                        ? 'SAVE & NEXT'
                                                        : 'PUBLISH',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            if (MyApp.USER_TYPE_VALUE != 'Parent')
                              SingleChildScrollView(
                                  child: AssesmentsTabs(
                                assesData: assesData,
                                viewData: viewData,
                                changeTab: (v) async {
                                  _controller!.index = 2;
                                },
                              )),
                            if (MyApp.USER_TYPE_VALUE != 'Parent') Links()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  _dialog(var context, List images) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Choose File',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
              body: SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            List<Widget>.generate(images.length, (int index) {
                          if (images[index]['type'] == 'Image') {
                            return GestureDetector(
                              onTap: () {
                                mediaFiles.add(images[index]);
                                mediaFilecaptions.add(TextEditingController());
                                _editMediaFileChildren.add([]);
                                _editMediaFileEducators.add([]);
                                h = h + 100.0;
                                print(mediaFiles);
                                setState(() {});
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: new BoxDecoration(
                                    //  borderRadius: BorderRadius.circular(15.0),
                                    shape: BoxShape.rectangle,
                                    image: new DecorationImage(
                                      image: new NetworkImage(
                                          Constants.ImageBaseUrl +
                                              images[index]['filename']),
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                mediaFiles.add(images);
                                print(mediaFiles);
                                setState(() {});
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: VideoItem(
                                  width: 100,
                                  height: 100,
                                  url: Constants.ImageBaseUrl +
                                      images[index]['filename']),
                            );
                          }
                        }))
                  ],
                )),
              )),
            );
          });
        });
  }

  Future<File> compressAndGetFile(File file, String targetPath) async {
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 900,
      minHeight: 900,
      quality: 40,
    );

    if (result == null) {
      throw Exception("Compression failed: Unable to get compressed file.");
    }

    File compressedFile = File(result.path); // Convert XFile to File

    print("Original size: ${file.lengthSync()} bytes");
    print("Compressed size: ${compressedFile.lengthSync()} bytes");

    return compressedFile;
  }

  Widget rectBorderWidget(Size size, var context) {
    return DottedBorder(
      dashPattern: [8, 4],
      strokeWidth: 2,
      child: Container(
        width: 100,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: null,
              ),
              Text('Upload'),
            ],
          ),
        ),
      ),
    );
  }
}
