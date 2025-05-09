import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/observationmodel.dart';
import 'package:mykronicle_mobile/observation/addobservation.dart';
import 'package:mykronicle_mobile/observation/obsdata.dart';
import 'package:mykronicle_mobile/observation/viewobservation.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/removeTags.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ObservationMain extends StatefulWidget {
  static String Tag = Constants.OBSERVATION_MAIN_TAG;

  @override
  _ObservationMainState createState() => _ObservationMainState();
}

class _ObservationMainState extends State<ObservationMain> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  String searchString = '';
  bool showStatus = false;
  bool showAdded = false;
  bool showChildren = false;
  bool showAuthor = false;
  bool showMedia = false;
  final DateFormat formatter = DateFormat('dd-MM-yyyy – kk:mm');

  bool allChildren = false;

  bool showAssesments = false;
  bool showComments = false;
  bool showLinks = false;

  bool observationsFetched = false;
  List<ObservationModel> _allObservations = [];
  List<ChildModel> _allChildrens = [];
  Map<String, bool> childValues = {};
  bool childrensFetched = false;
  bool obsStatusDraft = false;
  bool obsStatusPublished = false;
  bool disabledAssesment = false;
  bool disabledComment = false;
  bool disabledLink = false;

  List childs = [];
  List assessments = [];
  List observations = [];
  List added = [];
  List media = [];
  List comments = [];
  List links = [];

  Map<String, bool> mediaValues = {
    'Any': false,
    'Image': false,
    'Video': false,
  };

  Map<String, bool> assesmentsValues = {
    'Does Not Have Any Assessment': false,
    'Has Montessori': false,
    'Has Early Years Learning Framework': false,
    'Has Developmental Milestones': false,
    'Does Not Have Montessori': false,
    'Does Not Have Early Years Learning Framework': false,
    'Does Not Have Developmental Milestones': false,
  };

  Map<String, bool> commentsValues = {
    'With Comments': false,
    'With Staff Comments': false,
    'With Relative Comments': false,
    'No Comments': false,
    'No Staff Comments': false,
    'No Relative Comments': false,
  };
  Map<String, bool> linksValues = {
    'Not Filtered': false,
    'Linked to anything': false,
    'Not Linked to anything': false,
    'Linked to observations': false,
    'Not Linked to observations': false,
    'Linked to reflections': false,
    'Not Linked to reflections': false
  };

  Map<String, bool> authorValues = {
    'Any': false,
    'Me': false,
    'Staff': false,
  };
  Map<String, bool> addedValues = {
    'None': false,
    'Today': false,
    'This Week': false,
    'This Month': false,
    'Custom': false,
  };
  DateTime? startDate;
  DateTime? endDate;

  // Declare variables at the class level (outside the build method)
  bool drawer_obsStatusDraft = false;
  bool drawer_obsStatusPublished = false;
  List drawer_childs = [];
  Map<String, bool> drawer_addedValues = {};
  Map<String, bool> drawer_authorValues = {};
  List drawer_observations = [];
  DateTime? drawer_startDate;
  DateTime? drawer_endDate;

// Function to initialize drawer variables
  initializeDrawerVariables() async {
    drawer_obsStatusDraft = obsStatusDraft;
    drawer_obsStatusPublished = obsStatusPublished;
    drawer_childs = List.from(childs);
    drawer_addedValues = Map.from(addedValues);
    drawer_authorValues = Map.from(authorValues);
    drawer_observations = List.from(observations);
    drawer_startDate = startDate;
    drawer_endDate = endDate;
    if (this.mounted) setState(() {});
  }

  void printDebugValues() {
    print('=== Debugging Filter Values ===');
    print('Observation Status:');
    print(
        '  Original - Draft: $obsStatusDraft, Published: $obsStatusPublished');
    print(
        '  Drawer   - Draft: $drawer_obsStatusDraft, Published: $drawer_obsStatusPublished');
    print('\nChild Selections:');
    print('  Original: $childs');
    print('  Drawer  : $drawer_childs');
    print('\nAdded Values:');
    print('  Original: $addedValues');
    print('  Drawer  : $drawer_addedValues');
    print('\nAuthor Values:');
    print('  Original: $authorValues');
    print('  Drawer  : $drawer_authorValues');
    print('\nObservations:');
    print('  Original: $observations');
    print('  Drawer  : $drawer_observations');
    print('\nDate Range:');
    print(
        '  Original - Start: ${startDate != null ? DateFormat('MM/dd/yyyy').format(startDate!) : 'null'}, '
        'End: ${endDate != null ? DateFormat('MM/dd/yyyy').format(endDate!) : 'null'}');
    print(
        '  Drawer   - Start: ${drawer_startDate != null ? DateFormat('MM/dd/yyyy').format(drawer_startDate!) : 'null'}, '
        'End: ${drawer_endDate != null ? DateFormat('MM/dd/yyyy').format(drawer_endDate!) : 'null'}');
    print('==============================');
  }

  void printFunction() {
    print(obsStatusDraft);
    print(obsStatusPublished);
    print(childs);
    print(addedValues);
    print(authorValues);
    print(observations);
  }

  Widget getEndDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 5),
            ListTile(
              title: Text(
                'Apply Filters',
                style: Constants.header2,
              ),
              trailing: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  // printDebugValues();
                  Navigator.pop(context);
                },
              ),
            ),

            // Observation Status Section
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                title: Text('Observation Status', style: Constants.header2),
                children: [
                  Container(
                    height: 100,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        ListTile(
                          trailing: Checkbox(
                            value: drawer_obsStatusDraft,
                            onChanged: (value) {
                              if (value == true) {
                                drawer_obsStatusPublished = false;
                                drawer_obsStatusDraft = true;
                                if (!drawer_observations.contains('Draft')) {
                                  drawer_observations.add('Draft');
                                }
                                if (drawer_observations.contains('Published')) {
                                  drawer_observations.remove('Published');
                                }
                              } else if (value == false) {
                                drawer_obsStatusDraft = false;
                                if (drawer_observations.contains('Draft')) {
                                  drawer_observations.remove('Draft');
                                }
                              }
                              setState(() {});
                            },
                          ),
                          title: Text('Draft'),
                        ),
                        ListTile(
                          trailing: Checkbox(
                            value: drawer_obsStatusPublished,
                            onChanged: (value) {
                              if (value == true) {
                                drawer_obsStatusDraft = false;
                                if (drawer_observations.contains('Draft')) {
                                  drawer_observations.remove('Draft');
                                }
                                drawer_obsStatusPublished = true;
                                if (!drawer_observations
                                    .contains('Published')) {
                                  drawer_observations.add('Published');
                                }
                              } else if (value == false) {
                                drawer_obsStatusPublished = false;
                                if (drawer_observations.contains('Published')) {
                                  drawer_observations.remove('Published');
                                }
                              }
                              setState(() {});
                            },
                          ),
                          title: Text('Published'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
// Added Section
            Builder(builder: (context) {
              try {
                return Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    title: Text('Added', style: Constants.header2),
                    children: [
                      Container(
                        height: (drawer_addedValues['Custom'] == true)
                            ? 400
                            : 280, // Increased height to accommodate date pickers
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            CheckboxListTile(
                              title: Text('None'),
                              value: drawer_addedValues['None'],
                              onChanged: (bool? value) {
                                if (value == true) {
                                  // Unselect all other options
                                  drawer_addedValues.forEach((key, _) {
                                    drawer_addedValues[key] = false;
                                  });
                                  drawer_addedValues['None'] = true;
                                }
                                setState(() {});
                              },
                            ),
                            CheckboxListTile(
                              title: Text('Today'),
                              value: drawer_addedValues['Today'],
                              onChanged: (bool? value) {
                                if (value == true) {
                                  // Unselect all other options
                                  drawer_addedValues.forEach((key, _) {
                                    drawer_addedValues[key] = false;
                                  });
                                  drawer_addedValues['Today'] = true;
                                }
                                setState(() {});
                              },
                            ),
                            CheckboxListTile(
                              title: Text('This Week'),
                              value: drawer_addedValues['This Week'],
                              onChanged: (bool? value) {
                                if (value == true) {
                                  // Unselect all other options
                                  drawer_addedValues.forEach((key, _) {
                                    drawer_addedValues[key] = false;
                                  });
                                  drawer_addedValues['This Week'] = true;
                                }
                                setState(() {});
                              },
                            ),
                            CheckboxListTile(
                              title: Text('This Month'),
                              value: drawer_addedValues['This Month'],
                              onChanged: (bool? value) {
                                if (value == true) {
                                  // Unselect all other options
                                  drawer_addedValues.forEach((key, _) {
                                    drawer_addedValues[key] = false;
                                  });
                                  drawer_addedValues['This Month'] = true;
                                }
                                setState(() {});
                              },
                            ),
                            CheckboxListTile(
                              title: Text('Custom Date'),
                              value: drawer_addedValues['Custom'],
                              onChanged: (bool? value) {
                                if (value == true) {
                                  // Unselect all other options
                                  drawer_addedValues.forEach((key, _) {
                                    drawer_addedValues[key] = false;
                                  });
                                  drawer_addedValues['Custom'] = true;
                                } else {
                                  drawer_addedValues['Custom'] = false;
                                }
                                setState(() {});
                              },
                            ),
                            // Date pickers (shown only when Custom is selected)
                            if (drawer_addedValues['Custom'] == true) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('Start Date'),
                                      trailing: TextButton(
                                        child: Text(
                                          drawer_startDate != null
                                              ? DateFormat('MM/dd/yyyy')
                                                  .format(drawer_startDate!)
                                              : 'Select Date',
                                        ),
                                        onPressed: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: drawer_startDate ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              drawer_startDate = picked;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('End Date'),
                                      trailing: TextButton(
                                        child: Text(
                                          drawer_endDate != null
                                              ? DateFormat('MM/dd/yyyy')
                                                  .format(drawer_endDate!)
                                              : 'Select Date',
                                        ),
                                        onPressed: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: drawer_endDate ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              drawer_endDate = picked;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                return SizedBox();
              }
            }),
            // Child Section
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                title: Text('Child', style: Constants.header2),
                children: [
                  Container(
                    height: 220,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        CheckboxListTile(
                          title: Text('All Children'),
                          value: allChildren,
                          onChanged: (value) {
                            allChildren = value!;
                            if (value == true) {
                              drawer_childs.clear();
                              for (int i = 0; i < _allChildrens.length; i++) {
                                childValues[_allChildrens[i].id] = value!;
                                drawer_childs.add(_allChildrens[i].id);
                              }
                            } else {
                              for (int i = 0; i < _allChildrens.length; i++) {
                                childValues[_allChildrens[i].id] = value;
                              }
                              drawer_childs.clear();
                            }
                            setState(() {});
                          },
                        ),
                        Container(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _allChildrens != null
                                ? _allChildrens.length
                                : 0,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    _allChildrens[index].imageUrl != null
                                        ? Constants.ImageBaseUrl +
                                            _allChildrens[index].imageUrl
                                        : '',
                                  ),
                                ),
                                title: Text(_allChildrens[index].name),
                                trailing: Checkbox(
                                  value: childValues[_allChildrens[index].id],
                                  onChanged: (value) {
                                    if (!value!) {
                                      allChildren = false;
                                    }
                                    if (value == true) {
                                      if (!drawer_childs
                                          .contains(_allChildrens[index].id)) {
                                        drawer_childs
                                            .add(_allChildrens[index].id);
                                      }
                                    } else {
                                      if (drawer_childs
                                          .contains(_allChildrens[index].id)) {
                                        drawer_childs
                                            .remove(_allChildrens[index].id);
                                      }
                                    }
                                    childValues[_allChildrens[index].id] =
                                        value;
                                    setState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Author Section
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                title: Text('Author', style: Constants.header2),
                children: [
                  Container(
                    height: 160,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      children: drawer_authorValues.keys.map((String key) {
                        return CheckboxListTile(
                          title: Text(key),
                          value: drawer_authorValues[key],
                          onChanged: (bool? value) {
                            // drawer_authorValues.keys.map((String key) {
                            //   drawer_authorValues[key] = false;
                            // }).toList();
                            drawer_authorValues[key] = value!;
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                child: Text('Apply Filters'),
                onPressed: () {
                  // Update the main variables from drawer variables
                  obsStatusDraft = drawer_obsStatusDraft;
                  obsStatusPublished = drawer_obsStatusPublished;
                  childs = List.from(drawer_childs);
                  addedValues = Map.from(drawer_addedValues);
                  authorValues = Map.from(drawer_authorValues);
                  observations = List.from(drawer_observations);
                  startDate = drawer_startDate;
                  endDate = drawer_endDate;

                  // Update added and authors lists
                  // added.clear();
                  // if (drawer_addedValues['All'] == true) {
                  //   added.add('All');
                  // } else {
                  //   drawer_addedValues.forEach((key, value) {
                  //     if (value == true && key != 'All') added.add(key);
                  //   });
                  // }

                  // authors.clear();
                  // if (drawer_authorValues['Any'] == true) {
                  //   authors.add('Any');
                  // } else {
                  //   drawer_authorValues.forEach((key, value) {
                  //     if (value == true && key != 'Any') authors.add(key);
                  //   });
                  // }

                  _fetchFilteredData();
                  observationsFetched = false;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  } //     'Assessment',
  //     style: Constants.header2,
  //   ),
  //   trailing: IconButton(
  //     icon: Icon(showAssesments
  //         ? Icons.keyboard_arrow_up
  //         : Icons.keyboard_arrow_down),
  //     onPressed: () {
  //       showAssesments = !showAssesments;
  //       setState(() {});
  //     },
  //   ),
  // ),
  // Visibility(
  //   visible: showAssesments,
  //   child: Container(
  //     height: assesmentsValues.length * 55.0,
  //     child: ListView(
  //       physics: NeverScrollableScrollPhysics(),
  //       children: assesmentsValues.keys.map((String key) {
  //         return new CheckboxListTile(
  //           title: new Text(key),
  //           value: assesmentsValues[key],
  //           onChanged: (bool? value) {
  //             if (key == 'Does Not Have Any Assessment') {
  //               if (value == true) {
  //                 assesmentsValues['Does Not Have Any Assessment'] =
  //                     true;
  //                 assesmentsValues['Has Montessori'] = false;
  //                 assesmentsValues[
  //                     'Has Early Years Learning Framework'] = false;
  //                 assesmentsValues['Has Developmental Milestones'] =
  //                     false;
  //                 assesmentsValues['Does Not Have Montessori'] = false;
  //                 assesmentsValues[
  //                         'Does Not Have Early Years Learning Framework'] =
  //                     false;
  //                 assesmentsValues[
  //                     'Does Not Have Developmental Milestones'] = false;
  //                 disabledAssesment = true;
  //                 if (!assessments
  //                     .contains('Does Not Have Any Assessment')) {
  //                   assessments.add('Does Not Have Any Assessment');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               } else {
  //                 if (assessments
  //                     .contains('Does Not Have Any Assessment')) {
  //                   assessments.remove('Does Not Have Any Assessment');
  //                 }
  //                 assesmentsValues['Does Not Have Any Assessment'] =
  //                     false;
  //                 disabledAssesment = false;
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               }
  //             } else if (key == 'Has Montessori' &&
  //                 disabledAssesment == false &&
  //                 assesmentsValues['Does Not Have Montessori'] ==
  //                     false) {
  //               if (value == true) {
  //                 assesmentsValues[key] = true;
  //                 assesmentsValues['Does Not Have Montessori'] = false;
  //                 if (!assessments.contains('Has Montessori')) {
  //                   assessments.add('Has Montessori');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               } else {
  //                 assesmentsValues[key] = false;
  //                 if (assessments.contains('Has Montessori')) {
  //                   assessments.remove('Has Montessori');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               }
  //             } else if (key == 'Does Not Have Montessori' &&
  //                 disabledAssesment == false &&
  //                 assesmentsValues['Has Montessori'] == false) {
  //               if (value == true) {
  //                 assesmentsValues[key] = true;
  //                 assesmentsValues['Has Montessori'] = false;
  //                 if (!assessments
  //                     .contains('Does Not Have Montessori')) {
  //                   assessments.add('Does Not Have Montessori');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               } else {
  //                 assesmentsValues[key] = false;
  //                 if (assessments
  //                     .contains('Does Not Have Montessori')) {
  //                   assessments.remove('Does Not Have Montessori');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               }
  //             } else if (key == 'Has Early Years Learning Framework' &&
  //                 disabledAssesment == false &&
  //                 assesmentsValues[
  //                         'Does Not Have Early Years Learning Framework'] ==
  //                     false) {
  //               if (value == true) {
  //                 assesmentsValues[key] = true;
  //                 assesmentsValues[
  //                         'Does Not Have Early Years Learning Framework'] =
  //                     false;
  //                 if (!assessments
  //                     .contains('Has Early Years Learning Framework')) {
  //                   assessments
  //                       .add('Has Early Years Learning Framework');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               } else {
  //                 assesmentsValues[key] = false;
  //                 if (assessments
  //                     .contains('Has Early Years Learning Framework')) {
  //                   assessments
  //                       .remove('Has Early Years Learning Framework');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               }
  //             } else if (key ==
  //                     'Does Not Have Early Years Learning Framework' &&
  //                 disabledAssesment == false &&
  //                 assesmentsValues[
  //                         'Has Early Years Learning Framework'] ==
  //                     false) {
  //               if (value == true) {
  //                 assesmentsValues[key] = true;
  //                 assesmentsValues[
  //                     'Has Early Years Learning Framework'] = false;
  //                 if (!assessments.contains(
  //                     'Does Not Have Early Years Learning Framework')) {
  //                   assessments.add(
  //                       'Does Not Have Early Years Learning Framework');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               } else {
  //                 assesmentsValues[key] = false;
  //                 if (assessments.contains(
  //                     'Does Not Have Early Years Learning Framework')) {
  //                   assessments.remove(
  //                       'Does Not Have Early Years Learning Framework');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               }
  //             } else if (key == 'Has Developmental Milestones' &&
  //                 disabledAssesment == false &&
  //                 assesmentsValues[
  //                         'Does Not Have Developmental Milestones'] ==
  //                     false) {
  //               if (value == true) {
  //                 assesmentsValues[key] = true;
  //                 assesmentsValues[
  //                     'Does Not Have Developmental Milestones'] = false;
  //                 if (!assessments
  //                     .contains('Has Developmental Milestones')) {
  //                   assessments.add('Has Developmental Milestones');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               } else {
  //                 assesmentsValues[key] = false;
  //                 if (assessments
  //                     .contains('Has Developmental Milestones')) {
  //                   assessments.remove('Has Developmental Milestones');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               }
  //             } else if (key ==
  //                     'Does Not Have Developmental Milestones' &&
  //                 disabledAssesment == false &&
  //                 assesmentsValues['Has Developmental Milestones'] ==
  //                     false) {
  //               if (value == true) {
  //                 assesmentsValues[key] = true;
  //                 assesmentsValues['Has Developmental Milestones'] =
  //                     false;
  //                 if (!assessments.contains(
  //                     'Does Not Have Developmental Milestones')) {
  //                   assessments
  //                       .add('Does Not Have Developmental Milestones');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               } else {
  //                 assesmentsValues[key] = false;
  //                 if (assessments.contains(
  //                     'Does Not Have Developmental Milestones')) {
  //                   assessments.remove(
  //                       'Does Not Have Developmental Milestones');
  //                 }
  //                 observationsFetched = false;
  //                 _fetchFilteredData();
  //               }
  //             }

  //             setState(() {});
  //           },
  //         );
  //       }).toList(),
  //     ),
  //   ),
  // ),

  // ListTile(
  //   title: Text(
  //     'Media',
  //     style: Constants.header2,
  //   ),
  //   trailing: IconButton(
  //     icon: Icon(showMedia
  //         ? Icons.keyboard_arrow_up
  //         : Icons.keyboard_arrow_down),
  //     onPressed: () {
  //       showMedia = !showMedia;
  //       setState(() {});
  //     },
  //   ),
  // ),
  // Visibility(
  //   visible: showMedia,
  //   child: Container(
  //     height: 160,
  //     child: ListView(
  //       physics: NeverScrollableScrollPhysics(),
  //       children: mediaValues.keys.map((String key) {
  //         return new CheckboxListTile(
  //           title: new Text(key),
  //           value: mediaValues[key],
  //           onChanged: (bool? value) {
  //             if (key == 'Any') {
  //               mediaValues['Image'] = value!;
  //               mediaValues['Video'] = value!;
  //               mediaValues[key] = value!;

  //               if (value == true) {
  //                 media.clear();
  //                 media.add('Any');
  //               } else {
  //                 media.clear();
  //               }
  //             } else {
  //               if (value == true) {
  //                 media.add(key);
  //               } else {
  //                 media.remove(key);
  //               }
  //               mediaValues[key] = value!;
  //             }

  //             _fetchFilteredData();
  //             observationsFetched = false;
  //             setState(() {});
  //           },
  //         );
  //       }).toList(),
  //     ),
  //   ),
  // ),

  // ListTile(
  //   title: Text(
  //     'Comments',
  //     style: Constants.header2,
  //   ),
  //   trailing: IconButton(
  //     icon: Icon(showComments
  //         ? Icons.keyboard_arrow_up
  //         : Icons.keyboard_arrow_down),
  //     onPressed: () {
  //       showComments = !showComments;
  //       setState(() {});
  //     },
  //   ),
  // ),
  // Visibility(
  //   visible: showComments,
  //   child: Container(
  //     height: commentsValues.length * 55.0,
  //     child: ListView(
  //       physics: NeverScrollableScrollPhysics(),
  //       children: commentsValues.keys.map((String key) {
  //         return new CheckboxListTile(
  //           title: new Text(key),
  //           value: commentsValues[key],
  //           onChanged: (bool? value) {
  //             if (value == true && disabledComment == false) {
  //               commentsValues[key] = value!;
  //               disabledComment = true;
  //               comments.clear();
  //               comments.add(key);
  //               observationsFetched = false;
  //               _fetchFilteredData();
  //             } else if (disabledComment == true && value == false) {
  //               commentsValues[key] = value!;
  //               disabledComment = false;
  //               comments.clear();
  //               observationsFetched = false;
  //               _fetchFilteredData();
  //             }

  //             setState(() {});
  //           },
  //         );
  //       }).toList(),
  //     ),
  //   ),
  // ),

  // ListTile(
  //   title: Text(
  //     'Links',
  //     style: Constants.header2,
  //   ),
  //   trailing: IconButton(
  //     icon: Icon(showLinks
  //         ? Icons.keyboard_arrow_up
  //         : Icons.keyboard_arrow_down),
  //     onPressed: () {
  //       showLinks = !showLinks;
  //       setState(() {});
  //     },
  //   ),
  // ),
  // Visibility(
  //   visible: showLinks,
  //   child: Container(
  //     height: linksValues.length * 55.0,
  //     child: ListView(
  //       physics: NeverScrollableScrollPhysics(),
  //       children: linksValues.keys.map((String key) {
  //         return new CheckboxListTile(
  //           title: new Text(key),
  //           value: linksValues[key],
  //           onChanged: (bool? value){
  //             if (value == true && disabledLink == false){
  //               linksValues[key] = value!;
  //               disabledLink = true;
  //               links.clear();
  //               links.add(key);
  //               observationsFetched = false;
  //               _fetchFilteredData();
  //             } else if (disabledLink == true && value == false) {
  //               linksValues[key] = value!;
  //               disabledLink = false;
  //               observationsFetched = false;
  //               links.clear();
  //               _fetchFilteredData();
  //             }
  //             setState(() {});
  //           },
  //         );
  //       }).toList(),
  //     ),
  //   ),
  // ),

  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;
  bool permission = true;
  bool permissionAdd = true;

  @override
  void initState() {
    _fetchCenters();

    super.initState();
  }

  Future<void> _fetchCenters() async {
    print('_fetchCenters');
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
        print('+++++++++++++success is in _fetchCenters+++++++++++++');
      } catch (e, s) {
        print('+++++++++++++error is in _fetchCenters+++++++++++++');
        print(e);
        print(s);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  Map<String, dynamic> buildFilterRequestMap() {
    List<String> authors = [];

    drawer_authorValues.forEach((key, value) {
      if (value == true) {
        authors.add(key);
      }
    });

    List<String> added = [];

    drawer_addedValues.forEach((key, value) {
      if (value == true) {
        if (key == 'Custom') {
          // For custom date, we need to check if dates are selected
          if (drawer_startDate != null && drawer_endDate != null) {
            added.add(key);
          }
        } else {
          added.add(key);
        }
      }
    });
    // Convert dates to proper format if they exist
    final fromDate = drawer_startDate != null
        ? DateFormat('yyyy-MM-dd').format(drawer_startDate!)
        : null;
    final toDate = drawer_endDate != null
        ? DateFormat('yyyy-MM-dd').format(drawer_endDate!)
        : null;
    // Build the request map
    final requestMap = <String, dynamic>{
      "userid": MyApp.LOGIN_ID_VALUE,
      'childs': drawer_childs.isNotEmpty ? drawer_childs : [],
      'authors': authors.isNotEmpty ? authors : [],
      'observations': drawer_observations.isNotEmpty ? drawer_observations : [],
      'added': added.isNotEmpty ? added : [],
      'centerid': centers[currentIndex].id
    };

    // Handle custom date case
    if (drawer_addedValues['Custom'] == true &&
        fromDate != null &&
        toDate != null) {
      requestMap['fromDate'] = fromDate;
      requestMap['toDate'] = toDate;
    } else {
      requestMap['fromDate'] = null;
      requestMap['toDate'] = null;
    }

    // Print for debugging (remove in production)
    print('Sending filter request:');
    print(requestMap);

    return requestMap;
  }

  Future<void> _fetchFilteredData() async {
    print('+++++enter in _fetchFilteredData+++++');
    // _allObservations.clear();

    // var b = {
    //   "userid": MyApp.LOGIN_ID_VALUE,
    //   "childs": childs,
    //   "authors": authors,
    //   // "assessments": assessments,
    //   "observations": observations,
    //   "added": added,
    //   // "media": media,
    //   // "comments": comments,
    //   // "links": links,
    // };
    var b = buildFilterRequestMap();
    print(jsonEncode(b));
    // return;
    final response = await http.post(
      Uri.parse(Constants.BASE_URL +
          "observation/getListFilterObservations/" +
          MyApp.LOGIN_ID_VALUE),
      headers: {
        'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
      },
      body: jsonEncode(b),
    );
    print(Constants.BASE_URL +
        "observation/getListFilterObservations/" +
        MyApp.LOGIN_ID_VALUE);
    print('this' + response.statusCode.toString());
    var data = jsonDecode(response.body);
    var res = data['observations'];
    print(res);
    if (res != null) {
      _allObservations = [];
      try {
        print('enter in loop of _fetchFilteredData');
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          print('index $i loop _fetchFilteredData');

          _allObservations.add(ObservationModel.fromJson(res[i]));
        }
        print('after loop done');
        observationsFetched = true;
        if (this.mounted) setState(() {});
        print('+++++++++++++success is in _fetchFilteredData+++++++++++++');
      } catch (e, s) {
        print('+++++++++++++error is in _fetchFilteredData+++++++++++++');
        print(e);
        print(s);
      }
    }
  }

  Future<void> _fetchData() async {
    print('++++++++++_fetchData++++++');
    ObservationsAPIHandler handler = ObservationsAPIHandler({});
    var data = await handler.getList(centers[currentIndex].id);
    print('trashshsh' + data.toString());
    print(data['observations']);
    print(data['permissions']);
    print(MyApp.USER_TYPE_VALUE);

    if (data['observations'] != null) {
      if (this.mounted) setState(() {});
    }
    observationsFetched = true;
    if (!data.containsKey('error')) {
      if ((data['permissions'] != null &&
              data['permissions']['addObservation'] == '1') ||
          MyApp.USER_TYPE_VALUE == 'Superadmin' ||
          MyApp.USER_TYPE_VALUE == 'Parent') {
        permissionAdd = true;
      } else {
        permissionAdd = false;
      }
      if ((data['permissions'] != null &&
              data['permissions']['viewAllObservation'] == '1') ||
          MyApp.USER_TYPE_VALUE == 'Superadmin' ||
          MyApp.USER_TYPE_VALUE == 'Parent') {
        var res = data['observations'];
        _allObservations = [];
        try {
          assert(res is List);
          for (int i = 0; i < res.length; i++) {
            _allObservations.add(ObservationModel.fromJson(res[i]));
          }
          observationsFetched = true;
          permission = true;
          if (this.mounted) setState(() {});
        } catch (e, s) {
          print('+++error in fetch data++++');
          print(s);
          print(e);
        }

        var child = data['childs'];
        print(child);
        _allChildrens = [];
        try {
          assert(child is List);
          for (int i = 0; i < child.length; i++) {
            _allChildrens.add(ChildModel.fromJson(child[i]));
            childValues[_allChildrens[i].id] = false;
          }
          childrensFetched = true;
          if (this.mounted) setState(() {});
        } catch (e) {
          print(e);
        }
      } else {
        permission = false;
      }
      setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: key,
        endDrawer: getEndDrawer(context),
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        floatingActionButton: floating(context),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: observationsFetched
                  ? Container(
                      child: Column(children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'Observation',
                              style: Constants.header1,
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            if (permission && MyApp.USER_TYPE_VALUE != 'Parent')
                              GestureDetector(
                                  onTap: () async {
                                    await initializeDrawerVariables();
                                    key.currentState?.openEndDrawer();
                                  },
                                  child: Icon(
                                    AntDesign.filter,
                                    color: Constants.kButton,
                                  )),
                            SizedBox(
                              width: 6,
                            ),
                            if (permissionAdd &&
                                MyApp.USER_TYPE_VALUE != 'Parent')
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChangeNotifierProvider(
                                                  create: (context) =>
                                                      Obsdata(),
                                                  child: AddObservation(
                                                    type: 'create',
                                                    data: null,
                                                    centerid:
                                                        centers[currentIndex]
                                                            .id,
                                                    selecChildrens: [],
                                                    media: [],
                                                    totaldata: {},
                                                  ))));
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Constants.kButton,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 8, 12, 8),
                                      child: Text(
                                        '+  Add',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )),
                              )
                          ],
                        ),

                        SizedBox(
                          height: 8,
                        ),
                        centersFetched
                            ? DropdownButtonHideUnderline(
                                child: Container(
                                  height: 30,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Constants.greyColor),
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Center(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: centers[currentIndex].id,
                                        items:
                                            centers.map((CentersModel value) {
                                          return new DropdownMenuItem<String>(
                                            value: value.id,
                                            child: new Text(value.centerName),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          for (int i = 0;
                                              i < centers.length;
                                              i++) {
                                            if (centers[i].id == value) {
                                              setState(() {
                                                currentIndex = i;

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
                          height: 8,
                        ),
                        if (observationsFetched &&
                            _allObservations.length > 0 &&
                            permission)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                              color: Colors.white,
                            ),
                            height: 40.0,
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                              decoration: new InputDecoration(
                                //  hintText: 'Search list data',
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 3.0),
                                border: new OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchString = value;
                                });
                              },
                            ),
                          ),

// ),
                        SizedBox(
                          height: 10,
                        ),
                        if (!permission)
                          Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "You don't have permission for this center")
                                ],
                              )),

                        if (observationsFetched &&
                            _allObservations.length == 0 &&
                            permission)
                          Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [Text('No Observations..')])),
                        if (observationsFetched &&
                            _allObservations.length > 0 &&
                            permission)
                          Container(
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _allObservations.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return _allObservations[index]
                                          .title
                                          .toLowerCase()
                                          .contains(searchString.toLowerCase())
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ViewObservation(
                                                        id: _allObservations[
                                                                index]
                                                            .id,
                                                        montCount:
                                                            _allObservations[
                                                                    index]
                                                                .montessoricount,
                                                        eylfCount:
                                                            _allObservations[
                                                                    index]
                                                                .eylfcount,
                                                        devCount: _allObservations[
                                                                index]
                                                            .milestonecount)));
                                          },
                                          child: Card(
                                            child: Container(
                                                // height: _allObservations[index]
                                                //             .observationsMedia ==
                                                //         'null'
                                                //     ? 160
                                                //     : 280,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.85,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 0, 8, 8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 8, 0, 8),
                                                        child: _allObservations[
                                                                        index]
                                                                    .title ==
                                                                null
                                                            ? null
                                                            : tagRemove(
                                                                _allObservations[
                                                                        index]
                                                                    .title,
                                                                maxLines: 5,
                                                                'heading',
                                                                centers[currentIndex]
                                                                    .id,
                                                                context),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Author:',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              Text(
                                                                _allObservations[index]
                                                                            .userName !=
                                                                        null
                                                                    ? _allObservations[
                                                                            index]
                                                                        .userName
                                                                        .toString()
                                                                    : '',
                                                                style: TextStyle(
                                                                    color: Constants
                                                                        .kMain,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Approved by:',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              Text(
                                                                _allObservations[index]
                                                                            .userName !=
                                                                        null
                                                                    ? _allObservations[
                                                                            index]
                                                                        .userName
                                                                        .toString()
                                                                    : '',
                                                                style: TextStyle(
                                                                    color: Constants
                                                                        .kMain,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Created on:',
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                          Builder(builder:
                                                              (context) {
                                                            try {
                                                              return Text(
                                                                _allObservations[index]
                                                                            .dateAdded !=
                                                                        null
                                                                    ? formatter.format(
                                                                        DateTime.parse(
                                                                            _allObservations[index].dateAdded))
                                                                    : '',
                                                                style: TextStyle(
                                                                    color: Constants
                                                                        .kMain,
                                                                    fontSize:
                                                                        12),
                                                              );
                                                            } catch (e) {
                                                              return Text(
                                                                  _allObservations[
                                                                          index]
                                                                      .dateAdded
                                                                      .toString());
                                                            }
                                                          }),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      _allObservations[index]
                                                                      .observationsMedia ==
                                                                  'null' ||
                                                              _allObservations[
                                                                          index]
                                                                      .observationsMedia ==
                                                                  ''
                                                          ? Text('')
                                                          : Builder(builder:
                                                              (context) {
                                                              try {
                                                                return Image
                                                                    .network(
                                                                  errorBuilder:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
                                                                    return Text(
                                                                        '');
                                                                  },
                                                                  Constants
                                                                          .ImageBaseUrl +
                                                                      _allObservations[
                                                                              index]
                                                                          .observationsMedia,
                                                                  height: 150,
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                );
                                                              } catch (e) {
                                                                return VideoItem(
                                                                    url: Constants
                                                                            .ImageBaseUrl +
                                                                        _allObservations[index]
                                                                            .observationsMedia);
                                                              }
                                                            }),
                                                      // _allObservations[
                                                      //                 index]
                                                      //             .observationsMediaType !=
                                                      //         'Video' ||  _allObservations[
                                                      //                 index]
                                                      //             .observationsMedia ==
                                                      //         'null'
                                                      //     ? Image.network(
                                                      //         Constants
                                                      //                 .ImageBaseUrl +
                                                      //             _allObservations[
                                                      //                     index]
                                                      //                 .observationsMedia,
                                                      //         height: 150,
                                                      //         width: MediaQuery.of(
                                                      //                 context)
                                                      //             .size
                                                      //             .width,
                                                      //         fit: BoxFit
                                                      //             .fill,
                                                      //       )
                                                      //     : VideoItem(
                                                      //         url: Constants
                                                      //                 .ImageBaseUrl +
                                                      //             _allObservations[
                                                      //                     index]
                                                      //                 .observationsMedia),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          _allObservations[
                                                                          index]
                                                                      .montessoricount !=
                                                                  null
                                                              ? Text(
                                                                  'Montessori: ' +
                                                                      _allObservations[
                                                                              index]
                                                                          .montessoricount +
                                                                      ' ',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Constants
                                                                        .kCount,
                                                                  ))
                                                              : SizedBox(),
                                                          _allObservations[
                                                                          index]
                                                                      .eylfcount !=
                                                                  null
                                                              ? Text(
                                                                  'EYLF: ' +
                                                                      _allObservations[
                                                                              index]
                                                                          .eylfcount,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Constants
                                                                        .kCount,
                                                                  ))
                                                              : SizedBox(),
                                                          Expanded(
                                                              child:
                                                                  SizedBox()),
                                                          _allObservations[
                                                                          index]
                                                                      .status ==
                                                                  'Published'
                                                              ? GestureDetector(
                                                                  onTap: () {
                                                                    // Navigator.push(context,MaterialPageRoute(
                                                                    //   builder: (context) =>AddObservation()));
                                                                  },
                                                                  child: Container(
                                                                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(8))),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets
                                                                            .fromLTRB(
                                                                            12,
                                                                            8,
                                                                            12,
                                                                            8),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.check,
                                                                              color: Colors.white,
                                                                              size: 14,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            Text(
                                                                              _allObservations[index].status != null ? _allObservations[index].status : '',
                                                                              style: TextStyle(color: Colors.white),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )),
                                                                )
                                                              : GestureDetector(
                                                                  onTap: () {
                                                                    // Navigator.push(context,MaterialPageRoute(
                                                                    //   builder: (context) =>AddObservation()));
                                                                  },
                                                                  child: Container(
                                                                      decoration: BoxDecoration(color: Color(0xffFFEFB8), borderRadius: BorderRadius.all(Radius.circular(8))),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets
                                                                            .fromLTRB(
                                                                            12,
                                                                            8,
                                                                            12,
                                                                            8),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.drafts,
                                                                              color: Color(0xffCC9D00),
                                                                              size: 14,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            Text(
                                                                              _allObservations[index].status != null ? _allObservations[index].status : '',
                                                                              style: TextStyle(color: Color(0xffCC9D00)),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )),
                                                                ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                )),
                                          ),
                                        )
                                      : Container();
                                }),
                          )
                      ]),
                    )
                  : Container(
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            height: 40,
                            width: 40,
                            child: Center(child: CircularProgressIndicator())),
                      ],
                    ))),
        ),
      ),
    );
  }
}

String textcustom() {
  return 'hbfdjhfjdhfjdhfjhfjhfjdhfjhfjhfjhfjhfjhfjjjjjjjjjN DH FHSD FHS DFH F HFH SDHFSUFD H UFHUFHUFHUFHU FHF HFH G FU FUF  F FF  HH FUFHUFHDU FHUF F  DHFUFHUEHURHUGF   F F jjj jjjj jjjj jjjjjjjjjjjjjjj    fdujfhudfh uf hu h eudf uch ufi hiufgayugf AFG F GAG DFAFESUYFG  FHF UFHUI FF   HF GDG  HFUFHH F F F FUHFDU FDHSUFHUDSFHUSHFU   HDSUFHSUGFUFGF';
}
