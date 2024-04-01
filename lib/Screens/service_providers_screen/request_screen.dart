import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_service_providers/Utils/message.dart';

class RequestScreen extends StatefulWidget {
  RequestScreen({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
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
            .where("status", whereIn: ['pending', 'accepted']).snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No request found '),
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
                            color: status == 'accepted'
                                ? Colors.green
                                : status == 'pending'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                      if (status != 'accepted')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  acceptRequest(
                                      serviceRequests[index].reference,
                                      true,
                                      requestData['seeker_name']);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Accept'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  rejectRequest(
                                      serviceRequests[index].reference,
                                      requestData['seeker_name']);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Reject'),
                              ),
                            ],
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

  void acceptRequest(
      DocumentReference requestRef, bool isAccepted, String seekerName) async {
    try {
      await requestRef.update({'status': 'accepted'});
      const snackBar = SnackBar(
        content: Text('Request accepted'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      sendNotificationToAccept(seekerName);

      setState(() {
        // Update the UI to reflect the change
      });
    } catch (e) {
      print('Error updating request status: $e');
    }
  }

  void sendNotificationToAccept(String seekerName) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('tokens')
            .where('name', isEqualTo: seekerName)
            .get();

    querySnapshot.docs.forEach((doc) {
      if (doc.exists) {
        String seekerToken = doc['token'];

        Message().sendMessageToDevice(
            seekerToken,
            "Service request was Accepted",
            "Your Scheduling request was Accepted by $name !!");
      }
    });
  }

  void rejectRequest(DocumentReference requestRef, String seekerName) async {
    try {
      await requestRef.update({'status': 'rejected'});
      const snackBar = SnackBar(
        content: Text('Request rejected'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Show SnackBar
      sendNotificationToCancle(seekerName);
      setState(() {});
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  void sendNotificationToCancle(String seekerName) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('tokens')
            .where('name', isEqualTo: seekerName)
            .get();

    querySnapshot.docs.forEach((doc) {
      if (doc.exists) {
        String seekerName = doc['token'];

        Message().sendMessageToDevice(seekerName, "Service request was Cancle",
            "Your  Service  request was cancle by $name.");
      }
    });
  }
}
