import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../User/user.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;
import 'package:image/image.dart' as Imd;
import 'package:firebase_storage/firebase_storage.dart';
import 'HomePage.dart';
import '../widgets/Progress.dart';
import 'dart:math' as Math;

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:async';

class UploadPost extends StatefulWidget {
  @override
  _UploadPostState createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> with AutomaticKeepAliveClientMixin<UploadPost>{
  File image_file;
  bool get wantKeepAlive=>true;
  bool uploading = false;
  String postId =Uuid().v4();

  TextEditingController captionEditingController = TextEditingController();
  TextEditingController locationEditingController = TextEditingController();


  selectFromCamera() async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      image_file = image;
    });
  }

  selectFromGallery() async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image_file = image;
    });
  }

  selectPhoto(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Open Camera"),
                onPressed: () {
                  print("Opening Camera");
                  selectFromCamera();
                },
              ),
              SimpleDialogOption(
                child: Text("Open Galery"),
                onPressed: () {
                  print("Opening Gallery");
                  selectFromGallery();
                },
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () {
                  print("Cancelling Task");
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  displaySelectImageScreen() {
    var size = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Post"),
        backgroundColor: Colors.white,

      ),
      body: Container(
        width: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add_photo_alternate,
              size: size * 0.7,
              color: Colors.grey[300],
            ),
            RaisedButton(
              onPressed: () {
                selectPhoto(context);
              },
              child: Text("Select Image",style: TextStyle(color: Colors.white),),
              color: Colors.blue,
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          ],
        ),
      ),
    );
  }

  compressPhoto()async{
    final dir = await getTemporaryDirectory();
    final path = dir.path;
    ImD.Image imageFile = ImD.decodeImage(image_file.readAsBytesSync());
    final compressedImage = File('$path/img_$postId')..writeAsBytesSync(ImD.encodeJpg(imageFile,quality: 90));
    setState(() {
      image_file=compressedImage;
    });
  }

  Future<String> uploadPhoto(file)async{

    StorageUploadTask storageUploadTask = postImageReference.child("post_$postId.jpg").putFile(file);
    StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete;
    String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }
  savePostInfoToDB(String url, String location, String description){
    postsDb.document(currentUser.id).collection("userPosts").document(postId).setData({
      "postId" : postId,
      "ownerId" : currentUser.id,
      "timestamp":DateTime.now(),
      "likes": {},
      "username":currentUser.username,
      "description":description,
      "location":location,
      "post_url":url,
    });
  }

  controlUploadAndSave()async{
    setState(() {
      uploading=true;
    });


    String imageUrl = await uploadPhoto(image_file);
    print("Uploading");

    savePostInfoToDB(imageUrl,locationEditingController.text,captionEditingController.text);
    print("Uploaded Scccessfully");

    locationEditingController.clear();
    captionEditingController.clear();
    setState(() {
      image_file=null;
      uploading = false;
      postId = Uuid().v4();

    });


  }

  displayUploadPostScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          setState(() {
            image_file=null;
          });
        }),
        title: Text("New Post"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              onPressed: (){
                print("upload starting");
                uploading ? null : controlUploadAndSave();

              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Text("Post",style: TextStyle(color: Colors.white),),
              color: Colors.blue,
            ),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            uploading ? linearProgress() : Text(""),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 230,
                width: MediaQuery.of(context).size.width*0.8,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: FileImage(image_file),fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(360),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: captionEditingController,
                decoration: InputDecoration(
                  icon: Icon(Icons.comment),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Caption..',
                  labelText: 'Caption',
                  contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.blue),
                  ),
                  enabledBorder:OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.grey[400]),
                  ),
                ),
              ),
            ), 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: TextFormField(
                
                controller: locationEditingController,
                decoration: InputDecoration(
                  icon: Icon(Icons.location_on),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Location..',
                  labelText: 'Location',
                  contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.grey[400]),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return image_file == null
        ? displaySelectImageScreen()
        : image_file == null? circularProgress(): displayUploadPostScreen();
  }
}
