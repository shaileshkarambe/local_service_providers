import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawRequestForm extends StatefulWidget {
  @override
  _WithdrawRequestFormState createState() => _WithdrawRequestFormState();
}

class _WithdrawRequestFormState extends State<WithdrawRequestForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String name = "";

  String? accountHolderNameValidator(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        !RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$').hasMatch(fieldContent)) {
      return 'Enter Valid Account Holder Name';
    }
    return null;
  }

  String? accountNumberValidator(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        !RegExp(r'^[0-9]{9,18}$').hasMatch(fieldContent)) {
      return 'Enter Valid Account Number';
    }
    return null;
  }

  String? bankNameValidator(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        !RegExp(r'^[A-Za-z\s&(),.-]+$').hasMatch(fieldContent)) {
      return 'Enter Valid Bank Name';
    }
    return null;
  }

  String? ifscCodeValidator(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        !RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(fieldContent)) {
      return 'Enter Valid ISFC code';
    }
    return null;
  }

  String? amountValidator(String? fieldContent) {
    if (fieldContent!.isEmpty ||
        !RegExp(r'^\d+(\.\d+)?$').hasMatch(fieldContent)) {
      return 'Enter Valid Amount';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getProviderDetails();
  }

  void getProviderDetails() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = (snap.data() as Map<String, dynamic>)['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Request Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              TextFormField(
                  controller: _accountHolderController,
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: accountHolderNameValidator),
              const SizedBox(height: 20),
              TextFormField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: accountNumberValidator),
              const SizedBox(height: 20),
              TextFormField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: bankNameValidator),
              const SizedBox(height: 20),
              TextFormField(
                  controller: _ifscCodeController,
                  decoration: const InputDecoration(
                    labelText: 'IFSC Code',
                    border: OutlineInputBorder(),
                  ),
                  validator: ifscCodeValidator),
              const SizedBox(height: 20),
              TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  validator: amountValidator),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final isValided = _formKey.currentState?.validate() ?? false;
                  if (isValided) {
                    saveWithdrawRequest();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveWithdrawRequest() {
    // Get current user ID from Firebase Authentication (assuming you have implemented authentication)
    // Replace with actual user ID

    // Save withdraw request data to Firestore
    FirebaseFirestore.instance.collection('withdraw_requests').add({
      'providerName': name,
      'accountHolderName': _accountHolderController.text,
      'accountNumber': _accountNumberController.text,
      'bankName': _bankNameController.text,
      'ifscCode': _ifscCodeController.text,
      'amount': _amountController.text,
      'timestamp': FieldValue.serverTimestamp(), // Optionally include timestamp
    }).then((value) {
      // Handle successful submission

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Withdraw request submitted successfully. Amount should reflect within 24 Hours'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }).catchError((error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting withdraw request: $error'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Optionally, you can show an error message
    });
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _ifscCodeController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
