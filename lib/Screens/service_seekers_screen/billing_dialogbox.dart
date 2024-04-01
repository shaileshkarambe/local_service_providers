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

  // Future<void> storePaymentDetails(String paymentID) async {
  //   await FirebaseFirestore.instance.collection('transaction').add({
  //     "payment ID": paymentID,
  //     'provider_name': providerName,
  //     'date': selectedDate,
  //     'amount': charges,
  //     'seeker_name': seekername,
  //     'status': 'pending',
  //   });
  // }

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
              Text("Service Name: $categoryName"),
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
    //Navigator.pop(context);
    Fluttertoast.showToast(msg: " payment Success ${response.signature}");
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
    //storePaymentDetails(response.paymentId!);
    // sendMessageToDevice(registrationToken);
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
    String accessToken =
        'ya29.c.c0AY_VpZgjeo2T-SIDQdBnVTRjIrWiIPNvvMBWo4JhKZcWx3Sal3K0TDyViw2iX6tT_7xhmJjnfcIWdwCNq8fEoiLkXxigRc5GtOshNoD5V4wVe25QG4-Hw530OKCnU7kPC4CdtWpxDjZ4swxeKr4InjJOLy4XHX6HHexPw00ERs1RT3rqln1TwEo4naKqkI-T8xL1bt9r8eRjXg_H6JGVXPSFULor7w53en5vHnJtV14Ub5pNjzNdGpPYqctqo695Ny8tgLqAZvwh3e510xTxUUcOCafHkuyYa3dOegtAQKZbcSXBfOkkh6d8XJdFwjZhPBn3e9SMM9TsAFCcX9YMIh4YzcWwE000k6kS_EIkVJ4furTioeNI1t-iDQL387Dp049kcahco6dWQkYY-kbh-Ur1aoRufcxRs2QVzrcoaurqRS7xfXez6hftl7oe0hp4lxjdJrZgi1s7Fooshjews-h9imafrcsuFva6mmhZhM07ln20QeI5R_RhJ3StxgZ1gmimdnIxSyjBt25UOQaS0e3x4ylYJV5USg5hyl053iitj4verlQtwvsn3334IY5Besv4xWeFtk9Q75x9q2-V3U5cxgaIthg94tB3JY4p-rzWggjp28kmhf00qj08nwx3wsB_jQJMeo5kj3e4Y9aXgBBdx9I7RZXXjmIrtexfo7pMX45f8tqUj4QFgwn1QjzVYnYI9Uhl4a_k6omme2O7o0Maxcjiw0BUsmdZ6rv1gqw52zb6W7nYsmuyao4F7IFrMy0chu_b_QIbI980RhkimkaBe9hxaluu3j_MFYIOg6Oc0iJbyR-FyB6iIVYnhzny_Fms77xjzVR2w4vU-mZ-xY3FnQFSuXtS9pysRcd8X59R7tgRyQQQWytW9Bvm0iflZ1zg9rcWYytQWpBdezYyQROlOJeU4U5gl34cvaXBfmg_0lXlQt8pzef41t29j-kuMBpXY-blf8yyhUo13cM033_7n8vcUcOn75_stFrZF4snwVW882ozXUV';
    //'ya29.c.c0AY_VpZjY6fv9CwEcJeJ5eYYUR-VvbPUqfXi3neKKWN0gDzpm_qBaCQhSiUqFDiAHYMF1yqU6z2yb5111ADsOzI8Y9FIhJQa4E8rU6Scr9hFHFrc4naLEKeZbNHBYaDfNSlIIv5SK7ePD0CaVryfNrUfFrL-Zfe8rpfs5WsN2cj_NqRnXHXHglh9r0mxvQHWHEkqirtj8vnvjOp7q2zOpyO6xxWWP1L2XK_fVMVvwRfPyGbw_t21nI1lR2WyY7yBFd01tpoWV5OG5aAIMcmBdw8O0JbWAxlYQ9whfOoeEyMjeTWyqmdUd8DzZWGtVimUDoZpVtnBfEU9eJvriLqXU_TcxLP5H3ba2ZPoZ8HcJhL0O1zRi5Z_fxut6T385DlaRviu0rOd-FiV_vBMbVqu-vQVwuFdJ9fx4XkVdVbu4WuUegqs-8JIxfn-5_mg-Jxg8Bik8pzes06ughcRXwo3hFzOwR1eOw7Jr6Iclw60zXq5k9e6IeegXj9nVUu_xl36RtmJhv8cfvXSqeJwjUpqklv3q0aQt2JdOQenIrfmUeXlaJo2rnvQIFf-ziUZkeRawlUy6cMeVI6uxx0F7RMbv3VczVq35kS2dFjtf-qhXRiaidW3xd41itzm9-B6BvSV-3Sw0V29ajz-SIjnafyl-hg7WZR2osbvtm76F7qaRFQaz0xg_63mMzszoqr-4-IWzcxl1Jq3lc76xnvs8mWz3-eYdY0Fbk9iZMh8ZydFju3y5ifMJs_y7wu2VZhJtnVyRlcSSYFBzQqZQIl-vmd1FB1ce3Fpvz9_mWoZM1U-bw4SWymt3VaYfMMJn-Bl5kXlp-cbOFn-Y56J0d9F2QtZfBl41X0fypo2F_yyQpfVxZtlMXwdk6nqJxS3Mp-cikQRjSxt0js9XSjobJvSsdIwzV0JzWtyRZUxa8n0j5Fmt10Oo4Zn0XnUx82661rv1-MUd5syO2Z9XUYYfvRlyMpZnOVsdc_8zBOYgieWOXUrxpZ-iF4wn795MORW';
    // 'ya29.c.c0AY_VpZi5bq_j3pjjITX9S4XXlT375_UlDMNaoaFC3uH2cVgreBFyQWlHkxXjuDwA5qIuWaSUvJCyEge9LyTnVjVlEyAXgB5B7xUupf57Tw-SfmjWCZpGz5I1a1t1OsjRXC8nZALSJ9MUaMUrumFDW-VbObBf5d9vgI9DpwooSyiEVxwKsNF42LOi7ZSmtZbqkxIh8cHUiBSyWL66RzKHKypUA3lk1-h1Kib4Mx9vJ2gXl6dpX3Mf6s0fySsLxz0hj4N-H9pMwuSVZergMknGbMGnO0KIPlm5VtcQJEIyaxgYMo448lNXJYTWERIDWJfyqfaI3nFLWAEWJLTMES8CqAlrptatVqzw_LkGDqzGv_ZTNwMOHrbeZzUE384AFSqa0Wtu8tRypuUfIlfomZ9eWIya_xjZrs086-WwV42--Rn6dv29nz0MMhht-imtg6k6555iOU00pucrQSnr34F_X5n5Sl4qVue7V9IzpJh4B8_sseIle0IgwQaO0YVl1F8Qt7Y9zrdMOv-UfrOvBns8xrpRJJJxclBv9WsF1c3MdUsJj0e2OuXkMySBuO7j7dvdteW52FQIgii4vmV65lUO9n6jRu4qh59yJFIgwZbeye67mWVFYipkdyn8BYSy14_ogbmn9yp2W0a1o7nWoxtxieWxftZJUS2mwX6tqbdFlceFjak2fp9wzmvgeM70ipj6tUhYtOk-vJSB1o5mS-1eVorttng5cnXIyVvsX0-5XFRdf4173zURSfVWwlQQFboJ1QQZS7u_iij-tzsQJUldb50j39ecF807f8taJFXIf90wStQlqJIQkjWbf1uihcpyYepBwiezV9wag14s4ywl81XyvFk4s0pB-1a3VJdukJ2Bfz2q65vVgqfooOs71u9O8JQwmk8aRi2sr3uSc5wMXhF_ef5nin743X5oItvkx87jRBegMq3kktr2sQBiI1ZVm70sY_oVOQf_Sm7vg-jd-km6ab9kz_MOftcoi15zUwgW86izFtlhbmj';

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
