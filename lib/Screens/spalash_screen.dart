import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_service_providers/Screens/choose_screen.dart';

class SpalashScreen extends StatefulWidget {
  const SpalashScreen({super.key});

  @override
  State<SpalashScreen> createState() => _SpalashScreenState();
}

class _SpalashScreenState extends State<SpalashScreen> {
  void navigateToChooseScreen() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: ((context) => const ChooseScreen())));
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () => navigateToChooseScreen());
  }

  @override
  Widget build(context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [
          Colors.white,
          Colors.white,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomLeft,
      )),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('Images/logo1.jpg', width: 300, height: 300),
          //FlutterLogo(),
          const SizedBox(
            height: 30,
          ),
        ],
      )),
    );
  }
}
