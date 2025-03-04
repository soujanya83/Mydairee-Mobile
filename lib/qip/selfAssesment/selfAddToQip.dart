import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/areamodel.dart';
import 'package:mykronicle_mobile/models/qiplistmodel.dart';
import 'package:mykronicle_mobile/models/standardsmodel.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class SelfAddToQip extends StatefulWidget {
  final String centerid;
  final String notes;

  SelfAddToQip(this.centerid, this.notes);

  @override
  _SelfAddToQipState createState() => _SelfAddToQipState();
}

class _SelfAddToQipState extends State<SelfAddToQip> {
  int selectedQipIndex;
  List<QipListModel> _allQips = [];
  bool viewList = true;
  List<AreaModel> areas = [];
  int areaIndex = 0;
  int standardIndex = 0;
  int elementIndex = 0;
  List<StandardsModel> standards = [];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  void updateStandards() async {
    var _objToSend = {
      "areaid": areas[areaIndex].id,
      "userid": MyApp.LOGIN_ID_VALUE,
      "qipid": _allQips[selectedQipIndex].id
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

  void _load() async {
    QipAPIHandler qipAPIHandler = QipAPIHandler({});
    var data = await qipAPIHandler.getQipAreas(
        widget.centerid, _allQips[selectedQipIndex].id);
    var area = data['areas'];
    areas = [];
    try {
      assert(area is List);
      for (int i = 0; i < area.length; i++) {
        areas.add(AreaModel.fromJson(area[i]));
      }
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }
    updateStandards();
    setState(() {});
  }

  void _fetchData() async {
    QipAPIHandler handler = QipAPIHandler({});
    var data = await handler.getList(widget.centerid);
    if (!data.containsKey('error')) {
      print(data);

      var res = data['qips'];

      _allQips = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          _allQips.add(QipListModel.fromJson(res[i]));
        }
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
      setState(() {});
    } else {
      MyApp.Show401Dialog(context);
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
                viewList
                    ? Container(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _allQips.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                    onTap: () {
                                      viewList = false;
                                      selectedQipIndex = index;
                                      _load();
                                      setState(() {});
                                    },
                                    title: Text(_allQips[index].name),
                                    trailing: Icon(Icons.arrow_forward_ios)),
                              );
                            }),
                      )
                    : Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                                onPressed: () {
                                  viewList = true;
                                  setState(() {});
                                },
                                child: Text("Back to Qips")),
                            if (areas != null && areas.length > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 3.0, right: 3, bottom: 3),
                                child: DropdownButtonHideUnderline(
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Constants.greyColor),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Center(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: areas[areaIndex].id,
                                          items: areas.map((AreaModel value) {
                                            return new DropdownMenuItem<String>(
                                              value: value.id,
                                              child: new Text(value.title),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            for (int i = 0;
                                                i < areas.length;
                                                i++) {
                                              if (areas[i].id == value) {
                                                setState(() {
                                                  areaIndex = i;
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
                            if (standards != null && standards.length > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 3.0, right: 3, bottom: 3),
                                child: DropdownButtonHideUnderline(
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Constants.greyColor),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Center(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: standards[standardIndex].id,
                                          items: standards
                                              .map((StandardsModel value) {
                                            return new DropdownMenuItem<String>(
                                              value: value.id,
                                              child: new Text(value.name),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            for (int i = 0;
                                                i < standards.length;
                                                i++) {
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
                            if (standards != null &&
                                standards.length > 0 &&
                                standards[standardIndex].elements != null &&
                                standards[standardIndex].elements.length > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 3.0, right: 3, bottom: 3),
                                child: DropdownButtonHideUnderline(
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Constants.greyColor),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Center(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: standards[standardIndex]
                                              .elements[elementIndex]
                                              .id,
                                          items: standards[standardIndex]
                                              .elements
                                              .map(
                                                  (StandardElementModel value) {
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
                                              if (standards[standardIndex]
                                                      .elements[i]
                                                      .id ==
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
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        var _objToSend = {
                                          "qipid":
                                              _allQips[selectedQipIndex].id,
                                          "areaid": areas[areaIndex].id,
                                          "elementid": standards[standardIndex]
                                              .elements[elementIndex]
                                              .id,
                                          "pronotes": widget.notes,
                                          "userid": MyApp.LOGIN_ID_VALUE
                                        };
                                        QipAPIHandler qipAPIHandler =
                                            QipAPIHandler(_objToSend);
                                        var data =
                                            await qipAPIHandler.saveProgress();
                                        if (data['Status'] == 'SUCCESS') {
                                          MyApp.ShowToast(
                                              'Updated Sucessfully', context);
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text("Save"))
                                ],
                              ),
                            )
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
