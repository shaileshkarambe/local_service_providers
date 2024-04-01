import 'package:flutter/material.dart';
import 'package:local_service_providers/Screens/service_providers_screen/tabs_screen_provider.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/tabs_screen.dart';

class Pass extends StatelessWidget {
  const Pass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Choose Your Role",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => const TabsScreen()));
            },
            child: const Text(
              "Service seekers",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (ctx) => const TabsScreenProvider()));
            },
            child: const Text(
              "Service Provider",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          )
        ],
      ),
    ));
  }
}
