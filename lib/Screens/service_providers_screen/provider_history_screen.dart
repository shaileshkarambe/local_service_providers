import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HistoryScreenProvider extends StatefulWidget {
  const HistoryScreenProvider({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  _HistoryScreenProvider createState() => _HistoryScreenProvider();
}

class _HistoryScreenProvider extends State<HistoryScreenProvider> {
  late String name;

  @override
  void initState() {
    super.initState();
    name = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Scheduling')
            .where('provider_name', isEqualTo: name)
            .where("status", whereIn: [
          'canceled',
          'completed',
          'rejected',
        ]).snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No data found '),
            );
          } else {
            final serviceRequests = snapshot.data!.docs;
            return ListView.builder(
              itemCount: serviceRequests.length,
              itemBuilder: (ctx, index) {
                final requestData =
                    serviceRequests[index].data() as Map<String, dynamic>;
                final status = requestData['status'];
                return Card(
                  key: ValueKey(serviceRequests[index].id), // Added key
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        title: Text("User Name: ${requestData['seeker_name']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Scheduling Date: ${formattedTimestamp(requestData['date'])}",
                            ),
                            Text(
                              "Scheduling Time: ${formattedTime(requestData['date'])}",
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          "Status: $status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == 'completed'
                                ? Colors.green
                                : status == 'canceled'
                                    ? Colors.blue
                                    : status == 'rejected'
                                        ? Colors.redAccent
                                        : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String formattedTimestamp(Timestamp timestamp) {
    // Format the timestamp into a human-readable format
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String formattedTime(Timestamp timestamp) {
    // Format the timestamp into a human-readable time
    DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }
}
