import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  emptyTextField(){
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title:Row(
          children: [
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
          Expanded(
            child: Container(
              child: Text("Messages"),
            ),
          ),

          Container(

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageController,
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
                        prefixIcon: Icon(Icons.search,color: Colors.grey,),
                        suffixIcon: IconButton(icon: Icon(Icons.clear,color: Colors.grey,), onPressed: (){
                          emptyTextField();
                        })
                    )
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
