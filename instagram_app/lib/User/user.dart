import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  String profileName;
  final String username;
  final String url;
  final String email;
  String bio;
  int report;

  User({
    this.id,
    this.profileName,
    this.username,
    this.url,
    this.email,
    this.bio,
    this.report
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      email: doc['email'],
      username: doc['username'],
      url: doc['url'],
      profileName: doc['profileName'],
      bio: doc['bio'],
      report: doc['report']
    );
  }
}