import 'package:flutter/material.dart';
import '../User/user.dart';
import '../widgets/Progress.dart';
import 'HomePage.dart';
import '../widgets/DisplayImage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'EditProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/Post.dart';
import '../widgets/PostTileWidget.dart';


class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() =>_ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool isOwner=false;
  User userProfile;
  String currentUserId = currentUser.id;
  String postOrientation="grid";
  List<Post> postsList = [];
  bool loading = false;
  int postCount = 0;
  int followerCount=0;
  int followingCount = 0;
  bool following = false;



  columnBuilder({String title, int count}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: <Widget>[
        Text(count.toString(),style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold,),),
        Text(title,style: TextStyle(fontSize: 13,color: Colors.black,),),
      ],
    );
  }
  displayEditButton(){
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Container(
        child: FlatButton(
          padding: EdgeInsets.all(0),
          color: Colors.grey[200],

          focusColor: Colors.grey,

          child: Text("Edit Profile",style: TextStyle(),),
          onPressed: (){
            print("Open Edit Profile");
            Navigator.push(context, MaterialPageRoute(builder: (context)=> EditProfile(user: userProfile,),),);
          },
        ),
      ),
    );
  }
  displayButtons(){
    return Row(
      children: <Widget>[
        Expanded(
          child: FlatButton(
            padding: EdgeInsets.all(0),
            color: Colors.blue,

            focusColor: Colors.blue,

            child: Text("Follow",style: TextStyle(color: Colors.white),),
            onPressed: (){
              print("Open Edit Profile");

            },
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width*0.05,
        ),
        Expanded(
          child: FlatButton(
            padding: EdgeInsets.all(0),
            color: Colors.grey[100],

            focusColor: Colors.grey,

            child: Text("Message",style: TextStyle(),),
            onPressed: (){
              print("Open Direct Message");

            },
          ),
        ),
      ],
    );
  }
  buildButton(){
    return isOwner ? displayEditButton() : displayButtons();
  }
  buildHeader(){
    return FutureBuilder(
        future: userDb.document(widget.userProfileId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          userProfile = User.fromDocument(dataSnapshot.data);
          return Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(userProfile.url,),
                      radius: 40,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          columnBuilder(title: "Posts",count: postCount),
                          columnBuilder(title: "Follower",count: followerCount),
                          columnBuilder(title: "Following",count: followingCount),
                        ],
                      ),
                    ),

                  ],

                ),
                SizedBox(
                  height: 10,
                ),
                Text(userProfile.profileName,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),),
                SizedBox(height: 5,),
                Text(userProfile.bio==""? "Enter Bio": userProfile.bio,style: TextStyle(color: Colors.grey,fontSize: 13,),),
                buildButton(),
              ],
            ),
          );
        },
    );
  }
  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        signOut();

    }
  }



  buildGridOrListView(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid" ? Colors.black : Colors.grey,
          onPressed: (){
            setState(() {
              postOrientation = "grid";
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.list),
          color: postOrientation == "list" ? Colors.black : Colors.grey,
          onPressed: (){
            setState(() {
              postOrientation = "list";
            });
          },
        ),
      ],
    );
  }
  buildList(){
    if(loading){
      return circularProgress();
    }
    else if(postsList.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
              child: Icon(Icons.photo_library,size: 250,color: Colors.grey,),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("No Posts",style: TextStyle(color: Colors.grey,fontSize: 42,),),
            )
          ],
        ),
      );
    }
    else if(postOrientation=="grid"){
      List<GridTile>  gridTile = [];
      postsList.forEach((eachPost){
        gridTile.add(GridTile(child: PostTile(post: eachPost,)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTile,
      );
    }
    else if(postOrientation=="list"){
      return Column(
        children: postsList,
      );

    }
  }



  void getUserData()async{
    DocumentSnapshot documentSnapshot = await userDb.document(widget.userProfileId).get();
    if(documentSnapshot.exists){
      userProfile = User.fromDocument(documentSnapshot);
    }
  }
  checkOwner(){
    if(widget.userProfileId==currentUserId){
      setState(() {
        isOwner = true;
      });
    }
    else{
      setState(() {
        isOwner = false;
      });
    }
  }
  alreadyFollwing(){
    followingDb.document(currentUserId).collection("userFollowing").document(widget.userProfileId).get().then((document){
      if(document.exists){
        setState(() {
          following = true;
        });
      }
      else if(!document.exists){
        setState(() {
          following = false;
        });
      }
    });
  }
  countFollower()async{
    QuerySnapshot querySnapshot = await followersDb.document(widget.userProfileId).collection("userFollower").getDocuments();
    setState(() {
      followerCount = querySnapshot.documents.length;
    });
  }
  countFollowing()async{
    QuerySnapshot querySnapshot = await followingDb.document(widget.userProfileId).collection("userFollowing").getDocuments();
    setState(() {
      followingCount = querySnapshot.documents.length;
    });
  }

  getAllProfilePost()async{
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postsDb.document(widget.userProfileId).collection("userPosts").orderBy("timestamp",descending: true).getDocuments();
    setState(() {
      loading = false;
      postCount = querySnapshot.documents.length;
      postsList = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
    checkOwner();
    getAllProfilePost();
    countFollower();
    countFollowing();
    alreadyFollwing();


  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          buildHeader(),
          buildGridOrListView(),
          buildList(),
        ],
      ),
    );
  }
}
