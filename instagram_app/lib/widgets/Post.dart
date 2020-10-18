import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/HomePage.dart';
import 'Progress.dart';
import '../User/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../screens/ProfilePage.dart';
import 'dart:async';
//
//class Post extends StatefulWidget {
//
//  final String postId;
//  final String ownerId;
////  final String timestamp;
//  final dynamic likes;
//  final String username;
//  final String description;
//  final String location;
//  final String post_url;
//  Post({
//    this.postId,
//    this.ownerId,
////    this.timestamp,
//    this.likes,
//    this.username,
//    this.description,
//    this.location,
//    this.post_url,
////    this.timestamp
//  });
//
//  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
//    return Post(
//      description: documentSnapshot['description'],
//      likes: documentSnapshot['likes'],
//      location: documentSnapshot['location'],
//      ownerId: documentSnapshot['ownerId'],
//      postId: documentSnapshot['postId'],
////      timestamp: documentSnapshot['timestamp'],
//      post_url: documentSnapshot['post_url'],
//      username: documentSnapshot['username'],
//    );
//  }
//
//  int getTotalNumberOfLikes(likes) {
//    if (likes == null) {
//      return 0;
//    } else {
//      int counter = 0;
//      likes.values.forEach((eachValue) {
//        if (eachValue == true) {
//          counter = counter + 1;
//        }
//      });
//      return counter;
//    }
//  }
//
//  @override
//  _PostState createState() => _PostState();
//}
//
//class _PostState extends State<Post> {
//
//  final String postId;
//  final String ownerId;
////  final String timestamp;
//  Map likes;
//  final String username;
//  final String description;
//  final String location;
//  final String post_url;
//  int likeCount;
//  bool showHeart = false;
//  final String currentUserId = currentUser.id;
//  bool isLiked ;
//  int count=0;
//  User owner;
//
//
//
//  _PostState({
//    this.postId,
//    this.ownerId,
////    this.timestamp,
//    this.likes,
//    this.username,
//    this.description,
//    this.location,
//    this.post_url,
//    this.likeCount,
//  });
//
//
//  removeLike(){
//    bool isOwner = currentUserId != ownerId;
//    if(isOwner){
//      activityDb.document(ownerId).collection("feedItems").document(postId).get().then((document){
//        if(document.exists){
//          document.reference.delete();
//        }
//      });
//    }
//  }
//  addLike(){
//    bool isOwner = ownerId != currentUserId;
//    if(isOwner){
//      activityDb.document(ownerId).collection("feedItems").document(postId).setData({
//        "type" : "like",
//        "username" : currentUser.username,
//        "userId" : currentUserId,
//        "timestamp" : DateTime.now(),
//        "url" : post_url,
//        "postId" : postId,
//        "userProfileImage" : currentUser.url,
//      });
//    }
//  }
//
//  controlLike(){
//    bool like = likes[currentUserId]==true;
//
//    print(" incontrol like");
//    if(like){
//      print("like is true so its becomeing false");
//      activityDb.document(ownerId).collection("userPosts").document(postId).updateData({"likes.$currentUserId": false,});
//      setState(() {
//        likeCount=likeCount-1;
//        isLiked=false;
//        likes[currentUserId]=false;
//        print(isLiked);
//      });
//    }
//    else if(!like){
//      print("like is false so its becoming true");
//      activityDb.document(ownerId).collection("userPosts").document(postId).updateData({"likes.$currentUserId": true,});
//      addLike();
//      setState(() {
//        likeCount = likeCount+1;
//        isLiked = true;
//        likes[currentUserId]=true;
//        showHeart = true;
//      });
//      Timer(Duration(milliseconds: 800), (){
//        setState(() {
//          showHeart=false;
//        });
//      });
//    }
//  }
//
//
//  PostDesign(){
//    return FutureBuilder(
//      future: userDb.document(ownerId).get(),
//      builder: (context, dataSnapshot) {
//        if (!dataSnapshot.hasData) {
//          return circularProgress();
//        }
//        owner =User.fromDocument(dataSnapshot.data);
//        bool isPostOwner = currentUserId == ownerId;
//
//        return owner.email==null? circularProgress(): Padding(
//          padding: const EdgeInsets.symmetric(horizontal: 0),
//          child: ListView(
//            children: <Widget>[
//              ListTile(
//                leading: CircleAvatar(
//                  backgroundImage: CachedNetworkImageProvider(owner.url),
//                  backgroundColor: Colors.grey,
//                ),
//                title: GestureDetector(
//                  onTap: () {
//                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(userProfileId: owner.id,)));
//
//                  },
//                  child: Text(
//                    owner.profileName,
//                    style: TextStyle(
//                      color: Colors.black,
//                      fontSize: 17,
//                      fontWeight: FontWeight.bold,
//                    ),
//                  ),
//                ),
//                subtitle: Text(location,style: TextStyle(color: Colors.grey),),
//                trailing: isPostOwner ? IconButton(
//                    icon: Icon(
//                      Icons.more_vert,
//                      color: Colors.grey,
//                    ),
//                    onPressed: (){
//                      print("More Option clicked");
//                    }) : null,
//              ),
//              Container(
//                child: GestureDetector(
//                  onDoubleTap: (){
//                    print("Post Liked");
////                    controlLike();
//                  },
//                  child: Stack(
//                    alignment: Alignment.center,
//                    children: <Widget>[
//                      Image(
//                        image: CachedNetworkImageProvider(post_url),
//                      ),
//                      showHeart ? Icon(Icons.favorite,size: 100,color: Colors.red,): Text(""),
//                    ],
//                  ),
//                ),
//              ),
//              Column(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  Padding(
//                    padding: const EdgeInsets.symmetric(vertical: 20),
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.start,
//                      children: <Widget>[
//
//                        GestureDetector(
//                          onTap: (){
//                            print("Tap On Like Icon");
////                            controlLike();
//                            print(isLiked);
//                          },
//                          child: isLiked ? Icon(Icons.favorite, color: Colors.red[800],size: 28,) : Icon(Icons.favorite_border,color: Colors.black,size: 28,),
//                        ),
//                        GestureDetector(
//                          onTap: (){
//                            print("Tap On Comment Icon");
////                            displayComment(context,postId: postId,url: url);
//                          },
//                          child: Icon(Icons.chat_bubble_outline, color: Colors.black,size: 28,),
//                        ),
//                      ],
//                    ),
//                  ),
//                  Row(
//                    children: <Widget>[
//                      Container(
//                        child: Text(
//                          likeCount==1 ? "$likeCount like" : "$likeCount likes",
//                          style: TextStyle(
//                            color: Colors.black,
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                  Row(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Container(
//                        child: Text("$username  ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),
//                      ),
//                      Expanded(
//                        child: Text("$description", style: TextStyle(color: Colors.black),),
//                      )
//                    ],
//                  )
//                ],
//              ),
//
//            ],
//          ),
//        );
//
//      },
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    setState(() {
////      isLiked = likes[currentUserId]==true;
//    });
//    return Padding(
//      padding: EdgeInsets.all(12),
//      child: Column(
//
//        children: <Widget>[
//          PostDesign(),
//        ],
//      ),
//    );
//  }
//}

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final Timestamp timestamp;
  final String username;
  final String description;
  final String location;
  final String post_url;
  final dynamic likes;

  Post(
      {this.post_url,
      this.postId,
      this.ownerId,
      this.timestamp,
      this.username,
      this.description,
      this.location,
      this.likes});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      timestamp: documentSnapshot['timestamp'],
      username: documentSnapshot['username'],
      ownerId: documentSnapshot['ownerId'],
      postId: documentSnapshot['postId'],
      location: documentSnapshot['location'],
      likes: documentSnapshot['likes'],
      description: documentSnapshot['description'],
      post_url: documentSnapshot['post_url'],
    );
  }

  int getTotalLikes(likes) {
    if (likes == null) {
      return 0;
    } else {
      int counter = 0;
      likes.values.forEach((eachValue) {
        if (eachValue == true) {
          counter = counter + 1;
        }
      });
      return counter;
    }
  }

  @override
  _PostState createState() => _PostState(
        likeCount: getTotalLikes(this.likes),
        description: this.description,
        postId: this.postId,
        likes: this.likes,
        location: this.location,
        ownerId: this.ownerId,
        post_url: this.post_url,
        timestamp: this.timestamp,
        username: this.username,
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final Timestamp timestamp;
  final String username;
  final String description;
  final String location;
  final String post_url;
  Map likes;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final currentUserId = currentUser?.id;

  _PostState(
      {this.post_url,
      this.postId,
      this.ownerId,
      this.timestamp,
      this.username,
      this.description,
      this.location,
      this.likes,
      this.likeCount});

  void handleClick(String value) {
    switch (value) {
      case 'Delete':
        print("Delete");
        postsDb.document(ownerId).collection('userPosts').document(postId).delete();
        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
        break;
      case 'Edit':
        print("Edit Post");
    }
  }

  buildPost() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey)
        ),
        child: Column(
          children: <Widget>[
            FutureBuilder(
              future: userDb.document(ownerId).get(),
              builder: (context, dataSnapshot) {
                if (!dataSnapshot.hasData) {
                  return circularProgress();
                }
                User owner = User.fromDocument(dataSnapshot.data);
                bool isOwner;
                if (currentUserId == ownerId) {
                  isOwner = true;
                } else {
                  isOwner = false;
                }
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(owner.url),
                    backgroundColor: Colors.grey,
                  ),
                  title: GestureDetector(
                    child: Text(owner.profileName),
                    onTap: () {
                      print("Go to the user Profile");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            userProfileId: ownerId,
                          ),
                        ),
                      );
                    },
                  ),
                  subtitle: Text(location),
                  trailing: isOwner
                      ? PopupMenuButton<String>(
                          onSelected: handleClick,
                          itemBuilder: (BuildContext context) {
                            return {'Delete','Edit'}.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        )
                      : Text(""),
                );
              },
            ),
            GestureDetector(
              onDoubleTap: () {
                print("Post Liked");
                controlLike();
              },
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CachedNetworkImage(
                      imageUrl: post_url,
                    ),
                  ),
                  showHeart
                      ? Icon(
                          Icons.favorite,
                          size: 100,
                          color: Colors.red,
                        )
                      : Text(""),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 40, left: 8),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("Post Like");
                        controlLike();
                      },
                      child: isLiked
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 28,
                            )
                          : Icon(
                              Icons.favorite_border,
                              size: 28,
                              color: Colors.grey[600],
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("show Comment");
                      },
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey[600],
                        size: 28,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          "$likeCount Likes",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Text(
                          "$username ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          description,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  timeago.format(timestamp.toDate()),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                  ),

                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  removeLike() {
    bool isOwner = currentUserId != ownerId;
    if (isOwner) {
      activityDb
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isOwner = ownerId != currentUserId;
    if (isOwner) {
      activityDb
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUserId,
        "timestamp": DateTime.now(),
        "url": post_url,
        "postId": postId,
        "userProfileImage": currentUser.url,
      });
    }
  }

  controlLike() {
    bool like = likes[currentUserId] == true;

    print(" incontrol like");
    if (like) {
      print("like is true so its becomeing false");
      postsDb
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({
        "likes.$currentUserId": false,
      });
      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentUserId] = false;
        print(isLiked);
      });
    } else if (!like) {
      print("like is false so its becoming true");
      postsDb
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({
        "likes.$currentUserId": true,
      });
      addLike();
      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      isLiked = likes[currentUserId] == true;
    });
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildPost(),
        ],
      ),
    );
  }
}
