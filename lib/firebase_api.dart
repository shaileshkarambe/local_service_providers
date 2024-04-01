import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  FirebaseApi({required this.name});

  String name;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      final fcmToken = await _firebaseMessaging.getToken();

      await FirebaseFirestore.instance.collection("tokens").doc(name).set({
        "token": fcmToken,
        "name": name,
      });

      print("FCM Token: $fcmToken");

      // Listen for token refresh events
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print("Token refreshed: $newToken");
        updateToken(newToken, name);
      });
    } catch (error) {
      print("Error initializing notifications: $error");
    }
  }

  Future<void> updateToken(String newToken, String name) async {
    try {
      // Update the token in Firestore
      await FirebaseFirestore.instance.collection("tokens").doc(name).update({
        "token": newToken,
      });
    } catch (error) {
      print("Error updating token: $error");
    }
  }
}
