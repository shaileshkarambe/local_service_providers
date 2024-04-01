import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_service_providers/utils/utils.dart';
import 'package:local_service_providers/model/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.UserModel?> getUserDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snap = await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();
      return model.UserModel.fromSnap(snap);
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

//signUp User
  Future<String> emailSend({
    required String email,
    required String password,
  }) async {
    String res = " some error occurred";
    try {
      //register user using email & password
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> signUpUser({
    required String username,
    required String email,
    required String password,
    required String phonenumber,
    required String userType,
    required BuildContext context,
  }) async {
    String res = " some error occurred";
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //await sendEmailVerification(context);
      model.UserModel user = model.UserModel(
        username: username,
        uid: cred.user!.uid,
        email: email,
        phonenumber: phonenumber,
        userType: userType,
      );
      await _firestore.collection("users").doc(cred.user!.uid).set(
            user.toJson(),
          );
      return "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } on FirebaseAuthException catch (err) {
      return err.message ?? "An error occurred";
    } catch (err) {
      return "An error occurred: $err";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      showSnackBar("Email Verification Sent!  Please Verify email ", context);
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? "An error occurred", context);
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }
}
