import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/serviceapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class SaveService extends StatefulWidget {
  @override
  _SaveServiceState createState() => _SaveServiceState();
}

class _SaveServiceState extends State<SaveService> {
  TextEditingController sname,
      snumber,
      phstreet,
      phsuburb,
      phstate,
      phpostcode,
      ptelephone,
      pfax,
      pemail,
      pmobile,
      acontact,
      atelephone,
      amobile,
      afax,
      aemail,
      nname,
      ntelephone,
      nfax,
      nemail,
      nmobile,
      postreet,
      posuburb,
      postate,
      popostcode,
      summary,
      how,
      write,
      family,
      insert,
      ename,
      etelephone,
      eemail;

  List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;

  @override
  void initState() {
    sname = TextEditingController();
    snumber = TextEditingController();
    phstreet = TextEditingController();
    phsuburb = TextEditingController();
    phstate = TextEditingController();
    phpostcode = TextEditingController();

    ptelephone = TextEditingController();
    pfax = TextEditingController();
    pemail = TextEditingController();
    pmobile = TextEditingController();

    atelephone = TextEditingController();
    afax = TextEditingController();
    acontact = TextEditingController();
    amobile = TextEditingController();
    aemail = TextEditingController();

    nname = TextEditingController();
    ntelephone = TextEditingController();
    nfax = TextEditingController();
    nemail = TextEditingController();
    nmobile = TextEditingController();

    postreet = TextEditingController();
    posuburb = TextEditingController();
    postate = TextEditingController();
    popostcode = TextEditingController();

    ename = TextEditingController();
    etelephone = TextEditingController();
    eemail = TextEditingController();

    summary = TextEditingController();
    how = TextEditingController();
    write = TextEditingController();
    family = TextEditingController();
    insert = TextEditingController();
    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    print(dt);
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
      _fetchData();
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  Future<void> _fetchData() async {
    ServiceAPIHandler handler = ServiceAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var data = await handler.getServiceDetails();
    if (!data.containsKey('error') && data['ServiceDetails'] != null) {
      // checkValues.clear();
      print(data);
      //  var  = data['rooms'];
      sname.text = data['ServiceDetails']['serviceName'];
      snumber.text = data['ServiceDetails']['serviceApprovalNumber'];
      phstreet.text = data['ServiceDetails']['serviceStreet'];
      phsuburb.text = data['ServiceDetails']['serviceSuburb'];
      phstate.text = data['ServiceDetails']['serviceState'];
      phpostcode.text = data['ServiceDetails']['servicePostcode'];

      ptelephone.text = data['ServiceDetails']['contactTelephone'];
      pfax.text = data['ServiceDetails']['contactFax'];
      pemail.text = data['ServiceDetails']['contactEmail'];
      pmobile.text = data['ServiceDetails']['contactMobile'];

      atelephone.text = data['ServiceDetails']['providerTelephone'];
      afax.text = data['ServiceDetails']['providerFax'];
      acontact.text = data['ServiceDetails']['providerContact'];
      amobile.text = data['ServiceDetails']['providerMobile'];
      aemail.text = data['ServiceDetails']['providerEmail'];

      nname.text = data['ServiceDetails']['supervisorName'];
      ntelephone.text = data['ServiceDetails']['supervisorTelephone'];
      nfax.text = data['ServiceDetails']['supervisorFax'];
      nemail.text = data['ServiceDetails']['serviceApprovalNumber'];
      nmobile.text = data['ServiceDetails']['supervisorMobile'];

      postreet.text = data['ServiceDetails']['postalStreet'];
      posuburb.text = data['ServiceDetails']['postalSuburb'];
      postate.text = data['ServiceDetails']['postalState'];
      popostcode.text = data['ServiceDetails']['postalPostcode'];

      ename.text = data['ServiceDetails']['eduLeaderName'];
      etelephone.text = data['ServiceDetails']['eduLeaderTelephone'];
      eemail.text = data['ServiceDetails']['eduLeaderEmail'];

      summary.text = data['ServiceDetails']['strengthSummary'];
      how.text = data['ServiceDetails']['childGroupService'];
      write.text = data['ServiceDetails']['personSubmittingQip'];
      family.text = data['ServiceDetails']['educatorsData'];
      insert.text = data['ServiceDetails']['philosophyStatement'];

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                        'Service Details',
                        style: Constants.header1,
                      ),
                      SizedBox(height: 10),
                      if (centersFetched)
                        DropdownButtonHideUnderline(
                          child: Container(
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
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
                                          //      _rooms=null;
                                          //      _fetchData();
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
                      Text(
                        'Service Name',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 70,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          maxLines: 2,
                          controller: sname,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Service Approval Number',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 70,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          maxLines: 2,
                          controller: snumber,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Primary Contacts at Service',
                        style: Constants.header1,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Physical Location of Service',
                          style: TextStyle(fontSize: 15)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Street',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: phstreet,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Suburb',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: phsuburb,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'State/teritory',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: phstate,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Physical Location Contact Details',
                          style: TextStyle(fontSize: 15)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Telephone',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: ptelephone,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Mobile',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: pmobile,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Fax',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: pfax,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Email',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: pemail,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Approved Provider  ',
                          style: TextStyle(fontSize: 15)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Primary contact ',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: acontact,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Telephone',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: atelephone,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Mobile',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: amobile,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Fax',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: afax,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Email',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: aemail,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Nominated Supervisor ',
                          style: TextStyle(fontSize: 15)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Name ',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: nname,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Telephone',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: ntelephone,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Mobile',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: nmobile,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Fax',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: nfax,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Email',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: nemail,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Postal address (if different to physical location of service)',
                          style: TextStyle(fontSize: 15)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Street',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: postreet,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Suburb',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: posuburb,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'State/teritory',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: postate,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Additional information about your service',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          'Summary of strengths for Educational Program and practice'),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 100,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          maxLines: 3,
                          controller: summary,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('How are the children grouped at your service? '),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 100,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          maxLines: 3,
                          controller: how,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          'Write the name and position of person(s) responsible for submitting this Quality Improvement Plan (e.g. Cheryl Smith, Nominated Supervisor)'),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 100,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          maxLines: 3,
                          controller: write,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          'For family day care services, indicate the number of educators currently registered in the service and attach a list of the educators and their addresses.'),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 100,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          maxLines: 3,
                          controller: family,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Service statement of philosophy',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          'Please insert your service’s statement of philosophy here.'),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 100,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          maxLines: 3,
                          controller: insert,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                width: 80,
                                height: 38,
                                decoration: BoxDecoration(
                                  //    color: Constants.kButton,
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'CANCEL',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () async {
                              ServiceAPIHandler h = ServiceAPIHandler({
                                "userid": MyApp.LOGIN_ID_VALUE,
                                "centerid": centers[currentIndex].id,
                                "serviceName": sname.text,
                                "serviceApprovalNumber": snumber.text,
                                "serviceStreet": phstreet.text,
                                "serviceSuburb": phsuburb.text,
                                "serviceState": phstate.text,
                                "servicePostcode": phpostcode.text,
                                "contactTelephone": ptelephone.text,
                                "contactMobile": pmobile.text,
                                "contactFax": pfax.text,
                                "contactEmail": pemail.text,
                                "providerContact": acontact.text,
                                "providerTelephone": atelephone.text,
                                "providerMobile": amobile.text,
                                "providerFax": afax.text,
                                "providerEmail": aemail.text,
                                "supervisorName": sname.text,
                                "supervisorTelephone": ntelephone.text,
                                "supervisorMobile": nmobile.text,
                                "supervisorFax": nfax.text,
                                "supervisorEmail": nemail.text,
                                "postalStreet": postreet.text,
                                "postalSuburb": posuburb.text,
                                "postalState": postate.text,
                                "postalPostcode": popostcode.text,
                                "eduLeaderName": ename.text,
                                "eduLeaderTelephone": etelephone.text,
                                "eduLeaderEmail": eemail.text,
                                "strengthSummary": summary.text,
                                "childGroupService": how.text,
                                "personSubmittingQip": write.text,
                                "educatorsData": family.text,
                                "philosophyStatement": insert.text
                              });

                              var data = await h.saveService();
                              if (data['Status'] == 'SUCCESS') {
                                MyApp.ShowToast('Saved Successfully', context);
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              } else {
                                print(data);
                                //  MyApp.ShowToast('', context)
                              }
                            },
                            child: Container(
                                width: 60,
                                height: 38,
                                decoration: BoxDecoration(
                                    color: Constants.kButton,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'SAVE',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      )
                    ])))));
  }
}
