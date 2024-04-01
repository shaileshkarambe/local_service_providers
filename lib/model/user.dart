import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String uid;
  final String email;
  final String phonenumber;
  final String userType;

  const UserModel(
      {required this.username,
      required this.uid,
      required this.email,
      required this.phonenumber,
      required this.userType});

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "phonenumber": phonenumber,
        'userType': userType,
      };

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
        username: snapshot["username"],
        uid: snapshot['uid'],
        email: snapshot['email'],
        phonenumber: snapshot['phonenumber'],
        userType: snapshot["userType"]);
  }
}
