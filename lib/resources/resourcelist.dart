import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/resourcesapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/authormodel.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';

import 'package:mykronicle_mobile/models/resourcemodelV2.dart';
import 'package:mykronicle_mobile/models/tagsmodel.dart';
import 'package:mykronicle_mobile/resources/addresource.dart';
import 'package:mykronicle_mobile/resources/commentslist.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:mykronicle_mobile/utils/removeTags.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';
import 'package:share_plus/share_plus.dart';

class ResourceList extends StatefulWidget {
  @override
  _ResourceListState createState() => _ResourceListState();
}

class _ResourceListState extends State<ResourceList> {
  // var unescape = new HtmlUnescape();

  GlobalKey<ScaffoldState> key = GlobalKey();
  bool resourcesFetched = false;
  List<ResourceModels> _allResources = [];
  List<TagsModel> _trendTags = [];

  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;

  List<AuthorModel> authors = [];
  bool authorsFetched = false;
  int currentAuthor = 0;

  String fromDate = '';
  String toDate = '';

  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();

  bool centerChoosen = false;
  bool authorChoosen = false;
  String filterError = '';

  int load = 0;

  @override
  void initState() {
    startDate = TextEditingController();
    endDate = TextEditingController();
    super.initState();
    _fetchData();
  }

  bool loading = true;
  Future<void> _fetchData() async {
    if (this.mounted)
      setState(() {
        loading = true;
      });
    Map<String, String> obj = {
      "userid": MyApp.LOGIN_ID_VALUE,
    };
    if (fromDate != '' || centerChoosen || authorChoosen) {
      obj = {
        "fromdate": fromDate,
        "todate": toDate,
        "centerid": centerChoosen ? centers[currentIndex].id : '',
        "author": authorChoosen ? authors[currentAuthor].id : '',
        "userid": MyApp.LOGIN_ID_VALUE,
        "page": "0"
      };
    }
    print('resssisis' + obj.toString());
    ResourceAPIHandler handler = ResourceAPIHandler(obj);
    var data = await handler.getList();

    if (!data.containsKey('error')) {
      var res = data['resources'];
      var res2 = data['trendingTags'];
      print('resssisis' + res2.toString());
      _allResources = [];
      // _trendTags = [];

      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          print(i);
          _allResources.add(ResourceModels.fromJson(res[i]));
        }

        assert(res2 is List);
        if (_trendTags.isEmpty)
          for (int i = 0; i < res2.length; i++) {
            _trendTags.add(TagsModel.fromJson(res2[i]));
          }

        resourcesFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
    if (load == 0) {
      _fetchCenters();
      load = 1;
      loading = false;
      setState(() {});
    } else {
      loading = false;
      setState(() {});
    }
  }

  Future<void> _fetchAuthors() async {
    UtilsAPIHandler hlr = UtilsAPIHandler(
        {"centerid": centers[currentIndex].id, "userid": MyApp.LOGIN_ID_VALUE});
    var dt = await hlr.getAuthors();
    authors = [];
    if (!dt.containsKey('error')) {
      var res = dt['Authors'];

      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          authors.add(AuthorModel.fromJson(res[i]));
        }
        authorsFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
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
        }
        centersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    _fetchAuthors();
  }

  Widget getEndDrawer(BuildContext context) {
    return Drawer(
        child: Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Apply Filters',
                  style: Constants.header2,
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            TextField(
              readOnly: true,
              onTap: () async {
                await _selectDate(context).then((value) {
                  if (value != null) {
                    fromDate = value.toString().substring(0, 10);

                    var inputFormat = DateFormat("yyyy-MM-dd");
                    final DateFormat formati = DateFormat('dd-MM-yyyy');
                    var date1 = inputFormat.parse(fromDate);
                    startDate.text = formati.format(date1);

                    if (this.mounted) setState(() {});
                  }
                });
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'From Date',
                  hintStyle: TextStyle(color: Colors.grey)),
              controller: startDate,
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              readOnly: true,
              onTap: () async {
                await _selectDate(context).then((value) {
                  if (value != null) {
                    toDate = value.toString().substring(0, 10);

                    var inputFormat = DateFormat("yyyy-MM-dd");
                    final DateFormat formati = DateFormat('dd-MM-yyyy');
                    var date1 = inputFormat.parse(toDate);
                    endDate.text = formati.format(date1);

                    if (this.mounted) setState(() {});
                  }
                });
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'To Date',
                  hintStyle: TextStyle(color: Colors.grey)),
              controller: endDate,
            ),
            SizedBox(
              height: 10,
            ),
            Text('Select Center'),
            SizedBox(
              height: 5,
            ),
            centerChoosen
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
                                    authors = [];
                                    authorsFetched = false;
                                    _fetchAuthors();
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
                : TextField(
                    readOnly: true,
                    onTap: () {
                      centerChoosen = true;
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Choose Center',
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
            SizedBox(
              height: 10,
            ),
            Text('Select Author'),
            SizedBox(
              height: 5,
            ),
            authorChoosen
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
                            value: authors[currentAuthor].id,
                            items: authors.map((AuthorModel value) {
                              return new DropdownMenuItem<String>(
                                value: value.id,
                                child: new Text(value.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              for (int i = 0; i < authors.length; i++) {
                                if (authors[i].id == value) {
                                  setState(() {
                                    currentAuthor = i;
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
                : TextField(
                    readOnly: true,
                    onTap: () {
                      authorChoosen = true;
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Choose Author',
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
            SizedBox(
              height: 6,
            ),
            Text(
              filterError,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(
              height: 6,
            ),
            ElevatedButton(
                onPressed: () {
                  if (fromDate == '' && toDate == '') {
                    _fetchData();
                    Navigator.pop(context);
                  } else {
                    if ((fromDate != '' && toDate == '') ||
                        (fromDate == '' && toDate != '')) {
                      filterError =
                          'from date and end date both should be choosen';
                      setState(() {});
                    } else {
                      DateTime date1 = DateTime.parse(fromDate);
                      DateTime date2 = DateTime.parse(toDate);

                      if (date1.difference(date2).inDays >= 0) {
                        filterError = 'from date should be ahead of to date';
                        setState(() {});
                      } else {
                        filterError = '';
                        setState(() {});
                        _fetchData();
                        Navigator.pop(context);
                      }
                    }
                  }
                },
                child: Text('Apply',style: Constants.header6,),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Constants.kMain),
                ))
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        floatingActionButton: floating(context),
        endDrawer: getEndDrawer(context),
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(12.0),
          child:  _trendTags.isNotEmpty
              ? Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      Container(
                        height: 28,
                        child: Row(
                          children: [
                            Text(
                              'Resources',
                              style: Constants.header1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            GestureDetector(
                                onTap: () {
                                  key.currentState?.openEndDrawer();
                                },
                                child: Icon(
                                  AntDesign.filter,
                                  color: Constants.kButton,
                                )),
                            SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Addresource())).then((value) {
                                  if (value != null) {
                                    resourcesFetched = false;
                                    setState(() {});
                                    _fetchData();
                                  }
                                });
                              },
                              child: Container(
                                  height: 70,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      color: Constants.kButton,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Center(
                                    child: Text(
                                      '+ Add New',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  )),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (_trendTags.length != 0)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: ListView.builder(
                                  itemCount: _trendTags.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          UtilsAPIHandler utilsAPIHandler =
                                              UtilsAPIHandler({
                                            "tags":
                                                "[${jsonEncode(_trendTags[index].tags)}]",
                                            "userid": MyApp.LOGIN_ID_VALUE
                                          });
                                          var data = await utilsAPIHandler
                                              .getTrendingTagsData();
                                          if (!data.containsKey('error')) {
                                            var res = data['Resources'];
                                            _allResources = [];
                                            try {
                                              assert(res is List);
                                              for (int i = 0;
                                                  i < res.length;
                                                  i++) {
                                                _allResources.add(
                                                    ResourceModels.fromJson(
                                                        res[i]));
                                              }
                                              resourcesFetched = true;
                                              if (this.mounted) setState(() {});
                                            } catch (e) {
                                              print(e);
                                            }
                                          } else {
                                            MyApp.Show401Dialog(context);
                                          }
                                        },
                                        child: Text(
                                          _trendTags[index].tags,
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ),
                      if (_allResources.length == 0 && !loading)
                        Container(
                          height: MediaQuery.of(context).size.height * .4,
                          child: Center(
                            child: Text('No Resources are found'),
                          ),
                        ),
                      loading
                          ? Container(
                              height: MediaQuery.of(context).size.height * .7,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                      child: Container(
                                          height: 40,
                                          width: 40,
                                          child: CircularProgressIndicator()))
                                ],
                              ))
                          : Container(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _allResources.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return resourceCard(index);
                                  }),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                    ]))
              : Container(
                  height: MediaQuery.of(context).size.height * .7,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Container(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator()))
                    ],
                  )),
        )));
  }

  Widget resourceCard(int i) {
    return Card(
        child: Container(
            margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_allResources[i].title),
                    Expanded(
                      child: Container(),
                      flex: 1,
                    ),
                    PopupMenuButton(
                      child: Icon(Icons.more_horiz),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: GestureDetector(
                                child: TextButton(
                              child: Text('delete'),
                              onPressed: () async {
                                ResourceAPIHandler handler =
                                    ResourceAPIHandler({
                                  "userid": MyApp.LOGIN_ID_VALUE,
                                  "resourceId": _allResources[i].id
                                });
                                var data = await handler.deleteResource();
                                print('======data deleted======');
                                print(data.toString());
                                print(!data.containsKey('error'));

                                if (!data.containsKey('error')) {
                                  _allResources.removeAt(i);

                                  setState(() {});
                                } else {
                                  print(
                                      '----------------enter in else part----------------');
                                  MyApp.ShowToast(
                                      data['error'].toString(), context);
                                  // MyApp.Show401Dialog(context);
                                }

                                Navigator.pop(context);
                              },
                            )),
                          )
                        ];
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _allResources[i].media.length > 0
                    ? _allResources[i].media[0]['mediaType'] == 'Image'
                        ? Image.network(
                            Constants.ImageBaseUrl +
                                _allResources[i].media[0]['mediaUrl'],
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          )
                        : VideoItem(
                            url: Constants.ImageBaseUrl +
                                _allResources[i].media[0]['mediaUrl'])
                    : Container(
                        height: 150,
                        child: Center(
                          child: Text("No Media Available!"),
                        ),
                      ),
                SizedBox(
                  height: 5,
                ),
                (_allResources?[i].description != null)
                    ? tagRemove(
                        _allResources[i].description, 'title', '', context)
                    : SizedBox(),
                // Html(
                //     data: unescape.convert(
                //   _allResources[i].description,
                // )),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: _allResources[i].likes['liked'].toString() == "1"
                          ? Icon(
                              AntDesign.heart,
                              color: Colors.red,
                              size: 22,
                            )
                          : Icon(
                              AntDesign.hearto,
                              color: Colors.black,
                              size: 22,
                            ),
                      onTap: () async {
                        if (_allResources[i].likes['liked'].toString() == "0") {
                          _allResources[i].likes['liked'] = "1";
                          _allResources[i].likes['likesCount'] = (int.parse(
                                      _allResources[i]
                                          .likes['likesCount']
                                          .toString()) +
                                  1)
                              .toString();
                          setState(() {});

                          ResourceAPIHandler handler = ResourceAPIHandler({
                            "userid": MyApp.LOGIN_ID_VALUE,
                            "resourceId": _allResources[i].id
                          });
                          var data = await handler.addLike();
                        } else {
                          _allResources[i].likes['liked'] = "0";
                          _allResources[i].likes['likesCount'] = (int.parse(
                                      _allResources[i]
                                          .likes['likesCount']
                                          .toString()) -
                                  1)
                              .toString();
                          setState(() {});

                          ResourceAPIHandler handler = ResourceAPIHandler({
                            "userid": MyApp.LOGIN_ID_VALUE,
                            "likeId": _allResources[i].likes['likeid']
                          });

                          var data = await handler.removeLike();
                        }
                      },
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CommentsList(_allResources[i].id)))
                            .then((value) {
                          if (value != null) {
                            resourcesFetched = false;
                            setState(() {});
                            _fetchData();
                          }
                        });
                      },
                      child: Icon(
                        EvilIcons.comment,
                        size: 32,
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     _onShare(context, 'sub', 'text');
                    //   },
                    //   child: Icon(
                    //     FontAwesome.share,
                    //     color: Colors.blue,
                    //     size: 22,
                    //   ),
                    // ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _allResources[i].likes['likesCount'].toString() != '0'
                    ? Text(
                        _allResources[i].likes['likesCount'].toString() +
                            " likes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    : Container(),
                SizedBox(
                  height: _allResources[i].likes['likesCount'].toString() != '0'
                      ? 10
                      : 0,
                ),
                _allResources[i].comments['userCommented'] != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _allResources[i]
                                    .comments['userCommented']
                                    .toString() +
                                " ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _allResources[i].comments['lastComment'] != null
                              ? tagRemove(
                                  _allResources[i].comments['lastComment'],
                                  'title',
                                  '',
                                  context)
                              : SizedBox(),
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: _allResources[i].comments['userCommented'] != null
                      ? 10
                      : 0,
                ),
                _allResources[i].comments['totalComments'] != null
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CommentsList(_allResources[i].id)))
                              .then((value) {
                            if (value != null) {
                              resourcesFetched = false;
                              setState(() {});
                              _fetchData();
                            }
                          });
                        },
                        child: Text(
                          'View all ' +
                              _allResources[i]
                                  .comments['totalComments']
                                  .toString() +
                              ' comments',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CommentsList(_allResources[i].id)))
                        .then((value) {
                      if (value != null) {
                        resourcesFetched = false;
                        setState(() {});
                        _fetchData();
                      }
                    });
                  },
                  child: Text(
                    'Add Comment',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            )));
  }

  _onShare(BuildContext context, String sub, String text) async {
    final RenderBox box = context.findRenderObject() as RenderBox;

    await Share.share(text,
        subject: sub,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(1800),
      lastDate: new DateTime(2100),
    );
    return picked;
  }
}
