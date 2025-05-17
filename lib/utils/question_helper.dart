import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/questionhelpermodel.dart';
import 'package:mykronicle_mobile/services/callbacks.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/cropImage.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/video_item_local.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';

class QuestionHelper extends StatefulWidget {
  final StringCallback? funcCallback;
  final StringCallback? choiceCallback;
  final StringCallback? deleteMediaCallback;
  final StringCallback? questionCallback;
  final BoolCallback? mandatoryCallback;
  final FileCallback? imageCallBack;
  final FileCallback? videoCallBack;
  final ListCallback? options1ListCallBack;
  final ListCallback? options2ListCallBack;
  final ListCallback? options3ListCallBack;
  final ListCallback? options4ListCallBack;
  final String? choose;
  final QuestionHelperModel? helper;
  final String? id;

  const QuestionHelper(
      {Key? key,
      this.funcCallback,
      this.choiceCallback,
      this.deleteMediaCallback,
      this.questionCallback,
      this.mandatoryCallback,
      this.imageCallBack,
      this.videoCallBack,
      this.options1ListCallBack,
      this.options2ListCallBack,
      this.options3ListCallBack,
      this.options4ListCallBack,
      this.choose,
      this.helper,
      this.id})
      : super(key: key);

  @override
  _QuestionHelperState createState() => _QuestionHelperState();
}

class _QuestionHelperState extends State<QuestionHelper> {
  String _choosenValue = 'Multiple Choice';
  TextEditingController question = TextEditingController();
  List<TextEditingController> _mcqOptions = [TextEditingController()];
  //for checkbox and dropdown used same list _checkboxoptions
  List<TextEditingController> _checkBoxOptions2 = [TextEditingController()];
  List<TextEditingController> _checkBoxOptions3 = [TextEditingController()];
  bool mandatory = false;
  List<String> options1 = [''];
  List<String> options2 = [''];
  List<String> options3 = [''];
  List<String> options4 = [''];

  List<String> linearoptions = ['0', '1'];
  TextEditingController first = TextEditingController(text: '');
  TextEditingController last = TextEditingController(text: '');

  File? _image;
  //String _uploadedFileURL;

  File? _video;
  final picker = ImagePicker();

// This funcion will helps you to pick a Video File
  _pickVideo() async {
    PickedFile? pickedFile =
        (await picker.pickImage(source: ImageSource.gallery)) != null
            ? PickedFile(
                (await picker.pickImage(source: ImageSource.gallery))!.path)
            : null;
    if (pickedFile == null) return;
    _video = File(pickedFile.path ?? "");
    if (_video != null) {
      widget.videoCallBack!(_video!);
    }
    setState(() {});
  }

  Future<File> compressAndGetFile(File file, String targetPath) async {
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 900,
      minHeight: 900,
      quality: 40,
    );

    if (result == null) {
      throw Exception("Compression failed: Unable to get compressed file.");
    }

    File compressedFile = File(result.path); // Convert XFile to File

    print("Original size: ${file.lengthSync()} bytes");
    print("Compressed size: ${compressedFile.lengthSync()} bytes");

    return compressedFile;
  }

  Future _loadFromGallery(var context) async {
    print('heee');
    final picker = ImagePicker();
    final _galleryImage = await picker.pickImage(source: ImageSource.gallery);

    // setState(() {
    //   _image = File(_galleryImage.path);
    // });
    if (_galleryImage == null) return;
    File file = File(_galleryImage.path);
    var fileSizeInBytes = file.length();
    var fileSizeInKB = await fileSizeInBytes / 1024;
    var fileSizeInMB = fileSizeInKB / 1024;
    print('HERE' + fileSizeInMB.toString());
    if (fileSizeInMB > 2) {
      MyApp.ShowToast(
          'file size greater than 2 mb so image is being compressed', context);

      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

      File cFile = await compressAndGetFile(file, outPath);
      File? fImage = await cropImage(context, cFile);
      if (fImage != null) {
        _image = file;
      }
      setState(() {});
    } else {
      File? fImage = await cropImage(context, file);
      if (fImage != null) {
        _image = file;
      }
      setState(() {});
    }
    widget.imageCallBack!(_image!);
  }

  @override
  void initState() {
    print(widget.choose);
    if (widget.choose == 'copy') {
      _choosenValue = widget.helper?.choosenValue ?? '';
      mandatory = widget.helper?.mandatory ?? false;
      question.text = widget.helper?.question ?? '';
      _image = widget.helper?.image;
      _video = widget.helper?.video;
      options1 = widget.helper?.options1 ?? [];
      options2 = widget.helper?.options2 ?? [];
      options3 = widget.helper?.options3 ?? [];
      options4 = widget.helper?.options4 ?? [];
      if (widget.helper?.choosenValue == 'Multiple Choice') {
        try {
          for (var i = 0; i < options1.length; i++) {
            if (i == 0) {
              _mcqOptions[i].text = options1[i];
            } else {
              _mcqOptions.add(TextEditingController(text: options1[i]));
            }
          }
        } catch (e, s) {
          print(e.toString());
          print(s);
        }
      }
      // else if(widget.helper?.choosenValue=='TextField'){
      //   for(var i=0;i<options5.length;i++){
      //       if(i==0){
      //       _textFieldOptions[i].text=options5[i];
      //       }else{
      //        _textFieldOptions.add(TextEditingController(text: options5[i]));
      //       }
      //   }
      // }
      else if (widget.helper!.choosenValue == 'Linear Scale') {
        if (options4.length == 2) {
          first.text = options4[0];
          last.text = options4[1];
        }
      } else if (widget.helper!.choosenValue == 'CheckBox') {
        for (var i = 0; i < options2.length; i++) {
          try {
            _checkBoxOptions2[i].text = options2[i];
            if (i == 0) {
              _checkBoxOptions2[i].text = options2[i];
            } else {
              _checkBoxOptions2.add(TextEditingController(text: options2[i]));
            }
          } catch (e, s) {
            print(e.toString());
            print(s);
          }
        }
      } else {
        for (var i = 0; i < options3.length; i++) {
          try {
            _checkBoxOptions3[i].text = options3[i];
            if (i == 0) {
              _checkBoxOptions3[i].text = options3[i];
            } else {
              _checkBoxOptions3.add(TextEditingController(text: options3[i]));
            }
          } catch (e, s) {
            print(e.toString());
            print(s);
          }
        }
      }
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //    color: Constants.kButton,
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButtonHideUnderline(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 30,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Center(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _choosenValue,
                          items: <String>[
                            'Multiple Choice',
                            'CheckBox',
                            'DropDown',
                            'Linear Scale',
                            'TextField'
                          ].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _choosenValue = value!;
                              widget.choiceCallback!(value);
                              _mcqOptions = [TextEditingController()];
                              _checkBoxOptions2 = [TextEditingController()];
                              _checkBoxOptions3 = [TextEditingController()];
                              options1 = [''];
                              options2 = [''];
                              options3 = [''];
                              options4 = [''];
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),

                InkWell(
                    child: Icon(EvilIcons.image, size: 26),
                    onTap: () {
                      if (widget.helper?.imgUrl == null ||
                          ((widget.helper?.imgUrl.isEmpty) ?? true)){
                        _loadFromGallery(context);
                      }
                    }),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                    child: Icon(Ionicons.ios_add_circle_outline),
                    onTap: () {
                      widget.funcCallback!("add");
                    }),
                // InkWell(
                //     child: Icon(AntDesign.playcircleo),
                //     onTap: () {
                //       if (widget.helper?.vidUrl == null) {
                //         _pickVideo();
                //       }
                //     }),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              controller: question,
              decoration: new InputDecoration(
                  hintText: "Question",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                  border: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.red))),
              onChanged: (value) {
                print(value);
                widget.questionCallback!(question.text.toString());
              },
            ),
            optionsContainer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoSwitch(
                  activeColor: Colors.blue,
                  value: mandatory,
                  onChanged: (v) => setState(() {
                    mandatory = v;
                    widget.mandatoryCallback!(v);
                  }),
                ),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    widget.funcCallback!("copy");
                  },
                ),
                IconButton(
                  icon: Icon(AntDesign.delete),
                  onPressed: () {
                    widget.funcCallback!("delete");
                  },
                ),
              ],
            ),
            (widget.helper?.imgUrl != null &&
                    (widget.helper?.imgUrl.isNotEmpty ?? false))
                ? Stack(
                    children: [
                      Image.network(
                        Constants.ImageBaseUrl + (widget.helper?.imgUrl ?? ''),
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              showDeleteDialog(context, () {
                                widget.deleteMediaCallback!('image');
                                setState(() {});
                                Navigator.pop(context);
                              });
                            },
                          )),
                    ],
                  )
                : Container(),
            widget.helper?.vidUrl != null &&
                    ((widget.helper?.vidUrl.isNotEmpty) ?? false)
                ? Stack(
                    children: [
                      VideoItem(
                        url: Constants.ImageBaseUrl +
                            (widget.helper?.vidUrl ?? ""),
                      ),
                      Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              showDeleteDialog(context, () {
                                widget.deleteMediaCallback!('video');
                                setState(() {});
                                Navigator.pop(context);
                              });
                            },
                          )),
                    ],
                  )
                : Container(),
            widget.helper?.image != null
                ? Stack(
                    children: [
                      widget.helper?.image != null
                          ? Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: new DecorationImage(
                                  image: new FileImage(widget.helper!.image!),
                                  fit: BoxFit.fill,
                                ),
                              ))
                          : SizedBox(),
                      Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              showDeleteDialog(context, () {
                                widget.funcCallback!('image');
                                setState(() {});
                                Navigator.pop(context);
                              });
                            },
                          )),
                    ],
                  )
                : Container(),
            widget.helper?.video != null
                ? Stack(
                    children: [
                      if (widget.helper?.video != null)
                        VideoItemLocal(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          file: widget.helper!.video!,
                        ),
                      Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              showDeleteDialog(context, () {
                                widget.funcCallback!('video');
                                setState(() {});
                                Navigator.pop(context);
                              });
                            },
                          )),
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget optionsContainer() {
    if (_choosenValue == 'Multiple Choice') {
      return Column(
        children: [
          Container(
            height: _mcqOptions.length * 45.0,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: _mcqOptions.length,
                itemBuilder: (BuildContext context, int index) {
                  return TextField(
                    controller: _mcqOptions[index],
                    decoration: new InputDecoration(
                      prefixIcon: Icon(
                        CupertinoIcons.circle,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          CupertinoIcons.delete,
                        ),
                        onPressed: () {
                          if (index != 0) {
                            _mcqOptions.removeAt(index);
                            options1.removeAt(index);
                            setState(() {});
                          }
                        },
                      ),
                      hintText: "type Option here",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      options1[index] = _mcqOptions[index].text.toString();
                      widget.options1ListCallBack!(options1);
                      setState(() {});
                    },
                    // onEditingComplete: ,
                    // onSubmitted: ,
                  );
                }),
          ),
          TextField(
            showCursor: false,
            readOnly: true,
            // controller: _mcqOptions[index],
            decoration: new InputDecoration(
                prefixIcon: Icon(
                  CupertinoIcons.circle,
                ),
                hintText: "Add Other",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                border: InputBorder.none),
            onTap: () {
              _mcqOptions.add(TextEditingController());
              options1.add('');
              setState(() {});
              //  print('added oth');
            },
          ),
        ],
      );
    } else if (_choosenValue == 'TextField') {
      return Container();
    } else if (_choosenValue == 'Linear Scale') {
      return Container(
        height: 45.0,
        width: MediaQuery.of(context).size.width,
        child: Row(children: [
          SizedBox(
            width: 10,
          ),
          Container(
            width: 30,
            child: TextField(
              controller: first,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                linearoptions[0] = first.text.toString();
                widget.options4ListCallBack!(linearoptions);
                setState(() {});
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text('to'),
          SizedBox(
            width: 10,
          ),
          Container(
            width: 30,
            child: TextField(
              controller: last,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                linearoptions[1] = last.text.toString();
                widget.options4ListCallBack!(linearoptions);
                setState(() {});
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ]),
      );
    } else if (_choosenValue == 'CheckBox') {
      //dropdown or checkbox
      return Column(
        children: [
          Container(
            height: _checkBoxOptions2.length * 45.0,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: _checkBoxOptions2.length,
                itemBuilder: (BuildContext context, int index) {
                  return TextField(
                    controller: _checkBoxOptions2[index],
                    decoration: new InputDecoration(
                      prefixIcon: Icon(
                        Icons.check_box_outline_blank,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          CupertinoIcons.delete,
                        ),
                        onPressed: () {
                          if (index != 0) {
                            _checkBoxOptions2.removeAt(index);
                            options2.removeAt(index);
                            setState(() {});
                          }
                        },
                      ),
                      hintText: "type Option here",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      options2[index] =
                          _checkBoxOptions2[index].text.toString();
                      widget.options2ListCallBack!(options2);
                      setState(() {});
                    },
                    // onEditingComplete: ,
                    // onSubmitted: ,
                  );
                }),
          ),
          TextField(
            showCursor: false,
            readOnly: true,
            // controller: _mcqOptions[index],
            decoration: new InputDecoration(
                prefixIcon: Icon(
                  Icons.check_box_outline_blank,
                ),
                hintText: "Add Other",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                border: InputBorder.none),
            onTap: () {
              _checkBoxOptions2.add(TextEditingController());
              options2.add('');
              setState(() {});
              //  print('added oth');
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            height: _checkBoxOptions3.length * 45.0,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: _checkBoxOptions3.length,
                itemBuilder: (BuildContext context, int index) {
                  return TextField(
                    controller: _checkBoxOptions3[index],
                    decoration: new InputDecoration(
                      prefixIcon: Icon(
                        Icons.check_box_outline_blank,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          CupertinoIcons.delete,
                        ),
                        onPressed: () {
                          if (index != 0) {
                            _checkBoxOptions3.removeAt(index);
                            options3.removeAt(index);
                            setState(() {});
                          }
                        },
                      ),
                      hintText: "type Option here",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      options3[index] =
                          _checkBoxOptions3[index].text.toString();
                      widget.options3ListCallBack!(options3);
                      setState(() {});
                    },
                    // onEditingComplete: ,
                    // onSubmitted: ,
                  );
                }),
          ),
          TextField(
            showCursor: false,
            readOnly: true,
            // controller: _mcqOptions[index],
            decoration: new InputDecoration(
                prefixIcon: Icon(
                  Icons.check_box_outline_blank,
                ),
                hintText: "Add Other",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                border: InputBorder.none),
            onTap: () {
              _checkBoxOptions3.add(TextEditingController());
              options3.add('');
              setState(() {});
              //  print('added oth');
            },
          ),
        ],
      );
    }
  }
}
