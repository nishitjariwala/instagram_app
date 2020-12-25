import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
Dio dio = new Dio();



class ChatScreen extends StatefulWidget {
  final String userId;
  final String url;
  final String name;
  ChatScreen(this.userId,this.url,this.name);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController messageController = TextEditingController();
  String msg;
  bool isFriend=false;
  int report;


  emptyTextField(){
    messageController.clear();
  }

  isFriendCheck()async{
    List<String> followingLists=[];
    QuerySnapshot querySnapshot = await followersDb.document(currentUser.id).collection("userFollower").getDocuments();

    setState(() {
      followingLists = querySnapshot.documents
          .map((document) => document.documentID)
          .toList();
    });

    for(var f in followingLists){
      if(f==widget.userId){
        setState(() {
          print(isFriend);
          isFriend=true;
        });
      }
    }
  }
  displayError(context){
    return showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            title: Column(
              children: <Widget>[
                Text("you Have been Reported Because You Send Inappropriate Message To the person. You have been Reported $report Times"),
                RaisedButton(
                  child: Text("Ok",style: TextStyle(color: Colors.white),),
                  onPressed: (){
//                    if(report>=3){
//
//                    }
//                    else{
                      Navigator.pop(context);
//                    }
                  },
                  color: Colors.blue,
                ),
              ],
            ),

          );
        }
    );
  }




  sendMessage()async{
    isFriendCheck();
    if(!isFriend){


      //todo: herer os the Code for Check

      Dio dio = Dio();
      Response response = await dio.post("http://192.168.43.151:12345/predict", data: [{"tweet": msg}]);
      print(response.data["prediction"]);
      print("<<>>");
      bool abbusive= response.data["prediction"].toString()=="2"? false:true;
      print("message is" + msg);
      print("result is"+ abbusive.toString());
      if(abbusive){
        userDb.document(currentUser.id).updateData({
          'report': currentUser.report+1,
        });
        setState(() {
          report=currentUser.report+1;
          currentUser.report=currentUser.report+1;
        });
        emptyTextField();
        displayError(context);
        if(currentUser.report>=3){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
        }
        return null;
      }
    }

    if(msg.isEmpty){
      print("Null Message");
      return null;
    }

    DocumentSnapshot documentSnapshot = await chatListDb.document(currentUser.id).collection("list").document(widget.userId).get();
    if(!documentSnapshot.exists){
      print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

      print("Not exist");
      chatListDb.document(currentUser.id).collection("list").document(widget.userId).setData({
        'url':widget.url,
        'userId':widget.userId,
        'name':widget.name,
      });
      chatListDb.document(widget.userId).collection("list").document(currentUser.id).setData({
        'url':currentUser.url,
        'userId':currentUser.id,
        'name':currentUser.profileName,
      });
    }
    else{
      print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print("Exist");
    }


    chatDb.document(currentUser.id).collection("receiver").document(widget.userId).collection("messages").add({
      'msg': msg,
      'sender': currentUser.id,
      'receiver': widget.userId,
      'timestamp': DateTime.now(),
    });
    chatDb.document(widget.userId).collection("receiver").document(currentUser.id).collection("messages").add({
      'msg': msg,
      'sender': currentUser.id,
      'receiver': widget.userId,
      'timestamp': DateTime.now(),
    });
    emptyTextField();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isFriendCheck();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,

          title:Row(
            children: [
              IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back,color: Colors.purple,),
              ),
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(widget.url),
                radius: 20,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                widget.name,
              ),
            ],
          ) ,
          backgroundColor: Colors.white,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            streamBuilderWidget(widget.userId),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                color: Colors.transparent,
//              padding: Ed,

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        onChanged: (value){
                          msg=value;
                        },
                        decoration: InputDecoration(
                            hintText: "",
                            hintStyle: TextStyle(color: Colors.grey,),

                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(300),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(300),

                              borderSide: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            filled: true,
                            prefixIcon: IconButton(icon: Icon(Icons.clear,color: Colors.grey,), onPressed: (){
                              emptyTextField();
                            }),


                        )
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: Icon(Icons.send,color: Colors.white,),
                        onPressed: (){
                          sendMessage();
                        },

                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class streamBuilderWidget extends StatelessWidget {
  final String userId;
  streamBuilderWidget(this.userId);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: chatDb.document(currentUser.id).collection("receiver").document(userId).collection("messages").orderBy("timestamp",descending: true).snapshots(),
      builder: (context, snapshot) {
        List<messageDisplay> messageDisplayWidgets = [];
        if (!snapshot.hasData) {
          return Center(
            child: Text("No Chats"),
          );
        }

        final messages = snapshot.data.documents;

        for (var message in messages) {
          final text = message.data['msg'];
          final sender = message.data['sender'];
          final receiver=message.data['receiver'];
          final id = message.documentID;
          final messagedisplay = messageDisplay(
            text: text,
            sender: sender,
            receiver: receiver,
            isme: currentUser.id== sender,
            id: id,
          );
          messageDisplayWidgets.add(messagedisplay);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            children: messageDisplayWidgets,
            //children: textWidgets,
          ),
        );
      },
    );
  }
}

class messageDisplay extends StatelessWidget {
  messageDisplay({this.text, this.sender, this.isme,this.receiver,this.id});
  final String text;
  final String sender;
  final String receiver;
  final bool isme;
  final String id;
  final messageTextController = TextEditingController();

  checkTheText(){

    return Text(
      '$text',
      style: TextStyle(
        fontSize: 17,
        color: !isme? Colors.purpleAccent :Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:isme? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: <Widget>[

          Material(
              elevation: 5,
              borderRadius: BorderRadius.only(
                topLeft: isme ? Radius.circular(30) : Radius.circular(0),
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                topRight: isme ? Radius.circular(0) : Radius.circular(30),
              ),
              color: !isme ? Colors.white : Colors.purpleAccent,
              child: GestureDetector(

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: checkTheText(),
                ),
              )),
        ],
      ),
    );
  }
}

