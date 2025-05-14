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

  bool dataFetched = false;

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
    if (this.mounted)
      setState(() {
        dataFetched = true;
      });
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
                  if (MyApp.USER_TYPE_VALUE == 'Superadmin')
                    GestureDetector(
                      onTap: () async {
                        print(centers[currentIndex].id);
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Text(
                              '+  Add Self Assesment',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
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
                            if (this.mounted)
                              setState(() {
                                dataFetched = false;
                              });
                            for (int i = 0; i < centers.length; i++) {
                              if (centers[i].id == value) {
                                setState(() {
                                  currentIndex = i;
                                  // qipsFetched = false;
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
              !dataFetched
                  ? Container(
                      height: MediaQuery.of(context).size.height * .7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: 40,
                              width: 40,
                              child:
                                  Center(child: CircularProgressIndicator())),
                        ],
                      ))
                  : assesments.isEmpty
                      ? Container(
                          height: MediaQuery.of(context).size.height * .7,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  child:
                                      Text('Self assessments list is empty!')),
                            ],
                          ))
                      : ListView.builder(
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
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  shadowColor: Colors.blueGrey.withOpacity(0.1),
  margin: EdgeInsets.symmetric(vertical: 8),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.95),
          Colors.grey[50]!.withOpacity(0.95),
        ],
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              assesments[index].name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 12),
          if (assesments[index].educators.length > 0)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            padding: EdgeInsets.all(4),
            child: Row(
              children: [
                if (assesments[index].educators.length > 0)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        assesments[index].educators[0]['imageUrl'] != ""
                            ? Constants.ImageBaseUrl + 
                                assesments[index].educators[0]['imageUrl']
                            : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png',
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                if (assesments[index].educators.length > 1) ...[
                  SizedBox(width: 6),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey[100],
                      child: Text(
                        "+${assesments[index].educators.length - 1}",
                        style: TextStyle(
                          color: Colors.blueGrey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
