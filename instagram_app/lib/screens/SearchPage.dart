import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomePage.dart';
import '../widgets/Progress.dart';
import '../User/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'ProfilePage.dart';
//import '../widgets/HeaderPage.dart';

class SearchPage extends StatefulWidget {
  final User currentUser;
  SearchPage({this.currentUser});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{
  bool get wantKeepAlive=>true;

  TextEditingController searchEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  emptyTextField(){
    searchEditingController.clear();
  }

  controlSearching(String str){
    Future<QuerySnapshot> allUser = userDb.where('profileName' ,isGreaterThanOrEqualTo: str).getDocuments();
    setState(() {
      futureSearchResult = allUser;
    });
  }

  Widget searchAppBar(){

    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        style: TextStyle(fontSize: 18,color: Colors.black),
        controller: searchEditingController,
        decoration: InputDecoration(
            hintText: "Enter Username",
            hintStyle: TextStyle(color: Colors.grey,),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
              ),
            ),
            filled: true,
            prefixIcon: Icon(Icons.search,color: Colors.grey,),
            suffixIcon: IconButton(icon: Icon(Icons.clear,color: Colors.grey,), onPressed: (){
              emptyTextField();
            })
        ),
        onFieldSubmitted: controlSearching,
      ),
    );
  }
  Widget DisplayNoSearchResult(){
    return Text("No Result Found");
  }
  Widget DisplayUserScreen(){
    return FutureBuilder(
      future: futureSearchResult,
      builder: (context,dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }
        List<UserResult> searchUserResult=[];
        dataSnapshot.data.documents.forEach((document){
          User users = User.fromDocument(document);
          if(users.username!=widget.currentUser.username){
            UserResult userResult = UserResult(users);
            searchUserResult.add(userResult);
          }

        });
        return ListView(
          children: searchUserResult,
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: searchAppBar(),
      body: futureSearchResult==null ? DisplayNoSearchResult() : DisplayUserScreen(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);

  displayUserProfile(BuildContext context, User user){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(userProfileId: user.id ,)));
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: (){
                print("Tapped on "+user.profileName);
                displayUserProfile(context,user);
              },
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.black,backgroundImage: CachedNetworkImageProvider(user.url),),
                title: Text(
                  user.profileName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  user.username,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
