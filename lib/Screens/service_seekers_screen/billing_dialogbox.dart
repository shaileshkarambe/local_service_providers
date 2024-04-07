import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_web/razorpay_web.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BillingDialogBox extends StatefulWidget {
  const BillingDialogBox(
      {Key? key,
      required this.providerName,
      required this.categoryName,
      required this.charges,
      required this.selectedDate,
      required this.seekername,
      required this.email,
      required this.phonenumer})
      : super(key: key);

  final String providerName;
  final String categoryName;
  final String charges;
  final DateTime? selectedDate;
  final String seekername;
  final String phonenumer;
  final String email;

  @override
  State<BillingDialogBox> createState() => _BillingDialogBoxState();
}

class _BillingDialogBoxState extends State<BillingDialogBox> {
  late String providerName;
  late String categoryName;
  late double charges;
  late DateTime? selectedDate;
  late String seekername;
  late Razorpay _razorpay;
  late String phonenumber;
  late String email;
  bool _isPaymentProcessing = false;

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_KAyP9EVPkhoWAP',
      'amount': (charges * 100).toInt(),
      'name': seekername,
      'description': 'Payment for $categoryName Service',
      'send_sms_hash': true,
      'prefill': {'contact': phonenumber, 'email': email},
      'external': {
        'wallets': ['paytm'],
        'upi': {'vpa': 'your-upi-id@upi'}
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Error while payment ${response.code}");
    setState(() {
      _isPaymentProcessing = false;
    });
  }

  Widget build(BuildContext context) {
    double GST = charges * 0.05;
    double total = charges + GST + GST;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Billing Info",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.black),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Provider Name: $providerName"),
              const Spacer(),
              Flexible(child: Text("Service Name: $categoryName")),
            ],
          ),
          const Divider(color: Colors.black),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text("Service Charges:"),
              const Spacer(),
              Text("₹ $charges"),
            ],
          ),
          const SizedBox(height: 10),
          const Text("GST ", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Text("CGST 5%:"),
              const Spacer(),
              Text("₹ $GST"),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text("SGST 5%:"),
              const Spacer(),
              Text("₹  $GST"),
            ],
          ),
          const Divider(color: Colors.black),
          Row(
            children: [
              const Text("Total Payable Amount:"),
              const Spacer(),
              Text("₹  $total"),
            ],
          ),
          const Divider(color: Colors.black),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  openCheckout();
                },
                child: const Text('Make Payment'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    providerName = widget.providerName;
    categoryName = widget.categoryName;
    charges = double.parse(widget.charges);
    selectedDate = widget.selectedDate;
    seekername = widget.seekername;
    email = widget.email;
    phonenumber = widget.phonenumer;

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Navigator.pop(context);
    Fluttertoast.showToast(msg: " payment Successfully done");
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('Scheduling').add({
      "UID": uid,
      'paymentId': response.paymentId,
      'provider_name': providerName,
      'date': selectedDate,
      'status': 'pending',
      'amount': charges,
      'seeker_name': seekername,
    });

    sendNotification(providerName);
    setState(() {
      _isPaymentProcessing = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: ${response.walletName!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void sendNotification(String providerName) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('tokens')
            .where('name', isEqualTo: providerName)
            .get();

    querySnapshot.docs.forEach((doc) {
      if (doc.exists) {
        String providerToken = doc['token'];
        sendMessageToDevice(providerToken);
      }
    });
  }

  Future<void> sendMessageToDevice(String registrationToken) async {
    String accessToken = '';
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/local-service-providers-app/messages:send'); // Update with your project ID
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final payload = {
      'message': {
        'token': registrationToken,
        'notification': {
          'title': 'Service Request',
          'body':
              'you have get service request from $providerName at $selectedDate . Please provide response as soon as posible',
        },
        'data': {
          'key': 'value', // Your custom data payload
        },
      },
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        print('Message sent successfully!');
      } else {
        print('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to send message: $e');
    }
  }
}
