import 'package:flutter/material.dart';
import 'package:local_service_providers/Screens/service_providers_screen/regular_transaction.dart';
import 'package:local_service_providers/Screens/service_providers_screen/withdraw_transaction.dart';
import 'package:local_service_providers/Screens/service_providers_screen/withdrawrequest_form.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Current Balance:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Text(
              '₹$_balance',
              style: const TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _handleWithdraw();
              },
              child: const Text('Withdraw'),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: Column(
                children: [
                  _buildTransactionsCard(
                    title: 'Regular Transactions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => RegularTransactionsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20.0),
                  _buildTransactionsCard(
                    title: 'Withdrawal Transactions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => TransactionDetailScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  void _handleWithdraw() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => WithdrawRequestForm()),
    ).then((withdrawAmount) {
      if (mounted) {
        setState(() {
          if (withdrawAmount != null && withdrawAmount is double) {
            _balance -= withdrawAmount;
          }
        });
      }
    });
  }
}
