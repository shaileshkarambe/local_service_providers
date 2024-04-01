import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_service_providers/Screens/service_providers_screen/tabs_screen_provider.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/tabs_screen.dart';
import 'package:local_service_providers/Screens/spalash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'local-service-providers-app',
      options: const FirebaseOptions(
          apiKey: 'AIzaSyD438gc1qCM2kCJ-eLVo_Nrlfgn5zfTTNk',
          appId: '1:769748024327:android:0949e2f0ee37d49f5dbea2',
          messagingSenderId: '769748024327',
          projectId: 'local-service-providers-app'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Service Provider Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 212, 220, 226),
              ),
            );
          } else if (snapshot.hasData) {
            final User user = snapshot.data!;
            // Fetch user type from Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  String userType = data['userType'];

                  // Navigate based on user type
                  switch (userType) {
                    case 'Service_seeker':
                      return const TabsScreen();
                    case 'Service_provider':
                      return const TabsScreenProvider();
                  }
                }

                return const SizedBox(); // Placeholder
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          } else {
            return const SpalashScreen();
          }
        },
      ),
    );
  }
}
