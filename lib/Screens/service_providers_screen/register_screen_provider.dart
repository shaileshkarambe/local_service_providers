import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:local_service_providers/Screens/service_providers_screen/login_screen_provider.dart';
import 'package:local_service_providers/Screens/service_providers_screen/verify_Screen.dart';
import 'package:local_service_providers/Utils/utils.dart';
import 'package:local_service_providers/Widget/textfiled.dart';
import 'package:local_service_providers/dummyData/service_categorie.dart';
import 'package:local_service_providers/resources/auth_methods_providers.dart';

class RegisterScreenProviders extends StatefulWidget {
  const RegisterScreenProviders({super.key});

  @override
  State<RegisterScreenProviders> createState() =>
      _RegisterScreenProvidersState();
}

class _RegisterScreenProvidersState extends State<RegisterScreenProviders> {
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final TextEditingController userNameControler = TextEditingController();
  final TextEditingController emailControler = TextEditingController();
  final TextEditingController phoneNumberControler = TextEditingController();
  final TextEditingController passwordControler = TextEditingController();
  final TextEditingController serviceChargesControler = TextEditingController();
  bool isLoading = false;
  String dropdownValue = 'Car Repair';

  String? userNameValidtaor(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        !RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)?$').hasMatch(fieldContent)) {
      return 'enter valid name';
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
    if (fieldContent!.isNotEmpty ||
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$ ')
            .hasMatch(fieldContent)) {
      return null;
    }
    return 'Password should contain uppercase,lowercase & at least 8 characters)';
  }

  String? chargesValidtaor(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        !RegExp(r'^\d+(\.\d+)?$').hasMatch(fieldContent)) {
      return 'Enter Valid Charge';
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    userNameControler.dispose();
    phoneNumberControler.dispose();
    emailControler.dispose();
    passwordControler.dispose();
    serviceChargesControler.dispose();
  }

  void registerServiceProvider() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethodsProviders().emailSend(
        email: emailControler.text, password: passwordControler.text);
    await AuthMethodsProviders().sensendEmailVerification(context);

    setState(() {
      isLoading = false;
    });

    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => VerifyScreen(
          username: userNameControler.text,
          email: emailControler.text,
          password: passwordControler.text,
          phonenumber: phoneNumberControler.text,
          dropdownValue: dropdownValue,
          serviceCharges: serviceChargesControler.text,
          userType: 'Service_provider',
        ),
      ));
    }
  }

  void navigateToLogin() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: ((context) => const LoginScreenProvider())));
  }

  @override
  Widget build(BuildContext context) {
    final inputBoreder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
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
                      key: _formKey1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 50),
                          TextFieldInput(
                            textEditingController: userNameControler,
                            hintext: "  Enter your first name & Last Name",
                            textInputType: TextInputType.name,
                            validate: userNameValidtaor,
                          ),
                          const SizedBox(height: 30),
                          TextFieldInput(
                            textEditingController: emailControler,
                            hintext: "  Enter your email",
                            textInputType: TextInputType.emailAddress,
                            validate: emailValidtaor,
                          ),
                          const SizedBox(height: 30),
                          TextFieldInput(
                            textEditingController: phoneNumberControler,
                            hintext: "  Enter your phone number",
                            textInputType: TextInputType.phone,
                            validate: phoneValidtaor,
                          ),
                          const SizedBox(height: 30),
                          TextFieldInput(
                            textEditingController: passwordControler,
                            hintext: "  Enter your password",
                            textInputType: TextInputType.text,
                            validate: passwordValidtaor,
                            isPass: true,
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: serviceChargesControler,
                            decoration: InputDecoration(
                                border: inputBoreder,
                                hintText: "Enter service Charges",
                                focusedBorder: inputBoreder,
                                filled: true,
                                contentPadding: const EdgeInsets.all(0)),
                            keyboardType: TextInputType.number,
                            validator: chargesValidtaor,
                          ),
                          const SizedBox(height: 30),
                          DropdownButtonFormField<String>(
                            value: dropdownValue,
                            hint: const Text("Choose work categori"),
                            items: menuItems
                                .map((String e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                dropdownValue = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 50),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forget Password",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              final isValided =
                                  _formKey1.currentState?.validate() ?? false;
                              if (isValided) {
                                registerServiceProvider();
                              }
                            },
                            child: isLoading
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
                                  onPressed: navigateToLogin,
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
