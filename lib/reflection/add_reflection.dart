import 'dart:convert';
import 'dart:io';

import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:mime/mime.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/observation/childdetails.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/cropImage.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:path/path.dart';

class AddReflection extends StatefulWidget {
  // final String type;
  // final ObservationModel data;
  // final List<ChildSubModel> selecChildrens;
  // final Map totaldata;
  // final List media;
  final String centerid;
  AddReflection(
      {
      //   this.type,
      // this.data,
      // this.selecChildrens,
      // this.media,
      // this.totaldata,
      required this.centerid});
  @override
  _AddReflectionState createState() => _AddReflectionState();
}

class _AddReflectionState extends State<AddReflection> {
   List<File> files = [];

  // Initialize the controller
  TextEditingController title = TextEditingController();
  String titleErr = '';

  // Initialize GlobalKey
  // GlobalKey<HtmlEditorState> keyEditor = GlobalKey<HtmlEditorState>();
    GlobalKey<State<StatefulWidget>> keyEditor = GlobalKey();
  HtmlEditorController editorController = HtmlEditorController();

  List<Map<String, dynamic>> mentionUser = [];
  List<Map<String, dynamic>> mentionMont = [];
  bool mChildFetched = false;
  bool mMontFetched = false;
  
  GlobalKey<FlutterMentionsState> ref = GlobalKey<FlutterMentionsState>();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  // Select child
  List<ChildModel> _allChildrens = [];  // ✅ Initialized as empty list
  List<ChildModel> selectedChildrens = [];
  Map<String, bool> childValues = {};
  bool childrensFetched = false;

  // Select Educator
  List<UserModel> users=[];
  List<UserModel> selectedEdu = [];
  Map<String, bool> eduValues = {};
  bool usersFetched = false;
  bool all = false;

  List<CentersModel> centers=[];
  bool centersFetched = false;
  int currentIndex = 0;

  String endmenu = '';
  String status = 'DRAFT';

  @override
  void initState() {
    super.initState();
    _fetchData1();
    _fetchData();
    _load();

    title = new TextEditingController();
    keyEditor = new GlobalKey();
  }

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    RoomAPIHandler handler =
        RoomAPIHandler({"userid": MyApp.LOGIN_ID_VALUE, "id": ''});
    var data = await handler.getRoomDetails();
    if (!data.containsKey('error')) {
      var r = data['users'];
      users = [];
      try {
        assert(r is List);
        //  UserModel u = UserModel(userid: '0', name: 'select');
        //  users.insert(0, u);
        for (int i = 0; i < r.length; i++) {
          users.add(UserModel.fromJson(r[i]));
          eduValues[users[i].userid] = false;
        }
        usersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      // MyApp.Show401Dialog(context);
    }
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

  Future<void> _fetchData1() async {
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
        childValues[_allChildrens[i].childid??''] = false;
      }
      childrensFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }
    setState(() {});
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
          shrinkWrap: true,
          itemCount: users != null ? users.length : 0,
          itemBuilder: (BuildContext context, int index) {
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
          })
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
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        child: searchString == ''
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _allChildrens != null ? _allChildrens.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
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
                        value: childValues[_allChildrens[index].childid],
                        onChanged: (value) {
                          print(_allChildrens[index].childid);
                          if (value == true) {
                            if (!selectedChildrens
                                .contains(_allChildrens[index])) {
                              selectedChildrens.add(_allChildrens[index]);
                              print(_allChildrens[index].childid);
                            }
                          } else {
                            if (selectedChildrens
                                .contains(_allChildrens[index])) {
                              selectedChildrens.remove(_allChildrens[index]);
                            }
                          }

                          childValues[_allChildrens[index].childid??""] = value!;
                          setState(() {});
                        }),
                  );
                })
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _allChildrens != null ? _allChildrens.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return _allChildrens[index]
                          .name
                          .toLowerCase()
                          .contains(searchString.toLowerCase())
                      ? ListTile(
                          title: Text(_allChildrens[index].name),
                          trailing: Checkbox(
                              value: childValues[_allChildrens[index].id],
                              onChanged: (value) {
                                if (value == true) {
                                  if (!selectedChildrens
                                      .contains(_allChildrens[index])) {
                                    selectedChildrens.add(_allChildrens[index]);
                                  }
                                } else {
                                  if (selectedChildrens
                                      .contains(_allChildrens[index])) {
                                    selectedChildrens
                                        .remove(_allChildrens[index]);
                                  }
                                }

                                childValues[_allChildrens[index].id] = value!;

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        key: key,
        endDrawer: endmenu == 'Children'
            ? getStartDrawer(context)
            : getEndDrawer(context),
        // drawer: getStartDrawer(context),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                        'Reflections',
                        style: Constants.header1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (centersFetched)
                        DropdownButtonHideUnderline(
                          child: Container(
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
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

                                          _load();
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
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text('Children'),
                      ),
                      GestureDetector(
                        onTap: () {
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
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
                              children: List<Widget>.generate(
                                  selectedChildrens.length, (int index) {
                                return selectedChildrens[index].childid != null
                                    ? Chip(
                                        label:
                                            Text(selectedChildrens[index].name),
                                        onDeleted: () {
                                          setState(() {
                                            childValues[selectedChildrens[index]
                                                .childid??''] = false;
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
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
                              children: List<Widget>.generate(
                                  selectedEdu.length, (int index) {
                                return selectedEdu[index].userid != null
                                    ? Chip(
                                        label: Text(selectedEdu[index].name),
                                        onDeleted: () {
                                          setState(() {
                                            eduValues[selectedEdu[index]
                                                .userid] = false;
                                            selectedEdu.removeAt(index);
                                          });
                                        })
                                    : Container();
                              }))
                          : Container(),
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
                      Text('Reflection'),
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
                              key: ref,
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
                      GestureDetector(
                          onTap: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();

                            if (result != null) {
                              File file = File(result?.files.single.path??'');
                              var fileSizeInBytes = file.length();
                              var fileSizeInKB = await fileSizeInBytes / 1024;
                              var fileSizeInMB = fileSizeInKB / 1024;

                              if (fileSizeInMB > 2) {
                                MyApp.ShowToast(
                                    'file size greater than 2 mb so image is being compressed',
                                    context);

                                final filePath = file.absolute.path;
                                final lastIndex =
                                    filePath.lastIndexOf(new RegExp(r'.jp'));
                                final splitted =
                                    filePath.substring(0, (lastIndex));
                                final outPath =
                                    "${splitted}_out${filePath.substring(lastIndex)}";

                                File cFile =
                                    await compressAndGetFile(file, outPath);
                                files.add(cFile);
                                setState(() {});
                              } else {
                                files.add(file);
                                setState(() {});
                              }
                              // h = h + 100.0;
                              // if(files.length==1){
                              //   h=h+size.width/3;
                              // }else if(files.length%2==0){
                              //    h=h+size.width/3;
                              // }
                              setState(() {});
                            } else {
                              // User canceled the picker
                            }
                          },
                          child: rectBorderWidget(size, context)),

                      SizedBox(
                        height: 10,
                      ),
                      files.length > 0
                          ? Wrap(
                              spacing: 8.0, // gap between adjacent chips
                              runSpacing: 4.0, //
                              // direction: Axis.vertical,
                              // alignment: WrapAlignment.center,
                              // spacing:8.0,
                              // runAlignment:WrapAlignment.center,
                              // runSpacing: 8.0,
                              // crossAxisAlignment: WrapCrossAlignment.center,
                              // textDirection: TextDirection.rtl,
                              // verticalDirection: VerticalDirection.up,
                              children: List<Widget>.generate(files.length,
                                  (int index) {
                                String? mimeStr =
                                    lookupMimeType(files[index].path);
                                var fileType = mimeStr?.split('/');
                                if (fileType?[0].toString() == 'image') {
                                  return Stack(
                                    children: [
                                      Container(
                                          width: 100,
                                          height: 100,
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
                                        width: 100,
                                        height: 100,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                print("check");
                                status = 'DRAFT';
                              });
                            },
                            child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: status == 'DRAFT'
                                      ? Colors.green
                                      : Colors.white,
                                  border: Border.all(
                                    color: status == 'DRAFT'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            print("check");
                                            status = 'DRAFT';
                                          });
                                        },
                                        child: Text(
                                          'SAVE AS DRAFT',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                print("check");
                                status = 'PUBLISHED';
                              });
                            },
                            child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: status == 'PUBLISHED'
                                      ? Colors.green
                                      : Colors.white,
                                  border: Border.all(
                                    color: status == 'PUBLISHED'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            print("check");
                                            status = 'PUBLISHED';
                                          });
                                        },
                                        child: Text(
                                          'SAVE AS PUBLISHED',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      ),
                      // media.length > 0
                      //     ? Wrap(
                      //         spacing: 8.0, // gap between adjacent chips
                      //         runSpacing: 4.0, //
                      //         children: List<Widget>.generate(media.length,
                      //             (int index) {
                      //           if (media[index].mediaType == 'Image') {
                      //             return Stack(
                      //               children: [
                      //                 Container(
                      //                     width: 100,
                      //                     height: 100,
                      //                     decoration: new BoxDecoration(
                      //                       //  borderRadius: BorderRadius.circular(15.0),
                      //                       shape: BoxShape.rectangle,
                      //                       image: new DecorationImage(
                      //                         image: new NetworkImage(
                      //                             Constants.ImageBaseUrl +
                      //                                 media[index].mediaUrl),
                      //                         fit: BoxFit.cover,
                      //                       ),
                      //                     )),
                      //                 Positioned(
                      //                     right: 0,
                      //                     top: 0,
                      //                     child: IconButton(
                      //                       icon: Icon(Icons.clear),
                      //                       onPressed: () {
                      //                         showDeleteDialog(context, () {
                      //                           RecipeAPIHandler handler =
                      //                               RecipeAPIHandler({
                      //                             "mediaid": media[index].id
                      //                           });
                      //                           handler
                      //                               .deleteMedia()
                      //                               .then((value) {
                      //                             print(value);
                      //                             media.removeAt(index);
                      //                             setState(() {});
                      //                             Navigator.pop(context);
                      //                           });
                      //                         });
                      //                       },
                      //                     ))
                      //               ],
                      //             );
                      //           } else {
                      //             return Stack(
                      //               children: [
                      //                 Container(
                      //                   width: 100,
                      //                   height: 100,
                      //                   child: Card(
                      //                       child:
                      //                           Icon(Icons.video_collection)),
                      //                 ),
                      //                 Positioned(
                      //                     right: 0,
                      //                     top: 0,
                      //                     child: IconButton(
                      //                       icon: Icon(Icons.clear),
                      //                       onPressed: () {
                      //                         showDeleteDialog(context, () {
                      //                           RecipeAPIHandler handler =
                      //                               RecipeAPIHandler({
                      //                             "mediaid": media[index].id
                      //                           });
                      //                           handler
                      //                               .deleteMedia()
                      //                               .then((value) {
                      //                             var data =
                      //                                 jsonDecode(value.body);
                      //                             if (data['Status'] ==
                      //                                 'SUCCESS') {
                      //                               media.removeAt(index);
                      //                               setState(() {});
                      //                             } else {
                      //                               MyApp.ShowToast(
                      //                                   data['Status'],
                      //                                   context);
                      //                             }
                      //                           });
                      //                           Navigator.pop(context);
                      //                         });
                      //                       },
                      //                     ))
                      //               ],
                      //             );
                      //           }
                      //         }),
                      //       )
                      //     : Container(),
                      // Row(
                      //   children: [
                      //     InkWell(
                      //         onTap: () async {
                      //           FilePickerResult result =
                      //               await FilePicker.platform.pickFiles();

                      //           if (result != null) {
                      //             File file = File(result.files.single.path);
                      //             var fileSizeInBytes = file.length();
                      //             var fileSizeInKB =
                      //                 await fileSizeInBytes / 1024;
                      //             var fileSizeInMB = fileSizeInKB / 1024;

                      //             String mimeStr =
                      //                 lookupMimeType(result.files.single.path);
                      //             var fileType = mimeStr.split('/');

                      //             if (fileSizeInMB > 2 &&
                      //                 fileType[0].toString() == 'image') {
                      //               MyApp.ShowToast(
                      //                   'file size greater than 2 mb so image is being compressed',
                      //                   context);

                      //               final filePath = file.absolute.path;
                      //               final lastIndex = filePath
                      //                   .lastIndexOf(new RegExp(r'.jp'));
                      //               final splitted =
                      //                   filePath.substring(0, (lastIndex));
                      //               final outPath =
                      //                   "${splitted}_out${filePath.substring(lastIndex)}";

                      //               File cFile =
                      //                   await compressAndGetFile(file, outPath);
                      //               File fImage =
                      //                   await cropImage(context, cFile);
                      //               if (fImage != null) {
                      //                 files.add(fImage);
                      //                 setState(() {});
                      //               }
                      //             } else {
                      //               File fImage =
                      //                   await cropImage(context, file);
                      //               if (fImage != null) {
                      //                 files.add(fImage);
                      //                 setState(() {});
                      //               }
                      //             }
                      //           } else {
                      //             // User canceled the picker
                      //           }
                      //         },
                      //         child: rectBorderWidget(size, context)),
                      //     SizedBox(
                      //       width: 20,
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // files.length > 0
                      //     ? Wrap(
                      //         spacing: 8.0, // gap between adjacent chips
                      //         runSpacing: 4.0, //

                      //         children: List<Widget>.generate(files.length,
                      //             (int index) {
                      //           String mimeStr =
                      //               lookupMimeType(files[index].path);
                      //           var fileType = mimeStr.split('/');
                      //           print('dddt' + fileType.toString());
                      //           //dddt[image, jpeg]
                      //           if (fileType[0].toString() == 'image') {
                      //             return Stack(
                      //               children: [
                      //                 Container(
                      //                     width: size.width / 3,
                      //                     height: size.width / 3,
                      //                     decoration: new BoxDecoration(
                      //                       //  borderRadius: BorderRadius.circular(15.0),
                      //                       shape: BoxShape.rectangle,
                      //                       image: new DecorationImage(
                      //                         image:
                      //                             new FileImage(files[index]),
                      //                         fit: BoxFit.cover,
                      //                       ),
                      //                     )),
                      //                 Positioned(
                      //                     right: 0,
                      //                     top: 0,
                      //                     child: IconButton(
                      //                       icon: Icon(Icons.clear),
                      //                       onPressed: () {
                      //                         showDeleteDialog(context, () {
                      //                           files.removeAt(index);
                      //                           setState(() {});
                      //                           Navigator.pop(context);
                      //                         });
                      //                       },
                      //                     ))
                      //               ],
                      //             );
                      //           } else {
                      //             return Stack(
                      //               children: [
                      //                 Container(
                      //                   width: size.width / 3,
                      //                   height: size.width / 3,
                      //                   child: Card(
                      //                       child:
                      //                           Icon(Icons.video_collection)),
                      //                 ),
                      //                 Positioned(
                      //                     right: 0,
                      //                     top: 0,
                      //                     child: IconButton(
                      //                       icon: Icon(Icons.clear),
                      //                       onPressed: () {
                      //                         showDeleteDialog(context, () {
                      //                           files.removeAt(index);
                      //                           setState(() {});
                      //                           Navigator.pop(context);
                      //                         });
                      //                       },
                      //                     ))
                      //               ],
                      //             );
                      //           }
                      //         }),
                      //       )
                      //     : Container(),
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
                            String? refription =
                                ref.currentState?.controller?.markupText;
                             if(refription==null)return;
                            for (int i = 0; i < mentionUser.length; i++) {
                              if (refription!.contains(mentionUser[i]['name'])) {
                                refription = refription.replaceAll(
                                    "@" + mentionUser[i]['name'],
                                    '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                              }
                            }
                            for (int i = 0; i < mentionMont.length; i++) {
                              if (refription
                                  !.contains(mentionMont[i]['display'])) {
                                refription = refription.replaceAll(
                                    "#" + mentionMont[i]['display'],
                                    '<a data-tagid="${mentionMont[i]['rid']}" data-type="${mentionMont[i]['type']}" data-toggle="modal" data-target="#tagsModal" href="tags_${mentionMont[i]['id']}" link="tags_${mentionMont[i]['id']}"  >#${mentionMont[i]['display']}</a>');
                              }
                            }
                            print(refription);

                            if (title.text.toString() == '') {
                              titleErr = 'title required';
                            } else {
                              titleErr = '';
                            }

                            setState(() {});
                            if (title.text.toString() != '') {
                              titleErr = '';
                              setState(() {});
                              List edu = [];
                              for (int i = 0; i < selectedEdu.length; i++) {
                                edu.add(selectedEdu[i].userid.toString());
                              }

                              List child = [];
                              for (int i = 0;
                                  i < selectedChildrens.length;
                                  i++) {
                                child.add(
                                    selectedChildrens[i].childid.toString());
                              }

                              Map<String, dynamic> mp;
                              print(status);

                              mp = {
                                "title": title.text,
                                "about": refription,
                                "userid": MyApp.LOGIN_ID_VALUE,
                                "centerid": widget.centerid,
                                "childs": jsonEncode(child),
                                "educators": jsonEncode(edu),
                                "status": status,
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
                              print(mp);

                              FormData formData = FormData.fromMap(mp);

                              print("object check");
                              print(formData.fields.toString());
                              Dio dio = new Dio();

                              Response? response = await dio
                                  .post(
                                      Constants.BASE_URL +
                                          "Reflections/createReflection/",
                                      data: formData,
                                      options: Options(headers: {
                                        'X-DEVICE-ID':
                                            await MyApp.getDeviceIdentity(),
                                        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                      }))
                                  .then((value) {
                                var v = jsonDecode(value.toString());
                                print("object check");
                                print(v);
                                if (v['Status'] == 'SUCCESS') {
                                  Navigator.pop(context, 'kill');
                                  // Navigator.pop(context);
                                } else {
                                  print(v);
                                  MyApp.ShowToast("error", context);
                                }
                              }).catchError((error) => print(error));
                              print(response);
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
  XFile? result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    minWidth: 900, minHeight: 900, quality: 40,
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
