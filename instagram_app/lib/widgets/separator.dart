import 'package:flutter/material.dart';
class Separator extends StatelessWidget {
  const Separator({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        child: Container(
            margin: EdgeInsets.only(left: 10.0, right: 15.0),
            child: Divider(
              color: Colors.grey,
              height: 50,
            )),
      ),

      Text("OR",style: TextStyle(color: Colors.grey),),

      Expanded(
        child: Container(
            margin: EdgeInsets.only(left: 15.0, right: 10.0),
            child: Divider(
              color: Colors.grey,
              height: 50,
            )),
      ),
    ]);
  }
}
