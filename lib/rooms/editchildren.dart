import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/cropImage.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class EditChildren extends StatefulWidget {
  final String id;
  final String childid;
  final String type;
  EditChildren({required this.id, required this.childid, required this.type});

  @override
  _EditChildrenState createState() => _EditChildrenState();
}

class _EditChildrenState extends State<EditChildren> {
  TextEditingController first, last;

  String _chosenValue = 'Active';
  String _gender = 'Male';
  String _dob = '';
  String dob = '';
  String _doj = '';
  String doj = '';
  String imageUrl = '';
  bool mon = true, tue = true, wed = true, thu = true, fri = true;
  File _image;

  Future<File> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        minWidth: 900, minHeight: 900, quality: 40);

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Future _loadFromGallery(var context) async {
    print('heee');
    final picker = ImagePicker();
    final _galleryImage = await picker.getImage(source: ImageSource.gallery);

    // setState(() {
    //   _image = File(_galleryImage.path);
    // });
    File file = File(_galleryImage.path);
    var fileSizeInBytes = file.length();
    var fileSizeInKB = await fileSizeInBytes / 1024;
    var fileSizeInMB = fileSizeInKB / 1024;
    print('HERE' + fileSizeInMB.toString());
    if (fileSizeInMB > 2) {
      MyApp.ShowToast(
          'file size greater than 2 mb so image is being compressed', context);

      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

      File cFile = await compressAndGetFile(file, outPath);
      File fImage = await cropImage(context, cFile);
      if (fImage != null) {
        _image = file;
      }
      setState(() {});
    } else {
      File fImage = await cropImage(context, file);
      if (fImage != null) {
        _image = file;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    first = TextEditingController();
    last = TextEditingController();
    if (widget.type == 'edit') {
      _fetchData();
    }

    super.initState();
  }

  Future<void> _fetchData() async {
    RoomAPIHandler handler = RoomAPIHandler({
      "userid": MyApp.LOGIN_ID_VALUE,
      "roomid": widget.id,
      "childid": widget.childid
    });
    var data = await handler.getChid();
    if (!data.containsKey('error')) {
      var res = data['child'];
      print(res);
      var name = res['name'].toString().split(" ");
      if (name.length > 1) {
        first.text = name[0];
        last.text = name[1];
      } else {
        first.text = name[0];
      }
      _gender = res['gender'];
      _chosenValue = res['status'];
      if (res['daysAttending'][0] == '0') {
        mon = false;
      } else {
        mon = true;
      }
      if (res['daysAttending'][1] == '0') {
        tue = false;
      } else {
        tue = true;
      }
      if (res['daysAttending'][2] == '0') {
        wed = false;
      } else {
        wed = true;
      }
      if (res['daysAttending'][3] == '0') {
        thu = false;
      } else {
        thu = true;
      }
      if (res['daysAttending'][4] == '0') {
        fri = false;
      } else {
        fri = true;
      }
      var inputFormat = DateFormat("yyyy-MM-dd");
      final DateFormat formati = DateFormat('dd-MM-yyyy');
      var date1 = inputFormat.parse(res['dob']);
      dob = formati.format(date1);
      var date2 = inputFormat.parse(res['startDate']);
      doj = formati.format(date2);
      imageUrl = res['imageUrl'];

      setState(() {});
    } else {
      // MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Edit Children',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                            'First Name',
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
                          controller: first,
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
                      Text(
                        'Last Name',
                        style: Constants.header2,
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
                          controller: last,
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
                                items: <String>['Male', 'Female', 'Others']
                                    .map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _gender = value??'';
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
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
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Date of Join',
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
                                    doj,
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
                                      _doj = value.toString().substring(0, 10);

                                      var inputFormat =
                                          DateFormat("yyyy-MM-dd");
                                      final DateFormat formati =
                                          DateFormat('dd-MM-yyyy');
                                      var date1 = inputFormat.parse(_doj);
                                      doj = formati.format(date1);

                                      if (this.mounted) setState(() {});
                                    }
                                  });
                                },
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'Status',
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
                                value: _chosenValue,
                                items: <String>['Active', 'InActive']
                                    .map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                 onChanged: (String? value)  {
                                  setState(() {
                                    _chosenValue = value!;
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
                      CheckboxListTile(
                        value: mon,
                        onChanged: (val) {
                          mon = val;
                          setState(() {});
                        },
                        title: Text('Monday'),
                      ),
                      CheckboxListTile(
                        value: tue,
                        onChanged: (val) {
                          tue = val;
                          setState(() {});
                        },
                        title: Text('Tuesday'),
                      ),
                      CheckboxListTile(
                        value: wed,
                        onChanged: (val) {
                          wed = val;
                          setState(() {});
                        },
                        title: Text('Wednesday'),
                      ),
                      CheckboxListTile(
                        value: thu,
                        onChanged: (val) {
                          thu = val;
                          setState(() {});
                        },
                        title: Text('Thursday'),
                      ),
                      CheckboxListTile(
                        value: fri,
                        onChanged: (val) {
                          fri = val;
                          setState(() {});
                        },
                        title: Text('Friday'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      imageUrl != ''
                          ? Stack(
                              children: [
                                Container(
                                    width: 120,
                                    height: 120,
                                    decoration: new BoxDecoration(
                                      //  borderRadius: BorderRadius.circular(15.0),
                                      shape: BoxShape.rectangle,
                                      image: new DecorationImage(
                                        image: new NetworkImage(
                                            Constants.ImageBaseUrl + imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        imageUrl = '';
                                        _loadFromGallery(context);
                                        setState(() {});
                                      },
                                    ))
                              ],
                            )
                          : _image == null
                              ? GestureDetector(
                                  onTap: () async {
                                    _loadFromGallery(context);
                                  },
                                  child: DottedBorder(
                                    dashPattern: [8, 4],
                                    strokeWidth: 2,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.add),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text('Upload Child'),
                                            Text('Image')
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                              : Stack(
                                  children: [
                                    Container(
                                        width: 120,
                                        height: 120,
                                        decoration: new BoxDecoration(
                                          //  borderRadius: BorderRadius.circular(15.0),
                                          shape: BoxShape.rectangle,
                                          image: new DecorationImage(
                                            image: new FileImage(_image),
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    Positioned(
                                        right: 0,
                                        top: 0,
                                        child: IconButton(
                                          icon: Icon(Icons.clear),
                                          onPressed: () {
                                            showDeleteDialog(context, () {
                                              _image = null;
                                              setState(() {});
                                              Navigator.pop(context);
                                            });
                                          },
                                        ))
                                  ],
                                ),
                      SizedBox(
                        height: 15,
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
                              String img64 = '';
                              String imgName = '';

                              if (_image != null) {
                                final bytes =
                                    File(_image.path).readAsBytesSync();
                                imgName = basename(_image.path);
                                img64 = base64Encode(bytes);
                              }

                              String days = '';
                              days = mon ? '1' : '0';
                              days = days + (tue ? '1' : '0');
                              days = days + (wed ? '1' : '0');
                              days = days + (thu ? '1' : '0');
                              days = days + (fri ? '1' : '0');
                              print('dddd' + days);
                              if (first.text.toString().length == 0) {
                                MyApp.ShowToast('Enter First Name', context);
                              } else if (dob == '') {
                                MyApp.ShowToast('Add Date', context);
                              } else if (doj == '') {
                                MyApp.ShowToast('Add Date of join', context);
                              } else {
                                String _toSend = Constants.BASE_URL +
                                    'Room/editChild?id=' +
                                    widget.id +
                                    '&childId=' +
                                    widget.childid;

                                print(_toSend);

                                Map<String, dynamic> mp;

                                mp = {
                                  "firstname": first.text,
                                  "lastname": last.text,
                                  "dob": dob,
                                  "startDate": doj,
                                  "gender": _gender,
                                  "status": _chosenValue,
                                  "id": widget.id,
                                  "daysAttending": days,
                                  "createdAt": DateTime.now().toString(),
                                  "userid": MyApp.LOGIN_ID_VALUE,
                                };

                                if (widget.type == 'edit') {
                                  mp['childId'] = widget.childid;
                                  mp['id'] = widget.id;
                                }
                                if (img64 != '') {
                                  mp['imageName'] = imgName;
                                  mp['image'] = img64;
                                }
                                print(mp);

                                final response = await http.post(Uri.parse(_toSend),
                                    body: jsonEncode(mp),
                                    headers: {
                                      'X-DEVICE-ID':
                                          await MyApp.getDeviceIdentity(),
                                      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                    });
                                print(response.body);
                                if (response.statusCode == 200) {
                                  MyApp.ShowToast("updated", context);
                                  print('created');
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                } else if (response.statusCode == 401) {
                                  MyApp.Show401Dialog(context);
                                }
                              }
                            },
                            child: Container(
                                width: 60,
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
                                        'SEND',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      )
                    ])))));
  }

  Future<DateTime> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(1850),
      lastDate: new DateTime.now(),
    );
    return picked;
  }
}
