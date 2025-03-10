import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

Future<File?> cropImage(BuildContext context, File imgFile) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: imgFile.path,
    // aspectRatioPresets: [
    //   CropAspectRatioPreset.square,
    //   CropAspectRatioPreset.ratio3x2,
    //   CropAspectRatioPreset.original,
    //   CropAspectRatioPreset.ratio4x3,
    //   CropAspectRatioPreset.ratio16x9,
    // ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        title: 'Crop Image',
      ),
    ],
  );

  if (croppedFile != null) {
    return File(croppedFile.path); // Convert CroppedFile to File
  }
  return null;
}
