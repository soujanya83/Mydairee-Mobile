import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';
import 'package:html_editor_enhanced/html_editor.dart'; 
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/areamodel.dart';
import 'package:mykronicle_mobile/models/commentmodel.dart';
import 'package:mykronicle_mobile/models/issuesmodel.dart';
import 'package:mykronicle_mobile/models/progressnotesmodel.dart';
import 'package:mykronicle_mobile/models/standardsmodel.dart';
import 'package:mykronicle_mobile/qip/addEducators.dart';
import 'package:mykronicle_mobile/qip/viewqipissue.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class ViewElement extends StatefulWidget {
  final String qipId;

  final List<AreaModel> areas;
  final List<StandardsModel> standards;

  final int areaIndex;
  final int standardIndex;
  final int elementIndex;

  ViewElement(
      {required this.qipId,
      required this.areas,
      required this.standards,
      required this.areaIndex,
      required this.standardIndex,
      required this.elementIndex});

  @override
  _ViewElementState createState() => _ViewElementState();
}

class _ViewElementState extends State<ViewElement>
    with SingleTickerProviderStateMixin {
  TabController? _controller;

  List<AreaModel> areas=[];
  List<StandardsModel> standards=[];
  int areaIndex=0;
  int standardIndex=0;
  int elementIndex=0;

  // var unescape = new HtmlUnescape();

    GlobalKey<State<StatefulWidget>> keyEditor = GlobalKey();
  HtmlEditorController editorController = HtmlEditorController();
  List<ProgressNotesModel> progressNotesList=[];
  List<CommentModel> commentsList=[];
  List<IssuesModel> issuesList=[];
  TextEditingController commentController=TextEditingController();
  List tabNames = ["Progress Notes", "Issues", "Comments"];

  @override
  void initState() {
    areas = widget.areas;
    standards = widget.standards;
    areaIndex = widget.areaIndex;
    standardIndex = widget.standardIndex;
    elementIndex = widget.elementIndex;
    keyEditor = GlobalKey();
    commentController = TextEditingController();
    _fetchData();
    _controller = new TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void updateStandards() async {
    var _objToSend = {
      "areaid": widget.areas[areaIndex].id,
      "userid": MyApp.LOGIN_ID_VALUE,
      "qipid": widget.qipId
    };

    QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
    var data = await qipAPIHandler.getStandards();
    print(data);
    var standardsData = data['Standards'];
    print(standardsData);
    standards = [];
    try {
      assert(standardsData is List);
      for (int i = 0; i < standardsData.length; i++) {
        StandardsModel standardsModel =
            StandardsModel.fromJson(standardsData[i]);
        List<StandardElementModel> standardElementModels = [];
        for (int j = 0; j < standardsData[i]['elements'].length; j++) {
          StandardElementModel elementModel =
              StandardElementModel.fromJson(standardsData[i]['elements'][j]);
          standardElementModels.add(elementModel);
        }
        standardsModel.elements = standardElementModels;
        standards.add(standardsModel);
      }
      elementIndex = 0;
      _fetchData();
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _fetchData() async {
    if (standards != null && standards[standardIndex].elements != null) {
      var _objToSend = {
        "qipid": widget.qipId,
        "areaid": areas[areaIndex].id,
        "elementid": standards[standardIndex].elements[elementIndex].id,
        "userid": MyApp.LOGIN_ID_VALUE
      };
      QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
      var data = await qipAPIHandler.getQipElement();

      var progressNotes = data['ProgressNotes'];
      var comments = data['Comments'];
      var issues = data['Issues'];
      progressNotesList = [];
      commentsList = [];
      issuesList = [];
      try {
        assert(progressNotes is List);
        for (int i = 0; i < progressNotes.length; i++) {
          ProgressNotesModel progressNotesModel =
              ProgressNotesModel.fromJson(progressNotes[i]);
          progressNotesList.add(progressNotesModel);
        }
        assert(comments is List);
        for (int i = 0; i < comments.length; i++) {
          CommentModel commentModel = CommentModel.fromJson(comments[i]);
          commentsList.add(commentModel);
        }
        assert(issues is List);
        for (int i = 0; i < issues.length; i++) {
          IssuesModel issuesModel = IssuesModel.fromJson(issues[i]);
          issuesList.add(issuesModel);
        }
        setState(() {});
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 3.0, right: 3, bottom: 3),
                  child: DropdownButtonHideUnderline(
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
                            value: widget.areas[areaIndex].id,
                            items: widget.areas.map((AreaModel value) {
                              return new DropdownMenuItem<String>(
                                value: value.id,
                                child: new Text(value.title),
                              );
                            }).toList(),
                            onChanged: (value) {
                              for (int i = 0; i < widget.areas.length; i++) {
                                if (widget.areas[i].id == value) {
                                  setState(() {
                                    areaIndex = i;
                                  });
                                  standardIndex = 0;
                                  updateStandards();
                                  break;
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (standards != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 3.0, right: 3, bottom: 3),
                    child: DropdownButtonHideUnderline(
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
                              value: standards[standardIndex].id,
                              items: standards.map((StandardsModel value) {
                                return new DropdownMenuItem<String>(
                                  value: value.id,
                                  child: new Text(value.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                for (int i = 0; i < standards.length; i++) {
                                  if (standards[i].id == value) {
                                    setState(() {
                                      standardIndex = i;
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
                  ),
                if (standards[standardIndex].elements != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 3.0, right: 3, bottom: 3),
                    child: DropdownButtonHideUnderline(
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
                              value: standards[standardIndex]
                                  .elements[elementIndex]
                                  .id,
                              items: standards[standardIndex]
                                  .elements
                                  .map((StandardElementModel value) {
                                return new DropdownMenuItem<String>(
                                  value: value.id,
                                  child: new Text(value.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                for (int i = 0;
                                    i <
                                        standards[standardIndex]
                                            .elements
                                            .length;
                                    i++) {
                                  if (standards[standardIndex].elements[i].id ==
                                      value) {
                                    setState(() {
                                      elementIndex = i;
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
                  ),
                Container(
                    width: size.width,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddEducators(
                                      widget.qipId,
                                      widget.standards[standardIndex]
                                          .elements[elementIndex].id,
                                      areas[areaIndex].id)));
                        },
                        child: Text('Add Educators'))),
                Container(
                  child: DefaultTabController(
                    length: 3,
                    child: new TabBar(
                        isScrollable: true,
                        controller: _controller,
                        labelColor: Constants.kMain,
                        unselectedLabelColor: Colors.grey,
                        tabs: List<Tab>.generate(3, (i) {
                          return Tab(
                            text: tabNames[i],
                          );
                        })),
                  ),
                ),
                new Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: new TabBarView(
                    controller: _controller,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: HtmlEditor(
                                // showBottomToolbar: false,
                                key: keyEditor,
                                // height:
                                    // MediaQuery.of(context).size.height * 0.3,
                                     controller: editorController,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      final txt = await editorController
                                          .getText();
                                      String notes = txt;
                                      if (notes != '') {
                                        var _objToSend = {
                                          "qipid": widget.qipId,
                                          "areaid": widget.areas[areaIndex].id,
                                          "elementid": widget
                                              .standards[standardIndex]
                                              .elements[elementIndex]
                                              .id,
                                          "pronotes": notes,
                                          "userid": MyApp.LOGIN_ID_VALUE
                                        };
                                        QipAPIHandler qipAPIHandler =
                                            QipAPIHandler(_objToSend);

                                        await qipAPIHandler
                                            .saveNotes()
                                            .then((value) {
                                          editorController.setText('');
                                          _fetchData();
                                        });
                                      } else {
                                        MyApp.ShowToast(
                                            'Notes should not be empty',
                                            context);
                                      }
                                    },
                                    child: Text('Submit'))
                              ],
                            ),
                            if (progressNotesList != null)
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: ListView.builder(
                                    reverse: true,
                                    itemCount: progressNotesList.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  progressNotesList[index]
                                                              .userImg !=
                                                          ""
                                                      ? Constants.ImageBaseUrl +
                                                          progressNotesList[
                                                                  index]
                                                              .userImg
                                                      : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                                            ),
                                            title: Text(progressNotesList[index]
                                                .addedBy),
                                            subtitle: Html(
                                                data: parseFragment(progressNotesList[index].notetext).text)),
                                      );
                                    }),
                              )
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewIssue(
                                                    qipId: widget.qipId,
                                                    elementId: widget
                                                        .standards[
                                                            standardIndex]
                                                        .elements[elementIndex]
                                                        .id,
                                                    areaId: widget
                                                        .areas[areaIndex].id,
                                                    type: 'add', issuesModel: null,
                                                  ))).then(
                                          (value) => _fetchData());
                                    },
                                    child: Text(
                                      "+ Add Issue",
                                    ))
                              ],
                            ),
                            if (issuesList != null)
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: ListView.builder(
                                    itemCount: issuesList.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        child: ListTile(
                                          title: Text(issuesList[index]
                                              .issueIdentified),
                                          trailing: TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewIssue(
                                                            type: 'edit',
                                                            qipId: widget.qipId,
                                                            elementId: widget
                                                                .standards[
                                                                    standardIndex]
                                                                .elements[
                                                                    elementIndex]
                                                                .id,
                                                            areaId: widget
                                                                .areas[
                                                                    areaIndex]
                                                                .id,
                                                            issuesModel:
                                                                issuesList[
                                                                    index],
                                                          ))).then(
                                                  (value) => _fetchData());
                                            },
                                            child: Text('view more'),
                                          ),
                                        ),
                                      );
                                    }),
                              )
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 0.0),
                                    ),
                                    border: new OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(4),
                                      ),
                                    )),
                                controller: commentController,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      String cmnt = commentController.text;
                                      if (cmnt != '') {
                                        var _objToSend = {
                                          "qipid": widget.qipId,
                                          "areaid": widget.areas[areaIndex].id,
                                          "elementid": widget
                                              .standards[standardIndex]
                                              .elements[elementIndex]
                                              .id,
                                          "comment": cmnt,
                                          "userid": MyApp.LOGIN_ID_VALUE
                                        };
                                        QipAPIHandler qipAPIHandler =
                                            QipAPIHandler(_objToSend);

                                        await qipAPIHandler
                                            .saveComment()
                                            .then((value) {
                                          commentController.clear();
                                          _fetchData();
                                        });
                                      } else {
                                        MyApp.ShowToast(
                                            'Comment should not be empty',
                                            context);
                                      }
                                    },
                                    child: Text('Submit'))
                              ],
                            ),
                            if (commentsList != null)
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: ListView.builder(
                                    reverse: true,
                                    itemCount: commentsList.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  commentsList[index].userImg !=
                                                          ""
                                                      ? Constants.ImageBaseUrl +
                                                          commentsList[index]
                                                              .userImg
                                                      : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                                            ),
                                            title: Text(
                                                commentsList[index].addedBy),
                                            subtitle: Text(commentsList[index]
                                                .commentText)),
                                      );
                                    }),
                              )
                          ],
                        ),
                      ),
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
}
