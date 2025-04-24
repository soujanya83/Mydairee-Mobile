import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/extrasmodel.dart';
import 'package:mykronicle_mobile/models/eylfmodel.dart';
import 'package:mykronicle_mobile/models/montessorimodel.dart';
import 'package:mykronicle_mobile/models/montisarisubjectmodel.dart';
import 'package:mykronicle_mobile/models/roomsmodel.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';

class AddPlan extends StatefulWidget {
  final String type;
  final String centerid;
  final String planId;
  final Map? totaldata;

  AddPlan(
    this.type,
    this.centerid,
    this.planId,
    this.totaldata,
  );

  @override
  _AddPlanState createState() => _AddPlanState();
}

class _AddPlanState extends State<AddPlan> {
  // Dropdown values
  String? selectedMonth;
  String? selectedYear;
  RoomsDescModel? selectedRoom;
  List<UserModel> selectedEducators = [];
  List<ChildModel> selectedChildren = [];
  bool expandeylf = false;
  List<EylfOutcomeModel> eylfData = [];

  MontessariSubjectModel? practicalLifeData;
  final TextEditingController practicalLifeController = TextEditingController();

  MontessariSubjectModel? sensorialData;
  final TextEditingController sensorialController = TextEditingController();
  MontessariSubjectModel? mathData;
  final TextEditingController mathController = TextEditingController();
  MontessariSubjectModel? languageData;
  final TextEditingController languageController = TextEditingController();
  MontessariSubjectModel? cultureData;
  final TextEditingController cultureController = TextEditingController();

  // Dropdown data
  final List<String> months = [
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

  final List<String> years =
      List.generate(21, (index) => (2015 + index).toString());

  // Text editing controllers
  final TextEditingController focusAreasController = TextEditingController();
  final TextEditingController outdoorExperiencesController =
      TextEditingController();
  final TextEditingController inquiryTopicController = TextEditingController();
  final TextEditingController sustainabilityTopicController =
      TextEditingController();
  final TextEditingController specialEventsController = TextEditingController();
  final TextEditingController childrenVoicesController =
      TextEditingController();
  final TextEditingController familiesInputController = TextEditingController();
  final TextEditingController groupExperienceController = TextEditingController();
  final TextEditingController spontaneousExperienceController =
      TextEditingController();
  final TextEditingController mindfulnessExperienceController =
      TextEditingController();

  final TextEditingController eylfController = TextEditingController();

  @override
  void dispose() {
    focusAreasController.dispose();
    outdoorExperiencesController.dispose();
    inquiryTopicController.dispose();
    sustainabilityTopicController.dispose();
    specialEventsController.dispose();
    childrenVoicesController.dispose();
    familiesInputController.dispose();
    spontaneousExperienceController.dispose();
    mindfulnessExperienceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    assignAssessmentData();
  }

  List<RoomsModel> _rooms = [];
  List<ChildModel> childs = [];
  List<UserModel> users = [];
  var res;
  int currentRoomIndex = 0;

  Future<void> fetchData() async {
    try {
      RoomAPIHandler handler = RoomAPIHandler({
        "userid": MyApp.LOGIN_ID_VALUE,
        "centerid": widget.centerid, // ✅ Use correct center id
      });
      var data = await handler.getList();

      if (data != null && !data.containsKey('error')) {
        res = data['rooms'];
        _rooms = [];

        for (int i = 0; i < res.length; i++) {
          List<ChildModel> childsLocal = [];

          if (res[i]['childs'] != null && res[i]['childs'] is List) {
            for (int j = 0; j < res[i]['childs'].length; j++) {
              childsLocal.add(ChildModel.fromJson(res[i]['childs'][j]));
            }
          }

          RoomsDescModel roomDesc = RoomsDescModel.fromJson(res[i]);
          _rooms.add(RoomsModel(child: childsLocal, room: roomDesc));
        }

        if (res != null && res is List) {
          users = [];
          if (res[currentRoomIndex]['educators'] != null &&
              res[currentRoomIndex]['educators'] is List) {
            for (int j = 0;
                j < res[currentRoomIndex]['educators'].length;
                j++) {
              print('+++++++user initialize+++++++');
              users.add(
                  UserModel.fromJson(res[currentRoomIndex]['educators'][j]));

              eduValues[users[j].userid] = false;
            }
          }
          if (res[currentRoomIndex]['childs'] != null &&
              res[currentRoomIndex]['childs'] is List) {
            for (int j = 0; j < res[currentRoomIndex]['childs'].length; j++) {
              childs
                  .add(ChildModel.fromJson(res[currentRoomIndex]['childs'][j]));
              childValues[childs[j].id] = false;
            }
          }
        } else {
          print("Rooms list is null or not a List");
        }
        if (this.mounted) setState(() {});
      } else {
        print("Error in API: $data");
      }
    } catch (e, s) {
      print("Exception in fetchRoomsOnly: $e");
      print(s);
    }
  }

  changeRoomWithEducatorAndChild(int index) {
    if (res != null && res is List) {
      users = [];
      eduValues = {};
      childs = [];
      childValues = {};
      if (res[index]['educators'] != null && res[index]['educators'] is List) {
        for (int j = 0; j < res[index]['educators'].length; j++) {
          users.add(UserModel.fromJson(res[index]['educators'][j]));
          eduValues[users[j].userid] = false;
        }
      }
      if (res[index]['childs'] != null && res[index]['childs'] is List) {
        for (int j = 0; j < res[index]['childs'].length; j++) {
          childs.add(ChildModel.fromJson(res[index]['childs'][j]));
          childValues[childs[j].id] = false;
        }
      }
    } else {
      print("Rooms list is null or not a List");
    }
    if (this.mounted) setState(() {});
  }

  // int _radioValue = 0;
  bool all = false;
  List<UserModel> selectedEdu = [];
  Map<String, bool> eduValues = {};
  Map<String, bool> childValues = {};
  List<ChildModel> selectedChildrens = [];
  String endmenu = '';

  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

//assessment data

// assesment data
  static List<List<List<bool>>> checkValue = [];
  static List<List<bool>> e = [];
  static Map assesData = {};

// montessori data
  static List<List<bool>> em = [];
  static List<List<List<List<ExtrasModel>>>> extras = [];
  static List<List<List<String>>> dropAns = [];
  static List<List<List<List<bool>>>> selectedExtras = [];

  assignAssessmentData() async {
    print('+++++eylf data+++++');
    print(assesData['EYLF']);
    // return;
    ObservationsAPIHandler handling = ObservationsAPIHandler({
      "userid": MyApp.LOGIN_ID_VALUE,
      "obsid": '',
      "centerid": widget.centerid
    });
    assesData = await handling.getAssesmentsData();
    //eylf
    eylfData = (assesData['EYLF']['outcome'] as List<dynamic>)
        .map((e) => EylfOutcomeModel.fromJson(e))
        .toList();
    for (int i = 0; i < eylfData.length; i++) {
      for (int j = 0; j < eylfData[i].activity.length; j++) {
        for (int k = 0; k < eylfData[i].activity[j].subActivity.length; k++) {
          final sub = eylfData[i].activity[j].subActivity[k];
          if (widget.totaldata?['observationEylf'] != null) {
            for (final existing in widget.totaldata!['observationEylf']) {
              if (sub.id == existing['eylfSubactivityId']) {
                eylfData[i].activity[j].boolCheck = true;
                sub.checked = 'true';
              }
            }
          }
        }
      }
    }

    // montesssori montessariData
    for (int i = 0; i < (assesData['Montessori']['Subjects'].length); i++) {
      print('=======================================');
      print(assesData['Montessori']['Subjects'][i]['name'].toString());
      if (assesData['Montessori']['Subjects'][i]['name'].toString() ==
          'Practical Life') {
        practicalLifeData = MontessariSubjectModel.fromJson(
            assesData['Montessori']['Subjects'][i]);
      } else if (assesData['Montessori']['Subjects'][i]['name'].toString() ==
          'Sensorial') {
        sensorialData = MontessariSubjectModel.fromJson(
            assesData['Montessori']['Subjects'][i]);
      } else if (assesData['Montessori']['Subjects'][i]['name'].toString() ==
          'Maths') {
        mathData = MontessariSubjectModel.fromJson(
            assesData['Montessori']['Subjects'][i]);
      } else if (assesData['Montessori']['Subjects'][i]['name'].toString() ==
          'Language') {
        languageData = MontessariSubjectModel.fromJson(
            assesData['Montessori']['Subjects'][i]);
      } else if (assesData['Montessori']['Subjects'][i]['name'].toString() ==
          'Cultural') {
        cultureData = MontessariSubjectModel.fromJson(
            assesData['Montessori']['Subjects'][i]);
      }
    }
  }

  assignDataInEylfController() {
    eylfController.text = '';
    print('=================================================');
    for (int parentIndex = 0; parentIndex < eylfData.length; parentIndex++) {
      print(
          '====================*******i*****=$parentIndex============================');
      for (int childIndex = 0;
          childIndex < eylfData[parentIndex].activity.length;
          childIndex++) {
        print(
            '====================##########j##########=$childIndex===($parentIndex)=========================');
        print(
            '======value=${eylfData[parentIndex].activity[childIndex].choosen}==========');
        if (eylfData[parentIndex].activity[childIndex].choosen) {
          eylfController.text +=
              (("${eylfData[parentIndex].title} - ${eylfData[parentIndex].name}") +
                      ' : ' +
                      eylfData[parentIndex].activity[childIndex].title) +
                  '\n';
        }
      }
    }
  }

  assignPracticalLifeInController() {
    practicalLifeController.text = '';
    print(
        '======================PracticalLifeController===========================');
    for (int parentIndex = 0;
        parentIndex < (practicalLifeData?.activity.length ?? 0);
        parentIndex++) {
      print(
          '====================*******i*****=$parentIndex============================');
      for (int childIndex = 0;
          childIndex <
              (practicalLifeData?.activity[parentIndex].subActivity?.length ??
                  0);
          childIndex++) {
        print(
            '====================##########j##########=$childIndex===($parentIndex)=========================');
        print(
            '======value=${practicalLifeData?.activity[parentIndex].subActivity[childIndex].choosen ?? false}==========');
        if (practicalLifeData
                ?.activity[parentIndex].subActivity[childIndex].choosen ??
            false) {
          practicalLifeController.text +=
              (("${practicalLifeData?.activity[parentIndex].title} -") +
                      (practicalLifeData?.activity[parentIndex]
                              .subActivity[childIndex].title ??
                          '')) +
                  '\n';
        }
      }
    }
  }

  void assignSensorialInController() {
    sensorialController.text = '';

    if (sensorialData == null || sensorialData!.activity.isEmpty) return;

    for (var activity in sensorialData!.activity) {
      for (var sub in activity.subActivity ?? []) {
        if (sub.choosen) {
          sensorialController.text += '${activity.title} - ${sub.title}\n';
        }
      }
    }
  }

  void assignMathInController() {
    mathController.text = '';

    if (mathData == null || mathData!.activity.isEmpty) return;

    for (var activity in mathData!.activity) {
      for (var sub in activity.subActivity ?? []) {
        if (sub.choosen) {
          mathController.text += '${activity.title} - ${sub.title}\n';
        }
      }
    }
  }

  void assignLanguageInController() {
    languageController.text = '';

    if (languageData == null || languageData!.activity.isEmpty) return;

    for (var activity in languageData!.activity) {
      for (var sub in activity.subActivity ?? []) {
        if (sub.choosen) {
          languageController.text += '${activity.title} - ${sub.title}\n';
        }
      }
    }
  }

  void assignCultureInController() {
    cultureController.text = '';

    if (cultureData == null || cultureData!.activity.isEmpty) return;

    for (var activity in cultureData!.activity) {
      for (var sub in activity.subActivity ?? []) {
        if (sub.choosen) {
          cultureController.text += '${activity.title} - ${sub.title}\n';
        }
      }
    }
  }

  void showEylfDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.zero,
              title: Text(
                'Select EYLF',
                style: Constants.header4,
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Text(
                          'Early Years Learning Framework (EYLF) - Australia (V2.0 2022)',
                          style: Constants.header3,
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                            children:
                                List.generate(eylfData.length, (parentIndex) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor:
                                    Colors.transparent, // remove default line
                              ),
                              child: ExpansionTile(
                                  tilePadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                  childrenPadding: EdgeInsets.only(
                                      left: 12, right: 12, bottom: 12),
                                  title: Text(
                                    "${eylfData[parentIndex].title} - ${eylfData[parentIndex].name}",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  // leading: Icon(
                                  //   Icons.keyboard_arrow_right,
                                  //   color: Colors.blueAccent,
                                  // ),
                                  trailing: null,
                                  onExpansionChanged: (val) {
                                    setState(() {
                                      // No external variable `expandeylf` needed unless you want it globally
                                    });
                                  },
                                  children: List.generate(
                                      eylfData[parentIndex].activity.length,
                                      (childIndex) {
                                    return CheckboxListTile(
                                      title: Text(
                                        eylfData[parentIndex]
                                            .activity[childIndex]
                                            .title,
                                      ),
                                      value: eylfData[parentIndex]
                                          .activity[childIndex]
                                          .choosen,
                                      onChanged: (val) {
                                        setState(() {
                                          eylfData[parentIndex]
                                              .activity[childIndex]
                                              .choosen = val ?? false;
                                          print(
                                              '===================choosen value is===================');
                                          print(eylfData[parentIndex]
                                              .activity[childIndex]
                                              .choosen);
                                          assignDataInEylfController();
                                        });
                                      },
                                    );
                                  })
                                  //  outcome.activity.map((activity) {
                                  //   return CheckboxListTile(
                                  //     title: Text(activity.title),
                                  //     value: activity.boolCheck,
                                  //     onChanged: (val) {
                                  //       setState(() {
                                  //         activity.boolCheck = val ?? false;
                                  //         for (var sub in activity.subActivity) {
                                  //           sub.checked = val! ? 'true' : '';
                                  //         }
                                  //         assignDataInEylfController();
                                  //       });
                                  //     },
                                  //   );
                                  // }).toList(),
                                  ),
                            ),
                          );
                        })

                            //  eylfData.map((outcome) {
                            //   return ;
                            // }).toList(),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // You can collect selected subActivity ids here if needed
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showPracticalLifeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.zero,
              title: Text(
                'Select Practical Life',
                style: Constants.header4,
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            practicalLifeData?.activity.length ?? 0,
                            (parentIndex) {
                              return montessoriExpansionTile(
                                context,
                                parentIndex,
                                practicalLifeData,
                                setState,
                                assignPracticalLifeInController,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showSensorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.zero,
              title: Text('Select Sensorial', style: Constants.header4),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      sensorialData?.activity.length ?? 0,
                      (parentIndex) {
                        return montessoriExpansionTile(
                          context,
                          parentIndex,
                          sensorialData,
                          setState,
                          assignSensorialInController,
                        );
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showMathDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.zero,
              title: Text('Select Math', style: Constants.header4),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      mathData?.activity.length ?? 0,
                      (parentIndex) {
                        return montessoriExpansionTile(
                          context,
                          parentIndex,
                          mathData,
                          setState,
                          assignMathInController,
                        );
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.zero,
              title: Text('Select Language', style: Constants.header4),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      languageData?.activity.length ?? 0,
                      (parentIndex) {
                        return montessoriExpansionTile(
                          context,
                          parentIndex,
                          languageData,
                          setState,
                          assignLanguageInController,
                        );
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showCultureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.zero,
              title: Text('Select Culture', style: Constants.header4),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      cultureData?.activity.length ?? 0,
                      (parentIndex) {
                        return montessoriExpansionTile(
                          context,
                          parentIndex,
                          cultureData,
                          setState,
                          assignCultureInController,
                        );
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget montessoriExpansionTile(
    BuildContext context,
    int parentIndex,
    MontessariSubjectModel? data,
    void Function(void Function()) setState,
    Function assignController,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
              const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          title: Text(
            data?.activity[parentIndex].title ?? '',
            style: const TextStyle(fontSize: 15),
          ),
          trailing: null,
          onExpansionChanged: (val) {
            setState(() {});
          },
          children: List.generate(
            data?.activity[parentIndex].subActivity?.length ?? 0,
            (childIndex) {
              return CheckboxListTile(
                title: Text(
                  data?.activity[parentIndex].subActivity?[childIndex].title ??
                      '',
                ),
                value: data?.activity[parentIndex].subActivity?[childIndex]
                        .choosen ??
                    false,
                onChanged: (val) {
                  setState(() {
                    data?.activity[parentIndex].subActivity?[childIndex]
                        .choosen = val ?? false;
                    assignController();
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget getEndDrawer(BuildContext context) {
    return Drawer(
        child: Container(
            child: ListView(children: <Widget>[
      SizedBox(
        height: 5,
      ),
      ListTile(
        title: Text(
          'Select Educator',
          style: Constants.header2,
        ),
        trailing: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: users != null ? users.length : 0,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              print('+++++++++++++');
              print(eduValues.toString());
            }

            return ListTile(
              title: Text(users[index].name),
              trailing: Checkbox(
                  value: eduValues[users[index].userid],
                  onChanged: (value) {
                    if (value == true) {
                      if (!selectedEdu.contains(users[index])) {
                        selectedEdu.add(users[index]);
                        print(selectedEdu);
                      }
                    } else {
                      if (selectedEdu.contains(users[index])) {
                        selectedEdu.remove(users[index]);
                      }
                    }
                    eduValues[users[index].userid] = value!;
                    setState(() {});
                  }),
            );
          }),
      SizedBox(
        height: 10,
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
      ),
      SizedBox(
        height: 10,
      ),
    ])));
  }

  String searchString = "";

  Widget getStartDrawer(BuildContext context) {
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
      ListTile(
        title: Text(
          'Select All',
          style: TextStyle(fontSize: 16),
        ),
        trailing: Checkbox(
            value: all,
            onChanged: (value) {
              try {
                all = value!;
                for (var i = 0; i < childValues.length; i++) {
                  String key = childValues.keys.elementAt(i);
                  childValues[key] = value!;
                  if (value == true) {
                    if (!selectedChildrens.contains(childs[i])) {
                      selectedChildrens.add(childs[i]);
                    }
                  } else {
                    if (selectedChildrens.contains(childs[i])) {
                      selectedChildrens.remove(childs[i]);
                    }
                  }
                }
                setState(() {});
              } catch (e, s) {
                print('+++++++++++++++++++++');
                print(selectedChildrens.length.toString());
                print(childValues.length.toString());
                print(e);
                print(s);
              }
            }),
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        child: searchString == ''
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: childs != null ? childs.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(childs[index].name),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(childs[index].imageUrl != ""
                          ? Constants.ImageBaseUrl + childs[index].imageUrl
                          : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                    ),
                    trailing: Checkbox(
                        value: childValues[childs[index].id],
                        onChanged: (value) {
                          print(childs[index].id);
                          if (value == true) {
                            if (!selectedChildrens.contains(childs[index])) {
                              selectedChildrens.add(childs[index]);
                              print(childs[index].id);
                            }
                          } else {
                            if (selectedChildrens.contains(childs[index])) {
                              selectedChildrens.remove(childs[index]);
                            }
                          }

                          childValues[childs[index].id] = value!;
                          setState(() {});
                        }),
                  );
                })
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: childs != null ? childs.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return childs[index]
                          .name
                          .toLowerCase()
                          .contains(searchString.toLowerCase())
                      ? ListTile(
                          title: Text(childs[index].name),
                          trailing: Checkbox(
                              value: childValues[childs[index].id],
                              onChanged: (value) {
                                if (value == true) {
                                  if (!selectedChildrens
                                      .contains(childs[index])) {
                                    selectedChildrens.add(childs[index]);
                                  }
                                } else {
                                  if (selectedChildrens
                                      .contains(childs[index])) {
                                    selectedChildrens.remove(childs[index]);
                                  }
                                }

                                childValues[childs[index].id] = value!;

                                setState(() {});
                              }),
                        )
                      : Container();
                }),
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

  Widget build(BuildContext context) {
    Widget height10 = SizedBox(
      height: 10,
    );
    Widget height5 = SizedBox(
      height: 5,
    );
    return Scaffold(
      key: key,
      endDrawer: endmenu == 'Children'
          ? getStartDrawer(context)
          : getEndDrawer(context),
      appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            SizedBox(
              width: 40,
            )
          ],
          title: InkWell(
              onTap: () {
                assignAssessmentData();
              },
              child: Text('Add Plan'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Month',
              style: Constants.header2,
            ),
            height5,
            _buildDropdown(months, selectedMonth, (value) {
              setState(() => selectedMonth = value);
            }),
            Text(
              'Year',
              style: Constants.header2,
            ),
            height5,
            _buildDropdown(years, selectedYear, (value) {
              setState(() => selectedYear = value);
            }),
            Text(
              'Rooms',
              style: Constants.header2,
            ),
            height5,
            _buildRoomDropdown(),
            Text(
              'Children',
              style: Constants.header2,
            ),
            height10,
            GestureDetector(
              onTap: () {
                if (selectedRoom == null) {
                  return;
                }
                setState(() {
                  endmenu = 'Children';
                });
                key.currentState?.openEndDrawer();
              },
              child: Container(
                  width: 160,
                  height: 38,
                  decoration: BoxDecoration(
                      color: Constants.kButton,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          if (selectedRoom == null) {
                            return;
                          }
                          setState(() {
                            endmenu = 'Children';
                          });

                          key.currentState?.openEndDrawer();
                        },
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.blue[100],
                        ),
                      ),
                      Text(
                        'Select Children',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            selectedChildrens.length > 0
                ? Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: List<Widget>.generate(selectedChildrens.length,
                        (int index) {
                      return selectedChildrens[index].childid != null
                          ? Chip(
                              label: Text(selectedChildrens[index].name),
                              onDeleted: () {
                                setState(() {
                                  childValues[
                                      selectedChildrens[index].childid ??
                                          ''] = false;
                                  selectedChildrens.removeAt(index);
                                });
                              })
                          : Container();
                    }))
                : Container(),

            SizedBox(
              height: 10,
            ),
            Text(
              'Educator',
              style: Constants.header2,
            ),
            SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () {
                if (selectedRoom == null) {
                  return;
                }
                setState(() {
                  endmenu = 'Educator';
                });

                key.currentState?.openEndDrawer();
              },
              child: Container(
                  width: 160,
                  height: 38,
                  decoration: BoxDecoration(
                      color: Constants.kButton,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          if (selectedRoom == null) {
                            return;
                          }
                          setState(() {
                            endmenu = 'Educator';
                          });

                          key.currentState?.openEndDrawer();
                        },
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.blue[100],
                        ),
                      ),
                      Text(
                        'Select Educator',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            selectedEdu.length > 0
                ? Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        List<Widget>.generate(selectedEdu.length, (int index) {
                      return selectedEdu[index].userid != null
                          ? Chip(
                              label: Text(selectedEdu[index].name),
                              onDeleted: () {
                                setState(() {
                                  eduValues[selectedEdu[index].userid] = false;
                                  selectedEdu.removeAt(index);
                                });
                              })
                          : Container();
                    }))
                : Container(),
            SizedBox(
              height: 10,
            ),
            // _buildMultiSelect<UserModel>(
            //   'Select Educators',
            //   users,
            //   selectedEducators,
            //   (UserModel e) => e.name,
            //   (List<UserModel> selected) {
            //     setState(() => selectedEducators = selected);
            //   },
            // ),
            // _buildMultiSelect<ChildModel>(
            //   'Select Children',
            //   children,
            //   selectedChildren,
            //   (ChildModel c) => c.name,
            //   (List<ChildModel> selected) {
            //     setState(() => selectedChildren = selected);
            //   },
            // ),
            _buildTextField(
                hintText: 'Focus Areas',
                controller: focusAreasController,
                context: context),
            SizedBox(height: 16),
            Text(
              'Practical Life',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            customMultilineTextField(
              context: context,
              controller: practicalLifeController,
              maxLines: 5,
              minLines: 3,
              onTap: () {
                print('Tapped Practical Life');
                showPracticalLifeDialog(context);
              },
              readOnly: true,
            ),

            SizedBox(height: 24),
            Text(
              'Sensorial',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            customMultilineTextField(
              context: context,
              controller: sensorialController,
              maxLines: 5,
              minLines: 3,
              onTap: () {
                print('Tapped Sensorial');
                showSensorialDialog(context);
              },
              readOnly: true,
            ),

            SizedBox(height: 24),
            Text(
              'Math',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            customMultilineTextField(
              context: context,
              controller: mathController,
              maxLines: 5,
              minLines: 3,
              onTap: () {
                print('Tapped Math');
                showMathDialog(context);
              },
              readOnly: true,
            ),

            SizedBox(height: 24),
            Text(
              'Language',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            customMultilineTextField(
              context: context,
              controller: languageController,
              maxLines: 5,
              minLines: 3,
              onTap: () {
                print('Tapped Language');
                showLanguageDialog(context);
              },
              readOnly: true,
            ),

            SizedBox(height: 24),
            Text(
              'Culture',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            customMultilineTextField(
              context: context,
              controller: cultureController,
              maxLines: 5,
              minLines: 3,
              onTap: () {
                print('Tapped Culture');
                showCultureDialog(context);
              },
              readOnly: true,
            ),
            SizedBox(height: 16),
            Text(
              'Early Years Learning Framework',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            customMultilineTextField(
                context: context,
                controller: eylfController,
                maxLines: 5,
                minLines: 3,
                onTap: () {
                  print('-=---');
                  showEylfDialog(context);
                },
                readOnly: true),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.blueAccent),
            //     borderRadius: BorderRadius.all(Radius.circular(6)),
            //   ),
            //   child: ListTile(
            //     title: Text(
            //       'Early Years Learning Framework',
            //       style: TextStyle(fontSize: 15),
            //     ),
            //     leading: GestureDetector(
            //       onTap: () {
            //         showEylfDialog(context, eylfData);
            //         return;
            //         expandeylf = !expandeylf;
            //         setState(() {});
            //       },
            //       child: Icon(
            //         expandeylf
            //             ? Icons.keyboard_arrow_down
            //             : Icons.keyboard_arrow_right,
            //         color: Constants.kMain,
            //       ),
            //     ),
            //   ),
            // ),
            // Text(('${eylfData != null} && expandeylf')),
            Visibility(
                visible: eylfData != null && expandeylf,
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: eylfData != null ? eylfData.length : 0,
                        itemBuilder: (BuildContext context, int index) {
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
                                          : Icons.keyboard_arrow_right,
                                      color: Constants.kMain,
                                    ),
                                  ),
                                  title: Text(eylfData[index].title)),
                              Visibility(
                                  visible: eylfData[index].choosen,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: eylfData[index].activity !=
                                                  null
                                              ? eylfData[index].activity.length
                                              : 0,
                                          itemBuilder:
                                              (BuildContext context, int p) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 12.0),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                      leading: GestureDetector(
                                                        onTap: () {
                                                          eylfData[index]
                                                                  .activity[p]
                                                                  .choosen =
                                                              !eylfData[index]
                                                                  .activity[p]
                                                                  .choosen;
                                                          setState(() {});
                                                        },
                                                        child: Icon(
                                                          eylfData[index]
                                                                  .activity[p]
                                                                  .choosen
                                                              ? Icons
                                                                  .keyboard_arrow_down
                                                              : Icons
                                                                  .keyboard_arrow_right,
                                                          color:
                                                              Constants.kMain,
                                                        ),
                                                      ),
                                                      title: Text(
                                                          eylfData[index]
                                                              .activity[p]
                                                              .title)),
                                                  Visibility(
                                                      visible: eylfData[index]
                                                          .activity[p]
                                                          .choosen,
                                                      child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                          child:
                                                              ListView.builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  itemCount: eylfData[index]
                                                                              .activity[
                                                                                  p]
                                                                              .subActivity !=
                                                                          null
                                                                      ? eylfData[
                                                                              index]
                                                                          .activity[
                                                                              p]
                                                                          .subActivity
                                                                          .length
                                                                      : 0,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int k) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              12.0),
                                                                      child:
                                                                          Card(
                                                                        child:
                                                                            ListTile(
                                                                          title: Text(eylfData[index]
                                                                              .activity[p]
                                                                              .subActivity[k]
                                                                              .title),
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
              height: 30,
            ),
            Text('Additional Experiences',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildMultilineTextField(
                hintText: 'Outdoor Experiences (comma separated)',
                context: context,
                controller: outdoorExperiencesController),
            height10,
            _buildMultilineTextField(
                hintText: 'Inquiry Topic',
                context: context,
                controller: inquiryTopicController),
            height10,
            _buildMultilineTextField(
                hintText: 'Sustainability Topic',
                context: context,
                controller: sustainabilityTopicController),
            height10,
            _buildMultilineTextField(
                hintText: 'Special Events (comma separated)',
                context: context,
                controller: specialEventsController),
            height10,
            _buildMultilineTextField(
                hintText: 'Children\'s Voices',
                context: context,
                controller: childrenVoicesController),
            height10,
            _buildMultilineTextField(
                hintText: 'Families Input',
                context: context,
                controller: familiesInputController),
            height10,
            _buildMultilineTextField(
                hintText: 'Group Experience',
                context: context,
                controller: groupExperienceController),
            height10,
            _buildMultilineTextField(
                hintText: 'Spontaneous Experience',
                context: context,
                controller: spontaneousExperienceController),
            height10,
            _buildMultilineTextField(
                hintText: 'Mindfulness Experiences',
                context: context,
                controller: mindfulnessExperienceController),
            height10,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      List<String> items, String? value, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          iconColor: Constants.kButton,
          border: OutlineInputBorder(), // default border, but overridden below
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Constants.kButton), // Normal state
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Constants.kButton, width: 2), // When focused
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Constants.kButton), // On error
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Constants.kButton, width: 2), // On error + focus
          ),
        ),
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        iconDisabledColor: Constants.kButton,
      ),
    );
  }

  Widget _buildRoomDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<RoomsDescModel>(
        decoration: InputDecoration(
          // labelText: "Select Room",
          iconColor: Constants.kButton,
          border: OutlineInputBorder(), // default border, but overridden below
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Constants.kButton), // Normal state
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Constants.kButton, width: 2), // When focused
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Constants.kButton), // On error
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Constants.kButton, width: 2), // On error + focus
          ),
        ),
        value: selectedRoom,
        items: _rooms
            .map((roomValue) => DropdownMenuItem(
                  value: roomValue.room,
                  child: Text(roomValue.room.name),
                ))
            .toList(),
        onChanged: (room) {
          int selectedIndex = _rooms.indexWhere((r) {
            return r.room == room;
          });
          setState(() {
            selectedRoom = room;
            currentRoomIndex = selectedIndex;
          });
          changeRoomWithEducatorAndChild(currentRoomIndex);
        },
      ),
    );
  }

  Widget _buildMultiSelect<T>(
    String title,
    List<T> items,
    List<T> selectedItems,
    String Function(T) labelBuilder,
    void Function(List<T>) onSelectionChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Wrap(
            spacing: 8,
            children: items.map((item) {
              final selected = selectedItems.contains(item);
              return FilterChip(
                label: Text(labelBuilder(item)),
                selected: selected,
                onSelected: (bool value) {
                  setState(() {
                    selected
                        ? selectedItems.remove(item)
                        : selectedItems.add(item);
                    onSelectionChanged(selectedItems);
                  });
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // Widget _buildTextField(String label, TextEditingController controller) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16),
  //     child: TextFormField(
  //       controller: controller,
  //       decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
  //     ),
  //   );
  // }

  // Widget _buildMultilineTextField(String label, TextEditingController controller) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16),
  //     child: TextFormField(
  //       controller: controller,
  //       maxLines: null,
  //       minLines: 3,
  //       decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
  //     ),
  //   );
  // }
}

Widget _buildTextField({
  required TextEditingController controller,
  required BuildContext context,
  String? hintText,
  bool obscureText = false,
}) {
  return TextField(
    onTapOutside: (focus) {
      FocusScope.of(context).unfocus();
    },
    onSubmitted: (value) {
      FocusScope.of(context).nextFocus();
    },
    onEditingComplete: () {
      // FocusScope.of(context).nextFocus();
    },
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hintText,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Constants.kButton,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Constants.kButton,
          width: 1.5,
        ),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(4),
        ),
      ),
    ),
  );
}

Widget _buildMultilineTextField(
    {required TextEditingController controller,
    required BuildContext context,
    String? hintText,
    int minLines = 3,
    int maxLines = 5}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(hintText ?? ''),
      ),
      TextField(
        scrollPadding: EdgeInsets.only(bottom: 200),
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        onTapOutside: (focus) {
          FocusScope.of(context).unfocus();
        },
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: hintText,
          focusColor: Constants.kButton,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constants.kButton,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constants.kButton,
              width: 1.5,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget customMultilineTextField({
  required TextEditingController controller,
  required BuildContext context,
  String? hintText,
  int minLines = 3,
  int maxLines = 5,
  void Function()? onTap, // onTap function added
  bool readOnly = true, // disable option added
}) {
  return TextField(
    controller: controller,
    readOnly: readOnly,
    minLines: minLines,
    maxLines: maxLines,
    onTap: onTap,
    scrollPadding: EdgeInsets.only(bottom: 200),
    onTapOutside: (focus) {
      FocusScope.of(context).unfocus();
    },
    keyboardType: TextInputType.multiline,
    decoration: InputDecoration(
      hintText: hintText,
      focusColor: Constants.kButton,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Constants.kButton,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Constants.kButton,
          width: 1.5,
        ),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Constants.kButton,
          width: 1,
        ),
      ),
    ),
  );
}
