import 'dart:io';

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class PickerImage extends StatefulWidget {
  @override
  _PickerImageState createState() => _PickerImageState();
}

class _PickerImageState extends State<PickerImage> {
  File _image;
  Future getImageFromCamera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          IconButton(
            icon: Icon(Icons.add_a_photo_rounded),
            onPressed: (){
              getImageFromCamera();
            },
          ),
          _image == null ? Container() : Image.file(_image , height: 100, width: 100,)
        ],
      ),

    );
  }
}
