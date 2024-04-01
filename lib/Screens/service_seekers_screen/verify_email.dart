import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/tabs_screen.dart';
import 'package:local_service_providers/Utils/utils.dart';
import 'package:local_service_providers/resources/auth_methods.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.username,
    required this.email,
    required this.password,
    required this.phonenumber,
    required this.userType,
  });

  final String username, email, password, phonenumber, userType;

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late String username, email, password, phonenumber, userType;
  bool isLoading = false;
  final AuthMethods _authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();
    username = widget.username;
    email = widget.email;
    password = widget.password;
    phonenumber = widget.phonenumber;
    userType = widget.userType;
  }

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
    });

    bool isEmailVerified = await _authMethods.isEmailVerified();

    if (isEmailVerified) {
      try {
        await FirebaseAuth.instance.currentUser!.delete();

        String res = await _authMethods.signUpUser(
          username: username,
          email: email,
          password: password,
          phonenumber: phonenumber,
          userType: userType,
          context: context,
        );

        setState(() {
          isLoading = false;
        });

        if (res == 'success') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (ctx) => const TabsScreen(),
          ));
        } else {
          showSnackBar("Error while Register", context);
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        showSnackBar("Error while Register", context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email before continuing.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://media.finder.io/site/finder/blog/email-verification-solutions.png', // Placeholder image URL
                // height: 150.0,
                // width: 150.0,
              ),
              const Text(
                'A verification email has been sent to your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  bool isEmailVerified = await _authMethods.isEmailVerified();
                  if (isEmailVerified) {
                    registerUser();
                  }
                },
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      )
                    : const Text(
                        "continue",
                        style: TextStyle(fontSize: 20),
                      ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  await AuthMethods()
                      .emailSend(email: email, password: password);
                  await AuthMethods().sendEmailVerification(context);
                },
                child: const Text('Resend Verification Email'),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
