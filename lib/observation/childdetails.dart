import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/menuMediaModel.dart';
import 'package:mykronicle_mobile/models/observationmodel.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/observation/viewobservation.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';

class ChildDetails extends StatefulWidget {
  final String centerId;
  final String childId;

  ChildDetails({required this.centerId, required this.childId});

  @override
  _ChildDetailsState createState() => _ChildDetailsState();
}

class _ChildDetailsState extends State<ChildDetails> {
List<CentersModel> centers = [];
bool centersFetched = false;
int currentIndex = 0;
int childCurrentIndex = 0;
List<ChildModel> _allChildrens = [];
List<UserModel> _allRelatives = [];
List<MenuMediaModel> menuMedia = [];
List<ObservationModel> _allObservations = [];


  bool dataFetched = false;
  bool childrensFetched = false;

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
          if (widget.centerId == res[i]['id']) {
            currentIndex = i;
          }
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

    _fetchChildData();
  }

  Future<void> _fetchChildData() async {
    print('changed');
    UtilsAPIHandler handlerX = UtilsAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var dataX = await handlerX.getChildrens();
    if (!dataX.containsKey('error')) {
      var child = dataX['ChildList'];
      _allChildrens = [];
      try {
        assert(child is List);
        for (int i = 0; i < child.length; i++) {
          _allChildrens.add(ChildModel.fromJson(child[i]));
          if (widget.childId == child[i]['childid']) {
            childCurrentIndex = i;
          }
        }
        childrensFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }

      _fetchData();
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  Future<void> _fetchData() async {
    print(_allChildrens);
    if (_allChildrens.length > 0) {
      UtilsAPIHandler handler = UtilsAPIHandler({
        "userid": MyApp.LOGIN_ID_VALUE,
        "page": 1,
        "sort": "DESC",
        "childid": _allChildrens[childCurrentIndex].childid
      });
      var data = await handler.getChildDetails();
      if (!data.containsKey('error')) {
        var relative = data['Relatives'];
        var res = data['Observations'];
        _allRelatives = [];
        _allObservations = [];
        try {
          assert(relative is List);
          for (int i = 0; i < relative.length; i++) {
            _allRelatives.add(UserModel.fromJson(relative[i]));
          }
          menuMedia = [];
          assert(data['Media'] is List);
          for (int i = 0; i < data['Media'].length; i++) {
            menuMedia.add(MenuMediaModel.fromJson(data['Media'][i]));
          }
          assert(res is List);
          for (int i = 0; i < res.length; i++) {
            _allObservations.add(ObservationModel.fromJson(res[i]));
          }
          dataFetched = true;
          if (this.mounted) setState(() {});
        } catch (e) {
          print(e);
        }
      } else {
        MyApp.Show401Dialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
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
                                  childrensFetched = false;
                                  dataFetched = false;
                                  _fetchChildData();
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
              if (childrensFetched && _allChildrens.length > 0)
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
                          value: _allChildrens[childCurrentIndex].childid,
                          items: _allChildrens.map((ChildModel value) {
                            return new DropdownMenuItem<String>(
                              value: value.childid,
                              child: new Text(value.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            for (int i = 0; i < _allChildrens.length; i++) {
                              if (_allChildrens[i].childid == value) {
                                setState(() {
                                  childCurrentIndex = i;
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
              if (childrensFetched && _allChildrens.length > 0)
                userCard(childCurrentIndex),
              if (dataFetched && _allChildrens.length > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_allRelatives.length > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          " Relatives ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    relativeCard(),
                    if (menuMedia.length > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          " Media ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (menuMedia.length > 0)
                      Center(
                        child: Card(
                          child: Container(
                            height: 180,
                            child: CarouselSlider(
                                options: CarouselOptions(
                                    height: 150,
                                    autoPlay: true,
                                    enlargeCenterPage: true),
                                items: List.generate(
                                  menuMedia.length,
                                  (index) => menuMedia[index].type == 'Image'
                                      ? MyImageView(menuMedia[index].filename)
                                      : VideoItem(
                                          url: Constants.ImageBaseUrl +
                                              menuMedia[index].filename),
                                )),
                          ),
                        ),
                      ),
                    Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _allObservations.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewObservation(
                                              id: _allObservations[index].id,
                                              montCount: _allObservations[index].montessoricount,
                                              eylfCount: _allObservations[index].eylfcount,
                                              devCount:_allObservations[index].milestonecount
                                            )));
                              },
                              child: Card(
                                child: Container(
                                    height: _allObservations[index]
                                                .observationsMedia ==
                                            'null'
                                        ? 160
                                        : 280,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 8, 0, 8),
                                            child: Text(
                                              _allObservations[index].title !=
                                                      null
                                                  ? _allObservations[index]
                                                      .title
                                                  : '',
                                              style: Constants.header3,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Author:',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  Text(
                                                    _allObservations[index]
                                                                .approverName !=
                                                            null
                                                        ? _allObservations[
                                                                index]
                                                            .approverName
                                                        : '',
                                                    style: TextStyle(
                                                        color: Constants.kMain,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Approved by:',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  Text(
                                                    _allObservations[index]
                                                                .approverName !=
                                                            null
                                                        ? _allObservations[
                                                                index]
                                                            .approverName
                                                        : '',
                                                    style: TextStyle(
                                                        color: Constants.kMain,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          _allObservations[index]
                                                      .observationsMedia ==
                                                  'null'
                                              ? Text('')
                                              : _allObservations[index]
                                                          .observationsMediaType ==
                                                      'Image'
                                                  ? Image.network(
                                                      Constants.ImageBaseUrl +
                                                          _allObservations[
                                                                  index]
                                                              .observationsMedia,
                                                      height: 130,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      fit: BoxFit.fill,
                                                    )
                                                  : VideoItem(
                                                      url: Constants
                                                              .ImageBaseUrl +
                                                          _allObservations[
                                                                  index]
                                                              .observationsMedia, height: null,),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              _allObservations[index]
                                                          .montessoricount !=
                                                      null
                                                  ? Text(
                                                      'Montessori: ' +
                                                          _allObservations[
                                                                  index]
                                                              .montessoricount +
                                                          ' ',
                                                      style: TextStyle(
                                                        color: Constants.kCount,
                                                      ))
                                                  : SizedBox(),
                                              _allObservations[index]
                                                          .eylfcount !=
                                                      null
                                                  ? Text(
                                                      'EYLF: ' +
                                                          _allObservations[
                                                                  index]
                                                              .eylfcount,
                                                      style: TextStyle(
                                                        color: Constants.kCount,
                                                      ))
                                                  : SizedBox(),
                                              Expanded(child: SizedBox()),
                                              _allObservations[index].status ==
                                                      'Published'
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        // Navigator.push(context,MaterialPageRoute(
                                                        //   builder: (context) =>AddObservation()));
                                                      },
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.green,
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          8))),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    12,
                                                                    8,
                                                                    12,
                                                                    8),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 14,
                                                                ),
                                                                SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  _allObservations[index]
                                                                              .status !=
                                                                          null
                                                                      ? _allObservations[
                                                                              index]
                                                                          .status
                                                                      : '',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
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
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0xffFFEFB8),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          8))),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    12,
                                                                    8,
                                                                    12,
                                                                    8),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.drafts,
                                                                  color: Color(
                                                                      0xffCC9D00),
                                                                  size: 14,
                                                                ),
                                                                SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  _allObservations[index]
                                                                              .status !=
                                                                          null
                                                                      ? _allObservations[
                                                                              index]
                                                                          .status
                                                                      : '',
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xffCC9D00)),
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
                            );
                          }),
                    )
                  ],
                ),
            ],
          ),
        ),
      )),
    );
  }

  Widget relativeCard() {
    return Card(
      child: Container(
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _allRelatives.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                  Constants.ImageBaseUrl +
                                      _allRelatives[index].imageUrl)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Text(_allRelatives[index].name,
                                style: Constants.cardHeadingStyle),
                            Text(_allRelatives[index].relation)
                          ],
                        )
                      ],
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget userCard(int index) {
    return Card(
      child: Container(
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(Constants.ImageBaseUrl +
                          _allChildrens[index].imageUrl)),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(_allChildrens[index].name,
                        style: Constants.cardHeadingStyle),
                    Text(_allChildrens[index].gender??''),
                    Text(_allChildrens[index].status??''),
                    Text(_allChildrens[index].dob??'')
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MyImageView extends StatelessWidget {
  String imgPath;

  MyImageView(this.imgPath);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: FittedBox(
          fit: BoxFit.fill,
          child: Image.network(Constants.ImageBaseUrl + imgPath),
        ));
  }
}
