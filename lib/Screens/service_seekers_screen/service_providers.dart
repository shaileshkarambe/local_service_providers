import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:local_service_providers/Widget/service_providers.dart';
import 'package:local_service_providers/model/provider_list.dart';

class ServiceProviderScreen extends StatelessWidget {
  const ServiceProviderScreen({super.key, required this.item});
  final String item; //category name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Providers"),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('dropdownValue',
                  isEqualTo:
                      item) //check whether dropdown value is equal to category title
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Text("Error:${snapshot.error}");
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No users found for $item'),
              );
            } else {
              List<ProviderList> providerList =
                  snapshot.data!.docs.map((DocumentSnapshot doc) {
                return ProviderList.fromMap(
                    doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              return ListView.builder(
                itemCount: providerList.length,
                itemBuilder: (BuildContext context, int index) {
                  ProviderList provider = providerList[index];
                  return ServiceProvidersCard(provider: provider);
                },
              );
            }
          }),
    );
  }
}
