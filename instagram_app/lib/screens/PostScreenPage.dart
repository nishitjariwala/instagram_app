import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/Progress.dart';
import '../widgets/Post.dart';
//import '../widgets/HeaderPage.dart';



class PostScreenPage extends StatelessWidget {
  final String postId;
  final String userId;
  PostScreenPage({
    this.postId,
    this.userId
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsDb.document(userId).collection("userPosts").document(postId).get(),
      builder: (context,dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }
        Post post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: AppBar(
              title: Text("Post"),
              backgroundColor: Colors.white,
            ),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),

        );
      },
    );
  }
}
