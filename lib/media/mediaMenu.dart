import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mime/mime.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:mykronicle_mobile/api/mediaApi.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/menuMediaModel.dart';
import 'package:mykronicle_mobile/models/staffmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/cropImage.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:mykronicle_mobile/utils/video_item_local.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class MediaMenu extends StatefulWidget {
  @override
  _MediaMenuState createState() => _MediaMenuState();
}

class _MediaMenuState extends State<MediaMenu> {
  List<File> files = [];
  List<CentersModel> centers = [];
  List<MenuMediaModel> menuMedia = [];
  List<MenuMediaModel> menuMediaEarlier = [];
  List<MenuMediaModel> menuMediaWeek = [];
  List<ChildModel> _allChildrens = [];
  List<StaffModel> _allEductarors = [];
  List<List<StaffModel>> _editEducators = [];
  List<List<ChildModel>> _editChildren = [];
  List<TextEditingController> captions = [];

  bool centersFetched = false;
  int currentIndex = 0;
  bool childrensFetched = false;
  bool staffFetched = false;

  @override
  void initState() {
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
      //   MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  Future<void> _fetchData() async {
    ObservationsAPIHandler apiHandler =
        ObservationsAPIHandler({"userid": MyApp.LOGIN_ID_VALUE});
    var data1 = await apiHandler.getChildList();

    var child = data1['records'];
    _allChildrens = [];
    try {
      assert(child is List);
      for (int i = 0; i < child.length; i++) {
        _allChildrens.add(ChildModel.fromJson(child[i]));
      }
      childrensFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    UtilsAPIHandler utilsApiHandler = UtilsAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
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

    MediaAPIHandler handler = MediaAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var data = await handler.getMedia();
    print(data);
    if (!data.containsKey('error')) {
      print(data['Recent']);
      //Recent, ThisWeek, Earlier
      print(data.keys);
      menuMedia = [];
      menuMediaWeek = [];
      menuMediaEarlier = [];
      try {
        assert(data['Recent'] is List);
        for (int i = 0; i < data['Recent'].length; i++) {
          menuMedia.add(MenuMediaModel.fromJson(data['Recent'][i]));
          //     print(Constants.ImageBaseUrl + menuMedia[i].filename);
        }
        assert(data['ThisWeek'] is List);
        for (int i = 0; i < data['ThisWeek'].length; i++) {
          menuMediaWeek.add(MenuMediaModel.fromJson(data['ThisWeek'][i]));
        }
        assert(data['Earlier'] is List);
        for (int i = 0; i < data['Earlier'].length; i++) {
          menuMediaEarlier.add(MenuMediaModel.fromJson(data['Earlier'][i]));
        }
        print(menuMedia);
        print(menuMediaWeek);
        print(menuMediaEarlier);
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
      setState(() {});
    } else {
      //   MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: floating(context),
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Media ',
                  style: Constants.header2,
                ),
                SizedBox(
                  height: 8,
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
                                    menuMedia = [];
                                    files = [];
                                    _allChildrens = [];
                                    _editEducators = [];
                                    _editChildren = [];
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
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      allowMultiple: false, // Allows selecting multiple images
                    );

                    if (result != null) {
                      File file = File(result.files.single.path ?? '');
                      var fileSizeInBytes = file.length();
                      var fileSizeInKB = await fileSizeInBytes / 1024;
                      var fileSizeInMB = fileSizeInKB / 1024;

                      String mimeStr =
                          lookupMimeType(result.files.single.path ?? '') ?? '';
                      var fileType = mimeStr.split('/');

                      if (fileSizeInMB > 2 &&
                          fileType[0].toString() == 'image') {
                        MyApp.ShowToast(
                            'file size greater than 2 mb so image is being compressed',
                            context);

                        final filePath = file.absolute.path;
                        final lastIndex =
                            filePath.lastIndexOf(new RegExp(r'.jp'));
                        final splitted = filePath.substring(0, (lastIndex));
                        final outPath =
                            "${splitted}_out${filePath.substring(lastIndex)}";

                        File cFile = await compressAndGetFile(file, outPath);
                        _editEducators.add([]);
                        _editChildren.add([]);
                        captions.add(TextEditingController());
                        File? fImage = await cropImage(context, cFile);
                        if (fImage != null) {
                          files.add(fImage);
                        }
                        setState(() {});
                      } else {
                        captions.add(TextEditingController());
                        _editEducators.add([]);
                        _editChildren.add([]);
                        File? fImage = await cropImage(context, file);
                        if (fImage != null) {
                          files.add(fImage);
                        }
                        setState(() {});
                      }

                      setState(() {});
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: DottedBorder(
                    color: Colors.blueGrey.withOpacity(0.5),
                    dashPattern: const [10, 6],
                    strokeWidth: 1.8,
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(16),
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 60,
                            color: Colors.blueGrey.withOpacity(0.6),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Upload Media',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'JPG, PNG up to 5MB',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                if (files.length > 0)
                  Align(
                    alignment: Alignment.center,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 12.0,
                              runSpacing: 12.0,
                              children: List<Widget>.generate(files.length,
                                  (int index) {
                                String mimeStr =
                                    lookupMimeType(files[index].path) ?? '';
                                var fileType = mimeStr.split('/');
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        if (fileType[0].toString() == 'image')
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: FileImage(files[index]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        else
                                          VideoItemLocal(
                                            width: 100,
                                            height: 100,
                                            file: files[index],
                                          ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red[400]!
                                                  .withOpacity(0.2),
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.close, size: 18),
                                              color: Colors.red[400],
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                showDeleteDialog(context,
                                                    () async {
                                                  files.removeAt(index);
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 28,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue[600]!
                                                  .withOpacity(0.2),
                                            ),
                                            child: IconButton(
                                              icon: Icon(AntDesign.eyeo,
                                                  size: 18),
                                              color: Colors.blue[600],
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("Edit"),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.6,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                          child: ListView(
                                                              children: [
                                                                Container(
                                                                  width:
                                                                      size.height /
                                                                          8,
                                                                  height:
                                                                      size.height /
                                                                          8,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image: FileImage(
                                                                          files[
                                                                              index]),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                    'Children'),
                                                                SizedBox(
                                                                    height: 3),
                                                                MultiSelectDialogField(
                                                                  items: _allChildrens
                                                                      .map((e) =>
                                                                          MultiSelectItem(
                                                                              e,
                                                                              e.name))
                                                                      .toList(),
                                                                  initialValue:
                                                                      _editChildren[
                                                                          index],
                                                                  listType:
                                                                      MultiSelectListType
                                                                          .CHIP,
                                                                  onConfirm:
                                                                      (values) {
                                                                    _editChildren[
                                                                            index] =
                                                                        values;
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                    'Educators'),
                                                                SizedBox(
                                                                    height: 3),
                                                                MultiSelectDialogField(
                                                                  items: _allEductarors
                                                                      .map((e) =>
                                                                          MultiSelectItem(
                                                                              e,
                                                                              e.name))
                                                                      .toList(),
                                                                  initialValue:
                                                                      _editEducators[
                                                                          index],
                                                                  listType:
                                                                      MultiSelectListType
                                                                          .CHIP,
                                                                  onConfirm:
                                                                      (values) {
                                                                    _editEducators[
                                                                            index] =
                                                                        values;
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    height: 8),
                                                                Text('Caption'),
                                                                SizedBox(
                                                                    height: 3),
                                                                Container(
                                                                  height: 30,
                                                                  child:
                                                                      TextField(
                                                                    maxLines: 1,
                                                                    controller:
                                                                        captions[
                                                                            index],
                                                                    decoration:
                                                                        InputDecoration(
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.black26,
                                                                            width: 0.0),
                                                                      ),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                          Radius.circular(
                                                                              4),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ]),
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('OK'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                var _toSend =
                                    Constants.BASE_URL + 'Media/uploadFiles/';
                                Map<String, dynamic> postData = {};
                                for (int i = 0; i < files.length; i++) {
                                  List childTags = [];
                                  List eduTags = [];
                                  for (int j = 0;
                                      j < _editChildren[i].length;
                                      j++) {
                                    childTags.add(_editChildren[i][j].id);
                                  }
                                  for (int k = 0;
                                      k < _editEducators[i].length;
                                      k++) {
                                    eduTags.add(_editEducators[i][k].id);
                                  }
                                  postData["childTags" + i.toString()] =
                                      jsonEncode(childTags);
                                  postData["eduTags" + i.toString()] =
                                      jsonEncode(eduTags);
                                  postData['caption' + i.toString()] =
                                      captions[i].text;
                                  postData["media" + i.toString()] =
                                      await MultipartFile.fromFile(
                                          files[i].path,
                                          filename: basename(files[i].path));
                                }
                                postData['userid'] = MyApp.LOGIN_ID_VALUE;
                                postData['centerid'] = centers[currentIndex].id;

                                FormData formData = FormData.fromMap(postData);
                                Dio dio = new Dio();
                                Response? response = await dio
                                    .post(_toSend,
                                        data: formData,
                                        options: Options(headers: {
                                          'X-DEVICE-ID':
                                              await MyApp.getDeviceIdentity(),
                                          'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                        }))
                                    .then((value) {
                                  var v = jsonDecode(value.toString());
                                  if (v['Status'] == 'SUCCESS') {
                                    files = [];
                                    menuMedia = [];
                                    _allChildrens = [];
                                    _editEducators = [];
                                    _editChildren = [];
                                    captions = [];
                                    _fetchData();
                                  } else {
                                    MyApp.ShowToast("error", context);
                                  }
                                }).catchError((error) => print(error));
                              },
                              child: Text("Upload"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (menuMedia != null && menuMedia.length > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Recent :"),
                  ),
                if (menuMedia != null && menuMedia.length > 0)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemCount: menuMedia.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: menuMedia[index].type.toString() ==
                                              'Image'
                                          ? Image.network(
                                              Constants.ImageBaseUrl +
                                                  menuMedia[index].filename,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                      color: Colors.grey[200]),
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: Icon(
                                                    Icons.play_circle_filled,
                                                    size: 40,
                                                    color: Colors.white),
                                              ),
                                            ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text("Delete Media"),
                                              content: Text(
                                                  "Are you sure you want to delete this media?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    MediaAPIHandler handler =
                                                        MediaAPIHandler({
                                                      "mediaid":
                                                          menuMedia[index].id,
                                                      "userid":
                                                          MyApp.LOGIN_ID_VALUE
                                                    });
                                                    await handler
                                                        .deleteMedia()
                                                        .then((value) {
                                                      if (value['Status'] ==
                                                          'SUCCESS') {
                                                        _fetchData();
                                                      }
                                                    });
                                                  },
                                                  child: Text("Delete",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.close,
                                              size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 30,
                                      child: GestureDetector(
                                        onTap: () {
                                          MediaAPIHandler handler =
                                              MediaAPIHandler({
                                            "mediaid": menuMedia[index].id,
                                            "userid": MyApp.LOGIN_ID_VALUE
                                          });
                                          handler.getMediaTags().then((value) {
                                            if (value['Status'] == 'SUCCESS') {
                                              TextEditingController caption =
                                                  TextEditingController(
                                                      text: value['Media']
                                                          ['caption']);
                                              List<ChildModel> editChild = [];
                                              List<StaffModel> editEducator =
                                                  [];
                                              String mediaId =
                                                  value['Media']['id'];

                                              for (int i = 0;
                                                  i < value['ChildTags'].length;
                                                  i++) {
                                                var childID = value['ChildTags']
                                                    [i]['userid'];
                                                for (int j = 0;
                                                    j < _allChildrens.length;
                                                    j++) {
                                                  if (_allChildrens[j].id ==
                                                      childID) {
                                                    editChild
                                                        .add(_allChildrens[j]);
                                                  }
                                                }
                                              }
                                              for (int i = 0;
                                                  i < value['StaffTags'].length;
                                                  i++) {
                                                var userID = value['StaffTags']
                                                    [i]['userid'];
                                                for (int j = 0;
                                                    j < _allEductarors.length;
                                                    j++) {
                                                  if (_allEductarors[j].id ==
                                                      userID) {
                                                    editEducator
                                                        .add(_allEductarors[j]);
                                                  }
                                                }
                                              }

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Edit"),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.6,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                        child: ListView(
                                                          children: [
                                                            Container(
                                                              width:
                                                                  size.height /
                                                                      8,
                                                              height:
                                                                  size.height /
                                                                      8,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(Constants
                                                                          .ImageBaseUrl +
                                                                      menuMedia[
                                                                              index]
                                                                          .filename),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 8),
                                                            Text('Children'),
                                                            SizedBox(height: 3),
                                                            MultiSelectDialogField(
                                                              items: _allChildrens
                                                                  .map((e) =>
                                                                      MultiSelectItem(
                                                                          e,
                                                                          e.name))
                                                                  .toList(),
                                                              initialValue:
                                                                  editChild,
                                                              listType:
                                                                  MultiSelectListType
                                                                      .CHIP,
                                                              onConfirm:
                                                                  (values) {
                                                                editChild =
                                                                    values;
                                                              },
                                                            ),
                                                            SizedBox(height: 8),
                                                            Text('Educators'),
                                                            SizedBox(height: 3),
                                                            MultiSelectDialogField(
                                                              items: _allEductarors
                                                                  .map((e) =>
                                                                      MultiSelectItem(
                                                                          e,
                                                                          e.name))
                                                                  .toList(),
                                                              initialValue:
                                                                  editEducator,
                                                              listType:
                                                                  MultiSelectListType
                                                                      .CHIP,
                                                              onConfirm:
                                                                  (values) {
                                                                editEducator =
                                                                    values;
                                                              },
                                                            ),
                                                            SizedBox(height: 8),
                                                            Text('Caption'),
                                                            SizedBox(height: 3),
                                                            Container(
                                                              height: 30,
                                                              child: TextField(
                                                                maxLines: 1,
                                                                controller:
                                                                    caption,
                                                                decoration:
                                                                    InputDecoration(
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black26,
                                                                        width:
                                                                            0.0),
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(4)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () async {
                                                          var _toSend =
                                                              'https://stage.todquest.com/mykronicle101/api/Media/saveImageTags/';
                                                          List tags = [];
                                                          for (int i = 0;
                                                              i <
                                                                  editChild
                                                                      .length;
                                                              i++) {
                                                            tags.add({
                                                              "usertype":
                                                                  "child",
                                                              "mediaid":
                                                                  menuMedia[
                                                                          index]
                                                                      .id,
                                                              "userid":
                                                                  editChild[i]
                                                                      .id
                                                            });
                                                          }
                                                          for (int i = 0;
                                                              i <
                                                                  editEducator
                                                                      .length;
                                                              i++) {
                                                            tags.add({
                                                              "usertype":
                                                                  "staff",
                                                              "mediaid":
                                                                  menuMedia[
                                                                          index]
                                                                      .id,
                                                              "userid":
                                                                  editEducator[
                                                                          i]
                                                                      .id,
                                                            });
                                                          }
                                                          var _objToSend = {
                                                            "mediaId":
                                                                menuMedia[index]
                                                                    .id,
                                                            "imgCaption":
                                                                caption.text
                                                                    .toString(),
                                                            "userid": MyApp
                                                                .LOGIN_ID_VALUE,
                                                            "tags": tags,
                                                          };
                                                          var resp =
                                                              await http.post(
                                                            Uri.parse(_toSend),
                                                            body: jsonEncode(
                                                                _objToSend),
                                                            headers: {
                                                              'X-DEVICE-ID':
                                                                  await MyApp
                                                                      .getDeviceIdentity(),
                                                              'X-TOKEN': MyApp
                                                                  .AUTH_TOKEN_VALUE,
                                                            },
                                                          );
                                                          var data = jsonDecode(
                                                              resp.body);
                                                          if (data['Status'] ==
                                                              'SUCCESS') {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: Text('ok'),
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              MyApp.ShowToast(
                                                  value['Status'], context);
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.edit,
                                              size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (menuMediaWeek != null && menuMediaWeek.length > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("This Week :"),
                  ),
                if (menuMediaWeek != null && menuMediaWeek.length > 0)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemCount: menuMediaWeek.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: menuMediaWeek[index]
                                                  .type
                                                  .toString() ==
                                              'Image'
                                          ? Image.network(
                                              Constants.ImageBaseUrl +
                                                  menuMediaWeek[index].filename,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                      color: Colors.grey[200]),
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: Icon(
                                                    Icons.play_circle_filled,
                                                    size: 40,
                                                    color: Colors.white),
                                              ),
                                            ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text("Delete Media"),
                                              content: Text(
                                                  "Are you sure you want to delete this media?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    MediaAPIHandler handler =
                                                        MediaAPIHandler({
                                                      "mediaid":
                                                          menuMediaWeek[index]
                                                              .id,
                                                      "userid":
                                                          MyApp.LOGIN_ID_VALUE
                                                    });
                                                    await handler
                                                        .deleteMedia()
                                                        .then((value) {
                                                      if (value['Status'] ==
                                                          'SUCCESS') {
                                                        _fetchData();
                                                      }
                                                    });
                                                  },
                                                  child: Text("Delete",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.close,
                                              size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 30,
                                      child: GestureDetector(
                                        onTap: () {
                                          MediaAPIHandler handler =
                                              MediaAPIHandler({
                                            "mediaid": menuMediaWeek[index].id,
                                            "userid": MyApp.LOGIN_ID_VALUE
                                          });
                                          handler.getMediaTags().then((value) {
                                            if (value['Status'] == 'SUCCESS') {
                                              TextEditingController caption =
                                                  TextEditingController(
                                                      text: value['Media']
                                                          ['caption']);
                                              List<ChildModel> editChild = [];
                                              List<StaffModel> editEducator =
                                                  [];
                                              String mediaId =
                                                  value['Media']['id'];

                                              for (int i = 0;
                                                  i < value['ChildTags'].length;
                                                  i++) {
                                                var childID = value['ChildTags']
                                                    [i]['userid'];
                                                for (int j = 0;
                                                    j < _allChildrens.length;
                                                    j++) {
                                                  if (_allChildrens[j].id ==
                                                      childID) {
                                                    editChild
                                                        .add(_allChildrens[j]);
                                                  }
                                                }
                                              }
                                              for (int i = 0;
                                                  i < value['StaffTags'].length;
                                                  i++) {
                                                var userID = value['StaffTags']
                                                    [i]['userid'];
                                                for (int j = 0;
                                                    j < _allEductarors.length;
                                                    j++) {
                                                  if (_allEductarors[j].id ==
                                                      userID) {
                                                    editEducator
                                                        .add(_allEductarors[j]);
                                                  }
                                                }
                                              }

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Edit"),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.6,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                        child: ListView(
                                                          children: [
                                                            Container(
                                                              width:
                                                                  size.height /
                                                                      8,
                                                              height:
                                                                  size.height /
                                                                      8,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(Constants
                                                                          .ImageBaseUrl +
                                                                      menuMediaWeek[
                                                                              index]
                                                                          .filename),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 8),
                                                            Text('Children'),
                                                            SizedBox(height: 3),
                                                            MultiSelectDialogField(
                                                              items: _allChildrens
                                                                  .map((e) =>
                                                                      MultiSelectItem(
                                                                          e,
                                                                          e.name))
                                                                  .toList(),
                                                              initialValue:
                                                                  editChild,
                                                              listType:
                                                                  MultiSelectListType
                                                                      .CHIP,
                                                              onConfirm:
                                                                  (values) {
                                                                editChild =
                                                                    values;
                                                              },
                                                            ),
                                                            SizedBox(height: 8),
                                                            Text('Educators'),
                                                            SizedBox(height: 3),
                                                            MultiSelectDialogField(
                                                              items: _allEductarors
                                                                  .map((e) =>
                                                                      MultiSelectItem(
                                                                          e,
                                                                          e.name))
                                                                  .toList(),
                                                              initialValue:
                                                                  editEducator,
                                                              listType:
                                                                  MultiSelectListType
                                                                      .CHIP,
                                                              onConfirm:
                                                                  (values) {
                                                                editEducator =
                                                                    values;
                                                              },
                                                            ),
                                                            SizedBox(height: 8),
                                                            Text('Caption'),
                                                            SizedBox(height: 3),
                                                            Container(
                                                              height: 30,
                                                              child: TextField(
                                                                maxLines: 1,
                                                                controller:
                                                                    caption,
                                                                decoration:
                                                                    InputDecoration(
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black26,
                                                                        width:
                                                                            0.0),
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(4)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () async {
                                                          var _toSend =
                                                              'https://stage.todquest.com/mykronicle101/api/Media/saveImageTags/';
                                                          List tags = [];
                                                          for (int i = 0;
                                                              i <
                                                                  editChild
                                                                      .length;
                                                              i++) {
                                                            tags.add({
                                                              "usertype":
                                                                  "child",
                                                              "mediaid":
                                                                  menuMediaWeek[
                                                                          index]
                                                                      .id,
                                                              "userid":
                                                                  editChild[i]
                                                                      .id
                                                            });
                                                          }
                                                          for (int i = 0;
                                                              i <
                                                                  editEducator
                                                                      .length;
                                                              i++) {
                                                            tags.add({
                                                              "usertype":
                                                                  "staff",
                                                              "mediaid":
                                                                  menuMediaWeek[
                                                                          index]
                                                                      .id,
                                                              "userid":
                                                                  editEducator[
                                                                          i]
                                                                      .id,
                                                            });
                                                          }
                                                          var _objToSend = {
                                                            "mediaId":
                                                                menuMediaWeek[
                                                                        index]
                                                                    .id,
                                                            "imgCaption":
                                                                caption.text
                                                                    .toString(),
                                                            "userid": MyApp
                                                                .LOGIN_ID_VALUE,
                                                            "tags": tags,
                                                          };
                                                          var resp =
                                                              await http.post(
                                                            Uri.parse(_toSend),
                                                            body: jsonEncode(
                                                                _objToSend),
                                                            headers: {
                                                              'X-DEVICE-ID':
                                                                  await MyApp
                                                                      .getDeviceIdentity(),
                                                              'X-TOKEN': MyApp
                                                                  .AUTH_TOKEN_VALUE,
                                                            },
                                                          );
                                                          var data = jsonDecode(
                                                              resp.body);
                                                          if (data['Status'] ==
                                                              'SUCCESS') {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: Text('ok'),
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              MyApp.ShowToast(
                                                  value['Status'], context);
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.edit,
                                              size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                // Earlier section (directly pasteable)
if (menuMediaEarlier != null && menuMediaEarlier.length > 0)
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text("Earlier :"),
  ),
if (menuMediaEarlier != null && menuMediaEarlier.length > 0)
  Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.all(8),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: menuMediaEarlier.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: menuMediaEarlier[index].type.toString() ==
                              'Image'
                          ? Image.network(
                              Constants.ImageBaseUrl +
                                  menuMediaEarlier[index].filename,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error,
                                      stackTrace) =>
                                  Container(
                                      color: Colors.grey[200]),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                    Icons.play_circle_filled,
                                    size: 40,
                                    color: Colors.white),
                              ),
                            ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Delete Media"),
                              content: Text(
                                  "Are you sure you want to delete this media?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    MediaAPIHandler handler =
                                        MediaAPIHandler({
                                      "mediaid":
                                          menuMediaEarlier[index].id,
                                      "userid":
                                          MyApp.LOGIN_ID_VALUE
                                    });
                                    await handler
                                        .deleteMedia()
                                        .then((value) {
                                      if (value['Status'] ==
                                          'SUCCESS') {
                                        _fetchData();
                                      }
                                    });
                                  },
                                  child: Text("Delete",
                                      style: TextStyle(
                                          color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 30,
                      child: GestureDetector(
                        onTap: () {
                          MediaAPIHandler handler =
                              MediaAPIHandler({
                            "mediaid": menuMediaEarlier[index].id,
                            "userid": MyApp.LOGIN_ID_VALUE
                          });
                          handler.getMediaTags().then((value) {
                            if (value['Status'] == 'SUCCESS') {
                              TextEditingController caption =
                                  TextEditingController(
                                      text: value['Media']
                                          ['caption']);
                              List<ChildModel> editChild = [];
                              List<StaffModel> editEducator =
                                  [];
                              String mediaId =
                                  value['Media']['id'];

                              for (int i = 0;
                                  i < value['ChildTags'].length;
                                  i++) {
                                var childID = value['ChildTags']
                                    [i]['userid'];
                                for (int j = 0;
                                    j < _allChildrens.length;
                                    j++) {
                                  if (_allChildrens[j].id ==
                                      childID) {
                                    editChild
                                        .add(_allChildrens[j]);
                                  }
                                }
                              }
                              for (int i = 0;
                                  i < value['StaffTags'].length;
                                  i++) {
                                var userID = value['StaffTags']
                                    [i]['userid'];
                                for (int j = 0;
                                    j < _allEductarors.length;
                                    j++) {
                                  if (_allEductarors[j].id ==
                                      userID) {
                                    editEducator
                                        .add(_allEductarors[j]);
                                  }
                                }
                              }

                              showDialog(
                                context: context,
                                builder:
                                    (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Edit"),
                                    content:
                                        SingleChildScrollView(
                                      child: Container(
                                        height: MediaQuery.of(
                                                    context)
                                                .size
                                                .height *
                                            0.6,
                                        width: MediaQuery.of(
                                                    context)
                                                .size
                                                .width *
                                            0.7,
                                        child: ListView(
                                          children: [
                                            Container(
                                              width:
                                                  size.height /
                                                      8,
                                              height:
                                                  size.height /
                                                      8,
                                              decoration:
                                                  BoxDecoration(
                                                shape: BoxShape
                                                    .rectangle,
                                                image:
                                                    DecorationImage(
                                                  image: NetworkImage(Constants
                                                          .ImageBaseUrl +
                                                      menuMediaEarlier[
                                                              index]
                                                          .filename),
                                                  fit: BoxFit
                                                      .cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text('Children'),
                                            SizedBox(height: 3),
                                            MultiSelectDialogField(
                                              items: _allChildrens
                                                  .map((e) =>
                                                      MultiSelectItem(
                                                          e,
                                                          e.name))
                                                  .toList(),
                                              initialValue:
                                                  editChild,
                                              listType:
                                                  MultiSelectListType
                                                      .CHIP,
                                              onConfirm:
                                                  (values) {
                                                editChild =
                                                    values;
                                              },
                                            ),
                                            SizedBox(height: 8),
                                            Text('Educators'),
                                            SizedBox(height: 3),
                                            MultiSelectDialogField(
                                              items: _allEductarors
                                                  .map((e) =>
                                                      MultiSelectItem(
                                                          e,
                                                          e.name))
                                                  .toList(),
                                              initialValue:
                                                  editEducator,
                                              listType:
                                                  MultiSelectListType
                                                      .CHIP,
                                              onConfirm:
                                                  (values) {
                                                editEducator =
                                                    values;
                                              },
                                            ),
                                            SizedBox(height: 8),
                                            Text('Caption'),
                                            SizedBox(height: 3),
                                            Container(
                                              height: 30,
                                              child: TextField(
                                                maxLines: 1,
                                                controller:
                                                    caption,
                                                decoration:
                                                    InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .black26,
                                                        width:
                                                            0.0),
                                                  ),
                                                  border:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(Radius.circular(4)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          var _toSend =
                                              'https://stage.todquest.com/mykronicle101/api/Media/saveImageTags/';
                                          List tags = [];
                                          for (int i = 0;
                                              i <
                                                  editChild
                                                      .length;
                                              i++) {
                                            tags.add({
                                              "usertype":
                                                  "child",
                                              "mediaid":
                                                  menuMediaEarlier[
                                                          index]
                                                      .id,
                                              "userid":
                                                  editChild[i]
                                                      .id
                                            });
                                          }
                                          for (int i = 0;
                                              i <
                                                  editEducator
                                                      .length;
                                              i++) {
                                            tags.add({
                                              "usertype":
                                                  "staff",
                                              "mediaid":
                                                  menuMediaEarlier[
                                                          index]
                                                      .id,
                                              "userid":
                                                  editEducator[
                                                          i]
                                                      .id,
                                            });
                                          }
                                          var _objToSend = {
                                            "mediaId":
                                                menuMediaEarlier[
                                                        index]
                                                    .id,
                                            "imgCaption":
                                                caption.text
                                                    .toString(),
                                            "userid": MyApp
                                                .LOGIN_ID_VALUE,
                                            "tags": tags,
                                          };
                                          var resp =
                                              await http.post(
                                            Uri.parse(_toSend),
                                            body: jsonEncode(
                                                _objToSend),
                                            headers: {
                                              'X-DEVICE-ID':
                                                  await MyApp
                                                      .getDeviceIdentity(),
                                              'X-TOKEN': MyApp
                                                  .AUTH_TOKEN_VALUE,
                                            },
                                          );
                                          var data = jsonDecode(
                                              resp.body);
                                          if (data['Status'] ==
                                              'SUCCESS') {
                                            Navigator.pop(
                                                context);
                                          }
                                        },
                                        child: Text('ok'),
                                      )
                                    ],
                                  );
                                },
                              );
                            } else {
                              MyApp.ShowToast(
                                  value['Status'], context);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  ),   ],
            ),
          ),
        ),
      ),
    );
  }

  Future<File> compressAndGetFile(File file, String targetPath) async {
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 900,
      minHeight: 900,
      quality: 40,
    );

    print(file.lengthSync());
    print(result?.length());

    if (result != null) {
      return File(result.path);
    } else {
      throw Exception("Image compression failed");
    }
  }
}
