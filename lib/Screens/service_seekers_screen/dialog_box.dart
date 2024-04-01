import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/billing_dialogbox.dart';

final dateFormatter = DateFormat.yMd();
final timeFormatter = DateFormat.Hm();

class MyDialog extends StatefulWidget {
  const MyDialog({
    Key? key,
    required this.providerName,
    required this.categoryName,
    required this.charges,
    required this.email,
    required this.phonenumber,
  }) : super(key: key);

  final String providerName;
  final String categoryName;
  final String charges;
  final String email;
  final String phonenumber;

  @override
  _MyDialogState createState() =>
      _MyDialogState(providerName, categoryName, charges, email, phonenumber);
}

class _MyDialogState extends State<MyDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String name = '';
  String providerName;
  String categoryName;
  String charges;
  String email;
  String phonenumber;

  _MyDialogState(this.providerName, this.categoryName, this.charges, this.email,
      this.phonenumber);

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final pickDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (pickDate != null) {
      setState(() {
        _selectedDate = pickDate;
      });
    }
  }

  void _presentTimePicker() async {
    final pickTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickTime != null) {
      setState(() {
        _selectedTime = pickTime;
      });
    }
  }

  void getUserName() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = (snap.data() as Map<String, dynamic>)['username'];
    });
  }

  Future<void> _saveDataToFirestore() async {
    Navigator.of(context).pop();
    if (_selectedDate != null && _selectedTime != null) {
      // Save data to Firestore
      DateTime selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // await FirebaseFirestore.instance.collection('appointments').add({
      //   'date': selectedDateTime,
      //   "User Name": name,
      //   "Provider Name": providerName,
      //   "Service Category": categoryName,
      //   "charges": charges,
      //   'time': _selectedTime,
      // });

      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return BillingDialogBox(
            categoryName: categoryName,
            providerName: providerName,
            charges: charges,
            selectedDate: selectedDateTime,
            seekername: name,
            email: email,
            phonenumer: phonenumber,
          );
        },
      );

      // Navigator.of(context).pop(); // Close the dialog
    } else {
      // Show error message if any field is missing
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please fill in all fields."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Process To Scheduling",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(
            color: Colors.black,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Provider Name: $providerName",
              ),
              const Spacer(),
              Text(
                "Service Name: $categoryName",
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                _selectedDate == null
                    ? "No date Selected"
                    : dateFormatter.format(_selectedDate!),
              ),
              IconButton(
                onPressed: _presentDatePicker,
                icon: const Icon(Icons.calendar_today),
              ),
              const Spacer(),
              Text(
                _selectedTime == null
                    ? "No time Selected"
                    : timeFormatter.format(
                        DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute,
                        ),
                      ),
              ),
              IconButton(
                onPressed: _presentTimePicker,
                icon: const Icon(Icons.access_time),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _saveDataToFirestore,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
