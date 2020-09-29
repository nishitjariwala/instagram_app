import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _submit() {}
  _signup() {}
  _forgotPassword() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Instagram',
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'Billabong',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  child: Form(
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Email'),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onPressed: () async {},
                              elevation: 2,
                              color: Colors.blue,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              )),
                        ),
                      )
                    ],
                  ),

                          SizedBox(
                            height: 2.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Forgot your password?'),
                              FlatButton(
                                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                                  onPressed: _forgotPassword,
                                  child: Text('Get help',
                                      style: TextStyle(
                                          color: Colors.blueAccent, fontSize: 16)))
                            ],
                          ),
                          Row(
                            children: [
                              Divider(
                                color: Colors.black,
                                height: 1.0,
                                thickness: 1.0,
                                endIndent: 200,
                              ),
                              Text('OR'),
                              Divider(
                                color: Colors.black,
                                height: 1.0,
                                thickness: 1.0,
                              ),
                            ],
                          )
                        ],
                      )),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don't have an account ?"),
          FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 0.0),
              onPressed: _signup,
              child: Text(
                'Sign up',
                style: TextStyle(color: Colors.blueAccent, fontSize: 18),
              )),
        ],
      ),
    );
  }
}
