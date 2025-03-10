import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddParent extends StatefulWidget {
  final String type;
  final String id;

  AddParent(this.type,this.id);

  @override
  _AddParentState createState() => _AddParentState();
}

class _AddParentState extends State<AddParent> {
  TextEditingController? full, mobile, mail,pwd;

  String status = 'Active';
  List<String> relation =['Father'];
  String _gender = 'MALE';
  String _dob = '';
  String dob = '';
  List<ChildModel> children=[];
  bool active = false;
  bool childrenFetched=false;
  List<int> currentIndex=[0];

  @override
  void initState() {
    full = TextEditingController();
    mobile = TextEditingController();
    mail = TextEditingController();
    pwd =TextEditingController();
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    if (widget.type == 'edit') {
   SettingsApiHandler handler =
        SettingsApiHandler({"userid": MyApp.LOGIN_ID_VALUE,"recordId": widget.id,});
   
   var data = await handler.getParentDetails();
    if (!data.containsKey('error')) {
      print('ress'+data.toString());
       
       var parent =data['parents'];
       full?.text=parent['name'];
       mobile?.text=parent['contactNo'];
       mail?.text=parent['emailid'];
       pwd?.text=parent['password']; 
       _gender=parent['gender'];
      var inputFormat = DateFormat("yyyy-MM-dd");
      final DateFormat formati = DateFormat('dd-MM-yyyy');
      var date1 = inputFormat.parse(parent['dob']);
      dob = formati.format(date1);
      _dob=formati.format(date1);


       var res = data['children'];
       children = [];
       try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          children.add(ChildModel.fromJson(res[i]));
        }
        childrenFetched = true;    
      if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }

      for(var i=0;i<parent['children'].length;i++){
        if(i!=0){
           currentIndex.add(0);
           relation.add('Father');
         }
         for (int j = 0;j < children.length; j++) {
            if (children[j].id == parent['children'][i]['childid']) {
                 setState(() {
                   currentIndex[i] = j;
                 });
                break;
          }
        }
        relation[i]=parent['children'][i]['relation']; 
      }

     if (this.mounted) setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }

    }else{
   SettingsApiHandler handler =
        SettingsApiHandler({"userid": MyApp.LOGIN_ID_VALUE});
   
    var data = await handler.getParentDetails();
    if (!data.containsKey('error')) {
      print(data);
       var res = data['children'];
       children = [];
       try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          children.add(ChildModel.fromJson(res[i]));
        }
        childrenFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
       if (this.mounted) setState(() {});
   
    } else {
      MyApp.Show401Dialog(context);
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                        'Add Parent',
                        style: Constants.header1,
                      ),
                      Row(
                        children: [
                          Text('Parent Settings>'),
                          Text(
                            'Add Parent',
                            style: TextStyle(color: Constants.kMain),
                          )
                        ],
                      ),                  
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Personal Details',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Full Name',
                            style: Constants.header2,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: full,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Gender',
                            style: Constants.header2,
                          ),
                        ],
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Center(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _gender,
                                items: <String>['MALE', 'FEMALE', 'OTHERS']
                                    .map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                 onChanged: (String? value)  {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: 20.0,
                      // ),
                      // Row(
                      //   children: [
                      //     Text(
                      //       '*',
                      //       style: TextStyle(color: Colors.red),
                      //     ),
                      //     Text(
                      //       'Date of Birth',
                      //       style: Constants.header2,
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 10.0,
                      // ),
                      // Container(
                      //     padding: EdgeInsets.all(14.0),
                      //     decoration: BoxDecoration(
                      //         borderRadius:
                      //             BorderRadius.all(Radius.circular(8.0)),
                      //         border: Border.all(
                      //             color: Color(0xff8A8A8A), width: 1.0)),
                      //     child: Row(
                      //       children: <Widget>[
                      //         Expanded(
                      //             flex: 7,
                      //             child: new Text(
                      //               dob,
                      //               style: TextStyle(
                      //                   fontSize: 15.0, color: Colors.black),
                      //             )),
                      //         GestureDetector(
                      //           child: Icon(
                      //             Icons.calendar_today,
                      //             color: Constants.kMain,
                      //           ),
                      //           onTap: () async {
                      //             await _selectDate(context).then((value) {
                      //               if (value != null) {
                      //                 _dob = value.toString().substring(0, 10);

                      //                 var inputFormat =
                      //                     DateFormat("yyyy-MM-dd");
                      //                 final DateFormat formati =
                      //                     DateFormat('dd-MM-yyyy');
                      //                 var date1 = inputFormat.parse(_dob);
                      //                 dob = formati.format(date1);

                      //                 if (this.mounted) setState(() {});
                      //               }
                      //             });
                      //           },
                      //         ),
                      //       ],
                      //     )),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Date of Birth',
                            style: Constants.header2,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                          padding: EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              border: Border.all(
                                  color: Color(0xff8A8A8A), width: 1.0)),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 7,
                                  child: new Text(
                                    dob,
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.black),
                                  )),
                              GestureDetector(
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Constants.kMain,
                                ),
                                onTap: () async {
                                  await _selectDate(context).then((value) {
                                    if (value != null) {
                                      _dob = value.toString().substring(0, 10);

                                      var inputFormat =
                                          DateFormat("yyyy-MM-dd");
                                      final DateFormat formati =
                                          DateFormat('dd-MM-yyyy');
                                      var date1 = inputFormat.parse(_dob);
                                      dob = formati.format(date1);

                                      if (this.mounted) setState(() {});
                                    }
                                  });
                                },
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Contact Number',
                            style: Constants.header2,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: mobile,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Email',
                            style: Constants.header2,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: mail,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                        SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Password',
                            style: Constants.header2,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: pwd,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                         children: [
                           Text(
                            'Child Details',
                             style: Constants.header2,
                           ),
                           Expanded(child: Container(),),
                           ElevatedButton(
                             child: Text('Add'),
                              onPressed: (){
                                currentIndex.add(0);
                                relation.add('Father');
                                setState((){});
                             },)
                         ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: currentIndex.length,
                        itemBuilder: (BuildContext context,int i){
                         return   Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                           Container(
                             width: MediaQuery.of(context).size.width,
                             child: Row(
                               children: [
                                Text(
                                  'Select Children',
                                  style: Constants.header2,
                                ),
                                Expanded(child: Container(),),
                                IconButton(
                                  icon: Icon(Icons.delete), 
                                  onPressed: (){
                                    currentIndex.removeAt(i);
                                    relation.removeAt(i);
                                    setState(() {
                                      
                                    });
                                  })
                               ],
                             ),
                           ),
                          SizedBox(
                             height: 5,
                          ),
                          if(childrenFetched)
                            DropdownButtonHideUnderline(
                             child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width ,
                              decoration: BoxDecoration(
                               border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(8))),
                              child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                isExpanded: true,
                                value: children[currentIndex[i]].id,
                                items: children.map((ChildModel value) {
                                  return new DropdownMenuItem<String>(
                                    value: value.id,
                                    child: new Text(value.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  for (int j = 0;j < children.length; j++) {
                                    if (children[j].id == value) {
                                      setState(() {
                                        currentIndex[i] = j;
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
                      SizedBox(
                          height: 15,
                      ),
                      Text(
                          'Relation',
                          style: Constants.header2,
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: relation[i],
                                  items: <String>[ 'Father','Mother', 'Brother', 'Sister', 'Relative']
                                      .map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                   onChanged: (String? value)  {
                                    setState(() {
                                      relation[i] = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                           ),
                           SizedBox(height: 10,),
                            ],
                          ),
                        ),
                        );
                       }),      
                      SizedBox(
                        height: 15.0,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {

                              if (full?.text.toString().length == 0) {
                                MyApp.ShowToast('Enter Name', context);
                              }  else if (dob == '') {
                                MyApp.ShowToast('Add Date', context);
                              } else if (mobile?.text.toString() == '') {
                                MyApp.ShowToast('Enter Mobile Number', context);
                              } else if (mail?.text.toString()== '') {
                                MyApp.ShowToast('Enter Mail Id', context);
                              }else if(pwd?.text.length==0){
                                   MyApp.ShowToast('Enter Password', context);
                              }
                              else{
                                  List relations=[];
                                 for(var i=0;i<relation.length;i++){
                                   relations.add({
                                     "childid": children[currentIndex[i]].id,
                                     "relation":relation[i]
                                   });
                                 }

                                var _toSend =
                                    Constants.BASE_URL+'Settings/saveParentDetails';

                                var objToSend ={
                                   "name":full?.text.toString(),
                                   "gender":_gender.toUpperCase(),
                                   "dob":dob,
                                   "contactNo":mobile?.text.toString(),
                                   "emailid":mail?.text.toString(),
                                   "password":pwd?.text.toString(),
                                   "relation":relations,
                                   "userid":MyApp.LOGIN_ID_VALUE};

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
                                  Navigator.pop(context, 'kill');
                                } else if (response.statusCode ==
                                    401) {
                                  MyApp.Show401Dialog(context);
                                }
                               }
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
                                      'SAVE',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
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
                        height: 15.0,
                      ),
                    ])))));
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(1850),
      lastDate: new DateTime(2100),
    );
    return picked;
  }
}
