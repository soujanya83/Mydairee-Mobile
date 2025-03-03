import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class AccidentImage extends StatefulWidget {
  @override
  _AccidentImageState createState() => _AccidentImageState();
}

class _AccidentImageState extends State<AccidentImage> {
  final _imageKey = GlobalKey<ImagePainterState>();

  void saveImage() async {
    final image = await _imageKey.currentState.exportImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath =
        '$directory/sample/${DateTime.now().millisecondsSinceEpoch}.png';
    final imgFile = File('$fullPath');
    imgFile.writeAsBytesSync(image);
    final imgfilefinal= base64Encode(imgFile.readAsBytesSync());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[700],
        padding: const EdgeInsets.only(left: 10),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Image Exported successfully.",
                style: TextStyle(color: Colors.white)),
            TextButton(
                onPressed: () => OpenFile.open("$fullPath"),
                child: Text("Open", style: TextStyle(color: Colors.blue[200])))
          ],
        ),
      ),
    );
    
    Navigator.pop(context,imgfilefinal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(
          IconButton(onPressed: saveImage, icon: Icon(Icons.save))),
      body: ImagePainter.asset(
        Constants.ACCIDENT_IMG,
        key: _imageKey,
        initialStrokeWidth: 2,
        initialColor: Colors.green,
        initialPaintMode: PaintMode.line,
      ),
    );
  }
}
