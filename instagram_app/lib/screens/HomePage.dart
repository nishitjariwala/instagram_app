import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/separator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'GetUsername.dart';
import 'FeedPage.dart';
import 'SearchPage.dart';
import 'UploadPost.dart';
import 'NotificationPage.dart';
import 'ProfilePage.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../User/user.dart';
import '../widgets/Progress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final userDb = Firestore.instance.collection("user");
final postsDb = Firestore.instance.collection("posts");
final activityDb = Firestore.instance.collection("notifications");
final commentsDb = Firestore.instance.collection('comments');
final followersDb = Firestore.instance.collection('followers');
final followingDb = Firestore.instance.collection('following');
final feedDb = Firestore.instance.collection('timeline');
final chatDb = Firestore.instance.collection('chat');

final StorageReference postImageReference =
    FirebaseStorage.instance.ref().child("posts");

final auth = FirebaseAuth.instance;
User currentUser;
bool isSignedIn = false;
int flag = 1;
FirebaseMessaging firebaseMessaging = FirebaseMessaging();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String email;
  String username;
  String profileName;
  String password;
  bool progress = false;
  bool startProgress = false;

  final GlobalKey<FormState> _FormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int pageNum = 0;
  int pageIndex = 0;
  PageController pageController;

  signOut() {
    googleSignIn.signOut();
    auth.signOut();
    setState(() {
      isSignedIn = false;
    });
  }

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
          labelText: 'Email',
          contentPadding:
              const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
          focusedBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.white),
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

  Widget nameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: new InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Full Name',
          labelText: 'Full Name',
          contentPadding:
              const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
          focusedBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.white),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.grey[200]),
          ),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter Full Name';
          } else {
            return null;
          }
          ;
        },
        onSaved: (String value) {
          profileName = value;
        },
      ),
    );
  }

  Widget usernameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: new InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Username',
          labelText: 'Username',
          contentPadding:
              const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
          focusedBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.white),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.grey[200]),
          ),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter username';
          } else if (value.length < 6) {
            return 'Minimum of username length is 6';
          } else {
            return null;
          }
          ;
        },
        onSaved: (String value) {
          username = value;
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
        labelText: 'password',
        contentPadding:
            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        focusedBorder: OutlineInputBorder(
          borderSide: new BorderSide(color: Colors.white),
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

  controlSignIn(GoogleSignInAccount googleSignInAccount) async {
    if (googleSignInAccount != null) {
      print(googleSignInAccount.email);
      saveUserInfo();
      setState(() {
        print("done");
        isSignedIn = true;
      });
    } else {
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
      if (username != null) {
        userDb.document(googleSignInAccount.id).setData({
          'id': googleSignInAccount.id,
          'profileName': googleSignInAccount.displayName,
          'username': username,
          'url': googleSignInAccount.photoUrl,
          'email': googleSignInAccount.email,
          'bio': "",
          'report': 0,
        });
      }
      await followersDb
          .document(currentUser.id)
          .collection("userFollowers")
          .document(currentUser.id)
          .setData({});

      documentSnapshot = await userDb.document(googleSignInAccount.id).get();
    }

    setState(() {
      currentUser = User.fromDocument(documentSnapshot);
    });
  }

  displayError(context, String msg, bool showSignout) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Column(
              children: <Widget>[
                Text(msg),
                !showSignout?RaisedButton(
                  child: Text(
                     "Ok",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.blue,
                ):RaisedButton(
                  child: Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    signOut();
                  },
                  color: Colors.blue,
                ),
              ],
            ),
          );
        });
  }

  configurePushNotification() {
    final User cUser = currentUser;
    firebaseMessaging.getToken().then((token) {
      userDb.document(cUser.id).updateData({"androidNotificationToken": token});
    });
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> msg) async {
      final String recipientId = msg["data"]["recipient"];
      final String body = msg["notification"]["body"];

      if (recipientId == currentUser.id) {
        SnackBar snackbar = SnackBar(
          backgroundColor: Colors.grey[200],
          content: Text(
            body,
            style: TextStyle(color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        );
        scaffoldKey.currentState.showSnackBar(snackbar);
      }
    });
  }

//  TODO: Build Login Screen
  displayLoginScreen() {
    return ModalProgressHUD(
      inAsyncCall: startProgress,
      child: SafeArea(
        child: Scaffold(
            body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
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
                                      setState(() {
                                        startProgress = true;
                                      });
                                      try {
                                        print(email);
                                        final user = await auth
                                            .signInWithEmailAndPassword(
                                                email: email,
                                                password: password);
                                        if (user != null) {
                                          var id;
                                          await userDb
                                              .where('email', isEqualTo: email)
                                              .getDocuments()
                                              .then((event) {
                                            if (event.documents.isNotEmpty) {
                                              id = event
                                                  .documents.single.data['id'];
                                            }
                                          }).catchError((e) => print(
                                                  "error fetching data: $e"));
                                          DocumentSnapshot documentSnapshot =
                                              await userDb
                                                  .document(id)
                                                  .get(); //if it is a single document
                                          if (documentSnapshot.exists) {
                                            setState(() {
                                              currentUser = User.fromDocument(
                                                  documentSnapshot);
                                              startProgress = false;
                                              isSignedIn = true;
                                            });
                                            configurePushNotification();
                                          }
                                        }
                                      } catch (e) {
                                        setState(() {
                                          startProgress = false;
                                        });
                                        displayError(
                                            context,
                                            "Enter Correct Email Or password:-",
                                            false);
                                        print(e);
                                      }
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
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
                                        setState(() {
                                          flag = 0;
                                        });
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
      ),
    );
    ;
  }

  displaySignupScreen() {
    var uuid = Uuid();
    var id = uuid.v4();
    return ModalProgressHUD(
      inAsyncCall: startProgress,
      child: SafeArea(
        child: Scaffold(
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
                        Text(
                          "Sign up to see photos and videos from your friends.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        SignInButtonBuilder(
                          text: 'Sign in with Email',
                          icon: FontAwesomeIcons.google,
                          onPressed: () {
                            signIn();
                          },
                          backgroundColor: Colors.blue,
                        ),
                        Separator(),
                        emailField(),
                        nameField(),
                        usernameField(),
                        passwordField(),
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
                                    setState(() {
                                      startProgress = true;
                                    });

                                    try {
                                      final newUser = await auth
                                          .createUserWithEmailAndPassword(
                                              email: email, password: password);
                                      if (newUser != null) {
                                        userDb.document(id).setData({
                                          'bio': '',
                                          'email': email,
                                          'id': id,
                                          'profileName': profileName,
                                          'username': username,
                                          'url':
                                              'https://firebasestorage.googleapis.com/v0/b/instagramapp-8a9ce.appspot.com/o/profilepic.jpg?alt=media&token=ac756e64-9010-4e40-988f-c9ead16ad4a4',
                                          'report': 0,
                                        });
                                      }
                                      if (newUser != null) {
                                        await followersDb
                                            .document(currentUser.id)
                                            .collection("userFollowers")
                                            .document(currentUser.id)
                                            .setData({});
                                        DocumentSnapshot documentSnapshot =
                                            await userDb.document(id).get();

                                        setState(() {
                                          currentUser = User.fromDocument(
                                              documentSnapshot);
                                          startProgress = false;
                                          isSignedIn = true;
                                        });
                                        configurePushNotification();
                                      }
                                    } catch (e) {
                                      setState(() {
                                        startProgress = false;
                                      });

                                      displayError(
                                          context,
                                          "Already Signed In with this Email:- ",
                                          false);
                                      print(e);
                                    }
                                  },
                                  elevation: 2,
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Sign up",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                              /*defining default style is optional */
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Already have an account? ",
                                ),
                                TextSpan(
                                    text: 'Sign in',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        print("Go to Signin Screen");
                                        setState(() {
                                          flag = 1;
                                        });
                                      }),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  pageChange(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  pageChangeAnimation(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(microseconds: 400), curve: Curves.bounceInOut);
  }

//  TODO: Build HomeScreen Or Navigation Bar
  displayHomeScreen() {
    return currentUser.id == null
        ? circularProgress()
        : currentUser.report >= 3
            ? SafeArea(
              child: Scaffold(
                  body: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Your Account Has been Disabled",style: TextStyle(color: Colors.purpleAccent,fontSize: 20,),),
                        FlatButton(
                          color: Colors.purpleAccent,
                          child: Text("Signout",style: TextStyle(color: Colors.white),),
                          onPressed: (){
                            signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            )
            : SafeArea(
                child: Scaffold(
                    key: scaffoldKey,
                    body: PageView(
                      children: <Widget>[
                        FeedPage(
                          currentUser: currentUser,
                        ),
                        SearchPage(
                          currentUser: currentUser,
                        ),
                        UploadPost(),
                        NotificationsPage(),
                        ProfilePage(
                          userProfileId: currentUser.id,
                        ),
                      ],
                      controller: pageController,
                      onPageChanged: pageChange,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                    bottomNavigationBar: CupertinoTabBar(
                      currentIndex: pageIndex,
                      onTap: pageChangeAnimation,
                      activeColor: Colors.black,
                      inactiveColor: Colors.grey,
                      backgroundColor: Colors.grey[100],
                      items: [
                        BottomNavigationBarItem(icon: Icon(Icons.home)),
                        BottomNavigationBarItem(icon: Icon(Icons.search)),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.add_circle_outline)),
                        pageIndex == 3
                            ? BottomNavigationBarItem(
                                icon: Icon(Icons.favorite))
                            : BottomNavigationBarItem(
                                icon: Icon(Icons.favorite_border)),
                        BottomNavigationBarItem(icon: Icon(Icons.person)),
                      ],
                      border: Border(
                          top: BorderSide(color: Colors.grey, width: 0.3)),
                    )),
              );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();

    googleSignIn.onCurrentUserChanged.listen((googleSignInAccount) {
      controlSignIn(googleSignInAccount);
    });
    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((googleSignInAccount) {
      controlSignIn(googleSignInAccount);
    }).catchError((error) {
      print(error.toString());
    });
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isSignedIn
        ? displayHomeScreen()
        : flag == 1
            ? displayLoginScreen()
            : displaySignupScreen();
  }
}
