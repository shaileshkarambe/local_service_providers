import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_service_providers/Screens/service_providers_screen/tabs_screen_provider.dart';
import 'package:local_service_providers/Utils/utils.dart';
import 'package:local_service_providers/resources/auth_methods_providers.dart';

class VerifyScreen extends StatefulWidget {
  final String username,
      email,
      password,
      dropdownValue,
      phonenumber,
      serviceCharges,
      userType;

  VerifyScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.password,
    required this.dropdownValue,
    required this.phonenumber,
    required this.serviceCharges,
    required this.userType,
  }) : super(key: key);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  late String username,
      email,
      password,
      dropdownValue,
      phonenumber,
      serviceCharges,
      userType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    username = widget.username;
    email = widget.email;
    password = widget.password;
    dropdownValue = widget.dropdownValue;
    phonenumber = widget.phonenumber;
    serviceCharges = widget.serviceCharges;
    userType = widget.userType;
  }

  Future<void> registerServiceProvider() async {
    setState(() {
      isLoading = true;
    });
//check email verify
    bool isEmailVerified =
        await AuthMethodsProviders().checkEmailVerification();

    if (isEmailVerified) {
      try {
        //delete the user which first create
        await FirebaseAuth.instance.currentUser!.delete();
        // Sign up the provider
        String res = await AuthMethodsProviders().signUpProvider(
          username: username,
          email: email,
          password: password,
          phonenumber: phonenumber,
          dropdownValue: dropdownValue,
          serviceCharges: serviceCharges,
          userType: userType,
          context: context,
        );

        setState(() {
          isLoading = false;
        });

        if (res == 'success') {
          // Navigate to the provider's dashboard
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const TabsScreenProvider()));
        } else {
          showSnackBar("Error while Register", context);
        }
      } catch (error) {
        // Handle any errors during sign up
        setState(() {
          isLoading = false;
        });
        showSnackBar("Error while Register", context);
      }
    } else {
      // If email is not verified, show a message
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
                // Placeholder image URL
                'https://media.finder.io/site/finder/blog/email-verification-solutions.png',
              ),
              const Text(
                'A verification email has been sent to your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  await registerServiceProvider();
                },
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      )
                    : const Text(
                        "Continue",
                        style: TextStyle(fontSize: 20),
                      ),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () async {
                  await AuthMethodsProviders()
                      .emailSend(email: email, password: password);
                  await AuthMethodsProviders()
                      .sensendEmailVerification(context);
                },
                child: const Text('Resend Verification Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
