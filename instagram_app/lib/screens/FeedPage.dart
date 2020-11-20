import 'package:flutter/material.dart';
import 'HomePage.dart';
import '../User/user.dart';
import '../widgets/Post.dart';
import '../widgets/Progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedPage extends StatefulWidget {
  final User currentUser;
  FeedPage({this.currentUser});
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String name = currentUser.profileName;

  signOut() {
    googleSignIn.signOut();
    auth.signOut();
    setState(() {
      isSignedIn = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  List<Post> posts;
  List<String> postLists = [];
  List<String> followingLists = [];
  List<String> list = [];


  final scaffoldKey = GlobalKey<ScaffoldState>();

//  retriveTimeline() async {
//    QuerySnapshot querySnapshot = await feedDb
//        .document(widget.currentUser.id)
//        .collection("timelinePosts")
//        .orderBy("timestamp", descending: true)
//        .getDocuments();
//    List<Post> allPosts =
//        querySnapshot.documents.map((document) => Post.fromDocument(document));
//    setState(() {
//      this.posts = allPosts;
//    });
//  }

  retriveFollowing() async {
    QuerySnapshot querySnapshot = await followingDb
        .document(currentUser.id)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      followingLists = querySnapshot.documents
          .map((document) => document.documentID)
          .toList();
    });
    print("List is1");
    print('$followingLists');
    for (var id in followingLists) {
      QuerySnapshot querySnapshot = await postsDb
          .document(id)
          .collection("userPosts")
          .orderBy("timestamp", descending: true)
          .getDocuments();
      setState(() {
        posts = querySnapshot.documents.map((documentSnapshot) =>
            Post.fromDocument(documentSnapshot)).toList();
        list = querySnapshot.documents
            .map((document) => document.documentID)
            .toList();
        for (var listId in list) {
          postLists.add(listId);
        }
      });
    }
    print("Post List");
    print(postLists);
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retriveFollowing();
    print(followingLists);
  }

  createFeed() {
    if (posts == null) {
      return circularProgress();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(BuildContext context) {


    print(followingLists);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.near_me,
              color: Colors.black,
            ),
            onPressed: () {
              print("Open DM");
            },
          )
        ],
        leading: GestureDetector(
            onTap: () {
              print("Pressed Camera Icon");
            },
            child: Icon(
              Icons.camera_alt,
              color: Colors.black,
            )),
        title: Text(
          "Instagram",
          style: TextStyle(fontFamily: 'Billabong', fontSize: 35),
        ),
      ),
      body: posts==null?circularProgress():ListView(
        children: posts,
      ),

    );
  }
}
