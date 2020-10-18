import 'package:flutter/material.dart';
import '../User/user.dart';
import 'HomePage.dart';


class EditProfile extends StatefulWidget {
  User user ;
  EditProfile({this.user});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameEdittingController = TextEditingController();
  TextEditingController bioEdittingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameEdittingController.text = widget.user.profileName;
    bioEdittingController.text = widget.user.bio;
    print(nameEdittingController.text);
  }
  displayError(context){
    return showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            children: <Widget>[
              Text("Profile Name can't be Empty. Please Try Again !!!"),
              FlatButton(
                child: Text("Ok"),
                color: Colors.blue,
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Edit Profile"),
        automaticallyImplyLeading: false,
        leading: IconButton(icon: Icon(Icons.close), onPressed: (){
          Navigator.pop(context);
        }),
      ),
      body: Container(
       child: SingleChildScrollView(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             TextFormField(
               controller: nameEdittingController,
               decoration: InputDecoration(
                   filled: true,
                   fillColor: Colors.white,
                   hintText: 'Profile Name',
                   labelText: 'Profile Name',
                   contentPadding:
                   const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                   focusedBorder: OutlineInputBorder(
                     borderSide: new BorderSide(color: Colors.white),
                   ),
                   enabledBorder: UnderlineInputBorder(
                     borderSide: new BorderSide(color: Colors.grey[200]),
                   ),
                 ),
             ),
             SizedBox(height: 20,),
             TextFormField(
               controller: bioEdittingController,
               decoration: InputDecoration(
                 filled: true,
                 fillColor: Colors.white,
                 hintText: 'Bio',
                 labelText: 'Enter Bio',
                 contentPadding:
                 const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                 focusedBorder: OutlineInputBorder(
                   borderSide: new BorderSide(color: Colors.white),
                 ),
                 enabledBorder: UnderlineInputBorder(
                   borderSide: new BorderSide(color: Colors.grey[200]),
                 ),
               ),
             ),
             RaisedButton(
               child: Text("Update"),
               onPressed: ()async{
                 print("start Process of update");
                 print("checking");
                 if(nameEdittingController=="" || nameEdittingController.text==null){
                   displayError(context);
                 }
                 else{
                   userDb.document(widget.user.id).updateData({
                     "profileName": nameEdittingController.text,
                     "bio": bioEdittingController.text,
                   });
                   Navigator.pop(context);
                 }
               },
             )
           ],
         ),
       ),
      ),


    );
  }
}
