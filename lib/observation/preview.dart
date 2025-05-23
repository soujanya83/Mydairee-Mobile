import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';
import 'package:mime/mime.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:reorderables/reorderables.dart';
import 'addobservation.dart';

class Preview extends StatefulWidget {
  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  String unescapeHtml(String text) {
    return parseFragment(text).text ?? '';
  }

  // var unescape = new HtmlUnescape();
  String notes = "";
  String title = '';
  String ref = '';
  String childVoice = '';
  String futurePlan = '';
  bool expandeylf = false;
  bool expandmontessori = false;
  bool expandmilestones = false;
  List<bool> outcomes = [];
  List<bool> subjects = [];
  List<bool> ageGroups = [];

  @override
  void initState() {
    _load();
    super.initState();
  }

  void _load() {
    // notes = AddObservationState.previewnotes ?? '';
    // title = AddObservationState.previewtitle ?? '';
    // ref = AddObservationState.previewRef ?? '';
    notes = AddObservationState.notesController.text;
    title = AddObservationState.observationTextController.text;
    ref = AddObservationState.refController.text;
    childVoice = AddObservationState.childVoiceController.text;
    futurePlan = AddObservationState.futurePlanController.text;

    outcomes = List<bool>.generate(
        AddObservationState.assesData['EYLF']['outcome'].length,
        (index) => false);
    subjects = List<bool>.generate(
        AddObservationState.assesData['Montessori']['Subjects'].length,
        (index) => false);
    ageGroups = List<bool>.generate(
        AddObservationState
            .assesData['DevelopmentalMilestones']['ageGroups'].length,
        (index) => false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Constants.header1,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Add Observation > ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text('Preview')
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                if (AddObservationState.selectedRooms.length > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Childrens',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                if (AddObservationState.selectedChildrens.length > 0)
                  Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      children: List<Widget>.generate(
                          AddObservationState.selectedChildrens.length,
                          (int index) {
                        return Chip(
                          avatar: CircleAvatar(
                            radius: 50.0,
                            backgroundImage: NetworkImage(AddObservationState
                                            .selectedChildrens[index]
                                            .imageUrl !=
                                        null &&
                                    AddObservationState.selectedChildrens[index]
                                            .imageUrl !=
                                        '' &&
                                    AddObservationState.selectedChildrens[index]
                                            .imageUrl !=
                                        'null'
                                ? Constants.ImageBaseUrl +
                                    AddObservationState
                                        .selectedChildrens[index].imageUrl
                                : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                            backgroundColor: Colors.transparent,
                          ),
                          label: Text(AddObservationState
                                      .selectedChildrens[index].name !=
                                  null
                              ? AddObservationState
                                  .selectedChildrens[index].name
                              : ''),
                        );
                      })),
                SizedBox(
                  height: 5,
                ),
                if (AddObservationState.selectedRooms.length > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Rooms',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                if (AddObservationState.selectedRooms.length > 0)
                  Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 6.0, // gap between lines
                      children: List<Widget>.generate(
                          AddObservationState.selectedRooms.length,
                          (int index) {
                        return Container(
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              // ignore: deprecated_member_use
                              border: Border.all(
                                  color: Constants.kButton.withOpacity(.7))),
                          child: Text(AddObservationState
                                      .selectedRooms[index].room.name !=
                                  null
                              ? AddObservationState
                                  .selectedRooms[index].room.name
                              : ''),
                        );
                      })),
                SizedBox(
                  height: 10,
                ),
                // if (notes != "")
                Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // if (notes != "")
                Text(notes.trimRight()),
                SizedBox(
                  height: 10,
                ),
                // if (ref != "")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reflection',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(ref.trimRight()),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                if (childVoice != "")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Child Voice',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(childVoice.trimRight()),
                    ],
                  ),
                SizedBox(
                  height: 10,
                ),
                if (futurePlan != "")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Future Plan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(futurePlan.trimRight()),
                    ],
                  ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Media',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                AddObservationState.files.length > 0
                    ? ReorderableWrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        onReorder: (int oldIndex, int newIndex) {
                          // print(oldIndex);
                          // print(newIndex);
                          // File file1 = AddObservationState.files[oldIndex];
                          // File file2 = AddObservationState.files[newIndex];
                          // AddObservationState.files[oldIndex] = file2;
                          // AddObservationState.files[newIndex] = file1;

                          // String caption1 = AddObservationState.captions[oldIndex].text.toString();
                          // String caption2 = AddObservationState.captions[newIndex].text.toString();
                          // AddObservationState.captions[oldIndex].text = caption2;
                          // AddObservationState.captions[newIndex].text = caption1;

                          // List<ChildModel> child1 = AddObservationState._editChildren[oldIndex];
                          // List<ChildModel> child2 = AddObservationState._editChildren[newIndex];

                          // AddObservationState._editChildren[oldIndex] = child2;
                          // AddObservationState._editChildren[newIndex] = child1;

                          // List<StaffModel> edu1 = AddObservationState._editEducators[oldIndex];
                          // List<StaffModel> edu2 = AddObservationState._editEducators[newIndex];

                          // AddObservationState._editEducators[oldIndex] = edu2;
                          // AddObservationState._editEducators[newIndex] = edu1;
                          // setState(() {});
                        },
                        children: List<Widget>.generate(
                            AddObservationState.files.length, (int index) {
                          String mimeStr = lookupMimeType(
                                  AddObservationState.files[index].path) ??
                              '';
                          var fileType = mimeStr.split('/');
                          if (fileType[0].toString() == 'image') {
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: new DecorationImage(
                                  image: new FileImage(
                                      AddObservationState.files[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        }),
                      )
                    : Container(),
                SizedBox(height: 10),
                AddObservationState.mediaFiles.length > 0
                    ? ReorderableWrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        onReorder: (int oldIndex, int newIndex) {
                          // print(oldIndex);
                          // print(newIndex);
                          // var file1 = AddObservationState.mediaFiles[oldIndex];
                          // var file2 = AddObservationState.mediaFiles[newIndex];
                          // AddObservationState.mediaFiles[oldIndex] = file2;
                          // AddObservationState.mediaFiles[newIndex] = file1;

                          // String caption1 = AddObservationState.mediaFilecaptions[oldIndex].text.toString();
                          // String caption2 = AddObservationState.mediaFilecaptions[newIndex].text.toString();
                          // AddObservationState.mediaFilecaptions[oldIndex].text = caption2;
                          // AddObservationState.mediaFilecaptions[newIndex].text = caption1;

                          // List<ChildModel> child1 = AddObservationState._editMediaFileChildren[oldIndex];
                          // List<ChildModel> child2 = AddObservationState._editMediaFileChildren[newIndex];

                          // AddObservationState._editMediaFileChildren[oldIndex] = child2;
                          // AddObservationState._editMediaFileChildren[newIndex] = child1;

                          // List<StaffModel> edu1 = AddObservationState._editMediaFileEducators[oldIndex];
                          // List<StaffModel> edu2 = AddObservationState._editMediaFileEducators[newIndex];

                          // AddObservationState._editMediaFileEducators[oldIndex] = edu2;
                          // AddObservationState._editMediaFileEducators[newIndex] = edu1;
                          // setState(() {});
                        },
                        children: List<Widget>.generate(
                            AddObservationState.mediaFiles.length, (int index) {
                          if (AddObservationState.mediaFiles[index]['type'] ==
                              'Image') {
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: new DecorationImage(
                                  image: new NetworkImage(
                                      Constants.ImageBaseUrl +
                                          AddObservationState.mediaFiles[index]
                                              ['filename']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        }),
                      )
                    : Container(),
                SizedBox(height: 10),

                AddObservationState.media.length > 0
                    ? ReorderableWrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        onReorder: (int oldIndex, int newIndex) {},
                        children: List<Widget>.generate(
                            AddObservationState.media.length, (int index) {
                          if (AddObservationState.media[index].mediaType ==
                              'Image'){
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: new DecorationImage(
                                  image: new NetworkImage(
                                      Constants.ImageBaseUrl +
                                          AddObservationState
                                              .media[index].mediaUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        }),
                      )
                    : Container(),
                SizedBox(height: 10),
                SizedBox(
                  height: 10,
                ),
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
                // SizedBox(
                //   height: 8,
                // ),
                // Visibility(
                //     visible: AddObservationState.assesData['EYLF']['outcome'] !=
                //             null &&
                //         expandeylf,
                //     child: Container(
                //         width: MediaQuery.of(context).size.width * 0.9,
                //         child: ListView.builder(
                //             shrinkWrap: true,
                //             physics: NeverScrollableScrollPhysics(),
                //             itemCount: AddObservationState.assesData['EYLF']
                //                         ['outcome'] !=
                //                     null
                //                 ? AddObservationState
                //                     .assesData['EYLF']['outcome'].length
                //                 : 0,
                //             itemBuilder: (BuildContext context, int index) {
                //               return AddObservationState.assesData['EYLF']
                //                               ['outcome'][index]['activity'] !=
                //                           null &&
                //                       AddObservationState
                //                               .assesData['EYLF']['outcome']
                //                                   [index]['activity']
                //                               .length >
                //                           0
                //                   ? Column(children: [
                //                       ListTile(
                //                           leading: GestureDetector(
                //                             onTap: () {
                //                               outcomes[index] =
                //                                   !outcomes[index];
                //                               setState(() {});
                //                             },
                //                             child: Icon(
                //                               outcomes[index]
                //                                   ? Icons.keyboard_arrow_down
                //                                   : Icons.keyboard_arrow_right,
                //                               color: Constants.kMain,
                //                             ),
                //                           ),
                //                           title: Text(AddObservationState
                //                                   .assesData['EYLF']['outcome']
                //                               [index]['title'])),
                //                       if (outcomes[index])
                //                         Padding(
                //                           padding:
                //                               const EdgeInsets.only(left: 12.0),
                //                           child: Container(
                //                             child: ListView.builder(
                //                               shrinkWrap: true,
                //                               physics:
                //                                   NeverScrollableScrollPhysics(),
                //                               itemCount: AddObservationState
                //                                   .assesData['EYLF']['outcome']
                //                                       [index]['activity']
                //                                   .length,
                //                               itemBuilder:
                //                                   (BuildContext context,
                //                                       int p) {
                //                                 return AddObservationState.assesData['EYLF']
                //                                                             ['outcome']
                //                                                         [index]
                //                                                     ['activity'][p]
                //                                                 [
                //                                                 'subActivity'] !=
                //                                             null &&
                //                                         AddObservationState
                //                                                 .assesData[
                //                                                     'EYLF']
                //                                                     ['outcome']
                //                                                     [index]
                //                                                     ['activity']
                //                                                     [p]
                //                                                     ['subActivity']
                //                                                 .length >
                //                                             0
                //                                     ? Padding(
                //                                         padding:
                //                                             const EdgeInsets
                //                                                 .only(
                //                                                 top: 8.0,
                //                                                 bottom: 8.0),
                //                                         child: Column(
                //                                           children: [
                //                                             Container(
                //                                               child: ListTile(
                //                                                 title: Text(
                //                                                   AddObservationState.assesData['EYLF']['outcome']
                //                                                               [
                //                                                               index]
                //                                                           [
                //                                                           'activity']
                //                                                       [
                //                                                       p]['title'],
                //                                                   style: TextStyle(
                //                                                       fontSize:
                //                                                           15),
                //                                                 ),
                //                                                 leading:
                //                                                     GestureDetector(
                //                                                   onTap: () {
                //                                                     if (AddObservationState
                //                                                             .e[
                //                                                         index][p]) {
                //                                                       AddObservationState.e[index]
                //                                                               [
                //                                                               p] =
                //                                                           false;
                //                                                     } else {
                //                                                       AddObservationState.e[index]
                //                                                               [
                //                                                               p] =
                //                                                           true;
                //                                                     }
                //                                                     setState(
                //                                                         () {});
                //                                                   },
                //                                                   child: Icon(
                //                                                     AddObservationState.e[index]
                //                                                             [p]
                //                                                         ? Icons
                //                                                             .keyboard_arrow_down
                //                                                         : Icons
                //                                                             .keyboard_arrow_right,
                //                                                   ),
                //                                                 ),
                //                                               ),
                //                                             ),
                //                                             Visibility(
                //                                                 visible: AddObservationState
                //                                                             .e !=
                //                                                         null
                //                                                     ? AddObservationState
                //                                                             .e[
                //                                                         index][p]
                //                                                     : false,
                //                                                 child: Padding(
                //                                                   padding:
                //                                                       const EdgeInsets
                //                                                           .only(
                //                                                           left:
                //                                                               15.0),
                //                                                   child:
                //                                                       Container(
                //                                                           child:
                //                                                               ListView.builder(
                //                                                     shrinkWrap:
                //                                                         true,
                //                                                     physics:
                //                                                         NeverScrollableScrollPhysics(),
                //                                                     itemCount: AddObservationState
                //                                                         .assesData[
                //                                                             'EYLF']
                //                                                             [
                //                                                             'outcome']
                //                                                             [
                //                                                             index]
                //                                                             [
                //                                                             'activity']
                //                                                             [p][
                //                                                             'subActivity']
                //                                                         .length,
                //                                                     itemBuilder:
                //                                                         (BuildContext
                //                                                                 context,
                //                                                             int i) {
                //                                                       return AddObservationState.checkValue[index][p]
                //                                                               [
                //                                                               i]
                //                                                           ? Card(
                //                                                               child: ListTile(
                //                                                                 title: Text(AddObservationState.assesData['EYLF']['outcome'][index]['activity'][p]['subActivity'][i]['title']),
                //                                                               ),
                //                                                             )
                //                                                           : Container();
                //                                                     },
                //                                                   )),
                //                                                 )),
                //                                           ],
                //                                         ),
                //                                       )
                //                                     : Container();
                //                               },
                //                             ),
                //                           ),
                //                         )
                //                     ])
                //                   : Container();
                //             }))),
                // Container(
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.blueAccent),
                //     borderRadius: BorderRadius.all(Radius.circular(6)),
                //   ),
                //   child: ListTile(
                //     title: Text(
                //       'Montessori Activities',
                //       style: TextStyle(fontSize: 15),
                //     ),
                //     leading: GestureDetector(
                //       onTap: () {
                //         expandmontessori = !expandmontessori;
                //         setState(() {});
                //       },
                //       child: Icon(
                //         expandmontessori
                //             ? Icons.keyboard_arrow_down
                //             : Icons.keyboard_arrow_right,
                //         color: Constants.kMain,
                //       ),
                //     ),
                //   ),
                // ),
                // Visibility(
                //     visible: AddObservationState.assesData['Montessori']
                //                 ['Subjects'] !=
                //             null &&
                //         expandmontessori,
                //     child: Container(
                //         width: MediaQuery.of(context).size.width * 0.9,
                //         child: ListView.builder(
                //             shrinkWrap: true,
                //             physics: NeverScrollableScrollPhysics(),
                //             itemCount: AddObservationState
                //                         .assesData['Montessori']['Subjects'] !=
                //                     null
                //                 ? AddObservationState
                //                     .assesData['Montessori']['Subjects'].length
                //                 : 0,
                //             itemBuilder: (BuildContext context, int index) {
                //               return AddObservationState.assesData['Montessori']
                //                               ['Subjects'][index]['activity'] !=
                //                           null &&
                //                       AddObservationState
                //                               .assesData['Montessori']
                //                                   ['Subjects'][index]
                //                                   ['activity']
                //                               .length >
                //                           0
                //                   ? Column(children: [
                //                       ListTile(
                //                           leading: GestureDetector(
                //                             onTap: () {
                //                               subjects[index] =
                //                                   !subjects[index];
                //                               setState(() {});
                //                             },
                //                             child: Icon(
                //                               subjects[index]
                //                                   ? Icons.keyboard_arrow_down
                //                                   : Icons.keyboard_arrow_right,
                //                               color: Constants.kMain,
                //                             ),
                //                           ),
                //                           title: Text(AddObservationState
                //                                   .assesData['Montessori']
                //                               ['Subjects'][index]['name'])),
                //                       if (subjects[index])
                //                         Padding(
                //                           padding:
                //                               const EdgeInsets.only(left: 12.0),
                //                           child: Container(
                //                             child: ListView.builder(
                //                               shrinkWrap: true,
                //                               physics:
                //                                   NeverScrollableScrollPhysics(),
                //                               itemCount: AddObservationState
                //                                   .assesData['Montessori']
                //                                       ['Subjects'][index]
                //                                       ['activity']
                //                                   .length,
                //                               itemBuilder:
                //                                   (BuildContext context,
                //                                       int p) {
                //                                 return AddObservationState.assesData['Montessori']
                //                                                             ['Subjects']
                //                                                         [index]
                //                                                     ['activity'][p]
                //                                                 [
                //                                                 'SubActivity'] !=
                //                                             null &&
                //                                         AddObservationState
                //                                                 .assesData[
                //                                                     'Montessori']
                //                                                     ['Subjects']
                //                                                     [index]
                //                                                     ['activity']
                //                                                     [p]
                //                                                     ['SubActivity']
                //                                                 .length >
                //                                             0
                //                                     ? Padding(
                //                                         padding:
                //                                             const EdgeInsets
                //                                                 .only(
                //                                                 top: 8.0,
                //                                                 bottom: 8.0),
                //                                         child: Column(
                //                                           children: [
                //                                             Container(
                //                                               child: ListTile(
                //                                                 title: Text(
                //                                                   AddObservationState.assesData['Montessori']['Subjects']
                //                                                               [
                //                                                               index]
                //                                                           [
                //                                                           'activity']
                //                                                       [
                //                                                       p]['title'],
                //                                                   style: TextStyle(
                //                                                       fontSize:
                //                                                           15),
                //                                                 ),
                //                                                 leading:
                //                                                     GestureDetector(
                //                                                   onTap: () {
                //                                                     if (AddObservationState
                //                                                             .em[
                //                                                         index][p]) {
                //                                                       AddObservationState.em[index]
                //                                                               [
                //                                                               p] =
                //                                                           false;
                //                                                     } else {
                //                                                       AddObservationState.em[index]
                //                                                               [
                //                                                               p] =
                //                                                           true;
                //                                                     }
                //                                                     setState(
                //                                                         () {});
                //                                                   },
                //                                                   child: Icon(
                //                                                     AddObservationState.em[index]
                //                                                             [p]
                //                                                         ? Icons
                //                                                             .keyboard_arrow_down
                //                                                         : Icons
                //                                                             .keyboard_arrow_right,
                //                                                   ),
                //                                                 ),
                //                                               ),
                //                                             ),
                //                                             Visibility(
                //                                                 visible: AddObservationState
                //                                                             .em !=
                //                                                         null
                //                                                     ? AddObservationState
                //                                                             .em[
                //                                                         index][p]
                //                                                     : false,
                //                                                 child: Padding(
                //                                                   padding:
                //                                                       const EdgeInsets
                //                                                           .only(
                //                                                           left:
                //                                                               15.0),
                //                                                   child:
                //                                                       Container(
                //                                                           child:
                //                                                               ListView.builder(
                //                                                     shrinkWrap:
                //                                                         true,
                //                                                     physics:
                //                                                         NeverScrollableScrollPhysics(),
                //                                                     itemCount: AddObservationState
                //                                                         .assesData[
                //                                                             'Montessori']
                //                                                             [
                //                                                             'Subjects']
                //                                                             [
                //                                                             index]
                //                                                             [
                //                                                             'activity']
                //                                                             [p][
                //                                                             'SubActivity']
                //                                                         .length,
                //                                                     itemBuilder:
                //                                                         (BuildContext
                //                                                                 context,
                //                                                             int i) {
                //                                                       return AddObservationState.checkValue[index][p]
                //                                                               [
                //                                                               i]
                //                                                           ? Card(
                //                                                               child: ListTile(
                //                                                                 title: Text(AddObservationState.assesData['Montessori']['Subjects'][index]['activity'][p]['SubActivity'][i]['title']),
                //                                                               ),
                //                                                             )
                //                                                           : Container();
                //                                                     },
                //                                                   )),
                //                                                 )),
                //                                           ],
                //                                         ),
                //                                       )
                //                                     : Container();
                //                               },
                //                             ),
                //                           ),
                //                         )
                //                     ])
                //                   : Container();
                //             }))),
                // SizedBox(
                //   height: 8,
                // ),
                // Container(
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.blueAccent),
                //     borderRadius: BorderRadius.all(Radius.circular(6)),
                //   ),
                //   child: ListTile(
                //     title: Text(
                //       'Developmental Milestones',
                //       style: TextStyle(fontSize: 15),
                //     ),
                //     leading: InkWell(
                //       onTap: () {
                //         expandmilestones = !expandmilestones;
                //         setState(() {});
                //       },
                //       child: Icon(
                //         expandmilestones
                //             ? Icons.keyboard_arrow_down
                //             : Icons.keyboard_arrow_right,
                //         color: Constants.kMain,
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 8,
                // ),
                // Visibility(
                //     visible:
                //         AddObservationState.assesData['DevelopmentalMilestones']
                //                     ['ageGroups'] !=
                //                 null &&
                //             expandmilestones,
                //     child: Container(
                //         width: MediaQuery.of(context).size.width * 0.9,
                //         child: ListView.builder(
                //             shrinkWrap: true,
                //             physics: NeverScrollableScrollPhysics(),
                //             itemCount: AddObservationState.assesData[
                //                             'DevelopmentalMilestones']
                //                         ['ageGroups'] !=
                //                     null
                //                 ? AddObservationState
                //                     .assesData['DevelopmentalMilestones']
                //                         ['ageGroups']
                //                     .length
                //                 : 0,
                //             itemBuilder: (BuildContext context, int index) {
                //               return AddObservationState.assesData[
                //                                   'DevelopmentalMilestones']
                //                               ['ageGroups'][index]['subname'] !=
                //                           null &&
                //                       AddObservationState
                //                               .assesData[
                //                                   'DevelopmentalMilestones']
                //                                   ['ageGroups'][index]
                //                                   ['subname']
                //                               .length >
                //                           0
                //                   ? Column(children: [
                //                       ListTile(
                //                           leading: GestureDetector(
                //                             onTap: () {
                //                               ageGroups[index] =
                //                                   !ageGroups[index];
                //                               setState(() {});
                //                             },
                //                             child: Icon(
                //                               ageGroups[index]
                //                                   ? Icons.keyboard_arrow_down
                //                                   : Icons.keyboard_arrow_right,
                //                               color: Constants.kMain,
                //                             ),
                //                           ),
                //                           title: Text(AddObservationState
                //                               .assesData[
                //                                   'DevelopmentalMilestones']
                //                                   ['ageGroups'][index]
                //                                   ['ageGroup']
                //                               .toString())),
                //                       if (ageGroups[index])
                //                         Padding(
                //                           padding:
                //                               const EdgeInsets.only(left: 12.0),
                //                           child: Container(
                //                             child: ListView.builder(
                //                               shrinkWrap: true,
                //                               physics:
                //                                   NeverScrollableScrollPhysics(),
                //                               itemCount: AddObservationState
                //                                   .assesData[
                //                                       'DevelopmentalMilestones']
                //                                       ['ageGroups'][index]
                //                                       ['subname']
                //                                   .length,
                //                               itemBuilder:
                //                                   (BuildContext context,
                //                                       int p) {
                //                                 return AddObservationState.assesData[
                //                                                             'DevelopmentalMilestones']
                //                                                         ['ageGroups']
                //                                                     [index]['subname']
                //                                                 [p]['title'] !=
                //                                             null &&
                //                                         AddObservationState
                //                                                 .assesData[
                //                                                     'DevelopmentalMilestones']
                //                                                     ['ageGroups']
                //                                                     [index]
                //                                                     ['subname']
                //                                                     [p]['title']
                //                                                 .length >
                //                                             0
                //                                     ? Padding(
                //                                         padding:
                //                                             const EdgeInsets
                //                                                 .only(
                //                                                 top: 8.0,
                //                                                 bottom: 8.0),
                //                                         child: Column(
                //                                           children: [
                //                                             Container(
                //                                               child: ListTile(
                //                                                 title: Text(
                //                                                   AddObservationState.assesData['DevelopmentalMilestones']['ageGroups']
                //                                                               [
                //                                                               index]
                //                                                           [
                //                                                           'subname']
                //                                                       [
                //                                                       p]['name'],
                //                                                   style: TextStyle(
                //                                                       fontSize:
                //                                                           15),
                //                                                 ),
                //                                                 leading:
                //                                                     GestureDetector(
                //                                                   onTap: () {
                //                                                     if (AddObservationState
                //                                                             .emi[
                //                                                         index][p]) {
                //                                                       AddObservationState.emi[index]
                //                                                               [
                //                                                               p] =
                //                                                           false;
                //                                                     } else {
                //                                                       AddObservationState.emi[index]
                //                                                               [
                //                                                               p] =
                //                                                           true;
                //                                                     }
                //                                                     setState(
                //                                                         () {});
                //                                                   },
                //                                                   child: Icon(
                //                                                     AddObservationState.emi[index]
                //                                                             [p]
                //                                                         ? Icons
                //                                                             .keyboard_arrow_down
                //                                                         : Icons
                //                                                             .keyboard_arrow_right,
                //                                                   ),
                //                                                 ),
                //                                               ),
                //                                             ),
                //                                             Visibility(
                //                                                 visible: AddObservationState
                //                                                             .emi !=
                //                                                         null
                //                                                     ? AddObservationState
                //                                                             .emi[
                //                                                         index][p]
                //                                                     : false,
                //                                                 child: Padding(
                //                                                   padding:
                //                                                       const EdgeInsets
                //                                                           .only(
                //                                                           left:
                //                                                               15.0),
                //                                                   child:
                //                                                       Container(
                //                                                           child:
                //                                                               ListView.builder(
                //                                                     shrinkWrap:
                //                                                         true,
                //                                                     physics:
                //                                                         NeverScrollableScrollPhysics(),
                //                                                     itemCount: AddObservationState
                //                                                         .assesData[
                //                                                             'DevelopmentalMilestones']
                //                                                             [
                //                                                             'ageGroups']
                //                                                             [
                //                                                             index]
                //                                                             [
                //                                                             'subname']
                //                                                             [p][
                //                                                             'title']
                //                                                         .length,
                //                                                     itemBuilder:
                //                                                         (BuildContext
                //                                                                 context,
                //                                                             int i) {
                //                                                       return AddObservationState.assesData['DevelopmentalMilestones']['ageGroups'][index]['subname'][p]['title'][i]['options'].length >
                //                                                               0
                //                                                           ? Card(
                //                                                               child: ListTile(
                //                                                                 title: Text(AddObservationState.assesData['DevelopmentalMilestones']['ageGroups'][index]['subname'][p]['title'][i]['name']),
                //                                                               ),
                //                                                             )
                //                                                           : Container();
                //                                                     },
                //                                                   )),
                //                                                 )),
                //                                           ],
                //                                         ),
                //                                       )
                //                                     : Container();
                //                               },
                //                             ),
                //                           ),
                //                         )
                //                     ])
                //                   : Container();
                //             }))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
