//import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:local_service_providers/Utils/utils.dart';
import 'package:local_service_providers/model/service_provider.dart' as model;

class AuthMethodsProviders {
  final FirebaseAuth _auth1 =
      FirebaseAuth.instance; // creating FirebaseAuth  instance

  final FirebaseFirestore _firestoreproviders =
      FirebaseFirestore.instance; //creating FirebaseFirestore instance

  Future<model.ServiceProviderModel> getUserDetails() async {
    // User currentUser = _auth1.currentUser!;
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    return model.ServiceProviderModel.fromSnap(snap);
  }

  //signUp User
  Future<String> emailSend({
    required String email,
    required String password,
  }) async {
    String res = " some error occurred";
    try {
      //register user using email & password
      UserCredential cred1 = await _auth1.createUserWithEmailAndPassword(
          email: email, password: password);

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //signUp User
  Future<String> signUpProvider(
      {required String username,
      required String email,
      required String password,
      required String phonenumber,
      required String dropdownValue,
      required String serviceCharges,
      required String userType,
      required BuildContext context}) async {
    String res = " some error occurred";
    try {
      //register user using email & password
      UserCredential cred = await _auth1.createUserWithEmailAndPassword(
          email: email, password: password);

      // adding user detail in to firebasefirestore
      model.ServiceProviderModel userProvider = model.ServiceProviderModel(
          username: username,
          uid: cred.user!.uid,
          email: email,
          phonenumber: phonenumber,
          dropdownValue: dropdownValue,
          serviceCharges: serviceCharges,
          userType: userType);
      await _firestoreproviders.collection("users").doc(cred.user!.uid).set(
            userProvider.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

//for login service Provider
  Future<String> loginServiceProvider({
    required String email,
    required String password,
  }) async {
    String res = "some error occurrd";
    try {
      await _auth1.signInWithEmailAndPassword(email: email, password: password);
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //sign out user
  Future<void> signOut() async {
    await _auth1.signOut();
  }

  Future<String> sensendEmailVerification(BuildContext context) async {
    String result = 'Error while Sending Email';
    try {
      _auth1.currentUser!.sendEmailVerification();
      showSnackBar("Email Verification sent", context);
      result = 'success';
    } catch (e) {
      showSnackBar("err", context);
    }
    return result;
  }

  Future<bool> checkEmailVerification() async {
    User? user = _auth1.currentUser;
    await user!.reload();
    user = _auth1.currentUser;
    return user!.emailVerified;
  }
}
