import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_service_providers/Screens/service_providers_screen/provider_drawer.dart';
import 'package:local_service_providers/Screens/service_providers_screen/provider_history_screen.dart';
import 'package:local_service_providers/Screens/service_providers_screen/request_screen.dart';
import 'package:local_service_providers/firebase_api.dart';

class TabsScreenProvider extends StatefulWidget {
  const TabsScreenProvider({super.key});

  @override
  State<TabsScreenProvider> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreenProvider> {
  int _selectedPageIndex = 0;
  String name = "", email = "";

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  void getUserName() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = (snap.data() as Map<String, dynamic>)['username'];
      email = (snap.data() as Map<String, dynamic>)['email'];
      FirebaseApi(name: name).initNotifications();
    });
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //tab active page on screen
    Widget activePage = RequestScreen(
      name: name,
    );

    //var activePageTitle = 'Provider Screen';
    if (_selectedPageIndex == 1) {
      activePage = HistoryScreenProvider(
        name: name,
      );
      //  activePageTitle = "History";
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        title: const Text("Servo"), //title of active page
      ),
      body: activePage,
      drawer: ProviderDrawer(name: name, email: email),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.people,
              ),
              label: "request"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.history,
              ),
              label: "History"),
        ],
      ),
    );
  }
}
