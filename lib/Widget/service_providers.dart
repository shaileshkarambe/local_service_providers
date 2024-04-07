import 'package:flutter/material.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/dialog_box.dart';
import 'package:local_service_providers/model/provider_list.dart';

class ServiceProvidersCard extends StatelessWidget {
  const ServiceProvidersCard({super.key, required this.provider});
//card of profile of service provider
  final ProviderList provider;

  void _openAddExpenseOverplay(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return MyDialog(
          providerName: provider.name,
          categoryName: provider.dropdownValue,
          charges: provider.serviceCharges,
          email: provider.email,
          phonenumber: provider.number,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        child: InkWell(
          onTap: () {
            _openAddExpenseOverplay(context);
          },
          splashColor: Colors.grey,
          child: Column(
            children: [
              Text(
                provider.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Icon(Icons.email),
                  Flexible(child: Text(provider.email)),
                  const Spacer(),
                  const Icon(Icons.work),
                  Flexible(child: Text(provider.dropdownValue))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
