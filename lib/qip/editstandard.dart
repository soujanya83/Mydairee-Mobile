import 'package:flutter/material.dart';
import 'package:html_editor/html_editor.dart';
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/areamodel.dart';
import 'package:mykronicle_mobile/models/standardsmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class EditStandard extends StatefulWidget {
  final List<AreaModel> areas;
  final int choosenStandardIndex;
  final int choosenAreaIndex;
  final List<StandardsModel> standards;
  final String qipId;
  EditStandard(this.areas, this.choosenStandardIndex, this.choosenAreaIndex,
      this.standards,this.qipId);

  @override
  _EditStandardState createState() => _EditStandardState();
}

class _EditStandardState extends State<EditStandard> {
  int areIndex;
  int standardIndex;
  var standardData;
  GlobalKey<HtmlEditorState> keyEditor1;
  GlobalKey<HtmlEditorState> keyEditor2;
  GlobalKey<HtmlEditorState> keyEditor3;
  List<StandardsModel> standards;

  String textData1 = '';
  String textData2 = '';
  String textData3 = '';

  @override
  void initState() {
    standards = widget.standards;
    keyEditor1 = GlobalKey();
    keyEditor2 = GlobalKey();
    keyEditor3 = GlobalKey();
    areIndex = widget.choosenAreaIndex;
    standardIndex = widget.choosenStandardIndex;
    _load();
    super.initState();
  }

  void updateStandards() async {
    var _objToSend = {
      "areaid": widget.areas[areIndex].id,
      "userid": MyApp.LOGIN_ID_VALUE,
      "qipid":widget.qipId
    };

    QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
    var data = await qipAPIHandler.getAreaStandards();
    print(data);
    var standardsData = data['AreaStd'];
    standards = [];
    try {
      assert(standardsData is List);
      for (int i = 0; i < standardsData.length; i++) {
        StandardsModel standardsModel =
            StandardsModel.fromJson(standardsData[i]);
        standards.add(standardsModel);
      }
      _load();
    } catch (e) {
      print(e);
    }
  }

  void _load() async {
    var _objToSend = {
      "stdid": standards[standardIndex].id,
      "userid": MyApp.LOGIN_ID_VALUE,
      "qipid":widget.qipId
    };

    QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
    var data = await qipAPIHandler.getStandardDetails();
    print(data);
    if (data['Standard'] != null) {
      standardData = data['Standard'];
      textData1 = standardData['val1'];
      textData2 = standardData['val2'];
      textData3 = standardData['val3'];
    } else {
      standardData = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Edit Standard Values',
                  style: Constants.header1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3.0, right: 3, bottom: 3),
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
                          value: widget.areas[areIndex].id,
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
                                  areIndex = i;
                                });
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
              if (standardData != null)
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
              if (standardData != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        standardData['name'] + ' - ' + standardData['about'],
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      Text('1. Practice is embedded in service operations'),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: textData1 != ''
                            ? HtmlEditor(
                                key: keyEditor1,
                                value: textData1,
                                showBottomToolbar: false,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              )
                            : HtmlEditor(
                                showBottomToolbar: false,
                                key: keyEditor1,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('2. Practice is informed by critical reflection'),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: textData2 != ''
                            ? HtmlEditor(
                                showBottomToolbar: false,
                                key: keyEditor2,
                                value: textData2,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              )
                            : HtmlEditor(
                                showBottomToolbar: false,
                                key: keyEditor2,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          '3. Practice is shaped by meaningful engagement with families, and/or community'),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: textData3 != ''
                            ? HtmlEditor(
                                showBottomToolbar: false,
                                key: keyEditor3,
                                value: textData3,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              )
                            : HtmlEditor(
                                showBottomToolbar: false,
                                key: keyEditor3,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                      ),
                    ],
                  ),
                ),
              if (standardData != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final txt1 = await keyEditor1.currentState.getText();
                          String s1 = txt1;
                          final txt2 = await keyEditor2.currentState.getText();
                          String s2 = txt2;
                          final txt3 = await keyEditor3.currentState.getText();
                          String s3 = txt3;

                          var _objToSend = {
                            "stdid": standards[standardIndex].id,
                            "val1": s1,
                            "val2": s2,
                            "val3": s3,
                            "userid": MyApp.LOGIN_ID_VALUE,
                             "qipid":widget.qipId,
                          };
                          QipAPIHandler qipAPIHandler =
                              QipAPIHandler(_objToSend);
                          var data =
                              await qipAPIHandler.updateStandardDetails();
                          print(data);
                          if (data['Status'] == 'SUCCESS') {
                            MyApp.ShowToast('Updated Sucessfully', context);
                             RestartWidget.restartApp(context);
                          }
                        },
                        child: Text('Update Now'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Constants.kMain)),
                      )
                    ],
                  ),
                )
            ],
          ),
        ),
      )),
    );
  }
}
