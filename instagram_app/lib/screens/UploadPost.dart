import 'package:flutter/material.dart';
import 'dart:io';
import 'HomePage.dart';

class UploadPost extends StatefulWidget {
  @override
  _UploadPostState createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {
  File image_file;


  displaySelectImageScreen(){

    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
      ),
    );

  }
  displayUploadPostScreen(){

  }

  @override
  Widget build(BuildContext context) {
    return image_file==null ? displaySelectImageScreen() : displayUploadPostScreen();
  }
}
