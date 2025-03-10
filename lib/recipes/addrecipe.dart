import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:mykronicle_mobile/api/recipeapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/ingredientmodel.dart';
import 'package:mykronicle_mobile/models/recipeMediaModel.dart';
import 'package:mykronicle_mobile/models/recipemodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/cropImage.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:path/path.dart';

class Addrecipe extends StatefulWidget {
  final String type;
  final String id;
  final String centerid;
  Addrecipe({required this.type, required this.id, required this.centerid});
  @override
  _AddrecipeState createState() => _AddrecipeState();
}

class _AddrecipeState extends State<Addrecipe> {
  List<File> files = [];
  List<IngredientModel> _allIngredients = [];
  int typeIndex = 0;
  List<IngredientModel> _selectedIngredients = [];
  List<TextEditingController> _quant = [];
  List<TextEditingController> _calories = [];
// Map<String ,bool> ingredientsValues={};
  List<RecipeMediaModel> media = [];
  TextEditingController name = TextEditingController(), recipe= TextEditingController();
  bool ingFetched = false;
  RecipeModel? _recipe;
  bool dataFetched = false;

  double h = 0;

  @override
  void initState() {
    name = TextEditingController();
    recipe = TextEditingController();
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    RecipeAPIHandler handler = RecipeAPIHandler({});
    var data = await handler.getIngredients();
    print(data);
    var child = data['Ingredients'];
    _allIngredients = [];
    try {
      assert(child is List);
      _allIngredients.add(IngredientModel(id: '0', name: 'Select Ingreidient'));
      for (int i = 0; i < child.length; i++) {
        _allIngredients.add(IngredientModel.fromJson(child[i]));
        //      ingredientsValues[_allIngredients[i].id]=false;
      }
      ingFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    if (widget.type == 'edit') {
      print('edit');
      RecipeAPIHandler han = RecipeAPIHandler({'rid': widget.id});
      var d = await han.getRecipeDetails();
      if (!d.containsKey('error')) {
        print(d);
        var res = d['Recipes'];

        _recipe = RecipeModel.fromJson(res);

        name.text = _recipe?.itemName??'';
        recipe.text = _recipe?.recipe??'';
        for (int i = 0; i < (_recipe?.ingredients.length??0); i++) {
          _selectedIngredients
              .add(IngredientModel.fromJson(_recipe?.ingredients[i]));
          for (int k = 0; k < _allIngredients.length; k++) {
            if (_allIngredients[k].id ==
                _recipe?.ingredients[i]['ingredientId']) {
              _allIngredients.remove(_allIngredients[k]);
              break;
            }
          }
          //  _allIngredients.remove(_allIngredients[i]);
          _quant
              .add(TextEditingController(text: _recipe?.ingredients[i]['qty']));
          _calories.add(
              TextEditingController(text: _recipe?.ingredients[i]['calories']));
        }
        for (int i = 0; i < (_recipe?.media.length??0); i++) {
          media.add(RecipeMediaModel.fromJson(_recipe?.media[i]));
        }
        dataFetched = true;
        if (this.mounted) setState(() {});
      } else {
        print('error');
        // MyApp.Show401Dialog(context);
      }
    }
  }

  GlobalKey<ScaffoldState> key = GlobalKey();
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        key: key,
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                        'Healthy Eating',
                        style: Constants.header1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Add Item',
                        style: Constants.header2,
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Text('Item Name'),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 40,
                        child: TextField(
                            controller: name,
                            decoration: new InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black26, width: 0.0),
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(4),
                                ),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Ingredients'),
                      SizedBox(
                        height: 5,
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      _allIngredients != null && _allIngredients.length > 0
                          ? DropdownButtonHideUnderline(
                              child: Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Center(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _allIngredients[typeIndex].id,
                                      items: _allIngredients
                                          .map((IngredientModel value) {
                                        return new DropdownMenuItem<String>(
                                          value: value.id,
                                          child: new Text(value.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        for (int i = 0;
                                            i < _allIngredients.length;
                                            i++) {
                                          if (_allIngredients[i].id == value) {
                                            if (value != '0') {
                                              _selectedIngredients
                                                  .add(_allIngredients[i]);
                                              _allIngredients
                                                  .remove(_allIngredients[i]);
                                              _quant
                                                  .add(TextEditingController());
                                              _calories
                                                  .add(TextEditingController());
                                              setState(() {});
                                            }

                                            break;
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),

                      SizedBox(
                        height: 10,
                      ),

                      if (_selectedIngredients.length > 0)
                        Container(
                            child: Column(
                          children: [
                            Container(
                              color: Colors.grey,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text('Ingredient')),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text('Quantity')),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.24,
                                        child: Text('Calories')),
                                  ],
                                ),
                              ),
                            ),
                            if (_selectedIngredients.length > 0)
                              ListView.builder(
                                  itemCount: _selectedIngredients.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                                _selectedIngredients[index]
                                                    .name)),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.22,
                                          child: TextField(
                                            controller: _quant[index],
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.22,
                                          child: TextField(
                                            controller: _calories[index],
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              showDeleteDialog(context, () {
                                                _allIngredients.add(
                                                    _selectedIngredients[
                                                        index]);
                                                _selectedIngredients
                                                    .removeAt(index);
                                                _quant.removeAt(index);
                                                _calories.removeAt(index);
                                                setState(() {});
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Icon(Icons.clear))
                                      ],
                                    ));
                                  })
                          ],
                        )),
                      SizedBox(
                        height: 10,
                      ),

//              _selectedIngredients.length>0? Wrap(
//   spacing: 8.0, // gap between adjacent chips
//   runSpacing: 4.0, // gap between lines
//   children: List<Widget>.generate(_selectedIngredients.length, (int index) {
//     return _selectedIngredients[index].id!=null?Chip(
//       label: Text(_selectedIngredients[index].name),
//       onDeleted: () {
//         setState(() {
//           ingredientsValues[_selectedIngredients[index].id]=false;
//           _selectedIngredients.removeAt(index);
//         });
//       }):Container();
//   })
//  ):Container(),

                      SizedBox(
                        height: 10,
                      ),
                      Text('Recipe'),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                          maxLines: 4,
                          controller: recipe,
                          decoration: new InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 0.0),
                            ),
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(4),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Media'),
                      SizedBox(
                        height: 5,
                      ),

                      GestureDetector(
                          onTap: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();

                            if (result != null) {
                              File file = File(result.files.single.path??'');
                              var fileSizeInBytes = file.length();
                              var fileSizeInKB = await fileSizeInBytes / 1024;
                              var fileSizeInMB = fileSizeInKB / 1024;

                              if (fileSizeInMB > 2) {
                                MyApp.ShowToast(
                                    'file size greater than 2 mb so image is being compressed',
                                    context);

                                final filePath = file.absolute.path;
                                final lastIndex =
                                    filePath.lastIndexOf(new RegExp(r'.jp'));
                                final splitted =
                                    filePath.substring(0, (lastIndex));
                                final outPath =
                                    "${splitted}_out${filePath.substring(lastIndex)}";

                                File cFile =
                                    await compressAndGetFile(file, outPath);
                                files.add(cFile);
                                setState(() {});
                              } else {
                                files.add(file);
                                setState(() {});
                              }
                              h = h + 100.0;
                              // if(files.length==1){
                              //   h=h+size.width/3;
                              // }else if(files.length%2==0){
                              //    h=h+size.width/3;
                              // }
                              setState(() {});
                            } else {
                              // User canceled the picker
                            }
                          },
                          child: rectBorderWidget(size, context)),

                      SizedBox(
                        height: 10,
                      ),
                      files.length > 0
                          ? Wrap(
                              spacing: 8.0, // gap between adjacent chips
                              runSpacing: 4.0, //
                              // direction: Axis.vertical,
                              // alignment: WrapAlignment.center,
                              // spacing:8.0,
                              // runAlignment:WrapAlignment.center,
                              // runSpacing: 8.0,
                              // crossAxisAlignment: WrapCrossAlignment.center,
                              // textDirection: TextDirection.rtl,
                              // verticalDirection: VerticalDirection.up,
                              children: List<Widget>.generate(files.length,
                                  (int index) {
                                String? mimeStr =
                                    lookupMimeType(files[index].path);
                                var fileType = mimeStr?.split('/');
                                if (fileType?[0].toString() == 'image') {
                                  return Stack(
                                    children: [
                                      Container(
                                          width: 100,
                                          height: 100,
                                          decoration: new BoxDecoration(
                                            //  borderRadius: BorderRadius.circular(15.0),
                                            shape: BoxShape.rectangle,
                                            image: new DecorationImage(
                                              image:
                                                  new FileImage(files[index]),
                                              fit: BoxFit.cover,
                                            ),
                                          )),
                                      Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              showDeleteDialog(context, () {
                                                files.removeAt(index);
                                                setState(() {});
                                                Navigator.pop(context);
                                              });
                                            },
                                          ))
                                    ],
                                  );
                                } else {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        child: Card(
                                            child:
                                                Icon(Icons.video_collection)),
                                      ),
                                      Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              showDeleteDialog(context, () {
                                                files.removeAt(index);
                                                setState(() {});
                                                Navigator.pop(context);
                                              });
                                            },
                                          ))
                                    ],
                                  );
                                }
                              }),
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      media.length > 0
                          ? Wrap(
                              spacing: 8.0, // gap between adjacent chips
                              runSpacing: 4.0, //
                              children: List<Widget>.generate(media.length,
                                  (int index) {
                                if (media[index].mediaType == 'Image') {
                                  return Stack(
                                    children: [
                                      Container(
                                          width: 100,
                                          height: 100,
                                          decoration: new BoxDecoration(
                                            //  borderRadius: BorderRadius.circular(15.0),
                                            shape: BoxShape.rectangle,
                                            image: new DecorationImage(
                                              image: new NetworkImage(
                                                  Constants.ImageBaseUrl +
                                                      media[index].mediaUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          )),
                                      Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              showDeleteDialog(context, () {
                                                RecipeAPIHandler handler =
                                                    RecipeAPIHandler({
                                                  "mediaid": media[index].id
                                                });
                                                handler
                                                    .deleteMedia()
                                                    .then((value) {
                                                  print(value);
                                                  media.removeAt(index);
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                });
                                              });
                                            },
                                          ))
                                    ],
                                  );
                                } else {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        child: Card(
                                            child:
                                                Icon(Icons.video_collection)),
                                      ),
                                      Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              showDeleteDialog(context, () {
                                                RecipeAPIHandler handler =
                                                    RecipeAPIHandler({
                                                  "mediaid": media[index].id
                                                });
                                                handler
                                                    .deleteMedia()
                                                    .then((value) {
                                                  var data =
                                                      jsonDecode(value.body);
                                                  if (data['Status'] ==
                                                      'SUCCESS') {
                                                    media.removeAt(index);
                                                    setState(() {});
                                                  } else {
                                                    MyApp.ShowToast(
                                                        data['Status'],
                                                        context);
                                                  }
                                                });
                                                Navigator.pop(context);
                                              });
                                            },
                                          ))
                                    ],
                                  );
                                }
                              }),
                            )
                          : Container(),

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
                              if (name.text.toString().length == 0) {
                                MyApp.ShowToast(
                                    'Enter Name of Recipe', context);
                              } else if (recipe.text.toString().length == 0) {
                                MyApp.ShowToast('Enter Recipe', context);
                              } else {
                                List<Map> sel = [];
                                for (var i = 0;
                                    i < _selectedIngredients.length;
                                    i++) {
                                  sel.add({
                                    "ingredientId": _selectedIngredients[i].id,
                                    "quantity": _quant[i].text,
                                    "calories": _calories[i].text
                                  });
                                }
                                print(sel);

                                Map<String, dynamic> mp;

                                mp = {
                                  "itemName": name.text,
                                  "type": widget.type,
                                  "recipe": recipe.text.toString(),
                                  "ingredients": jsonEncode(sel),
                                  "userid": MyApp.LOGIN_ID_VALUE,
                                  'centerid': widget.centerid
                                };

                                List videos = [];
                                List img = [];

                                for (int i = 0; i < files.length; i++) {
                                  File file = files[i];

                                  String? mimeStr =
                                      lookupMimeType(files[i].path);
                                  var fileType = mimeStr?.split('/');
                                  if (fileType?[0].toString() == 'image') {
                                    img.add(await MultipartFile.fromFile(
                                        file.path,
                                        filename: basename(file.path)));
                                  } else if (fileType?[0].toString() ==
                                      'video') {
                                    videos.add(await MultipartFile.fromFile(
                                        file.path,
                                        filename: basename(file.path)));
                                  }
                                }

                                for (int i = 0; i < img.length; i++) {
                                  String m = 'image' + i.toString();
                                  mp[m] = img[i];
                                }

                                for (int i = 0; i < videos.length; i++) {
                                  String m = 'video' + i.toString();
                                  mp[m] = videos[i];
                                }

                                FormData formData = FormData.fromMap(mp);
                                print(Constants.BASE_URL + "Recipes/addRecipe");
                                print(formData.fields.toString());
                                Dio dio = new Dio();

                                Response? response = await dio
                                    .post(
                                        Constants.BASE_URL +
                                            "Recipes/addRecipe",
                                        data: formData,
                                        options: Options(headers: {
                                          'X-DEVICE-ID':
                                              await MyApp.getDeviceIdentity(),
                                          'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                        }))
                                    .then((value) {
                                  var v = jsonDecode(value.toString());

                                  if (v['Status'] == 'SUCCESS') {
                                    Navigator.pop(context, 'kill');
                                  } else {
                                    MyApp.ShowToast("error", context);
                                  }
                                }).catchError((error) => print(error));
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
                                        'SEND',
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


Future<File> compressAndGetFile(File file, String targetPath) async {
  XFile? result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    minWidth: 900, minHeight: 900, quality: 40,
  );

  if (result == null) {
    throw Exception("Compression failed: Unable to get compressed file.");
  }

  File compressedFile = File(result.path); // Convert XFile to File

  print("Original size: ${file.lengthSync()} bytes");
  print("Compressed size: ${compressedFile.lengthSync()} bytes");

  return compressedFile;
}


  Widget rectBorderWidget(Size size, var context) {
    return DottedBorder(
      dashPattern: [8, 4],
      strokeWidth: 2,
      child: Container(
        width: 100,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    File file = File(result.files.single.path??"");
                    var fileSizeInBytes = file.length();
                    var fileSizeInKB = await fileSizeInBytes / 1024;
                    var fileSizeInMB = fileSizeInKB / 1024;

                    if (fileSizeInMB > 2) {
                      MyApp.ShowToast(
                          'file size greater than 2 mb so image is being compressed',
                          context);

                      final filePath = file.absolute.path;
                      final lastIndex =
                          filePath.lastIndexOf(new RegExp(r'.jp'));
                      final splitted = filePath.substring(0, (lastIndex));
                      final outPath =
                          "${splitted}_out${filePath.substring(lastIndex)}";

                      File? cFile = await compressAndGetFile(file, outPath);
                      File? fImage = await cropImage(context, cFile);
                      if (fImage != null) {
                        files.add(fImage);
                      }
                      setState(() {});
                    } else {
                      File? fImage = await cropImage(context, file);
                      if (fImage != null) {
                        files.add(fImage);
                      }
                      setState(() {});
                    }
                    h = h + 100.0;
                    // if(files.length==1){
                    //   h=h+size.width/3;
                    // }else if(files.length%2==0){
                    //    h=h+size.width/3;
                    // }
                    setState(() {});
                  } else {
                    // User canceled the picker
                  }

                  //  FilePickerResult result = await FilePicker.platform.pickFiles(
                  //     type: FileType.custom,
                  //     allowedExtensions: ['jpg', 'pdf', 'doc'],
                  //    );

                  //              if(result != null) {
                  //                   files = result.paths.map((path) => File(path)).toList();
                  //                   setState((){});
                  //              } else {
                  //                   // User canceled the picker
                  //             }
                },
              ),
              Text('Upload'),
            ],
          ),
        ),
      ),
    );
  }
}
