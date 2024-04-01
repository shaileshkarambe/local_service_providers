import 'package:flutter/material.dart';
import 'package:local_service_providers/Screens/service_providers_screen/login_screen_provider.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/registration_screen.dart';

class ChooseScreen extends StatelessWidget {
  const ChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Servo",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Choose Your Role',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistrationScreen()))
              }
              // Navigator.of(context).push(
              //     MaterialPageRoute(builder: (context) => const LoginPage()))
              // Add your button 1 action here
              ,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.grey, // Set the background color to grey
              ),
              child: const Text(
                'Services Seekers',
                style: TextStyle(color: Colors.black, fontSize: 23),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreenProvider())),
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.grey, // Set the background color to grey
              ),
              child: const Text(
                'Services Provider',
                style: TextStyle(color: Colors.black, fontSize: 23),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
