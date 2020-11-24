import 'package:flutter/material.dart';
import 'HomePage.dart';
import '../User/user.dart';
import '../widgets/Post.dart';
import '../widgets/Progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DirectMessage.dart';


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
  noPostPage(){
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No Posts Yet",textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }

  createFeed() {
    return StreamBuilder(
      stream: postsDb.document("6de2faee-8620-46fe-8a03-b2a642951589").collection("userPosts").snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        final post = snapshot.data.documents;

        for (var p in post){
          final timestamp=p.data['timestamp'];
          final post_url=p.data['post_url'];
          final username=p.data['username'];
          final ownerId=p.data['ownerId'];
          final location=p.data['location'];
          final likes=p.data['likes'];
          final description=p.data['description'];
          final postId=p.data['postId'];
          final Post postDisplay =Post(timestamp: timestamp,post_url: post_url,username: username,ownerId: ownerId,location: location,likes: likes,description: description,postId: postId,);
          posts.add(postDisplay);

        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: posts,
            //children: textWidgets,
          ),
        );
      },


    );
  }

  @override
  Widget build(BuildContext context) {


    print(followingLists);
    return Scaffold(
      key: scaffoldKey,
      endDrawer: new Container(
          child: DirectMessage(),

      ),
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>DirectMessage()));
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
      body: posts==null?noPostPage():ListView(
        children:posts
      ),

    );
  }
}

class FeedPage1 extends StatefulWidget {
  final User currentUser;
  FeedPage1(this.currentUser);
  @override
  _FeedPage1State createState() => _FeedPage1State();
}

class _FeedPage1State extends State<FeedPage1> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Post> posts;
  List<String> followingList;
  retriveFollowing()async{
    QuerySnapshot querySnapshot = await followingDb.document(widget.currentUser.id).collection("userFollowing").getDocuments();
    setState(() {
      followingList = querySnapshot.documents.map((document) => document.documentID).toList();
    });
  }
  retriveTimeline()async{
    QuerySnapshot querySnapshot = await feedDb.document(widget.currentUser.id).collection("timelinePosts").orderBy("timestamp",descending: true).getDocuments();

    List<Post> allPost = querySnapshot.documents.map((document) => Post.fromDocument(document)).toList();
    setState(() {
      this.posts = allPost;
    });
  }
  createUserFeed(){
    if(posts==null){
      return circularProgress();
    }
    else{
      return ListView(
        children: posts,
      );
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retriveFollowing();
    retriveTimeline();
  }

  @override
  Widget build(BuildContext context) {
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
      body: RefreshIndicator(
        child: createUserFeed(),
        onRefresh: (){
          retriveTimeline();
        },
      ),
    );
  }
}

