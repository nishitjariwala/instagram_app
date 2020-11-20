import 'package:flutter/material.dart';
import '../widgets/Progress.dart';
import 'HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/gestures.dart';
import 'ProfilePage.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String postUrl;
  CommentsPage({
    this.postUrl,
    this.ownerId,
    this.postId,
  });
  @override
  CommentsPageState createState() => CommentsPageState(postId: postId,postUrl: postUrl,ownerId: ownerId,);
}

class CommentsPageState extends State<CommentsPage> {
  final String postId;
  final String ownerId;
  final String postUrl;
  TextEditingController commentController = TextEditingController();


  CommentsPageState({
    this.postUrl,
    this.ownerId,
    this.postId,
  });


  displayComments(){
    return StreamBuilder(
        stream: commentsDb.document(postId).collection("comments").orderBy("timestamp",descending: true).snapshots(),
        builder: (context,dataSnapshot){
          if(!dataSnapshot.hasData){
            return circularProgress();
          }
          List<Comment> comments = [];
          dataSnapshot.data.documents.forEach((document){
            comments.add(Comment.fromDocument(document));
          });
          return ListView(
            children: comments,
          );
        }
    );
  }
  saveComment(){
    String comment;
    comment = commentController.text;
    if(comment.isNotEmpty){
      commentsDb.document(postId).collection("comments").add({
        "url": currentUser.url,
        "userId": currentUser.id,
        "username": currentUser.username,
        "timestamp": DateTime.now(),
        "comment": comment,
      });
      bool isNotOwner = ownerId != currentUser.id;
      if(isNotOwner){
        activityDb.document(ownerId).collection("feedItems").add({
          "type" : "comment",
          "postId": postId,
          "userProfileImage": currentUser.url,
          "postUrl": postUrl,
          "userId": currentUser.id,
          "username": currentUser.username,
          "comment": comment,
          "timestamp": DateTime.now(),
        });
      }
      commentController.clear();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: displayComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: "Comment..",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey,)
                ),
                focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black,)
                ),
              ),
              style: TextStyle(
                  color: Colors.black
              ),
            ),
            trailing: GestureDetector(
              child: Icon(Icons.send),
              onTap: (){
                saveComment();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  Comment({
    this.timestamp,
    this.url,
    this.username,
    this.userId,
    this.comment,
  });
  factory Comment.fromDocument(DocumentSnapshot documentSnapshot){
    return Comment(
      url: documentSnapshot["url"],
      userId: documentSnapshot["userId"],
      username: documentSnapshot["username"],
      timestamp: documentSnapshot["timestamp"],
      comment: documentSnapshot["comment"],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Container(

        child: Column(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(currentUser.url),
                radius: 25,
              ),
              title: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black,fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(text: username+"  ", style: TextStyle(fontWeight: FontWeight.bold),recognizer: TapGestureRecognizer()..onTap = (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(userProfileId: userId,)));
                    }),
                    TextSpan(text: comment),
                  ],
                ),
              ),
              subtitle: Text(timeago.format(timestamp.toDate()),style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}
