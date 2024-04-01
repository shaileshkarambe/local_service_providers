import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/login_screen.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/verify_email.dart';
import 'package:local_service_providers/Utils/utils.dart';
import 'package:local_service_providers/Widget/textfiled.dart';
import 'package:local_service_providers/resources/auth_methods.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  String? userNameValidtaor(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        RegExp(r'^[A-Za-z][A-Za-z0-9_]{7,29}$').hasMatch(fieldContent)) {
      return 'Enter Valid UserID';
    }
    return null;
  }

  String? emailValidtaor(String? fieldContent) {
    if (EmailValidator.validate(fieldContent!) == false) {
      return 'Enter Valid Email';
    }
    return null;
  }

  String? phoneValidtaor(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        !RegExp(r'^(\+?91[\-\s]?)?[789]\d{9}$').hasMatch(fieldContent)) {
      return 'Enter a valid Indian phone number';
    }
    return null;
  }

  String? passwordValidtaor(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
            .hasMatch(fieldContent)) {
      return 'Enter Valid Password';
    }
    return null;
  }

  void _registerUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().emailSend(
        email: _emailController.text, password: _passwordController.text);
    await AuthMethods().sendEmailVerification(context);
    setState(() {
      _isLoading = false;
    });

    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => VerifyEmailScreen(
          username: _userNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          userType: 'Service_seeker',
          phonenumber: _phoneNumberController.text,
        ),
      ));
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: ((context) => const LoginScreen())));
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color.fromARGB(255, 206, 50, 39),
                Color.fromARGB(255, 233, 37, 37)
              ], end: Alignment.bottomLeft, begin: Alignment.topCenter)),
              child: Padding(
                padding: const EdgeInsets.only(top: 180.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 50),
                          TextFieldInput(
                            textEditingController: _userNameController,
                            hintext: "  Enter your full name",
                            textInputType: TextInputType.name,
                            validate: userNameValidtaor,
                          ),
                          const SizedBox(height: 30),
                          TextFieldInput(
                            textEditingController: _emailController,
                            hintext: "  Enter your email",
                            textInputType: TextInputType.emailAddress,
                            validate: emailValidtaor,
                          ),
                          const SizedBox(height: 30),
                          TextFieldInput(
                            textEditingController: _phoneNumberController,
                            hintext: "  Enter your phone number",
                            textInputType: TextInputType.phone,
                            validate: phoneValidtaor,
                          ),
                          const SizedBox(height: 30),
                          TextFieldInput(
                            textEditingController: _passwordController,
                            hintext: "  Enter your password",
                            textInputType: TextInputType.text,
                            validate: passwordValidtaor,
                            isPass: true,
                          ),
                          const SizedBox(height: 40),
                          TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forget Password",
                                style: TextStyle(fontSize: 15),
                              )),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _registerUser();
                                    }
                                  },
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),
                                  )
                                : const Text(
                                    "Register",
                                    style: TextStyle(fontSize: 20),
                                  ),
                          ),
                          const SizedBox(height: 70),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already Have Account ?"),
                              TextButton(
                                  onPressed: _navigateToLogin,
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(fontSize: 15),
                                  ))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 70, left: 30),
              child: Text(
                "Hello Please \n Register",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
