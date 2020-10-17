import 'package:flutter/material.dart';
import '../User/user.dart';
import '../widgets/Progress.dart';
import 'HomePage.dart';
import '../widgets/DisplayImage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'EditProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() =>_ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool isOwner=true;
  User userProfile;
  String currentUserId = currentUser.id;

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
          color: Colors.grey[100],

          focusColor: Colors.grey,

          child: Text("Edit Profile",style: TextStyle(),),
          onPressed: (){
            print("Open Edit Profile");
            Navigator.push(context, MaterialPageRoute(builder: (context)=> EditProfile(user: currentUser,),),);
          },
        ),
      ),
    );
  }
  displayButtons(){
    return Text("Hello");
  }
  buildButton(){
    return isOwner ? displayEditButton() : displayButtons();
  }


  buildHeader(){
    return Padding(
      padding: const EdgeInsets.only(left: 20),
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
                    columnBuilder(title: "Posts",count: 0),
                    columnBuilder(title: "Follower",count: 0),
                    columnBuilder(title: "Following",count: 0),
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
          Text(userProfile.bio,style: TextStyle(color: Colors.grey,fontSize: 13,),),

        ],
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        signOut();

    }
  }

  @override
  Widget build(BuildContext context) {
    
    return currentUser == null || userProfile ==null ? circularProgress(): Scaffold(
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
      body: Column(
        children: <Widget>[
          buildHeader(),
        ],
      ),
    );
  }
}
