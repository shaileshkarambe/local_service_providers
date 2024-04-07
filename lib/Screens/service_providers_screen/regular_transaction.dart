import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegularTransactionsScreen extends StatefulWidget {
  @override
  _RegularTransactionsScreenState createState() =>
      _RegularTransactionsScreenState();
}

class _RegularTransactionsScreenState extends State<RegularTransactionsScreen> {
  late List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      setState(() {
        _transactions = transactionsSnapshot.docs
            .map((doc) => Transaction.fromFirestore(doc))
            .toList();
      });
    } catch (error) {
      print("Error fetching transactions: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regular Transactions'),
      ),
      body: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (BuildContext context, int index) {
          final transaction = _transactions[index];
          return ListTile(
            title: Text(transaction.title),
            subtitle: Text(
                'Amount: ₹${transaction.amount.toStringAsFixed(2)} - ${_formatTimestamp(transaction.timestamp)}'),
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch)
        .toString();
  }
}

class Transaction {
  final String title;
  final double amount;
  final Timestamp timestamp;

  Transaction({
    required this.title,
    required this.amount,
    required this.timestamp,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction(
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
