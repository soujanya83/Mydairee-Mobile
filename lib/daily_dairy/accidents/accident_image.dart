import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

class AccidentImage extends StatefulWidget {
  @override
  _AccidentImageState createState() => _AccidentImageState();
}

class _AccidentImageState extends State<AccidentImage> {
  final _imageKey = GlobalKey<ImagePainterState>();
  late ImagePainterController _controller;  // ✅ Add controller

  @override
  void initState() {
    super.initState();
    _controller = ImagePainterController(  // ✅ Set properties in controller
      mode: PaintMode.line,  // Equivalent to initialPaintMode
      strokeWidth: 2,  // Equivalent to initialStrokeWidth
      color: Colors.green,  // Equivalent to initialColor
    );
  }

  void saveImage() async {
    final image = await _controller.exportImage();
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to export image")),
      );
      return;
    }

    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath = '$directory/sample/${DateTime.now().millisecondsSinceEpoch}.png';
    final imgFile = File(fullPath);
    
    await imgFile.writeAsBytes(image);

    final imgfilefinal = base64Encode(await imgFile.readAsBytes());

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
                onPressed: () => OpenFile.open(fullPath),
                child: Text("Open", style: TextStyle(color: Colors.blue[200]))),
          ],
        ),
      ),
    );

    Navigator.pop(context, imgfilefinal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(
          IconButton(onPressed: saveImage, icon: Icon(Icons.save))),
      body: ImagePainter.asset(
        Constants.ACCIDENT_IMG,
        key: _imageKey,
        controller: _controller,  // ✅ Pass the updated controller
        scalable: true,  // Optional: Allows zooming & panning
        showControls: true,  // Optional: Displays UI controls for painting
      ))
    ;
  }
}
