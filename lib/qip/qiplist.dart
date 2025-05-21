import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/qiplistmodel.dart';
import 'package:mykronicle_mobile/qip/editqip.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class QipList extends StatefulWidget {
  @override
  _QipListState createState() => _QipListState();
}

class _QipListState extends State<QipList> {
  bool qipsFetched = false;
  List<QipListModel> _allQips = [];

  bool permission = true;
  bool permissionAdd = true;
  bool permissionDel = true;
  bool permissionEd = true;

  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;

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
      //MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  Future<void> _fetchData() async {
    QipAPIHandler handler = QipAPIHandler({});
    var data = await handler.getList(centers[currentIndex].id);
    print('==========response==============');
    debugPrint(data.toString());
    if (!data.containsKey('error')) {
      print(data);
      if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
          MyApp.USER_TYPE_VALUE == 'Staff' ||
          data['permissions'] != null) {
        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            (data['permissions'] != null &&
                data['permissions']['addQIP'] == '1')) {
          permissionAdd = true;
        } else {
          permissionAdd = false;
        }

        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            MyApp.USER_TYPE_VALUE == 'Staff' ||
            data['permissions']['deleteQIP'] == '1') {
          permissionDel = true;
        } else {
          permissionDel = false;
        }

        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            MyApp.USER_TYPE_VALUE == 'Staff' ||
            data['permissions']['editQIP'] == '1') {
          permissionEd = true;
        } else {
          permissionEd = false;
        }

        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            MyApp.USER_TYPE_VALUE == 'Staff' ||
            data['permissions']['viewQip'] == '1') {
          var res = data['qips'];

          _allQips = [];
          try {
            assert(res is List);
            for (int i = 0; i < res.length; i++) {
              _allQips.add(QipListModel.fromJson(res[i]));
            }
            qipsFetched = true;
            permission = true;
            if (this.mounted) setState(() {});
          } catch (e) {
            print(e);
          }
        } else {
          permission = false;
        }
      } else {
        permission = false;
        permissionAdd = false;
        permissionDel = false;
        permissionEd = false;
      }
      setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floating(context),
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
            child: Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quality Improvement Plan',
                style: Constants.header2,
              ),
              if (permissionAdd)
                GestureDetector(
                  onTap: () async {
                    var _objToSend = {
                      "centerid": centers[currentIndex].id,
                      "userid": MyApp.LOGIN_ID_VALUE
                    };
                    QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
                    await qipAPIHandler.addQip().then((value) => _fetchData());
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Constants.kButton,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Text(
                          '+  Generate QIP',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )),
                )
            ],
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
                              qipsFetched = false;
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
          if (!qipsFetched && permission)
            Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Loading...')],
                )),
          if (!permission)
            Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("You don't have permission for this center")],
                )),
          if (qipsFetched && _allQips.length == 0 && permission)
            Container(
                child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Center(
                    child: SizedBox(
                        height: 100.0, child: Image.asset(Constants.FILE))),
                Text('No QIP is generated at')
              ],
            )),
          if (qipsFetched && _allQips.length > 0 && permission)
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text('QIP / ' + _allQips[index].name),
                        trailing: Container(
                          width: 60,
                          child: Row(
                            children: [
                              if (permissionDel)
                                GestureDetector(
                                  child: Icon(
                                    AntDesign.delete,
                                    color: Constants.kMain,
                                  ),
                                  onTap: () async {
                                    showDeleteDialog(context, () async {
                                      QipAPIHandler handler = QipAPIHandler({
                                        "userid": MyApp.LOGIN_ID_VALUE,
                                        "id": _allQips[index].id,
                                      });
                                      var data = await handler.deleteListItem();
                                      print('===================');
                                      print(data);
                                      if (data['error'] != null) {
                                        MyApp.ShowToast(
                                            data['error'].toString(), context);
                                      } else {
                                        MyApp.ShowToast(
                                            'Deleted Successfully!'.toString(),
                                            context);
                                        qipsFetched = false;
                                        _fetchData();
                                        setState(() {});
                                      }

                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              SizedBox(
                                width: 10,
                              ),
                              if (permissionEd)
                                GestureDetector(
                                  child: Icon(
                                    AntDesign.eyeo,
                                    color: Constants.kMain,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditQip(
                                                  centers[currentIndex].id,
                                                  _allQips[index].id,
                                                )));

                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => NewQip(
                                    //               view: 'edit',
                                    //               qipid: _allQips[index].id,
                                    //               centerid:
                                    //                   centers[currentIndex].id,
                                    //             )));
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: _allQips.length,
              ),
            ),
        ])),
      )),
    );
  }
}
