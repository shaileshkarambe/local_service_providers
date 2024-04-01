import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_service_providers/Screens/service_providers_screen/withdrawrequest_form.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0.0; // Initialize with the user's current balance
  late List<Transaction> _transactions = [];
  late List<WithdrawRequest> _withdrawRequests = [];
  bool _showRegularTransactions = true;

  @override
  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    // Start listening for scheduling updates
    FirebaseFirestore.instance
        .collection('Scheduling')
        .where('status', isEqualTo: 'completed')
        .where('provider_name',
            isEqualTo: FirebaseAuth.instance.currentUser!.displayName)
        .snapshots()
        .listen((snapshot) {
      snapshot.docs.forEach((doc) {
        final amount = doc['amount'] as double;
        _updateBalance(amount); // Update balance
        _addTransaction('Scheduled Service', amount); // Add transaction
        // Save transaction to Firestore
        FirebaseFirestore.instance.collection('transactions').add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'title': 'Scheduled Service',
          'amount': amount,
          'timestamp': DateTime.now(),
        });
      });
    });
  }

  Future<void> _fetchTransactions() async {
    try {
      // Assuming you have a 'transactions' collection in Firestore
      QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        _transactions = transactionsSnapshot.docs
            .map((doc) => Transaction.fromFirestore(doc))
            .toList();
      });
    } catch (error) {
      print("Error fetching transactions: $error");
    }

    try {
      // Assuming you have a 'withdraw_requests' collection in Firestore
      QuerySnapshot withdrawRequestsSnapshot = await FirebaseFirestore.instance
          .collection('withdraw_requests')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        _withdrawRequests = withdrawRequestsSnapshot.docs
            .map((doc) => WithdrawRequest.fromFirestore(doc))
            .toList();
      });
    } catch (error) {
      print("Error fetching withdraw requests: $error");
    }
  }

  void _updateBalance(double amount) {
    setState(() {
      _balance += amount;
    });
  }

  void _addTransaction(String title, double amount) {
    final transaction = Transaction(title: title, amount: amount);
    setState(() {
      _transactions.add(transaction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Current Balance:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '₹$_balance', // Display the user's balance
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Implement withdraw logic here
                _handleWithdraw();
              },
              child: const Text('Withdraw'),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showRegularTransactions = true;
                    });
                  },
                  child: const Text('Regular Transactions'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showRegularTransactions = false;
                    });
                  },
                  child: const Text('Withdrawal Transactions'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: _showRegularTransactions
                  ? _buildRegularTransactionsList()
                  : _buildWithdrawalTransactionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularTransactionsList() {
    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (BuildContext context, int index) {
        final transaction = _transactions[index];
        return ListTile(
          title: Text(transaction.title),
          subtitle: Text('Amount: ₹${transaction.amount.toStringAsFixed(2)}'),
        );
      },
    );
  }

  Widget _buildWithdrawalTransactionsList() {
    return ListView.builder(
      itemCount: _withdrawRequests.length,
      itemBuilder: (BuildContext context, int index) {
        final request = _withdrawRequests[index];
        return ListTile(
          title: Text('Amount: ₹${request.amount.toStringAsFixed(2)}'),
          subtitle: Text('Status: ${request.status}'),
        );
      },
    );
  }

  void _handleWithdraw() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => WithdrawRequestForm()),
    ).then((withdrawAmount) {
      if (mounted) {
        // Check if the widget is mounted before calling setState
        setState(() {
          if (withdrawAmount != null && withdrawAmount is double) {
            // Subtract the withdrawal amount from the current balance
            _balance -= withdrawAmount;
          }
        });
      }
    });
  }
}

class Transaction {
  final String title;
  final double amount;

  Transaction({
    required this.title,
    required this.amount,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction(
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
    );
  }
}

class WithdrawRequest {
  final double amount;
  final String status;

  WithdrawRequest({
    required this.amount,
    required this.status,
  });

  factory WithdrawRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WithdrawRequest(
      amount: (data['amount'] ?? 0.0).toDouble(),
      status: data['status'] ?? '',
    );
  }
}
