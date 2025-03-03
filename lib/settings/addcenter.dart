import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mykronicle_mobile/utils/hexconversion.dart';

class AddCenter extends StatefulWidget {
  final String type;
  final String id;

  AddCenter(this.type,this.id);

  @override
  _AddCenterState createState() => _AddCenterState();
}

class _AddCenterState extends State<AddCenter> {

 List<String> status=['Active','Inactive'];

 List<String> statusValues =[];

  TextEditingController name, city, address, state , code;
  
  List<TextEditingController> rname = [];

  List<TextEditingController> capacity = [];

  List<String> rid=[];

  int pickedIndex=0;

  List<Color> pickerColor =[];
  List<Color> currentColor =[];

// ValueChanged<Color> callback
void changeColor(Color color) {
  setState(() => pickerColor[pickedIndex] = color);
}

  @override
  void initState() {
    name = TextEditingController();
    city = TextEditingController();
    address = TextEditingController();
    state = TextEditingController();
    code = TextEditingController();

    rname.add(TextEditingController());
    capacity.add(TextEditingController());
    statusValues.add('Active');
    rid.add('');

    pickerColor.add(Color(0xff9320cc));
    currentColor.add(Color(0xff9320cc));

    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    if (widget.type == 'edit') {

     SettingsApiHandler handler =
        SettingsApiHandler({"userid": MyApp.LOGIN_ID_VALUE,"centerId": widget.id,});
   
    var data = await handler.getCenterDetails();
    if (!data.containsKey('error')) {
      print(data);

        name.text=data['centerName'];
        city.text = data['addressCity'];
        address.text = data['adressStreet'];
        state.text=data['addressState'];
        code.text=data['addressZip'];
    
       var rooms = data['Rooms'];
       for(var i=0;i<rooms.length;i++){
         if(i!=0){
           rname.add(TextEditingController());
           capacity.add(TextEditingController());
           statusValues.add('Active');
           rid.add('');
           pickerColor.add(Color(0xff9320cc));
           currentColor.add(Color(0xff9320cc));
         }

         rname[i].text=rooms[i]['name'];
         capacity[i].text=rooms[i]['capacity'];
         statusValues[i]=rooms[i]['status'];
         rid[i]=rooms[i]['id'];
         pickerColor[i]=HexColor(rooms[i]['color']);
         currentColor[i]=HexColor(rooms[i]['color']);
       }
       if (this.mounted) setState(() {});
   
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
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                        'Add Center',
                        style: Constants.header1,
                      ),
                      Row(
                        children: [
                          Text('User Settings>'),
                          Text(
                            'Add Center',
                            style: TextStyle(color: Constants.kMain),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                     
                      Text(
                        'Center Details',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Center Name',
                            style: Constants.header2,
                          ),
                        ],
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
                          controller: name,
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
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'City',
                            style: Constants.header2,
                          ),
                        ],
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
                          controller: city,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: InputBorder.none),
                        ),
                      ),
                     SizedBox(height: 10,),
                      Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Address',
                            style: Constants.header2,
                          ),
                        ],
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
                          controller: address,
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
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'State',
                            style: Constants.header2,
                          ),
                        ],
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
                          controller: state,
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
                        children: [
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Post Code',
                            style: Constants.header2,
                          ),
                        ],
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
                          controller: code,
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
                        'Room Details',
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                 Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: rname.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: [
                                            Text('Room Name'),
                                            Spacer(),
                                            IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: () {
                                                   statusValues.add("Active");
                                                
                                                  pickerColor.add(Color(0xff9320cc));
                                                  currentColor.add(Color(0xff9320cc));

                                                  rname.add(
                                                      TextEditingController());
                                                  capacity.add(
                                                      TextEditingController());
                                                  rid.add('');
                                                  setState(() {});
                                                }),
                                            index == 0
                                                ? Container()
                                                : IconButton(
                                                    icon: Icon(
                                                      Icons.remove,
                                                    ),
                                                    onPressed: () {
                                                      statusValues.removeAt(index);
                                                     
                                                      pickerColor.removeAt(index);
                                                      currentColor.removeAt(index);
                                                      rname.removeAt(index);
                                                      rid.removeAt(index);
                                                      capacity.removeAt(index);
                                                      setState(() {});
                                                    }),
                                          ],
                                        ),
                                      ),
                                    
                                      Container(
                                        height: 30,
                                        child: TextField(
                                            maxLines: 1,
                                           // keyboardType: TextInputType.number,
                                            controller: rname[index],
                                            decoration: new InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black26,
                                                    width: 0.0),
                                              ),
                                              border: new OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(4),
                                                ),
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text('Room Capacity'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        height: 30,
                                        child: TextField(
                                            maxLines: 1,
                                            controller: capacity[index],
                                          keyboardType: TextInputType.number,
                                            decoration: new InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black26,
                                                    width: 0.0),
                                              ),
                                              border: new OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(4),
                                                ),
                                              ),
                                            )),
                                      ),
                                       SizedBox(
                                        height: 15,
                                      ),
                                      Text('Status'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                        DropdownButtonHideUnderline(
                                      
                                                  child: Container(
                                                  
                                                    height: 40,
                                                    width: MediaQuery.of(context).size.width,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey[300]),
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8),
                                                      child: Center(
                                                        child: DropdownButton<
                                                            String>(
                                                            isExpanded: true,
                                                          value: statusValues[index],
                                                          items: status.map(
                                                              (String value) {
                                                            return new DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: new Text(
                                                                  value),
                                                            );
                                                          }).toList(),
                                                          onChanged:
                                                              (String value) {
                                                            statusValues[index] = value;
                                                            setState(() {});
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ), 
                                                SizedBox(height: 10,),
                  Text('Room Color',style: Constants.header2,),
                  SizedBox(height: 5,),
                  GestureDetector(
                    onTap: (){
                      pickedIndex=index;
                      setState(() {
                        
                      });
                      showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                              titlePadding: const EdgeInsets.all(0.0),
                            contentPadding: const EdgeInsets.all(0.0),
                            content: SingleChildScrollView(

                                  child:  ColorPicker(
                                pickerColor: currentColor[index],
                                onColorChanged: changeColor,
                                colorPickerWidth: 300.0,
                                pickerAreaHeightPercent: 0.7,
                                enableAlpha: true,
                                displayThumbColor: true,
                                showLabel: true,
                                paletteType: PaletteType.hsv,
                                pickerAreaBorderRadius: const BorderRadius.only(
                                  topLeft: const Radius.circular(2.0),
                                  topRight: const Radius.circular(2.0),
                                ),
                              ),
                                ),
                                 actions: <Widget>[
      TextButton(
        child: const Text('Choose'),
        onPressed: () {
          setState(() => currentColor[pickedIndex] = pickerColor[pickedIndex]);
          print(currentColor[pickedIndex] );
          print('#'+currentColor[pickedIndex].toString().substring(10,currentColor[pickedIndex].toString().length-1));
          Navigator.of(context).pop();
        },
      ),
    ],
                              );
                            },
                          );
                       
                    },
                     child: Container(
                     height: 50,
                     width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 16.0),
                      decoration: BoxDecoration(
                         color: currentColor[index],
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.grey)
                      ),
                      
                    ),
                  ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ]))));
                      })),


                      SizedBox(
                        height: 15.0,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {

                                
                                  var _toSend =
                                     Constants.BASE_URL + 'Settings/saveCenterDetails';
                                  List data = [];
                                  for (var i = 0; i < rname.length; i++) {
                                    data.add({
                                      "roomid":rid[i],
                                      "roomName": rname[i].text.toString(),
                                      "roomCapacity": capacity[i].text.toString(),
                                      "roomColor": '#'+currentColor[i].toString().substring(10,currentColor[i].toString().length-1),
                                      "roomStatus":statusValues[i],
                                    });
                                  }
                                  var objToSend = {
                                      "centerName":name.text.toString(),
                                      "adressStreet":address.text.toString(),
                                      "addressCity":city.text.toString(),
                                      "addressState":state.text.toString(),
                                      "addressZip":code.text.toString(),
                                      "userid":MyApp.LOGIN_ID_VALUE,
                                      "rooms": data
                                  };


                                 if(widget.type=='edit'){
                                   objToSend["centerId"]=widget.id;
                                 }

                                  print(jsonEncode(objToSend));
                                  final response = await http.post(_toSend,
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
                    ])))));
  }

  Future<DateTime> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(1850),
      lastDate: new DateTime(2100),
    );
    return picked;
  }
}
