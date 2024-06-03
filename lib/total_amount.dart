import 'package:catatanpengeluaran/add_notes.dart';
import 'package:catatanpengeluaran/note_list.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'transaction_model.dart';
import 'hive_database.dart';

class TotalAmountPage extends StatefulWidget {
  final String username;

  TotalAmountPage({required this.username});
  @override
  _TotalAmountPageState createState() => _TotalAmountPageState();
}

class _TotalAmountPageState extends State<TotalAmountPage> {
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _netAmount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      // Ambil data pengguna dari database
      User? user = await HiveDatabase.getUser(widget.username);

      if (user != null) {
        // Ambil daftar transaksi dari data pengguna
        List<Transaction> transactions = user.transactions;

        // Hitung total pendapatan, total pengeluaran, dan jumlah bersih
        _totalIncome = transactions
            .where((transaction) => transaction.category == 'income')
            .map((transaction) => transaction.amount)
            .fold(0, (prev, amount) => prev + amount);

        _totalExpenses = transactions
            .where((transaction) => transaction.category == 'expenses')
            .map((transaction) => transaction.amount)
            .fold(0, (prev, amount) => prev + amount);

        _netAmount = _totalIncome - _totalExpenses;

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("User data not found");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching transactions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load transactions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Amount'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: 200,
            height: 200,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Income: \$${_totalIncome.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Total Expenses: \$${_totalExpenses.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Net Amount: \$${_netAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF8f14b8),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined, color: Colors.grey),
            label: 'Add Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined, color: Colors.grey),
            label: 'Show List Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.balance, color: Colors.white),
            label: 'Show Total Amount',
          ),
        ],
        onTap: (int index) async {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNotePage(username: widget.username),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteListPage(username: widget.username),
              ),
            );
          } else if (index == 2) {
            // Already on Total Amount page
          }
        },
      ),
    );
  }
}
