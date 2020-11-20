import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'ProfilePage.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'PostScreenPage.dart';
import '../widgets/Progress.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  retriveNotification()async{
    QuerySnapshot querySnapshot = await activityDb.document(currentUser.id).collection("feedItems").orderBy("timestamp",descending: true).limit(20).getDocuments();
    List<NotificationsItem> notificationsItem = [];
    querySnapshot.documents.forEach((dataSnapshot){
      notificationsItem.add(NotificationsItem.fromDocument(dataSnapshot));
    });
    return notificationsItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: FutureBuilder(
          future: retriveNotification(),
          builder: (context,dataSnapshot){
            if(!dataSnapshot.hasData){
              return circularProgress();
            }
            return ListView(
              children: dataSnapshot.data,
            );
          },
        ),
      ),
    );
  }
}

String notificationItemText;
Widget mediaPreview;


class NotificationsItem extends StatelessWidget {

  final String username;
  final String type;
  final String comment;
  final String postId;
  final String userId;
  final String userProfileImage;
  final String postUrl;
  final Timestamp timestamp;

  NotificationsItem({
    this.postId,
    this.username,
    this.postUrl,
    this.timestamp,
    this.userId,
    this.comment,
    this.type,
    this.userProfileImage
  });

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationsItem(
      postId: documentSnapshot['postId'],
      username:documentSnapshot['username'],
      type:documentSnapshot['type'],
      comment:documentSnapshot['comment'],
      userId:documentSnapshot['userId'],
      userProfileImage:documentSnapshot['userProfileImage'],
      postUrl:documentSnapshot['postUrl'],
      timestamp:documentSnapshot['timestamp'],
    );
  }

  configureMediaPreview(context){
    if(type=="comment" || type=="like"){
      mediaPreview = GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreenPage(postId: postId,userId: userId,),),);
        },
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: CachedNetworkImageProvider(postUrl),fit: BoxFit.fill),
              ),
            ),
          ),
        ),
      );
    }
    else{
      mediaPreview = Text("");
    }
    if(type=="like"){
      notificationItemText = " Liked Your Post";
    }
    else if(type=="comment"){
      notificationItemText = " Commented on your Post: $comment";
    }
    else{
      notificationItemText = " Started Following you";
    }

  }



  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: GestureDetector(
            onTap: (){
//              Write Function Here
//            Write Code to display User Profile page
//              Navigator.push(context, MaterialPageRoute(builder: (context)=>Pro ))
            },
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(text: username,style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: " $notificationItemText")
                ],

              ),
            ),
          ),
          leading: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(userProfileId: userId,)));
            },
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImage),
            ),
          ),
          subtitle: Text(timeAgo.format(timestamp.toDate()),overflow: TextOverflow.ellipsis,),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
