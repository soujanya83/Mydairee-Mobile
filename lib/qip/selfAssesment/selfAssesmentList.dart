import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/assesmentmodel.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/qip/selfAssesment/viewAssesment.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class SelfAssesment extends StatefulWidget {
  @override
  _SelfAssesmentState createState() => _SelfAssesmentState();
}

class _SelfAssesmentState extends State<SelfAssesment> {
  List<AssesmentModel> assesments = [];
  bool assesmentsFetched = false;

  List<CentersModel> centers;
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

  void _fetchData() async {
    var _objToSend = {
      "centerid": centers[currentIndex].id,
      "userid": MyApp.LOGIN_ID_VALUE
    };
    QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
    var data = await qipAPIHandler.getSelfAssesmentList();
    var res = data['Records'];
    assesments = [];
    try {
      assert(res is List);
      for (int i = 0; i < res.length; i++) {
        assesments.add(AssesmentModel.fromJson(res[i]));
      }
      assesmentsFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Self Assesment',
                    style: Constants.header2,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var _objToSend = {
                        "centerid": centers[currentIndex].id,
                        "userid": MyApp.LOGIN_ID_VALUE
                      };
                      QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
                      await qipAPIHandler
                          .addSelfAsses()
                          .then((value) => _fetchData());
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Constants.kButton,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Text(
                            '+  Add Self Assesment',
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
                                  // qipsFetched = false;
                                  // _fetchData();
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
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: assesments.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewAssesment(assesments[index])));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(assesments[index].name),
                              Row(
                                children: [
                                  if (assesments[index].educators.length > 0)
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(assesments[
                                                      index]
                                                  .educators[0]['imageUrl'] !=
                                              ""
                                          ? Constants.ImageBaseUrl +
                                              assesments[index].educators[0]
                                                  ['imageUrl']
                                          : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                                    ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  if (assesments[index].educators.length - 1 >
                                      0)
                                    CircleAvatar(
                                      backgroundColor: Constants.greyColor,
                                      child: Text("+" +
                                          (assesments[index].educators.length -
                                                  1)
                                              .toString()),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
      )),
    );
  }
}
