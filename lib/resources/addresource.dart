import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:html_editor/html_editor.dart';
import 'package:mime/mime.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/cropImage.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:path/path.dart';

class Addresource extends StatefulWidget {
  @override
  _AddresourceState createState() => _AddresourceState();
}

class _AddresourceState extends State<Addresource> {
  List<File> files = [];
  TextEditingController title;
  String titleErr = '';
  GlobalKey<HtmlEditorState> keyEditor;

  List<Map<String, dynamic>> mentionUser;
  List<Map<String, dynamic>> mentionMont;
  bool mChildFetched = false;
  bool mMontFetched = false;
  GlobalKey<FlutterMentionsState> desc = GlobalKey<FlutterMentionsState>();

  @override
  void initState() {
    super.initState();
    _load();
    title = new TextEditingController();
    keyEditor = new GlobalKey();
  }

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  void _load() async {
    ObservationsAPIHandler handler =
        ObservationsAPIHandler({"userid": MyApp.LOGIN_ID_VALUE});

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
        if (mChild['type'] == 'Staff') {
          mentionUser.add(mChild);
        }
      }
      mChildFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

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
                      Text(
                        'Resources',
                        style: Constants.header1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Add Post',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Title'),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 40,
                        child: TextField(
                            controller: title,
                            decoration: new InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black26, width: 0.0),
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(4),
                                ),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        titleErr,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Description'),
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
                              key: desc,
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
                      SizedBox(
                        height: 10,
                      ),
                      Text('Media'),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          InkWell(
                              onTap: () async {
                                FilePickerResult result =
                                    await FilePicker.platform.pickFiles();

                                if (result != null) {
                                  File file = File(result.files.single.path);
                                  var fileSizeInBytes = file.length();
                                  var fileSizeInKB =
                                      await fileSizeInBytes / 1024;
                                  var fileSizeInMB = fileSizeInKB / 1024;

                                  String mimeStr =
                                      lookupMimeType(result.files.single.path);
                                  var fileType = mimeStr.split('/');

                                  if (fileSizeInMB > 2 &&
                                      fileType[0].toString() == 'image') {
                                    MyApp.ShowToast(
                                        'file size greater than 2 mb so image is being compressed',
                                        context);

                                    final filePath = file.absolute.path;
                                    final lastIndex = filePath
                                        .lastIndexOf(new RegExp(r'.jp'));
                                    final splitted =
                                        filePath.substring(0, (lastIndex));
                                    final outPath =
                                        "${splitted}_out${filePath.substring(lastIndex)}";

                                    File cFile =
                                        await compressAndGetFile(file, outPath);
                                    File fImage =
                                        await cropImage(context, cFile);
                                    if (fImage != null) {
                                      files.add(fImage);
                                      setState(() {});
                                    }
                                  } else {
                                    File fImage =
                                        await cropImage(context, file);
                                    if (fImage != null) {
                                      files.add(fImage);
                                      setState(() {});
                                    }
                                  }
                                } else {
                                  // User canceled the picker
                                }
                              },
                              child: rectBorderWidget(size, context)),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      files.length > 0
                          ? Wrap(
                              spacing: 8.0, // gap between adjacent chips
                              runSpacing: 4.0, //

                              children: List<Widget>.generate(files.length,
                                  (int index) {
                                String mimeStr =
                                    lookupMimeType(files[index].path);
                                var fileType = mimeStr.split('/');
                                print('dddt' + fileType.toString());
                                //dddt[image, jpeg]
                                if (fileType[0].toString() == 'image') {
                                  return Stack(
                                    children: [
                                      Container(
                                          width: size.width / 3,
                                          height: size.width / 3,
                                          decoration: new BoxDecoration(
                                            //  borderRadius: BorderRadius.circular(15.0),
                                            shape: BoxShape.rectangle,
                                            image: new DecorationImage(
                                              image:
                                                  new FileImage(files[index]),
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
                                                files.removeAt(index);
                                                setState(() {});
                                                Navigator.pop(context);
                                              });
                                            },
                                          ))
                                    ],
                                  );
                                } else {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: size.width / 3,
                                        height: size.width / 3,
                                        child: Card(
                                            child:
                                                Icon(Icons.video_collection)),
                                      ),
                                      Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              showDeleteDialog(context, () {
                                                files.removeAt(index);
                                                setState(() {});
                                                Navigator.pop(context);
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
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: <
                          Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              width: 82,
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
                            String description =
                                desc.currentState.controller.markupText;

                            for (int i = 0; i < mentionUser.length; i++) {
                              if (description
                                  .contains(mentionUser[i]['name'])) {
                                description = description.replaceAll(
                                    "@" + mentionUser[i]['name'],
                                    '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                              }
                            }
                            for (int i = 0; i < mentionMont.length; i++) {
                              if (description
                                  .contains(mentionMont[i]['display'])) {
                                description = description.replaceAll(
                                    "#" + mentionMont[i]['display'],
                                    '<a data-tagid="${mentionMont[i]['rid']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="tags_${mentionMont[i]['id']}" link="tags_${mentionMont[i]['id']}"  >#${mentionMont[i]['display']}</a>');
                              }
                            }
                            print(description);

                            if (title.text.toString() == '') {
                              titleErr = 'title required';
                            } else {
                              titleErr = '';
                            }

                            setState(() {});
                            if (title.text.toString() != '') {
                              titleErr = '';
                              setState(() {});
                              Map<String, dynamic> mp;

                              mp = {
                                "title": title.text,
                                "description": description,
                                "userid": MyApp.LOGIN_ID_VALUE,
                                "createdAt": DateTime.now(),
                                "createdBy": MyApp.LOGIN_ID_VALUE,
                              };

                              for (int i = 0; i < files.length; i++) {
                                File file = files[i];
                                String m = 'resMedia' + i.toString();
                                var d = await MultipartFile.fromFile(file.path,
                                    filename: basename(file.path),
                                    contentType: MediaType.parse('image/jpg'));
                                // print('ddd' + d.toString());
                                // String mimeStr = lookupMimeType(files[i].path);
                                // var fileType = mimeStr.split('/');
                                // mp[m] = {
                                //   "mime": fileType[0] + '/' + fileType[1],
                                //   "postname": basename(file.path),
                                //   "name": d,
                                // };
                                mp[m] = d;
                              }

                              FormData formData = FormData.fromMap(mp);

                              print(formData.fields.toString());
                              Dio dio = new Dio();

                              Response response = await dio
                                  .post(
                                      Constants.BASE_URL +
                                          "resources/addResources/",
                                      data: formData,
                                      options: Options(headers: {
                                        'X-DEVICE-ID':
                                            await MyApp.getDeviceIdentity(),
                                        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                      }))
                                  .then((value) {
                                var v = jsonDecode(value.toString());
                                if (v['Status'] == 'SUCCESS') {
                                  Navigator.pop(context, 'kill');
                                } else {
                                  print(v);
                                  MyApp.ShowToast("error", context);
                                }
                              }).catchError((error) => print(error));
                            }
                          },
                          child: Container(
                              // width: 82,
                              // height: 38,
                              decoration: BoxDecoration(
                                  color: Constants.kButton,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'ADD POST',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ])
                    ])))));
  }

  Future<File> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        minWidth: 900, minHeight: 900, quality: 40);

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Widget rectBorderWidget(Size size, var context) {
    return DottedBorder(
      dashPattern: [8, 4],
      strokeWidth: 2,
      child: Container(
        width: size.width / 3,
        height: size.width / 3,
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
