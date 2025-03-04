import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/cropImage.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:intl/intl.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:path/path.dart';

import 'package:http_parser/http_parser.dart';

class AddUser extends StatefulWidget {
  final String type;
  final String id;

  AddUser(this.type, this.id);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  TextEditingController first, mobile, mail, title, pwd, empcode;

  String status = 'STAFF';
  String _gender = 'MALE';
  String _dob = '';
  String dob = '';
  String editpin = '';
  bool active = false;
  List<CentersModel> centers;
  Map<String, bool> centerValues = {};
  List<CentersModel> _selectedCenter = [];
  bool centersFetched = false;
  String pin = '';

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
      File fImage = await cropImage(context, file);
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
    mobile = TextEditingController();
    mail = TextEditingController();
    title = TextEditingController();
    pwd = TextEditingController();
    empcode = TextEditingController();

    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchData() async {
    if (widget.type == 'edit') {
      SettingsApiHandler handler = SettingsApiHandler({
        "userid": MyApp.LOGIN_ID_VALUE,
        "recordId": widget.id,
      });
      var data = await handler.getUsersData();
      if (!data.containsKey('error')) {
        var res = data['userdata'];
        print(res);
        first.text = res['name'].toString();
        mail.text = res['emailid'].toString();
        _gender = res['gender'];
        if (res['userType'].toString().toLowerCase() == 'superadmin') {
          pwd.text = res['password'];
        } else if (res['userType'].toString().toLowerCase() == 'staff') {
          editpin = res['password'];
          pin = res['password'];
          empcode.text = res['username'].toString();
        }
        status = res['userType'].toString().toUpperCase();
        mobile.text = res['contactNo'];
        var inputFormat = DateFormat("yyyy-MM-dd");
        final DateFormat formati = DateFormat('dd-MM-yyyy');
        var date1 = inputFormat.parse(res['dob']);
        dob = formati.format(date1);
        _dob = formati.format(date1);
        title.text = res['title'];
        //  imageUrl = res['imageUrl'];
        for (var j = 0; j < data['centers'].length; j++) {
          for (var i = 0; i < centers.length; i++) {
            if (centers[i].id == data['centers'][j]['id'].toString()) {
              _selectedCenter.add(centers[i]);
              centerValues[centers[i].id] = true;
            }
          }
        }
        setState(() {});
      } else {
        // MyApp.Show401Dialog(context);
      }
    }
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
          centerValues[centers[i].id] = false;
        }
        centersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      //MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: Header.appBar(),
        endDrawer: Drawer(
          child: Container(
              child: ListView(
            children: [
              SizedBox(
                height: 5,
              ),
              ListTile(
                title: Text(
                  'Select Center',
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
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: ListView.builder(
                    // shrinkWrap: true,
                    itemCount: centers != null ? centers.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(centers[index].centerName),
                        trailing: Checkbox(
                            value: centerValues[centers[index].id],
                            onChanged: (value) {
                              if (value == true) {
                                if (!_selectedCenter.contains(centers[index])) {
                                  _selectedCenter.add(centers[index]);
                                }
                              } else {
                                if (_selectedCenter.contains(centers[index])) {
                                  _selectedCenter.remove(centers[index]);
                                }
                              }

                              centerValues[centers[index].id] = value!;
                              setState(() {});
                            }),
                      );
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
              )
            ],
          )),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                     widget.type == 'edit'?'Edit User': 'Add User',
                        style: Constants.header1,
                      ),
                      Row(
                        children: [
                          Text('User Settings>'),
                          Text(
                     widget.type == 'edit'?'Edit User':'Add User',
                            style: TextStyle(color: Constants.kMain),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Select Center',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 10,
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Colors.blue[100],
                                  ),
                                ),
                                Text(
                                  'Select Center',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      _selectedCenter.length > 0
                          ? Wrap(
                              spacing: 8.0, // gap between adjacent chips
                              runSpacing: 4.0, // gap between lines
                              children: List<Widget>.generate(
                                  _selectedCenter.length, (int index) {
                                return _selectedCenter[index].id != null
                                    ? Chip(
                                        label: Text(
                                            _selectedCenter[index].centerName),
                                        onDeleted: () {
                                          setState(() {
                                            centerValues[_selectedCenter[index]
                                                .id] = false;
                                            _selectedCenter.removeAt(index);
                                          });
                                        })
                                    : Container();
                              }))
                          : Container(),
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
                            'Name',
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
                            'Mobile',
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
                            'Mail Id',
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
                        height: 15,
                      ),
                      Text(
                        'Account Details',
                        style: Constants.header2,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Title',
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
                          controller: title,
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
                      Text(
                        'User Type',
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
                                value: status,
                                items: <String>['STAFF', 'SUPERADMIN']
                                    .map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                 onChanged: (String? value)  {
                                  setState(() {
                                    status = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // if (status == 'SUPERADMIN')
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       SizedBox(
                      //         height: 10,
                      //       ),
                      //       Text(
                      //         'Password',
                      //         style: Constants.header2,
                      //       ),
                      //       SizedBox(
                      //         height: 5,
                      //       ),
                      //       Container(
                      //         height: 50,
                      //         padding: EdgeInsets.only(left: 16.0),
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(3),
                      //             border: Border.all(color: Colors.grey)),
                      //         child: TextField(
                      //           controller: pwd,
                      //           autofocus: false,
                      //           obscureText: false,
                      //           decoration: InputDecoration(
                      //               contentPadding: EdgeInsets.all(0),
                      //               border: InputBorder.none),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // if (status == 'STAFF')
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       SizedBox(height: 10),
                      //       Text(
                      //         'Employee Code',
                      //         style: Constants.header2,
                      //       ),
                      //       SizedBox(
                      //         height: 5,
                      //       ),
                      //       Container(
                      //         height: 50,
                      //         padding: EdgeInsets.only(left: 16.0),
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(3),
                      //             border: Border.all(color: Colors.grey)),
                      //         child: TextField(
                      //           controller: empcode,
                      //           autofocus: false,
                      //           obscureText: false,
                      //           decoration: InputDecoration(
                      //               contentPadding: EdgeInsets.all(0),
                      //               border: InputBorder.none),
                      //         ),
                      //       ),
                      //       SizedBox(height: 10),
                      //       Text(
                      //         'PIN',
                      //         style: Constants.header2,
                      //       ),
                      //       SizedBox(height: 3),
                      //       if (editpin.length != 0)
                      //         Row(
                      //           //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //           children: [
                      //             Text(editpin),
                      //             Expanded(
                      //               flex: 1,
                      //               child: Container(),
                      //             ),
                      //             GestureDetector(
                      //                 onTap: () {
                      //                   editpin = '';
                      //                   setState(() {});
                      //                 },
                      //                 child: Text(
                      //                   'Change',
                      //                   style: TextStyle(color: Colors.blue),
                      //                 ))
                      //           ],
                      //         ),
                      //       if (editpin.length == 0)
                      //         OTPTextField(
                      //           length: 4,
                      //           width: MediaQuery.of(context).size.width,
                      //           fieldWidth: 50,
                      //           style: TextStyle(fontSize: 17),
                      //           textFieldAlignment:
                      //               MainAxisAlignment.spaceAround,
                      //           //fieldStyle: FieldStyle.underline,
                      //           onCompleted: (p) {
                      //             print("Completed: " + p);
                      //             setState(() {
                      //               pin = p;
                      //             });
                      //           },
                      //         ),
                      //     ],
                      //   ),
                      SizedBox(
                        height: 15,
                      ),
                      _image == null
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
                                        Text('Upload User'),
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
                      SizedBox(height: 15),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (first.text.toString().length == 0) {
                                  MyApp.ShowToast('Enter Name', context);
                                } else if (dob == '') {
                                  MyApp.ShowToast('Add Date', context);
                                } else if (mobile.text.toString() == '') {
                                  MyApp.ShowToast(
                                      'Enter Mobile Number', context);
                                } else if (mail.text.toString() == '') {
                                  MyApp.ShowToast('Enter Mail Id', context);
                                } else if (status == 'STAFF' &&
                                    pin.length == 0) {
                                  MyApp.ShowToast(
                                      'Enter Complete Pin', context);
                                } else if (status == 'STAFF' &&
                                    empcode.text.length == 0) {
                                  MyApp.ShowToast(
                                      'Enter Employee Code', context);
                                }
                                // else if (status == 'SUPERADMIN' &&
                                //     pwd.text.length == 0) {
                                //   MyApp.ShowToast('Enter Password', context);
                                // }
                                else {
                                  List centers = [];
                                  for (int i = 0;
                                      i < _selectedCenter.length;
                                      i++) {
                                    centers.add(_selectedCenter[i].id);
                                  }

                                  print(jsonEncode(centers));

                                  String _toSend = Constants.BASE_URL +
                                      'Settings/saveUsersDetails';

                                  print(_toSend);

                                  Map<String, dynamic> objToSend;

//  {"username":"EMP0001","password":"1111",}
                                  objToSend = {
                                    "centerIds": centers,
                                    "name": first.text,
                                    "gender": _gender.toUpperCase(),
                                    "dob": dob,
                                    "contactNo": mobile.text.toString(),
                                    "emailid": mail.text.toString(),
                                    "title": title.text.toString(),
                                    'userType': status,
                                    "userid": MyApp.LOGIN_ID_VALUE,
                                  };
                                  // if (status == 'STAFF') {
                                  //   objToSend['username'] =
                                  //       empcode.text.toString();
                                  //   objToSend['password'] = pin;
                                  // } else {
                                  //   objToSend['password'] = pwd.text.toString();
                                  // }
                                  //check whether int or not
                                  if (widget.type == 'edit') {
                                    objToSend['recordId'] = widget.id;
                                  }
                                  if (_image != null) {
                                    var d = await MultipartFile.fromFile(
                                        _image.path,
                                        filename: basename(_image.path),
                                        contentType:
                                            MediaType.parse('image/jpg'));

                                    // print('ddd' + d.toString());
                                    // String mimeStr =
                                    //     lookupMimeType(_image.path);
                                    // var fileType = mimeStr.split('/');
                                    // objToSend['image'] = {
                                    //   "mime": fileType[0] + '/' + fileType[1],
                                    //   "postname": basename(_image.path),
                                    //   "name": d,
                                    // };
                                    objToSend['image'] = d;
                                  }
                                  MyApp.getDeviceIdentity().then(
                                      (value) => print('authtoken' + value));
                                  print('authtoken' + MyApp.AUTH_TOKEN_VALUE);

                                  FormData formData =
                                      FormData.fromMap(objToSend);

                                  print(formData.fields.toString());
                                  Dio dio = new Dio();

                                  await dio
                                      .post(Uri.parse(_toSend),
                                          data: formData,
                                          options: Options(headers: {
                                            'X-DEVICE-ID':
                                                await MyApp.getDeviceIdentity(),
                                            'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                          }))
                                      .then((value) {
                                    print('happ' + value.toString());
                                    var v = jsonDecode(value.toString());
                                    if (v['Status'] == 'SUCCESS') {
                                      MyApp.ShowToast("updated", context);
                                      Navigator.pop(context, 'kill');
                                    } else {
                                      MyApp.ShowToast("error", context);
                                    }
                                  }).catchError((error) => print(error));
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

  Future<DateTime> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(1850),
      lastDate: new DateTime(2100),
    );
    return picked;
  }
}
