import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderModel {
  final String username;
  final String uid;
  final String email;
  final String dropdownValue;
  final String serviceCharges;
  final String phonenumber;
  final String userType;

  const ServiceProviderModel({
    required this.username,
    required this.uid,
    required this.email,
    required this.phonenumber,
    required this.dropdownValue,
    required this.serviceCharges,
    required this.userType,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "phonenumber": phonenumber,
        "dropdownValue": dropdownValue,
        "serviceCharges": serviceCharges,
        "userType": userType
      };

  static ServiceProviderModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return ServiceProviderModel(
        username: snapshot["username"],
        uid: snapshot['uid'],
        email: snapshot['email'],
        phonenumber: snapshot['phonenumber'],
        dropdownValue: snapshot['dropdownValue'],
        serviceCharges: snapshot['serviceCharges'],
        userType: snapshot['userType']);
  }
}
