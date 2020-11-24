import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'ChatScreen.dart';


class DirectMessage extends StatefulWidget {
  @override
  _DirectMessageState createState() => _DirectMessageState();
}

class _DirectMessageState extends State<DirectMessage> {



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
        ),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: chatListDb.document(currentUser.id).collection("list").snapshots(),
            builder: (context,snapshot){
              List<DisplayUser> displayUsers=[];
              if (!snapshot.hasData) {
                return Center(
                  child: Text("No Chats"),
                );

              }
              final displayUser = snapshot.data.documents;
              for(var i in displayUser){
                final userId = i.data['userId'];
                final name = i.data['name'];
                final url = i.data['url'];

                final display = DisplayUser(userId, name, url);
                displayUsers.add(display);
              }
              return ListView(

                children: displayUsers,
                //children: textWidgets,
              );
            },
          ),
        ),

      ),
    );
  }
}

class DisplayUser extends StatelessWidget {
  final String userId;
  final String url;
  final String name;
  DisplayUser(this.userId,this.name,this.url);

  displayChat(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(userId, url, name)));
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Card(
        elevation: 5,
        color: Colors.white,
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  print("Tapped on "+name);
                displayChat(context);
                },
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.black,backgroundImage: CachedNetworkImageProvider(url),),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

