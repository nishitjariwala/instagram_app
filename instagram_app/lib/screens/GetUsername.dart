import 'package:flutter/material.dart';
import 'dart:async';


class GetUserName extends StatefulWidget {

  @override
  _GetUserNameState createState() => _GetUserNameState();
}

class _GetUserNameState extends State<GetUserName> {
  TextEditingController usernameController = TextEditingController();

  final _Scaffold = GlobalKey<ScaffoldState>();

  final _formKey=GlobalKey<FormState>();

  String userName;

  submitUserName(){
    final form = _formKey.currentState;
    if(form.validate()){
      form.save();

      SnackBar snackBar = SnackBar(content: Text("Welcome "+ userName));
      _Scaffold.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds:2),(){
        Navigator.pop(context, userName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _Scaffold,
      appBar: AppBar(
        title: Text("Setting",),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Text("Enter Your Username"),
                Form(
                  autovalidate: true,
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(
                          color: Colors.black,

                        ),
                        validator: (value){
                          if(value.trim().length<5 || value.isEmpty){
                            return "Enter Proper Username";
                          }
                          else{
                            return null;
                          }
                        },
                        onSaved: (value){
                          userName=value;
                        },
                      ),
                      RaisedButton(
                        onPressed: (){
                          submitUserName();
                        },
                        child: Text("Proceed"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
