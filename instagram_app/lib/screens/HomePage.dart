import 'package:flutter/material.dart';
import '../widgets/separator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'GetUsername.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final userDb = Firestore.instance.collection("user");

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;
  String email;
  String password;
  bool progress = false;

  final GlobalKey<FormState> _FormKey = GlobalKey<FormState>();

//  TODO: For Login & Signup Page
  bool isEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  Widget emailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: new InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Email',
          contentPadding:
              const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
          focusedBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.grey),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.grey[200]),
          ),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Email is Empty';
          } else if (!isEmail(value)) return ("Enter Proper Email");
        },
        onSaved: (String value) {
          email = value;
        },
      ),
    );
  }

  Widget passwordField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Password',
        contentPadding:
            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        focusedBorder: OutlineInputBorder(
          borderSide: new BorderSide(color: Colors.grey),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: new BorderSide(color: Colors.grey[200]),
        ),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Required';
        } else if (value.length < 6) {
          return 'Please Enter Proper Password (Min.Length: 6)';
        }
      },
      onSaved: (String value) {
        password = value;
      },
    );
  }

//  TODO: Functions for Signin with google
  signIn() {
    googleSignIn.signIn();
  }

  signOut() {
    googleSignIn.signOut();
  }

  controlSignIn(GoogleSignInAccount googleSignInAccount) async {
    if (googleSignInAccount != null) {
      print(googleSignInAccount.email);
      saveUserInfo();
      setState(() {
        print("done");
        isSignedIn = true;
      });
    }
    else{
      setState(() {
        print("signout");
        isSignedIn = false;
      });
    }
  }

  saveUserInfo() async {
    final GoogleSignInAccount googleSignInAccount = googleSignIn.currentUser;
    DocumentSnapshot documentSnapshot =
        await userDb.document(googleSignInAccount.id).get();
    if (!documentSnapshot.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => GetUserName()));
      print("print username" + username.toString());

      userDb.document(googleSignInAccount.id).setData({
        'id': googleSignInAccount.id,
        'profileName': googleSignInAccount.displayName,
        'username': username,
        'url': googleSignInAccount.photoUrl,
        'email': googleSignInAccount.email,
        'bio': "",
        'report': 0,
      });

      documentSnapshot = await userDb.document(googleSignInAccount.id).get();
    }
//    currentUser = User.fromDocument(documentSnapshot);
//    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
  }

//  TODO: Build Login Screen
  displayLoginScreen() {
    return SafeArea(
      child: Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Form(
                key: _FormKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Instagram",
                        style: TextStyle(
                          fontSize: 70,
                          color: Colors.black,
                          fontFamily: 'Billabong',
                        ),
                      ),
                      emailField(),
                      passwordField(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      progress = true;
                                    });
                                    if (!_FormKey.currentState.validate()) {
                                      return;
                                    }
                                    _FormKey.currentState.save();
                                  },
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
                      Separator(),
                      GestureDetector(
                        onTap: () {
                          print("Google Login");
                          signIn();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FaIcon(
                              FontAwesomeIcons.google,
                              color: Colors.blue[900],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Log in with Google",
                              style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 15),
                            /*defining default style is optional */
                            children: <TextSpan>[
                              TextSpan(
                                text: "Don't have an account? ",
                              ),
                              TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      print("Go to Signup Screen");
                                    }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
    ;
  }

//  TODO: Build HomeScreen Or Navigation Bar
  displayHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomeScreen"),
      ),
      body: RaisedButton(
        onPressed: (){
          signOut();
        },
        child: Text("SignOut"),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((googleSignInAccount) {
      controlSignIn(googleSignInAccount);
    });
    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((googleSignInAccount) {
      controlSignIn(googleSignInAccount);
    }).catchError((error) {
      print("error" + error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isSignedIn ? displayHomeScreen() : displayLoginScreen();
  }
}
