import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_painter/image_painter.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/dailydairyapi.dart';
import 'package:mykronicle_mobile/daily_dairy/accidents/accident_image.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/signature.dart';
import 'package:http/http.dart' as http;

class AddAccidents extends StatefulWidget {
  final String centerid;
  final String roomid;
  final String accid;
  final String type;

  AddAccidents(
      {required this.centerid,
      required this.roomid,
      required this.accid,
      required this.type});
  @override
  _AddAccidentsState createState() => _AddAccidentsState();
}

class _AddAccidentsState extends State<AddAccidents> {
  TextEditingController? name, positionRole;
  String nameError = '';
  String positionroleError = '';
  String? pHour, pMin;
  DateTime? recordDate;

  List<String>? hours;
  List<String>? minutes;

  Uint8List? person_signature;

  Uint8List? child_signature;
  String? personsignatureError = '', childsignatureError = '';

  String? addmark;

  bool abrasion = false,
      allergy = false,
      amputation = false,
      anaphylaxis = false,
      asthama = false,
      bite = false,
      broken = false,
      burn = false,
      choking = false,
      concussion = false,
      crush = false,
      cut = false,
      drowning = false,
      eye = false,
      electic = false,
      high = false,
      infectious = false,
      ingestion = false,
      internal = false,
      poisoning = false,
      rash = false,
      respiratory = false,
      seizure = false,
      sprain = false,
      stabbing = false,
      tooth = false,
      venomous = false,
      other = false;

  // child

  TextEditingController? cAge,
      witnessname,
      cactivity,
      ccause,
      ccsurrondings,
      ccunaccount,
      cclocked,
      cloc;
  String cnameError = '',
      cAgeError = '',
      witnessnameError = '',
      cactivityError = '',
      ccaauseError = '',
      ccsurrondingsError = '',
      ccunaccountError = '',
      cclockedError = '',
      clocError = '';

  DateTime? cDob;
  DateTime? cIncidentDate;
  DateTime? cIDate;

  String? cHour, cMin;

  String _gender = 'Male';

  // action
  TextEditingController? adetail, ayesdetails, afuture1, afuture2, afuture3;
  String adetailError = '',
      ayesdetailsError = '',
      afuture1Error = '',
      afuture2Error = '',
      afuture3Error = '';
  String _aEmergency = 'Yes';
  String _aAttention = 'Yes';

  //gaurdian
  TextEditingController? gName1, gContact1, gName2, gContact2;
  String gNmae1Error = '',
      gContact1Error = '',
      gName2Error = '',
      gContact2Error = '';
  String? gHour1, gMin1;
  DateTime? gDate1;

  String? gHour2, gMin2;
  DateTime? gDate2;

  bool gContacted1 = false, gMsg1 = false;

  bool gContacted2 = false, gMsg2 = false;

  // internal notifications
  TextEditingController? nName,
      nSupervisorName,
      eAgency,
      eAuthority,
      paName,
      aNotes;
  String nNameError = '',
      nSupervisorNameError = '',
      inchargesignatureError = '',
      supervisorsignatureError = '';
  String eAgencyError = '',
      eAuthorityError = '',
      paNameError = '',
      aNotesError = '';
  String? nHour1,
      nMin1,
      nHour2,
      nMin2,
      eHour1,
      eMin1,
      eHour2,
      eMin2,
      paHour,
      paMin;
  DateTime? nDate1, nDate2, eDate1, eDate2, paDate;
  Uint8List? incharge_signature, supervisor_signature;
  bool childrensFetched = false;
  List<ChildModel> _allChildrens = [];

  int currentIndex = 0;
  var accInfo;

  Future<void> _fetchData() async {
    Map<String, String> data = {
      'superadmin': '1',
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': widget.centerid,
      'roomid': widget.roomid,
    };

    print(data);
    DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data);
    var dt = await hlr.getData();
    if (!dt.containsKey('error')) {
      print('herrrr' + dt['childs'].toString());
      var child = dt['childs'];
      _allChildrens = [];
      try {
        assert(child is List);
        for (int i = 0; i < child.length; i++) {
          _allChildrens.add(ChildModel.fromJson(child[i]));
        }
        if (_allChildrens.length != 0) childrensFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
      print(widget.type);
      if (widget.type == 'edit') {
        Map<String, String> dataX = {
          "id": widget.accid,
          "accidentid": widget.accid,
          "userid": MyApp.LOGIN_ID_VALUE
        };
        print(dataX);

        DailyDairyAPIHandler hlr = DailyDairyAPIHandler(dataX);
        var dt = await hlr.getAccidentsInfo();

        if (!dt.containsKey('error')) {
          accInfo = dt['AccidentInfo'];

          name?.text = accInfo['person_name'] ?? '';
          positionRole?.text = accInfo['person_role'] ?? '';
          recordDate = DateTime.tryParse(accInfo['date'] ?? '');

          if ((accInfo['time'] ?? '').contains(':')) {
            var split = accInfo['time'].split(':');
            pHour = split[0];
            pMin = split[1];
          }

          for (int i = 0; i < _allChildrens.length; i++) {
            if (_allChildrens[i].id == accInfo['childid']) {
              currentIndex = i;
              break;
            }
          }

          cDob = DateTime.tryParse(accInfo['child_dob'] ?? '');
          cAge?.text = accInfo['child_age'] ?? '';
          _gender = accInfo['child_gender'] ?? 'Male';

          cIncidentDate = DateTime.tryParse(accInfo['incident_date'] ?? '');
          if ((accInfo['incident_time'] ?? '').contains(':')) {
            var split = accInfo['incident_time'].split(':');
            cHour = split[0];
            cMin = split[1];
          }

          cloc?.text = accInfo['incident_location'] ?? '';
          cIDate = DateTime.tryParse(accInfo['witness_date'] ?? '');
          witnessname?.text = accInfo['witness_name'] ?? '';
          cactivity?.text = accInfo['gen_actyvt'] ?? '';
          ccause?.text = accInfo['cause'] ?? '';
          ccsurrondings?.text = accInfo['illness_symptoms'] ?? '';
          ccunaccount?.text = accInfo['missing_unaccounted'] ?? '';
          cclocked?.text = accInfo['taken_removed'] ?? '';

          adetail?.text = accInfo['action_taken'] ?? '';
          _aEmergency = accInfo['emrg_serv_attend'] ?? 'Yes';
          ayesdetails?.text = accInfo['med_attention'] ?? '';
          _aAttention = accInfo['med_attention_details'] ?? 'Yes';

          afuture1?.text = accInfo['prevention_step_1'] ?? '';
          afuture2?.text = accInfo['prevention_step_2'] ?? '';
          afuture3?.text = accInfo['prevention_step_3'] ?? '';

          gName1?.text = accInfo['parent1_name'] ?? '';
          gContact1?.text = accInfo['contact1_method'] ?? '';
          if ((accInfo['contact1_time'] ?? '').contains(':')) {
            var split = accInfo['contact1_time'].split(':');
            gHour1 = split[0];
            gMin1 = split[1];
          }
          gDate1 = DateTime.tryParse(accInfo['contact1_date'] ?? '');
          gContacted1 = accInfo['contact1'] == 'Yes';
          gMsg1 = accInfo['contact1_msg'] == 'Yes';

          gName2?.text = accInfo['parent2_name'] ?? '';
          gContact2?.text = accInfo['contact2_method'] ?? '';
          if ((accInfo['contact2_time'] ?? '').contains(':')) {
            var split = accInfo['contact2_time'].split(':');
            gHour2 = split[0];
            gMin2 = split[1];
          }
          gDate2 = DateTime.tryParse(accInfo['contact2_date'] ?? '');
          gContacted2 = accInfo['contact2'] == 'Yes';
          gMsg2 = accInfo['contact2_msg'] == 'Yes';

          nName?.text = accInfo['responsible_person_name'] ?? '';
          if ((accInfo['rp_internal_notif_time'] ?? '').contains(':')) {
            var split = accInfo['rp_internal_notif_time'].split(':');
            nHour1 = split[0];
            nMin1 = split[1];
          }
          nDate1 = DateTime.tryParse(accInfo['rp_internal_notif_date'] ?? '');
          nSupervisorName?.text = accInfo['nominated_supervisor_name'] ?? '';
          if ((accInfo['nominated_supervisor_time'] ?? '').contains(':')) {
            var split = accInfo['nominated_supervisor_time'].split(':');
            nHour2 = split[0];
            nMin2 = split[1];
          }
          nDate2 =
              DateTime.tryParse(accInfo['nominated_supervisor_date'] ?? '');

          eAgency?.text = accInfo['ext_notif_other_agency'] ?? '';
          if ((accInfo['enor_time'] ?? '').contains(':')) {
            var split = accInfo['enor_time'].split(':');
            eHour1 = split[0];
            eMin1 = split[1];
          }
          eDate1 = DateTime.tryParse(accInfo['enor_date'] ?? '');

          eAuthority?.text = accInfo['ext_notif_regulatory_auth'] ?? '';
          if ((accInfo['enra_time'] ?? '').contains(':')) {
            var split = accInfo['enra_time'].split(':');
            eHour2 = split[0];
            eMin2 = split[1];
          }
          eDate2 = DateTime.tryParse(accInfo['enra_date'] ?? '');

          paName?.text = accInfo['ack_parent_name'] ?? '';
          if ((accInfo['ack_time'] ?? '').contains(':')) {
            var split = accInfo['ack_time'].split(':');
            paHour = split[0];
            paMin = split[1];
          }
          paDate = DateTime.tryParse(accInfo['ack_date'] ?? '');
          aNotes?.text = accInfo['add_notes'] ?? '';

          abrasion = accInfo['abrasion'].toString() == '1' ? true : false;
          electic = accInfo['electric_shock'].toString() == '1' ? true : false;
          allergy =
              accInfo['allergic_reaction'].toString() == '1' ? true : false;
          high = accInfo['high_temperature'].toString() == '1' ? true : false;
          amputation = accInfo['amputation'].toString() == '1' ? true : false;
          infectious =
              accInfo['infectious_disease'].toString() == '1' ? true : false;
          anaphylaxis = accInfo['anaphylaxis'].toString() == '1' ? true : false;
          ingestion = accInfo['ingestion'].toString() == '1' ? true : false;
          asthama = accInfo['asthma'].toString() == '1' ? true : false;
          internal =
              accInfo['internal_injury'].toString() == '1' ? true : false;
          bite = accInfo['bite_wound'].toString() == '1' ? true : false;
          poisoning = accInfo['poisoning'].toString() == '1' ? true : false;
          broken = accInfo['broken_bone'].toString() == '1' ? true : false;
          rash = accInfo['rash'].toString() == '1' ? true : false;
          burn = accInfo['burn'].toString() == '1' ? true : false;
          respiratory = accInfo['respiratory'].toString() == '1' ? true : false;
          choking = accInfo['choking'].toString() == '1' ? true : false;
          seizure = accInfo['seizure'].toString() == '1' ? true : false;
          concussion = accInfo['concussion'].toString() == '1' ? true : false;
          sprain = accInfo['sprain'].toString() == '1' ? true : false;
          crush = accInfo['crush'].toString() == '1' ? true : false;
          stabbing = accInfo['stabbing'].toString() == '1' ? true : false;
          cut = accInfo['cut'].toString() == '1' ? true : false;
          tooth = accInfo['tooth'].toString() == '1' ? true : false;
          drowning = accInfo['drowning'].toString() == '1' ? true : false;
          venomous = accInfo['venomous_bite'].toString() == '1' ? true : false;
          eye = accInfo['eye_injury'].toString() == '1' ? true : false;
          other = accInfo['other'].toString() == '1' ? true : false;

          setState(() {});
        }
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  void initState() {
    hours = List<String>.generate(24, (counter) => "${counter + 1}");
    minutes = List<String>.generate(60, (counter) => "$counter");

    pMin = minutes?[0];
    pHour = hours?[0];
    recordDate = DateTime.now();
    name = TextEditingController();
    positionRole = TextEditingController();

    // child

    witnessname = TextEditingController();
    cactivity = TextEditingController();
    cAge = TextEditingController();

    ccause = TextEditingController();
    ccsurrondings = TextEditingController();
    ccunaccount = TextEditingController();
    cclocked = TextEditingController();
    cloc = TextEditingController();

    cMin = minutes?[0];
    cHour = hours?[0];

    cDob = DateTime.now();
    cIncidentDate = DateTime.now();
    cIDate = DateTime.now();

    // action
    adetail = TextEditingController();
    ayesdetails = TextEditingController();
    afuture1 = TextEditingController();
    afuture2 = TextEditingController();
    afuture3 = TextEditingController();

    //guardian
    gName1 = TextEditingController();
    gName2 = TextEditingController();
    gContact1 = TextEditingController();
    gContact2 = TextEditingController();

    gMin1 = minutes?[0];
    gHour1 = hours?[0];

    gDate1 = DateTime.now();

    gMin2 = minutes?[0];
    gHour2 = hours?[0];

    gDate2 = DateTime.now();
    // INCHARGE

    nName = TextEditingController();
    nSupervisorName = TextEditingController();

    nMin1 = minutes?[0];
    nHour1 = hours?[0];

    nMin2 = minutes?[0];
    nHour2 = hours?[0];

    nDate1 = DateTime.now();
    nDate2 = DateTime.now();

    //external
    eAgency = TextEditingController();
    eAuthority = TextEditingController();
    eMin1 = minutes?[0];
    eHour1 = hours?[0];
    eDate1 = DateTime.now();

    eMin2 = minutes?[0];
    eHour2 = hours?[0];
    eDate2 = DateTime.now();

    //parental
    paName = TextEditingController();

    paMin = minutes?[0];
    paHour = hours?[0];
    paDate = DateTime.now();

    //note

    aNotes = TextEditingController();
    _fetchData();
    super.initState();
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
              InkWell(
                onTap: () {
                  print('======================');
                  _fetchData();
                },
                child: Text(
                  'Add Accidents',
                  style: Constants.header1,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'INCIDENT, INJURY, TRAUMA, & ILLNESS RECORD',
                style: Constants.header2,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Details of person completing this record',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: name,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              nameError != ''
                  ? Text(
                      nameError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Position Role',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: positionRole,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              positionroleError != ''
                  ? Text(
                      positionroleError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Signature',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignaturePage()))
                            .then((value) {
                          if (value != null) {
                            person_signature = value!;
                            // print(person_signature.toString());
                            // print("object1");
                            // final imageEncoded = base64.encode(person_signature);
                            // print(imageEncoded);
                            // String base64String = base64Encode(person_signature);
                            // String header = "data:image/png;base64,";

                            // print(header + base64String);
                            setState(() {});
                          }
                        });
                      },
                      child: Icon(Icons.edit))
                ],
              ),
              SizedBox(
                height: 5,
              ),
              person_signature != null
                  ? Image.memory(
                      person_signature!,
                      width: double.infinity,
                      height: 150,
                    )
                  : accInfo != null &&
                          accInfo['person_sign'] != null &&
                          accInfo['person_sign'] != ''
                      ? Image.network(
                          Constants.ImageBaseUrl + accInfo['person_sign'])
                      : TextField(
                          readOnly: true,
                          maxLines: 1,
                          onTap: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignaturePage()))
                                .then((value) {
                              if (value != null) {
                                person_signature = value!;
                                setState(() {});
                              }
                            });
                          },
                          //  controller: positionRole,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 0.0),
                            ),
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
              SizedBox(
                height: 10,
              ),
              person_signature == null
                  ? Text(
                      personsignatureError ?? '',
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        recordDate != null
                            ? DateFormat("dd-MM-yyyy").format(recordDate!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            recordDate =
                                await _selectDate(context, recordDate!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  hours != null && pHour != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value: hours != null && hours!.contains(pHour)
                                      ? pHour
                                      : null,
                                  items: hours?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    pHour = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: 20,
                  ),
                  minutes != null && pMin != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value:
                                      minutes != null && minutes!.contains(pMin)
                                          ? pMin
                                          : null,
                                  items: minutes?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    pMin = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),

              SizedBox(
                height: 15,
              ),
              Divider(),
              Text(
                'Child Details',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Child Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              childrensFetched
                  ? DropdownButtonHideUnderline(
                      child: Container(
                        height: 40,
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
                              value: _allChildrens
                                      .contains(_allChildrens[currentIndex])
                                  ? _allChildrens[currentIndex].id
                                  : null,
                              items: _allChildrens.map((ChildModel value) {
                                return new DropdownMenuItem<String>(
                                  value: value.id,
                                  child: new Text(value.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                for (int i = 0; i < _allChildrens.length; i++) {
                                  if (_allChildrens[i].id == value) {
                                    setState(() {
                                      currentIndex = i;
                                      // details = null;
                                      // _selectedChildrens =
                                      //     [];
                                      childrensFetched = false;
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
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              cnameError != ''
                  ? Text(
                      cnameError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Date of Birth',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        cDob != null
                            ? DateFormat("dd-MM-yyyy").format(cDob!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            cDob = await _selectDate(context, cDob!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Age',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: cAge,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              cAgeError != ''
                  ? Text(
                      cAgeError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Gender',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonHideUnderline(
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Center(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: <String>['Male', 'Female', 'Others']
                                .contains(_gender)
                            ? _gender
                            : null,
                        items: <String>[
                          'Male',
                          'Female',
                          'Others'
                        ] // ✅ Removed unnecessary `?`
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value == null) return;
                          setState(() {
                            _gender = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(),
              Text(
                'Incident Details',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Incident Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        cIncidentDate != null
                            ? DateFormat("dd-MM-yyyy").format(cIncidentDate!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            cIncidentDate =
                                await _selectDate(context, cIncidentDate!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Incident Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  hours != null && cHour != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value: hours != null && hours!.contains(cHour)
                                      ? cHour
                                      : null,
                                  items: hours?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    if (value == null) return;
                                    cHour = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: 20,
                  ),
                  minutes != null && cMin != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value:
                                      minutes != null && minutes!.contains(cMin)
                                          ? cMin
                                          : null,
                                  items: minutes?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    if (value == null) return;
                                    cMin = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: cloc,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              clocError != ''
                  ? Text(
                      clocError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Signature',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignaturePage()))
                            .then((value) {
                          if (value != null) {
                            child_signature = value!;
                            setState(() {});
                          }
                        });
                      },
                      child: Icon(Icons.edit))
                ],
              ),
              SizedBox(
                height: 5,
              ),
              child_signature != null
                  ? Image.memory(
                      child_signature!,
                      width: double.infinity,
                      height: 150,
                    )
                  : accInfo != null &&
                          accInfo['witness_sign'] != null &&
                          accInfo['witness_sign'] != ''
                      ? Image.network(
                          Constants.ImageBaseUrl + accInfo['witness_sign'])
                      : TextField(
                          readOnly: true,
                          maxLines: 1,
                          onTap: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignaturePage()))
                                .then((value) {
                              if (value != null) {
                                child_signature = value!;
                                setState(() {});
                              }
                            });
                          },
                          //  controller: positionRole,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 0.0),
                            ),
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
              SizedBox(
                height: 10,
              ),
              child_signature == null
                  ? Text(
                      childsignatureError ?? '',
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Date ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        cIDate != null
                            ? DateFormat("dd-MM-yyyy").format(cIDate!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            cIDate = await _selectDate(context, cIDate!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Witness Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: witnessname,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              witnessnameError != ''
                  ? Text(
                      witnessnameError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'General activity at the time of incident/ injury/ trauma/ illness',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: cactivity,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              cactivityError != ''
                  ? Text(
                      cactivityError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Cause of injury/ trauma:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: ccause,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ccaauseError != ''
                  ? Text(
                      ccaauseError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Circumstances surrounding any illness, including apparent symptoms:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: ccsurrondings,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ccsurrondingsError != ''
                  ? Text(
                      ccsurrondingsError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Circumstances if child appeared to be missing or otherwise unaccounted for (incl duration, who found child etc.):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: ccunaccount,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ccunaccountError != ''
                  ? Text(
                      ccunaccountError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Circumstances if child appeared to have been taken or removed from service or was locked in/out of service (incl who took the child, duration): ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: cclocked,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              cclockedError != ''
                  ? Text(
                      cclockedError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Divider(),
              Text(
                'Nature of Injury/ Trauma/ Illness:',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),

              accInfo != null &&
                      accInfo['injury_image'] != null &&
                      accInfo['injury_image'] != '' &&
                      addmark == null
                  ? Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: Text('Edit Marks'),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AccidentImage())).then((value) {
                                    if (value != null) {
                                      print("object");
                                      print(value);
                                      addmark = value!;
                                      setState(() {});
                                    }
                                  });
                                },
                              ),
                            ]),
                        Image.network(
                            Constants.ImageBaseUrl + accInfo['injury_image'])
                      ],
                    )
                  : addmark != null
                      ? Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    child: Text('Edit Marks'),
                                    onPressed: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AccidentImage()))
                                          .then((value) {
                                        if (value != null) {
                                          print("object");
                                          print(value);
                                          addmark = value!;
                                          setState(() {});
                                        }
                                      });
                                    },
                                  ),
                                ]),
                            Image.memory(
                              base64Decode(addmark ?? ''),
                            )
                          ],
                        )
                      : TextButton(
                          child: Text('Add Marks'),
                          onPressed: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AccidentImage()))
                                .then((value) {
                              if (value != null) {
                                print("object");
                                print(value);
                                addmark = value!;
                                setState(() {});
                              }
                            });
                          },
                        ),

              CheckboxListTile(
                  value: abrasion,
                  title: Text('Abrasion/ Scrape'),
                  onChanged: (val) {
                    if (val == null) return;
                    abrasion = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: allergy,
                  title: Text('Allergic reaction'),
                  onChanged: (val) {
                    if (val == null) return;
                    allergy = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: amputation,
                  title: Text('Amputation'),
                  onChanged: (val) {
                    if (val == null) return;
                    amputation = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: anaphylaxis,
                  title: Text('Anaphylaxis'),
                  onChanged: (val) {
                    if (val == null) return;
                    anaphylaxis = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: asthama,
                  title: Text('Asthma/ Respiratory'),
                  onChanged: (val) {
                    if (val == null) return;
                    asthama = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: bite,
                  title: Text('Bite Wound'),
                  onChanged: (val) {
                    if (val == null) return;
                    bite = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: broken,
                  title: Text('Broken Bone/ Fracture/ Dislocation'),
                  onChanged: (val) {
                    if (val == null) return;
                    broken = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: burn,
                  title: Text('Burn/ Sunburn'),
                  onChanged: (val) {
                    if (val == null) return;
                    burn = val;
                    setState(() {});
                  }),

              CheckboxListTile(
                  value: choking,
                  title: Text('Choking'),
                  onChanged: (val) {
                    if (val == null) return;
                    choking = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: concussion,
                  title: Text('Concussion'),
                  onChanged: (val) {
                    if (val == null) return;
                    concussion = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: crush,
                  title: Text('Crush/ Jam'),
                  onChanged: (val) {
                    if (val == null) return;
                    crush = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: cut,
                  title: Text('Cut/ Open Wound'),
                  onChanged: (val) {
                    if (val == null) return;
                    cut = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: drowning,
                  title: Text('Drowning (nonfatal)'),
                  onChanged: (val) {
                    if (val == null) return;
                    drowning = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: eye,
                  title: Text('Eye Injury'),
                  onChanged: (val) {
                    if (val == null) return;
                    eye = val;
                    setState(() {});
                  }),
              //
              CheckboxListTile(
                  value: electic,
                  title: Text('Electric Shock'),
                  onChanged: (val) {
                    if (val == null) return;
                    electic = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: high,
                  title: Text('High Temperature'),
                  onChanged: (val) {
                    if (val == null) return;
                    high = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: infectious,
                  title: Text('Infectious Disease (inc gastrointestinal)'),
                  onChanged: (val) {
                    if (val == null) return;
                    infectious = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: ingestion,
                  title: Text('Ingestion/ Inhalation/ Insertion'),
                  onChanged: (val) {
                    if (val == null) return;
                    ingestion = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: internal,
                  title: Text('Internal injury/ Infection'),
                  onChanged: (val) {
                    if (val == null) return;
                    internal = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: poisoning,
                  title: Text('Poisoning'),
                  onChanged: (val) {
                    if (val == null) return;
                    poisoning = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: rash,
                  title: Text('Rash'),
                  onChanged: (val) {
                    if (val == null) return;
                    broken = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: respiratory,
                  title: Text('Respiratory'),
                  onChanged: (val) {
                    if (val == null) return;
                    respiratory = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: seizure,
                  title: Text('Seizure/ unconscious/ convulsion'),
                  onChanged: (val) {
                    if (val == null) return;
                    seizure = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: sprain,
                  title: Text('Sprain/ swelling'),
                  onChanged: (val) {
                    if (val == null) return;
                    sprain = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: stabbing,
                  title: Text('Stabbing/ piercing'),
                  onChanged: (val) {
                    if (val == null) return;
                    stabbing = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: tooth,
                  title: Text('Tooth'),
                  onChanged: (val) {
                    if (val == null) return;
                    tooth = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: venomous,
                  title: Text('Venomous bite/ sting'),
                  onChanged: (val) {
                    if (val == null) return;
                    venomous = val;
                    setState(() {});
                  }),
              CheckboxListTile(
                  value: other,
                  title: Text('Other( please specify)'),
                  onChanged: (val) {
                    if (val == null) return;
                    other = val;
                    setState(() {});
                  }),
              SizedBox(
                height: 15,
              ),
              Divider(),
              Text(
                'Action Taken',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Details of action taken (including first aid, administration of medication etc.):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 2,
                controller: adetail,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              adetailError != ''
                  ? Text(
                      adetailError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Did emergency services attend:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonHideUnderline(
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Center(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: <String>['Yes', 'No'].contains(_aEmergency)
                            ? _aEmergency
                            : null,
                        items: <String>['Yes', 'No'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value == null) return;
                          setState(() {
                            _aEmergency = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'If yes to either of the above, provide details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 2,
                controller: ayesdetails,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              _aEmergency == "Yes"
                  ? ayesdetailsError != ''
                      ? Text(
                          ayesdetailsError,
                          style: TextStyle(color: Colors.red),
                        )
                      : Container() // ✅ This ensures a valid widget is returned
                  : Container(), // ✅ Replace Constants() with a proper widget

              SizedBox(
                height: 5,
              ),
              Text(
                'Was medical attention sought from a registered practitioner / hospital:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonHideUnderline(
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Center(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: <String>['Yes', 'No'].contains(_aAttention)
                            ? _aAttention
                            : null,
                        items: <String>['Yes', 'No'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value == null) return;
                          setState(() {
                            _aAttention = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 15,
              ),
              Text(
                'If yes to either of the above, provide details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: afuture1,
                decoration: InputDecoration(
                  hintText: '1.',
                  hintStyle: TextStyle(color: Constants.greyColor),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: afuture2,
                decoration: InputDecoration(
                  hintText: '2.',
                  hintStyle: TextStyle(color: Constants.greyColor),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: afuture3,
                decoration: InputDecoration(
                  hintText: '3.',
                  hintStyle: TextStyle(color: Constants.greyColor),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
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
              Divider(),
              Text(
                'Parent/Guardian Notifications (including attempted notifications)',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                '1.Parent/ Guardian name:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: gName1,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              gNmae1Error != ''
                  ? Text(
                      gNmae1Error,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              SizedBox(
                height: 5,
              ),
              Text(
                'Method of Contact:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: gContact1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              gContact1Error != ''
                  ? Text(
                      gContact1Error,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              SizedBox(
                height: 5,
              ),
              Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  hours != null && gHour1 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value:
                                      (hours != null && hours!.contains(gHour1))
                                          ? gHour1
                                          : null,
                                  items: hours?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    gHour1 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: 20,
                  ),
                  minutes != null && gMin1 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value: minutes != null &&
                                          minutes!.contains(gMin1)
                                      ? gMin1
                                      : null,
                                  items: minutes?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    gMin1 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        gDate1 != null
                            ? DateFormat("dd-MM-yyyy").format(gDate1!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            gDate1 = await _selectDate(context, gDate1!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Transform.translate(
                offset: Offset(-15, 0),
                child: ListTile(
                  title: Text(
                    'Contact Made',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Checkbox(
                    value: gContacted1,
                    onChanged: (val) {
                      gContacted1 = val!;
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Transform.translate(
                offset: Offset(-15, 0),
                child: ListTile(
                  title: Text(
                    'Message left',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Checkbox(
                    value: gMsg1,
                    onChanged: (val) {
                      if (val == null) return;
                      gMsg1 = val;
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                '2.Parent/ Guardian name:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: gName2,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              gName2Error != ''
                  ? Text(
                      gName2Error,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              SizedBox(
                height: 5,
              ),
              Text(
                'Method of Contact:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: gContact2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              gContact2Error != ''
                  ? Text(
                      gContact2Error,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              SizedBox(
                height: 5,
              ),
              Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  hours != null && gHour2 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value:
                                      hours != null && hours!.contains(gHour2)
                                          ? gHour2
                                          : null,
                                  items: hours?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    gHour2 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: 20,
                  ),
                  minutes != null && gMin2 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value: minutes != null &&
                                          minutes!.contains(gMin2)
                                      ? gMin2
                                      : null,
                                  items: minutes?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    gMin2 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        gDate2 != null
                            ? DateFormat("dd-MM-yyyy").format(gDate2!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            gDate2 = await _selectDate(context, gDate2!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Transform.translate(
                offset: Offset(-15, 0),
                child: ListTile(
                  title: Text(
                    'Contact Made',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Checkbox(
                    value: gContacted2,
                    onChanged: (val) {
                      gContacted2 = val!;
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Transform.translate(
                offset: Offset(-15, 0),
                child: ListTile(
                  title: Text(
                    'Message left',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Checkbox(
                    value: gMsg2,
                    onChanged: (val) {
                      gMsg2 = val!;
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(),
              Text(
                'Internal Notifications',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Responsible Person in Charge Name:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: nName,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              nNameError != ''
                  ? Text(
                      nNameError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Responsible Person in Charge Signature:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignaturePage()))
                            .then((value) {
                          if (value != null) {
                            incharge_signature = value!;
                            setState(() {});
                          }
                        });
                      },
                      child: Icon(Icons.edit))
                ],
              ),
              SizedBox(
                height: 5,
              ),
              incharge_signature != null
                  ? Image.memory(
                      incharge_signature!,
                      width: double.infinity,
                      height: 150,
                    )
                  : accInfo != null &&
                          accInfo['responsible_person_sign'] != null &&
                          accInfo['responsible_person_sign'] != ''
                      ? Image.network(Constants.ImageBaseUrl +
                          accInfo['responsible_person_sign'])
                      : TextField(
                          readOnly: true,
                          maxLines: 1,
                          onTap: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignaturePage()))
                                .then((value) {
                              if (value != null) {
                                incharge_signature = value!;
                                setState(() {});
                              }
                            });
                          },
                          //  controller: positionRole,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 0.0),
                            ),
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
              SizedBox(
                height: 10,
              ),
              incharge_signature == null
                  ? Text(
                      inchargesignatureError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  hours != null && nHour1 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value:
                                      hours != null && hours!.contains(nHour1)
                                          ? nHour1
                                          : null,
                                  items: hours?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    nHour1 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: 20,
                  ),
                  minutes != null && nMin1 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value: minutes != null &&
                                          minutes!.contains(nMin1)
                                      ? nMin1
                                      : null,
                                  items: minutes?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    nMin1 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        nDate1 != null
                            ? DateFormat("dd-MM-yyyy").format(nDate1!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            nDate1 = await _selectDate(context, nDate1!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Nominated Supervisor Name:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: nSupervisorName,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              nSupervisorNameError != ''
                  ? Text(
                      nSupervisorNameError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nominated Supervisor Signature:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignaturePage()))
                            .then((value) {
                          if (value != null) {
                            supervisor_signature = value!;
                            setState(() {});
                          }
                        });
                      },
                      child: Icon(Icons.edit))
                ],
              ),
              SizedBox(
                height: 5,
              ),
              supervisor_signature != null
                  ? Image.memory(
                      supervisor_signature!,
                      width: double.infinity,
                      height: 150,
                    )
                  : accInfo != null &&
                          accInfo['nominated_supervisor_sign'] != null &&
                          accInfo['nominated_supervisor_sign'] != ''
                      ? Image.network(Constants.ImageBaseUrl +
                          accInfo['nominated_supervisor_sign'])
                      : TextField(
                          readOnly: true,
                          maxLines: 1,
                          onTap: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignaturePage()))
                                .then((value) {
                              if (value != null) {
                                supervisor_signature = value!;
                                setState(() {});
                              }
                            });
                          },
                          //  controller: positionRole,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 0.0),
                            ),
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
              SizedBox(
                height: 10,
              ),
              supervisor_signature == null
                  ? Text(
                      supervisorsignatureError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  hours != null && nHour2 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value:
                                      hours != null && hours!.contains(nHour2)
                                          ? nHour2
                                          : null,
                                  items: hours?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    nHour2 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: 20,
                  ),
                  minutes != null && nMin2 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value: minutes != null &&
                                          minutes!.contains(nMin2)
                                      ? nMin2
                                      : null,
                                  items: minutes?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    nMin2 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        nDate2 != null
                            ? DateFormat("dd-MM-yyyy").format(nDate2!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            nDate2 = await _selectDate(context, nDate2!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(),
              Text(
                'External Notifications',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Other Agency:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: eAgency,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              eAgencyError != ''
                  ? Text(
                      eAgencyError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              SizedBox(
                height: 5,
              ),
              Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  hours != null && eHour1 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value:
                                      hours != null && hours!.contains(eHour1)
                                          ? eHour1
                                          : null,
                                  items: hours?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    eHour1 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: 20,
                  ),
                  minutes != null && eMin1 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value: minutes != null &&
                                          minutes!.contains(eMin1)
                                      ? eMin1
                                      : null,
                                  items: minutes?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    eMin1 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        eDate1 != null
                            ? DateFormat("dd-MM-yyyy").format(eDate1!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            eDate1 = await _selectDate(context, eDate1!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Regulatory authority:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 1,
                controller: eAuthority,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              eAuthorityError != ''
                  ? Text(
                      eAuthorityError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              SizedBox(
                height: 5,
              ),
              Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  hours != null && eHour2 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value:
                                      hours != null && hours!.contains(eHour2)
                                          ? eHour2
                                          : null,
                                  items: hours?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    eHour2 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: 20,
                  ),
                  minutes != null && eMin2 != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value: minutes != null &&
                                          minutes!.contains(eMin2)
                                      ? eMin2
                                      : null,
                                  items: minutes?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    eMin2 = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        eDate2 != null
                            ? DateFormat("dd-MM-yyyy").format(eDate2!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            eDate2 = await _selectDate(context, eDate2!);
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(),
              Text(
                'Parental acknowledgement',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Text('I'),
                    ),
                    Expanded(
                      child: TextField(
                        controller: paName,
                      ),
                    )
                  ],
                ),
              ),

              paNameError != ''
                  ? Text(
                      paNameError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, top: 3),
                child: Text(
                    '(name of parent / guardian) have been notified of my child’s incident / injury / trauma / illness.'),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  hours != null && paHour != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value:
                                      hours != null && hours!.contains(paHour)
                                          ? paHour
                                          : null,
                                  items: hours?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    paHour = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    width: 20,
                  ),
                  minutes != null && paMin != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  //  isExpanded: true,
                                  value: minutes != null &&
                                          minutes!.contains(paMin)
                                      ? paMin
                                      : null,
                                  items: minutes?.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    paMin = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 60,
                // width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        paDate != null
                            ? DateFormat("dd-MM-yyyy").format(paDate!)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            paDate = await _selectDate(
                                context, paDate ?? DateTime.now());
                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(),
              Text(
                'Accidental Notes',
                style: Constants.header2,
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                maxLines: 3,
                controller: aNotes,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              aNotesError != ''
                  ? Text(
                      aNotesError,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              SizedBox(
                height: 5,
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
                          width: 80,
                          height: 38,
                          decoration: BoxDecoration(
                            //    color: Constants.kButton,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
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
                        print(widget.centerid);
                        print("object1");
                        print(positionRole?.text.toString());

                        print(_allChildrens[currentIndex].id);
                        print(_allChildrens[currentIndex].name);

                        if (name?.text.toString() == '') {
                          nameError = 'Enter  Name';
                          setState(() {});
                        } else if (positionRole?.text.toString() == '') {
                          nameError = '';
                          positionroleError = 'Enter Position Role';
                          setState(() {});
                        } else if (_allChildrens[currentIndex].id == null) {
                          nameError = '';
                          positionroleError = '';
                          cnameError = 'Enter Child Name';
                          setState(() {});
                        } else if (cAge?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = 'Enter Child Age';
                          setState(() {});
                        } else if (cloc?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = 'Enter Location ';
                          setState(() {});
                        } else if (witnessname?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = 'Enter Witness Name';
                          setState(() {});
                        } else if (cactivity?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError =
                              'Enter General activity at the time of incident/ injury/ trauma/ illness';
                          setState(() {});
                        } else if (ccause?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = 'Enter Cause of injury/ trauma';
                          setState(() {});
                        } else if (ccsurrondings?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError =
                              'Enter Circumstances surrounding any illness, including apparent symptoms';
                          setState(() {});
                        } else if (ccunaccount?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError =
                              'Enter Circumstances if child appeared to be missing or otherwise unaccounted for (incl duration, who found child etc.)';
                          setState(() {});
                        } else if (cclocked?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError =
                              'Enter Circumstances if child appeared to have been taken or removed from service or was locked in/out of service (incl who took the child, duration)';
                          setState(() {});
                        } else if (adetail?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = 'Enter Details of action taken';
                          setState(() {});
                        } else if (gName1?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = 'Enter Parent Name';
                          setState(() {});
                        } else if (gContact1?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = 'Enter Contact Method';
                          setState(() {});
                        } else if (gName2?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = 'Enter Parent Name';
                          setState(() {});
                        } else if (gContact2?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = 'Enter Contact Method';
                          setState(() {});
                        } else if (nName?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = 'Enter Responsible Person Name';
                          setState(() {});
                        } else if (nSupervisorName?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError =
                              'Enter Nominated Supervisor Name';
                          setState(() {});
                        } else if (eAgency?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError = '';
                          eAgencyError = 'Enter Other Agency';
                          setState(() {});
                        } else if (eAuthority?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError = '';
                          eAgencyError = '';
                          eAuthorityError = 'Enter Regulatory authority';
                          setState(() {});
                        } else if (paName?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError = '';
                          eAgencyError = '';
                          eAuthorityError = '';
                          paNameError = 'Enter Name of parent / guardian';
                          setState(() {});
                        } else if (aNotes?.text.toString() == '') {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError = '';
                          eAgencyError = '';
                          eAuthorityError = '';
                          paNameError = '';
                          aNotesError = 'Additional Notes';
                          setState(() {});
                        } else if (person_signature == null) {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError = '';
                          eAgencyError = '';
                          eAuthorityError = '';
                          paNameError = '';
                          aNotesError = '';
                          personsignatureError = 'Enter Person Signature';
                          setState(() {});
                        } else if (child_signature == null) {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError = '';
                          eAgencyError = '';
                          eAuthorityError = '';
                          paNameError = '';
                          aNotesError = '';
                          personsignatureError = '';
                          childsignatureError = 'Enter Child Signature';
                          setState(() {});
                        } else if (incharge_signature == null) {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError = '';
                          eAgencyError = '';
                          eAuthorityError = '';
                          paNameError = '';
                          aNotesError = '';
                          personsignatureError = '';
                          childsignatureError = '';
                          inchargesignatureError = 'Enter Incharge Signature';
                          setState(() {});
                        } else if (supervisor_signature == null) {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError = '';
                          eAgencyError = '';
                          eAuthorityError = '';
                          paNameError = '';
                          aNotesError = '';
                          personsignatureError = '';
                          childsignatureError = '';
                          inchargesignatureError = '';
                          supervisorsignatureError =
                              'Enter Supervisor Signature';
                          setState(() {});
                        } else {
                          nameError = '';
                          positionroleError = '';
                          cnameError = '';
                          cAgeError = '';
                          clocError = ' ';
                          witnessnameError = '';
                          cactivityError = '';
                          cclockedError = '';
                          ccsurrondingsError = '';
                          ccunaccountError = '';
                          cclockedError = '';
                          adetailError = '';
                          gNmae1Error = '';
                          gContact1Error = '';
                          gName2Error = '';
                          gContact2Error = '';
                          nNameError = '';
                          nSupervisorNameError = '';
                          eAgencyError = '';
                          eAuthorityError = '';
                          paNameError = '';
                          aNotesError = '';
                          personsignatureError = '';
                          childsignatureError = '';
                          inchargesignatureError = '';
                          supervisorsignatureError = '';
                          setState(() {});

                          String header = "data:image/png;base64,";
                          String person_sig_base =
                              header + base64Encode(person_signature!);
                          String recorddatefinal =
                              DateFormat('yyyy-MM-dd').format(recordDate!);
                          String recordtimefinal = pHour! + ":" + pMin!;

                          String childDobfinal =
                              DateFormat('yyyy-MM-dd').format(cDob!);

                          String incidentdatefinal =
                              DateFormat('yyyy-MM-dd').format(cIncidentDate!);
                          String incidenttimefinal = cHour! + ":" + cMin!;
                          String incident_sig_base =
                              header + base64Encode(child_signature!);

                          String IDatefinal =
                              DateFormat('yyyy-MM-dd').format(cIDate!);

                          String gDate1final =
                              DateFormat('yyyy-MM-dd').format(gDate1!);
                          String gTinme1final =
                              gHour1 ?? '' + ":" + "${gMin1 ?? ''}";

                          String gDate2final =
                              DateFormat('yyyy-MM-dd').format(gDate2!);
                          String gTinme2final = gHour2! + ":" + gMin2!;
                          String incharge_sig_base =
                              header + base64Encode(incharge_signature!);

                          String nDate1final =
                              DateFormat('yyyy-MM-dd').format(nDate1!);
                          String nTime1 = nHour1! + ":" + nMin1!;

                          String supervisor_sig_bases =
                              header + base64Encode(supervisor_signature!);
                          String nDate2final =
                              DateFormat('yyyy-MM-dd').format(nDate2!);
                          String nTime2 = nHour2! + ":" + nMin2!;

                          String eDate2final =
                              DateFormat('yyyy-MM-dd').format(eDate2!);
                          String eTime2 = eHour2! + ":" + eMin2!;

                          String eDate1final =
                              DateFormat('yyyy-MM-dd').format(eDate1!);
                          String eTime1 = eHour1! + ":" + eMin1!;

                          String paDatefinal =
                              DateFormat('yyyy-MM-dd').format(paDate!);
                          String paTime = paHour! + ":" + paMin!;

                          String addmarkfinal = header + (addmark ?? '');

                          String _toSend =
                              Constants.BASE_URL + 'accident/saveAccident';

                          var objToSend = {
                            "centerid": widget.centerid,
                            "roomid": widget.roomid,
                            "person_name": name?.text.toString(),
                            "person_role": positionRole?.text.toString(),
                            "date": recorddatefinal,
                            "time": recordtimefinal,
                            "person_sign": person_sig_base,
                            "childid": _allChildrens[currentIndex].id,
                            "child_name": _allChildrens[currentIndex].name,
                            "child_dob": childDobfinal,
                            "child_age": cAge?.text.toString(),
                            "gender": _gender,
                            "incident_date": incidentdatefinal,
                            "incident_time": incidenttimefinal,
                            "incident_location": cloc?.text.toString(),
                            "witness_name": witnessname?.text.toString(),
                            "witness_date": IDatefinal,
                            "witness_sign": incident_sig_base,
                            "gen_actyvt": cactivity?.text.toString(),
                            "cause": ccause?.text.toString(),
                            "illness_symptoms": ccsurrondings?.text.toString(),
                            "missing_unaccounted": ccunaccount?.text.toString(),
                            "taken_removed": cclocked?.text.toString(),
                            // "injury_image": addmarkfinal,
                            "abrasion": abrasion == false ? 0 : 1,
                            "electric_shock": electic == false ? 0 : 1,
                            "allergic_reaction": allergy == false ? 0 : 1,
                            "high_temperature": high == false ? 0 : 1,
                            "amputation": amputation == false ? 0 : 1,
                            "infectious_disease": infectious == false ? 0 : 1,
                            "anaphylaxis": anaphylaxis == false ? 0 : 1,
                            "ingestion": ingestion == false ? 0 : 1,
                            "asthma": asthama == false ? 0 : 1,
                            "internal_injury": internal == false ? 0 : 1,
                            "bite_wound": bite == false ? 0 : 1,
                            "poisoning": poisoning == false ? 0 : 1,
                            "broken_bone": broken == false ? 0 : 1,
                            "rash": rash == false ? 0 : 1,
                            "burn": burn == false ? 0 : 1,
                            "respiratory": respiratory == false ? 0 : 1,
                            "choking": choking == false ? 0 : 1,
                            "seizure": seizure == false ? 0 : 1,
                            "concussion": concussion == false ? 0 : 1,
                            "sprain": sprain == false ? 0 : 1,
                            "crush": crush == false ? 0 : 1,
                            "stabbing": stabbing == false ? 0 : 1,
                            "cut": cut == false ? 0 : 1,
                            "tooth": tooth == false ? 0 : 1,
                            "drowning": drowning == false ? 0 : 1,
                            "venomous_bite": venomous == false ? 0 : 1,
                            "eye_injury": eye == false ? 0 : 1,
                            "other": other == false ? 0 : 1,
                            "remarks": "other remarks",
                            "action_taken": adetail?.text.toString(),
                            "emrg_serv_attend": _aEmergency == "Yes" ? 1 : 0,
                            "med_attention": _aAttention == "Yes" ? 1 : 0,
                            "med_attention_details":
                                ayesdetails?.text.toString(),
                            "prevention_step_1": afuture1?.text.toString(),
                            "prevention_step_2": afuture2?.text.toString(),
                            "prevention_step_3": afuture3?.text.toString(),
                            "parent1_name": gName1?.text.toString(),
                            "contact1_method": gContact1?.text.toString(),
                            "contact1_date": gDate1final,
                            "contact1_time": gTinme1final,
                            "contact1_made": gContacted1 == false ? 0 : 1,
                            "contact1_msg": gMsg1 == false ? 0 : 1,
                            "parent2_name": gName2?.text.toString(),
                            "contact2_method": gContact2?.text.toString(),
                            "contact2_date": gDate2final,
                            "contact2_time": gTinme2final,
                            "contact2_made": gContacted2 == false ? 0 : 1,
                            "contact2_msg": gMsg2 == false ? 0 : 1,
                            "responsible_person_name": nName?.text.toString(),
                            "responsible_person_sign": incharge_sig_base,
                            "rp_internal_notif_date": nDate1final,
                            "rp_internal_notif_time": nTime1,
                            "otheragency": eAgency?.text.toString(),
                            "enor_date": nDate2final,
                            "enor_time": nTime2,
                            "Regulatoryauthority": eAuthority?.text.toString(),
                            "enra_date": eDate1final,
                            "enra_time": eTime1,
                            "add_notes": aNotes?.text.toString(),
                            "userid": MyApp.LOGIN_ID_VALUE,
                          };
                          if (widget.type == 'edit') {
                            objToSend.addAll({'id': widget.accid});
                            // _toSend =
                            //     Constants.BASE_URL + 'accident/updateAccident';
                          }

                          print(jsonEncode(objToSend));

                          print(MyApp.LOGIN_ID_VALUE);
                          print(await MyApp.getDeviceIdentity());
                          final response = await http.post(Uri.parse(_toSend),
                              body: jsonEncode(objToSend),
                              headers: {
                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                              });
                          print(response.headers);
                          print(response.body);
                          if (response.statusCode == 200) {
                            if (widget.type == 'edit') {
                              MyApp.ShowToast("Updated", context);
                            } else {
                              MyApp.ShowToast("Created", context);
                            }

                            print('created');
                            // Navigator.of(context).popUntil(
                            //     (route) => route.isFirst);
                            Navigator.pop(context);
                          } else if (response.statusCode == 401) {
                            MyApp.Show401Dialog(context);
                          }
                          setState(() {});
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Constants.kButton,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Text(
                              'SAVE',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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
                height: 15,
              ),
            ],
          ),
        ),
      )),
    );
  }

  Future<DateTime> _selectDate(BuildContext context, DateTime dateTime) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: new DateTime(1800),
      lastDate: new DateTime(2100),
    );
    if (picked == null) {
      return dateTime;
    } else {
      return picked;
    }
  }
}
