import 'package:flutter/material.dart';
import 'HomePage.dart';
import '../User/user.dart';

class FeedPage extends StatefulWidget {
  final User currentUser;
  FeedPage({this.currentUser});
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String name = currentUser.profileName;
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text("Welcome $name click to Sign out"),
      onPressed: (){
        signOut();
      },
    );
  }
}
