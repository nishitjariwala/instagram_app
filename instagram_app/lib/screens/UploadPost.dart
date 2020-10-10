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
        title: Text("Post1"),
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            }),
      ),
      body: Container(
        width: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.photo_library,
              size: size * 0.7,
              color: Colors.grey[300],
            ),
            RaisedButton(
              onPressed: () {
                selectPhoto(context);
              },
              child: Text("Upload Image"),
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
      "url":url,
    });
  }

  controlUploadAndSave()async{
    setState(() {
      uploading=true;
    });
    await compressPhoto();

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
        title: Text("Post"),
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
        : displayUploadPostScreen();
  }
}
class UploadPage extends StatefulWidget {

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>{
  File file;

  bool uploading=false;
  String postId=Uuid().v4();
  bool get wantKeepAlive=>true;





  TextEditingController captionEditionController = TextEditingController();
  TextEditingController locationEditionController = TextEditingController();

  // TODO: To open Camera when Click on open Camera

  openCamera()async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,

    );
    setState(() {
      this.file=imageFile;
    });
  }
  // TODO: To open Gallery when Click on open Gallery

  openGallery()async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,

    );
    setState(() {
      this.file=imageFile;
    });
  }
  //TODO: when click on back button clear the post
  removePost(){
    locationEditionController.clear()
    ;captionEditionController.clear();
    setState(() {
      file = null;
    });
  }


  // TODO: CompressImage

  compressPhoto()async{

    final dir = await getTemporaryDirectory();
    final path = dir.path;
    ImD.Image imageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImage = File('$path/img_$postId')..writeAsBytesSync(ImD.encodeJpg(imageFile,quality: 90));
    setState(() {
      file=compressedImage;
    });
  }

  // TODO: Upload File to Firebase Storage
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
      "url":url,
    });
  }

  controlUploadAndSave()async{
    setState(() {
      uploading=true;
    });


    String imageUrl = await uploadPhoto(file);
    print("Uploading");

    savePostInfoToDB(imageUrl,locationEditionController.text,captionEditionController.text);
    print("Uploaded Scccessfully");

    locationEditionController.clear();
    captionEditionController.clear();
    setState(() {
      file=null;
      uploading = false;
      postId = Uuid().v4();

    });


  }
  takePhoto(nContext) {
    return showDialog(
        context: nContext,
        builder: (context){
          return SimpleDialog(
            backgroundColor: Colors.white,
            title: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text("New Post", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),

            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Open Camera",),

                onPressed: (){
                  print("open Camera");
                  openCamera();
                },
              ),

              SimpleDialogOption(
                child: Text("Open from Gallery"),
                onPressed: (){
                  print("Open Gallery");
                  openGallery();
                },
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: (){
                  print("Cancel Task");
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }

  Widget displayUploadScreen() {
    return Container(
//      color: Colors.grey.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.add_photo_alternate,
            size: 200,
            color: Colors.grey,
          ),
          RaisedButton(
            onPressed: () {
              takePhoto(context);
            },
            elevation: 5,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            child: Text(
              "Upload Post",
            ),
          ),
        ],
      ),
    );
  }

  displayUploadForm(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          print("Task Cancel");
          removePost();
        }),
        title: Text("New Post",style: TextStyle(color: Colors.black,fontSize: 24),),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: (){
                print("Start");
                print(uploading);
                uploading ? null : controlUploadAndSave();
              },
              color: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              child: Text("Post",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width*0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: FileImage(file),fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15,),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(currentUser.url),
            ),
            title: TextField(
              style: TextStyle(
                color: Colors.black,

              ),
              decoration: InputDecoration(
                focusColor: Colors.black,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                hintText: "Enter Caption",
              ),
              controller: captionEditionController,
            ),

          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.location_on,size: 40,),

            title: TextField(
              style: TextStyle(
                color: Colors.black,

              ),
              decoration: InputDecoration(
                focusColor: Colors.black,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                hintText: "Enter Location",
              ),
              controller: locationEditionController,
            ),

          ),


        ],
      ),


    );
  }


  @override


  Widget build(BuildContext context) {
    return file==null? displayUploadScreen(): displayUploadForm();
  }
}

