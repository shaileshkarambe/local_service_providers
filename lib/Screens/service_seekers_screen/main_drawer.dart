import 'package:flutter/material.dart';
import 'package:local_service_providers/Screens/choose_screen.dart';
import 'package:local_service_providers/Screens/service_providers_screen/wallet.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/user_profile_detail.dart';
import 'package:local_service_providers/resources/auth_methods.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key, required this.name, required this.email});
  String name, email;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.redAccent,
          ),
          accountName: Text(
            name,
            style: const TextStyle(color: Colors.black),
          ),
          accountEmail: Text(email),
          currentAccountPicture: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 5, 191, 238),
            child: Text(
              name[0],
              style: const TextStyle(fontSize: 30.0),
            ),
          ),
        ),
        ListTile(
            leading: const Icon(Icons.person),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const UserProfileDetails())),
            title: const Text("Profile"),
            hoverColor: Colors.grey),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Log Out"),
          hoverColor: Colors.grey,
          onTap: () async {
            await AuthMethods().signOut();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const ChooseScreen()));
          },
        ),
      ],
    ));
  }
}
