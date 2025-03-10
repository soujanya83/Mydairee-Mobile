import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart'; 
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/areamodel.dart';
import 'package:mykronicle_mobile/qip/standards.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class EditQip extends StatefulWidget {
  final String centerid;
  final String qipid; 
  EditQip(this.centerid, this.qipid);
  @override
  _EditQipState createState() => _EditQipState();
}

class _EditQipState extends State<EditQip> {
  TextEditingController name = TextEditingController();
  bool readOnly = true;
  List<AreaModel> areas = [];
  bool areasFetched = false;
  int currentIndex = 0;
  List<Color?> colors = [
    Colors.yellow[300],
    Colors.orange[300],
    Colors.red[300],
    Colors.green[300],
    Colors.blue[300],
    Colors.deepPurple[100],
    Colors.pink[300]
  ];
  double total = 0.0;

  @override
  void initState() {
    _load();
    super.initState();
  }

  void _load() async {
    QipAPIHandler qipAPIHandler = QipAPIHandler({});
    var data = await qipAPIHandler.getQipAreas(widget.centerid, widget.qipid);
    print(data['name']);
    name.text = data['name'];
    var area = data['areas'];
    areas = [];
    try {
      assert(area is List);
      for (int i = 0; i < area.length; i++) {
        areas.add(AreaModel.fromJson(area[i]));
        total = total + areas[i].resultPer;
      }
      total = total / areas.length;
      areasFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }
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
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Edit Qip',
                  style: Constants.header1,
                ),
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: size.width - 120,
                            child: TextField(
                              readOnly: readOnly,
                              controller: name,
                              // style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          readOnly
                              ? IconButton(
                                  onPressed: () {
                                    readOnly = false;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ))
                              : IconButton(
                                  onPressed: () async {
                                    var objToSend = {
                                      "userid": MyApp.LOGIN_ID_VALUE,
                                      "name": name.text,
                                      "id": widget.qipid
                                    };
                                    QipAPIHandler qipAPIHandler =
                                        QipAPIHandler(objToSend);
                                    var data = await qipAPIHandler.renameQip();
                                    print(data);
                                    readOnly = true;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.grey,
                                  ))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text('Progress'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: LinearProgressIndicator(
                          backgroundColor: Constants.greyColor,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Constants.kMain),
                          value: total,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              if (areas != null)
                ListView.builder(
                    itemCount: areas.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          children: [
                            Container(
                              color: colors[index],
                              height: 100,
                              width: size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Quality Area " + (index + 1).toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                      child: LinearProgressIndicator(
                                        backgroundColor: Constants.greyColor,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Constants.kMain),
                                        value: areas[index].resultPer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8),
                              child: SizedBox(
                                width: size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        width: size.width * 0.75,
                                        child: Text(areas[index].title)),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Standards(
                                                    areas,
                                                    index,
                                                    widget.qipid,
                                                    widget.centerid)));
                                      },
                                      icon: Icon(
                                        FontAwesome.mail_forward,
                                        size: 16,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    })
              // Container(
              //   width: size.width,
              //   height: 200,
              //   margin: EdgeInsets.all(10),
              //   padding: EdgeInsets.all(5),
              //   child: Text(''),
              //   decoration: BoxDecoration(
              //       color: Colors.yellow[200],
              //       border: Border.all(
              //         color: Colors.green,
              //         width: 20,
              //       )),
              // ),
            ],
          ),
        ),
      )),
    );
  }
}
