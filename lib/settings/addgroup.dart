import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:http/http.dart' as http;

class AddGroup extends StatefulWidget {

  final String type;
  final String id;

  AddGroup(this.type,this.id);

  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {

 TextEditingController? gname;
 TextEditingController? gDesc;
 
  List<ChildModel> _allChildrens=[];
  List<ChildModel> _selectedChildrens=[]; 
  Map<String ,bool> childValues={};
  bool childrensFetched=false;

  @override
  void initState() {
    gname= new TextEditingController();
    gDesc= new TextEditingController(); 
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
   if(widget.type=='edit'){

      SettingsApiHandler handler =
        SettingsApiHandler({"userid": MyApp.LOGIN_ID_VALUE,"groupId":widget.id});
    
    var data = await handler.getChildGroupDeatils();

  if(!data.containsKey('error')){

   var child = data['children'];
   var details =data['groupData'];
     _allChildrens = [];
      try {
        assert(child is List);
        for (int i = 0; i < child.length; i++) {
          _allChildrens.add(ChildModel.fromJson(child[i]));
          childValues[_allChildrens[i].id]=false;
        }
        for (int i = 0; i < details['children'].length; i++) {
          for(int j=0;j<_allChildrens.length;j++){
              if(_allChildrens[j].id==details['children'][i]['child_id']){
                _selectedChildrens.add(_allChildrens[j]);
                childValues[_allChildrens[j].id]=true;
                break;
              }
          }
          
        }
        childrensFetched = true;
        gname?.text=details['name'];
        gDesc?.text=details['description'];
        if(this.mounted) setState(() {});
      }
      catch (e) {
        print(e);
      }


    }else{
        MyApp.Show401Dialog(context);
    }

   }else{
      SettingsApiHandler handler =
        SettingsApiHandler({"userid": MyApp.LOGIN_ID_VALUE});
    
    var data = await handler.getChildGroupDeatils();

  if(!data.containsKey('error')){

   var child = data['children'];
     _allChildrens = [];
      try {
        assert(child is List);
        for (int i = 0; i < child.length; i++) {
          _allChildrens.add(ChildModel.fromJson(child[i]));
          childValues[_allChildrens[i].id]=false;
        }
        childrensFetched = true;
        if(this.mounted) setState(() {});
      }
      catch (e) {
        print(e);
      }


    }else{
        MyApp.Show401Dialog(context);
    }
   }

  }

  GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      endDrawer: Drawer(
              child: Container(
          child: ListView(
            children: [
             if(childrensFetched)
             Container(
               height: MediaQuery.of(context).size.height*0.75,
               child: ListView.builder(
                 itemCount: _allChildrens!=null?_allChildrens.length:0,
                 itemBuilder: (BuildContext context,int index){
                   return ListTile(
                    //  leading: CircleAvatar(
                    //           backgroundImage: NetworkImage(_allChildrens[index].imageUrl!=null?Constants.ImageBaseUrl+  _allChildrens[index].imageUrl:''),
                    //     ),
                     title: Text(_allChildrens[index].name),
                     trailing: Checkbox(
                       value:childValues[_allChildrens[index].id],
                       onChanged:(value){

                           
                           if(value==true){
                             if(!_selectedChildrens.contains(_allChildrens[index])){
                                 _selectedChildrens.add(_allChildrens[index]);
                             }
                             
                           }else{
                             if(_selectedChildrens.contains(_allChildrens[index])){
                                 _selectedChildrens.remove(_allChildrens[index]);
                             }
                             
                           }
                             childValues[_allChildrens[index].id]=value!;
                         
                           setState((){});
                       }
                     ),
               
                    );
           
               }),
             ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          
                        },
                        child: Container(
                                  decoration: BoxDecoration(
                            color: Constants.kButton,
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          child:Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Text('SAVE',style: TextStyle(color: Colors.white,fontSize: 16),),
                          )
                        ),
                      ),
                      SizedBox(width: 10,)
                   
                ],),
              )
           ],
          ),
        ),
      ),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
         child: Padding(
           padding: const EdgeInsets.all(12.0),
           child: Container(
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                        'Add Groups',
                        style: Constants.header1,
                      ),
                      Row(
                        children: [
                          Text('Child Group>'),
                          Text(
                            'Add Group',
                            style: TextStyle(color: Constants.kMain),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                        GestureDetector(
                      onTap: (){
                               key.currentState?.openEndDrawer();
                      },
                      child: Container(
                        width: 160,
                        height: 38,
                                decoration: BoxDecoration(
                          color: Constants.kButton,
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        child:Row(
                          children: <Widget>[
                          IconButton(
                            onPressed: (){
                             
                             },
                             icon: Icon(Icons.add_circle,color: Colors.blue[100],),
                          ),
                           Text('Select Children',style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ),
                    ),
                      SizedBox(
                        height: 5,
                      ),
                     _selectedChildrens.length>0? Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      children: List<Widget>.generate(_selectedChildrens.length, (int index) {
                         return _selectedChildrens[index].id!=null?Chip(
                           label: Text(_selectedChildrens[index].name),
                           onDeleted: () {
                               setState(() {
                                  childValues[_selectedChildrens[index].id]=false;
                                  _selectedChildrens.removeAt(index);
                                });
                      }):Container();
                      })
                     ):Container(),
                      Text(
                            'Group Name',
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
                          controller: gname,
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
                            'Description',
                            style: Constants.header2,
                          ),
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
                          maxLines: 2,
                          controller: gDesc,
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
                       SizedBox(
                        height: 15.0,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {

                                 if(gname?.text.toString()==''){
                                    MyApp.ShowToast('Enter name', context);
                                 }else if(gDesc?.text.toString()==''){ 
                                    MyApp.ShowToast('Enter Description', context);
                                 }
                                 else{
                                  
                                  List<String> ids=[];
                                  for(var i=0;i<_selectedChildrens.length;i++){
                                     ids.add(_selectedChildrens[i].id);
                                  }
                                  print(ids);
                                  var _toSend =
                                     Constants.BASE_URL + 'Settings/saveChildGroup';
                               
                                  var objToSend = {
                                    "name":gname?.text.toString(),
                                    "description":gDesc?.text.toString(),
                                    "children":ids,
                                    "userid":MyApp.LOGIN_ID_VALUE
                                    };


                                 if(widget.type=='edit'){
                                   objToSend["groupId"]=widget.id;
                                 }

                                  print(jsonEncode(objToSend));
                                  final response = await http.post(Uri.parse(_toSend),
                                      body: jsonEncode(objToSend),
                                      headers: {
                                        'X-DEVICE-ID':
                                            await MyApp.getDeviceIdentity(),
                                        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                      });
                                  print(response.body);
                                  if (response.statusCode == 200) {
                                    MyApp.ShowToast("updated", context);
                                    Navigator.pop(context, 'kill');
                                  } else if (response.statusCode == 401) {
                                    MyApp.Show401Dialog(context);
                                  }

                                 }
                             
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
                                      'SAVE',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  )),
                            ),
                            SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                
              ],
            )
          ),
         ),
      ),
    );
  }
}