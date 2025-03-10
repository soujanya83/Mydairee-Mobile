import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/surveyapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/surveymodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/surveys/addsurvey.dart';
import 'package:mykronicle_mobile/surveys/saveSurvey.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:intl/intl.dart';

class SurveyList extends StatefulWidget {
  @override
  _SurveyListState createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  bool surveyFetched = false;
  List<SurveyModel> _survey=[];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    SurveyAPIHandler handler =
        SurveyAPIHandler({"userid": MyApp.LOGIN_ID_VALUE});
    var data = await handler.getList();
    if (!data.containsKey('error')) {
      print(data);
      var res = data['records'];
      _survey = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          _survey.add(SurveyModel.fromJson(res[i]));
        }
        surveyFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: surveyFetched
                    ? Container(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                'Survey',
                                style: Constants.header1,
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              if (MyApp.USER_TYPE_VALUE != 'Parent')
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddSurvey(type: 'add', id: '',)))
                                        .then((value) => _fetchData());
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
                                          'Add New',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      )),
                                )
                            ],
                          ),
                          if (surveyFetched)
                            Container(
                              height: MediaQuery.of(context).size.height * 0.75,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  itemCount:
                                      _survey != null ? _survey.length : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var inputFormat = DateFormat("yyyy-MM-dd");
                                    final DateFormat formatter =
                                        DateFormat('dd-MM-yyyy');

                                    var date1 = inputFormat
                                        .parse(_survey[index].createdAt);
                                    var date = formatter.format(date1);

                                    return Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 20.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.45,
                                                      child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        SaveSurvey(
                                                                          id: _survey[index]
                                                                              .id,
                                                                        )));
                                                          },
                                                          child: Text(
                                                            _survey[index]
                                                                        .title !=
                                                                    null
                                                                ? _survey[index]
                                                                    .title
                                                                : '',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Constants
                                                                    .kMain),
                                                          ))),
                                                  Expanded(
                                                    child: Container(),
                                                  ),
                                                  _survey[index]
                                                              .createdByName !=
                                                          null
                                                      ? Text('By: ' +
                                                          _survey[index]
                                                              .createdByName
                                                              .toString())
                                                      : Container(),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(date.toString()),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Container(),
                                                  ),
                                                  if (MyApp.USER_TYPE_VALUE !=
                                                      'Parent')
                                                    GestureDetector(
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Constants.kMain,
                                                        size: 18,
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => AddSurvey(
                                                                    type:
                                                                        'edit',
                                                                    id: _survey[
                                                                            index]
                                                                        .id)));
                                                      },
                                                    ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  if (MyApp.USER_TYPE_VALUE !=
                                                      'Parent')
                                                    GestureDetector(
                                                      child: Icon(
                                                        AntDesign.delete,
                                                        color: Constants.kMain,
                                                        size: 16,
                                                      ),
                                                      onTap: () {
                                                        showDeleteDialog(
                                                            context, () async {
                                                          SurveyAPIHandler
                                                              handler =
                                                              SurveyAPIHandler({
                                                            "userid": MyApp
                                                                .LOGIN_ID_VALUE,
                                                            "id": _survey[index]
                                                                .id,
                                                          });
                                                          var data = await handler
                                                              .deleteListItem();
                                                          print('heyys' +
                                                              data.toString());
                                                          if (!data.containsKey(
                                                              'error')) {
                                                            surveyFetched =
                                                                false;
                                                            _fetchData();
                                                            setState(() {});
                                                          }
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      },
                                                    ),
                                                  //                                  Container(
                                                  //                         decoration: BoxDecoration(
                                                  //             //  color: _survey[index].status=='Sent'?Colors.green:Color(0xffFFEFB8),
                                                  //               borderRadius: BorderRadius.all(Radius.circular(8))
                                                  //             ),
                                                  //             child:Padding(
                                                  //               padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                                                  //  //             child:   Text(_announcements[index].status,style: TextStyle(color: _announcements[index].status=='Sent'?Colors.white:Color(0xffCC9D00)),),
                                                  //             )
                                                  //           )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            )
                        ],
                      ))
                    : Container())));
  }
}
