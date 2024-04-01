import 'package:flutter/material.dart';
import 'package:local_service_providers/Screens/service_providers_screen/register_screen_provider.dart';
import 'package:local_service_providers/Screens/service_providers_screen/tabs_screen_provider.dart';
import 'package:local_service_providers/Utils/utils.dart';
import 'package:local_service_providers/Widget/textfiled.dart';
import 'package:local_service_providers/resources/auth_methods_providers.dart';

class LoginScreenProvider extends StatefulWidget {
  const LoginScreenProvider({super.key});

  @override
  State<LoginScreenProvider> createState() => _LoginScreenProviderState();
}

class _LoginScreenProviderState extends State<LoginScreenProvider> {
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final TextEditingController emailNameControler = TextEditingController();
  final TextEditingController passwordControler = TextEditingController();
  bool isLoading = false;

  String? userNameValidtaor(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        RegExp(r'^[A-Za-z][A-Za-z0-9_]{7,29}$').hasMatch(fieldContent)) {
      return 'Enter Valid UserID';
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

  @override
  void dispose() {
    super.dispose();
    emailNameControler.dispose();
    passwordControler.dispose();
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethodsProviders().loginServiceProvider(
        email: emailNameControler.text, password: passwordControler.text);

    setState(() {
      isLoading = false;
    });

    if (res == 'success') {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (ctx) => const TabsScreenProvider(),
      ));
    } else {
      showSnackBar(res, context);
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: Center(
                  child: Form(
                    key: _formKey1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 50),
                        TextFieldInput(
                          textEditingController: emailNameControler,
                          hintext: "  Enter Email address",
                          textInputType: TextInputType.emailAddress,
                          validate: userNameValidtaor,
                        ),
                        const SizedBox(height: 40),
                        TextFieldInput(
                          textEditingController: passwordControler,
                          hintext: "  Enter your password",
                          textInputType: TextInputType.text,
                          validate: passwordValidtaor,
                          isPass: true,
                        ),
                        const SizedBox(height: 30),
                        TextButton(
                            onPressed: () {},
                            child: const Text("Forget Password")),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            final isValided =
                                _formKey1.currentState?.validate() ?? false;
                            if (isValided) {
                              loginUser();
                            }
                          },
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                )
                              : const Text(
                                  "LOGIN",
                                ),
                        ),
                        const SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't Have Account ?"),
                            TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreenProviders()));
                                },
                                child: const Text("Register")),
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
            padding: EdgeInsets.only(top: 80, left: 30),
            child: Text(
              "Welcome Back \n Login",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    ));
  }
}
