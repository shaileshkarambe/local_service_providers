import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:local_service_providers/Utils/message.dart';
import 'package:local_service_providers/Utils/notification.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
            .where('seeker_name', isEqualTo: name)
            // .orderBy('date', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Scheduling data found '),
            );
          } else {
            final serviceRequests = snapshot.data!.docs;
            return ListView.builder(
              itemCount: serviceRequests.length,
              itemBuilder: (ctx, index) {
                final requestData =
                    serviceRequests[index].data() as Map<String, dynamic>;
                final status = requestData['status'];
                final requestId = serviceRequests[index].id;
                return Dismissible(
                  key: ValueKey(requestId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    deleteRequest(requestId);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Text(
                              "Provider Name: ${requestData['provider_name']}"),
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
                                  : status == 'completed'
                                      ? Colors.blue
                                      : status == 'pending'
                                          ? Colors.orange
                                          : status == 'canceled'
                                              ? Colors.blueGrey
                                              : Colors.red,
                            ),
                          ),
                        ),
                        Row(children: [
                          if (status == 'accepted' || status == 'pending')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  cancelRequest(
                                      requestId, requestData['provider_name']);
                                },
                                child: const Text('Cancel Request'),
                              ),
                            ),
                          const Spacer(),
                          if (status == 'accepted')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  markAsComplete(
                                      requestId, requestData['provider_name']);
                                },
                                child: const Text('Mark as Complete'),
                              ),
                            ),
                        ])
                      ],
                    ),
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
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String formattedTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  void cancelRequest(String requestId, String providerName) {
    const snackBar = SnackBar(
      content: Text(
          'You cancel Service request. Your money reflects within 24 Hours in your account  '),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    FirebaseFirestore.instance
        .collection('Scheduling')
        .doc(requestId)
        .update({'status': 'canceled'}).then((_) {
      sendNotificationToCancle(providerName);
      setState(() {
        // Update UI
      });
    }).catchError((error) {
      print("Failed to cancel request: $error");
      // Handle error
    });
  }

  void sendNotificationToCancle(String providerName) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('tokens')
            .where('name', isEqualTo: providerName)
            .get();

    querySnapshot.docs.forEach((doc) {
      if (doc.exists) {
        String providerToken = doc['token'];
        sendNotification(providerToken, "title", "body");
        // Message().sendMessageToDevice(
        //     providerToken,
        //     " Sorry !! Service request was Cancle",
        //     "Your Scheduling Service request was cancel by $name.");
      }
    });
  }

  void markAsComplete(String requestId, String providerName) {
    sendNotificationToComplete(providerName);
    FirebaseFirestore.instance
        .collection('Scheduling')
        .doc(requestId)
        .update({'status': 'completed'}).then((_) {
      setState(() {
        // Update UI
      });
    }).catchError((error) {
      print("Failed to mark as complete: $error");
      // Handle error
    });

    FirebaseFirestore.instance
        .collection('transaction')
        .doc(requestId)
        .update({'status': 'completed'});
  }

  void sendNotificationToComplete(String providerName) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('tokens')
            .where('name', isEqualTo: providerName)
            .get();

    querySnapshot.docs.forEach((doc) {
      if (doc.exists) {
        String providerToken = doc['token'];

        sendNotification(providerToken, "", "body");
        // Message().sendMessageToDevice(
        //     providerToken,
        //     " Congratulations! You successfully completed your scheduling request",
        //     "Congratulations! You successfully completed your scheduling request.  Your money reflects within 24 Hours in your Wallet ");
      }
    });
  }

  void deleteRequest(String requestId) {
    FirebaseFirestore.instance
        .collection('Scheduling')
        .doc(requestId)
        .delete()
        .then((_) {
      setState(() {
        // Update UI if needed
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request deleted successfully.'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              // You can implement an undo action here if needed
            },
          ),
        ),
      );
    }).catchError((error) {
      print("Failed to delete request: $error");
      // Handle error
    });
  }
}
