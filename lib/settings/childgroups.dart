import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childgroupmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/settings/addgroup.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class ChildGroups extends StatefulWidget {
  @override
  _ChildGroupsState createState() => _ChildGroupsState();
}

class _ChildGroupsState extends State<ChildGroups> {

  bool settingsDataFetched = false;
  List<ChildGroupsModel> _allGroups;

@override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    SettingsApiHandler handler =
        SettingsApiHandler({"userid": MyApp.LOGIN_ID_VALUE});
    
    var data = await handler.getChildGroups();

    if (!data.containsKey('error')) {
     
      print(data);
      var groups = data['groups'];
      _allGroups = [];
      try {
        assert(groups is List);
        for (int i = 0; i < groups.length; i++) {
          _allGroups.add(ChildGroupsModel.fromJson(groups[i]));
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
      appBar: Header.appBar(),
      drawer: GetDrawer(),      
      body: SingleChildScrollView(
          child: Padding(
           padding: const EdgeInsets.all(12.0),
            child: settingsDataFetched? Container(
              child: Column(
                children: [
                  Row(
                      children: [
                         Text(
                             'Child Groups',
                            style: Constants.header2,
                          ),
                          Expanded(
                              child: Container(),
                           ),
                            // GestureDetector(
                            //     onTap: () async {},
                            //     child: Icon(
                            //       Entypo.select_arrows,
                            //       color: Constants.kButton,
                            //     )),
                           
                            SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddGroup('add',null))).then((value) {
                                      if (value != null) {
                                      settingsDataFetched=false;
                                        setState(() {});
                                        _fetchData();
                                      }
                                    });
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
                                      '+ Add Group',
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
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _allGroups.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context,int index){
                             return Card(
                                   child: Container(
                                 child: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Column(
                                     children: [
                                        Row(
                                          children: [
                                            Text(_allGroups[index].name),
                                            Expanded(child: Container(),),
                                             GestureDetector(
                                              child: Icon(Icons.edit),
                                              onTap: (){
                                               Navigator.push(
                                                       context,
                                                        MaterialPageRoute(
                                        builder: (context) => AddGroup('edit',_allGroups[index].id))).then((value) {
                                      if (value != null) {
                                      settingsDataFetched=false;
                                        setState(() {});
                                        _fetchData();
                                      }
                                    });
                                               },
                                              ),
                                            // GestureDetector(
                                            //   child: Icon(Icons.delete),
                                            //   onTap: (){

                                            //    },
                                            //   )

                                          ],
                                        ),

                                         _allGroups[index].children.length>0? Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      children: List<Widget>.generate(
                        _allGroups[index].children.length>5?5:_allGroups[index].children.length, (int i) {
                         return  _allGroups[index].children[i]['imageUrl']!=null &&_allGroups[index].children[i]['imageUrl']!=''?CircleAvatar(
                             radius: 40,
                             backgroundColor: Colors.grey,
                             backgroundImage: NetworkImage(
                                 Constants.ImageBaseUrl + _allGroups[index].children[i]['imageUrl'])
                           ): CircleAvatar(radius: 40,backgroundColor: Colors.grey,child: Text(_allGroups[index].children[i]['name'],style: TextStyle(color: Colors.white),),);
                         })
                       ):Container(),

                      _allGroups[index].children.length>4?TextButton(onPressed: (){
                          Navigator.push(
                                           context,
                                                        MaterialPageRoute(
                                        builder: (context) => AddGroup('edit',_allGroups[index].id))).then((value) {
                                      if (value != null) {
                                      settingsDataFetched=false;
                                        setState(() {});
                                        _fetchData();
                                      }
                                    });
                       }, child: Text('more..')):Container(),
                      

                                     ],
                                   ),
                                 ),
                               ),
                             );
                         }),
               ],
             ),
            ):Container(),
          ),
      ),
    );
  }
}