import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/settings/addcenter.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class CenterSettings extends StatefulWidget {
  @override
  _CenterSettingsState createState() => _CenterSettingsState();
}

class _CenterSettingsState extends State<CenterSettings> {
 
  String searchString = '';
  
  String order='ASC';
  bool settingsDataFetched = false;
  List<CentersModel> _allCenters;

@override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    SettingsApiHandler handler =
        SettingsApiHandler({"userid": MyApp.LOGIN_ID_VALUE,"order": order,});
    
    var data = await handler.getCenterSettings();

    if (!data.containsKey('error')) {
     
      print(data);
      var centers = data['centers'];
      _allCenters = [];
      try {
        assert(centers is List);
        for (int i = 0; i < centers.length; i++) {
          _allCenters.add(CentersModel.fromJson(centers[i]));
        }
        settingsDataFetched=true;
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
                child: settingsDataFetched?Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'Centers',
                            style: Constants.header2,
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          GestureDetector(
                               onTap: () async {
                                _allCenters= _allCenters.reversed.toList();
                                  setState(() {});
                                  
                              },
                              child: Icon(
                                Entypo.select_arrows,
                                color: Constants.kButton,
                              )),
                         
                          SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddCenter('add',null))).then((value) {
                                      if (value != null) {
                                      settingsDataFetched=false;
                                        setState(() {});
                                        _fetchData();
                                      }
                                    });;
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Constants.kButton,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                  child: Text(
                                    '+ Add Center',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                )),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Theme(
                          data: new ThemeData(
                            primaryColor: Colors.grey,
                            primaryColorDark: Colors.grey,
                          ),
                          child: Container(
                            height: 33.0,
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              keyboardType: TextInputType.text,
                              //validator: validatePassword,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  labelStyle: new TextStyle(color: Colors.grey),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.grey)),
                                  hintStyle: new TextStyle(
                                    inherit: true,
                                    color: Colors.grey,
                                  ),
                                  hintText: 'Search By Name'),
                              onChanged: (String val) {
                                searchString = val;
                                print(searchString);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                     
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: ListView.builder(
                          itemCount: _allCenters.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return centerCard(index);
                          },
                        ),
                      ),
                    ])):Container(),
                    )));
  }

  Widget centerCard(int i) {
    return _allCenters[i].centerName.toLowerCase().contains(searchString.toLowerCase())?Card(
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
                    radius: 40,
                    backgroundColor: Colors.grey,
                    // backgroundImage: NetworkImage(
                    //     Constants.ImageBaseUrl + _allChildrens[i].imageUrl)
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCenter('edit',_allCenters[i].id))).then((value) {
                                      if (value != null) {
                                      settingsDataFetched=false;
                                        setState(() {});
                                        _fetchData();
                                      }
                                    });
                        },
                        child: Text( _allCenters[i].centerName,
                            style: Constants.cardHeadingStyle)),
                    Text( _allCenters[i].adressStreet),
                    Text( _allCenters[i].addressCity)
                  ],
                )
              ],
            )
          ],
        ),
      ),
    ):Container();
  }
}
