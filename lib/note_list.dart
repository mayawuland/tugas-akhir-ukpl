import 'package:catatanpengeluaran/add_notes.dart';
import 'package:catatanpengeluaran/total_amount.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'hive_database.dart';
import 'transaction_model.dart';

class NoteListPage extends StatefulWidget {
  final String username;

  NoteListPage({required this.username});

  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  List<Transaction>? _transactions;
  List<Transaction>? _filteredTransactions;
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
        _transactions = user.transactions;
        _filteredTransactions = List.from(_transactions!); // Duplicate list for filtering

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
      print("Error during initialization: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load transactions')),
      );
    }
  }

  Future<void> _deleteTransaction(int filteredIndex) async {
    try {
      if (_filteredTransactions != null) {
        // Get the transaction to delete from filtered list
        Transaction transactionToDelete = _filteredTransactions![filteredIndex];

        // Ambil data pengguna dari database
        User? user = await HiveDatabase.getUser(widget.username);

        if (user != null) {
          // Cari indeks transaksi dalam daftar transaksi pengguna
          int transactionIndex = user.transactions.indexOf(transactionToDelete);

          if (transactionIndex != -1) {
            // Hapus transaksi dari daftar transaksi pengguna
            user.transactions.removeAt(transactionIndex);

            // Simpan kembali pengguna ke database
            await HiveDatabase.updateUser(user);

            // Update UI
            setState(() {
              _filteredTransactions!.removeAt(filteredIndex);
              _transactions = List.from(user.transactions); // Update the main transaction list
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Transaction deleted successfully')),
            );
            print("Transaction deleted successfully");
          } else {
            throw Exception("Transaction not found in the user's transaction list");
          }
        } else {
          throw Exception("User data not found");
        }
      }
    } catch (e) {
      print("Error deleting transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $e')),
      );
    }
  }

  Future<void> _confirmDeleteDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this transaction?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteTransaction(index);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildTransactionWidgets() {
    List<Widget> widgets = [];
    DateTime? lastDate;
    if (_filteredTransactions != null) {
      for (Transaction transaction in _filteredTransactions!) {
        if (lastDate == null || lastDate.day != transaction.transactionDate.day) {
          lastDate = transaction.transactionDate;
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                DateFormat.yMMMMd().format(lastDate),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          );
        }
        widgets.add(
          ListTile(
            title: Text(transaction.description),
            subtitle: Text('${transaction.category} - ${transaction.amount.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _confirmDeleteDialog(_filteredTransactions!.indexOf(transaction));
              },
            ),
          ),
        );
        widgets.add(Divider());
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction List'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _transactions == null || _transactions!.isEmpty
          ? Center(
        child: Text('No transactions available'),
      )
          : Column(
        children: [
          Expanded(
            child: ListView(
              children: _buildTransactionWidgets(),
            ),
          ),
        ],
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
            icon: Icon(Icons.list_alt_outlined, color: Colors.white),
            label: 'Show List Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.balance, color: Colors.grey),
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
            // Already on Transaction List page
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TotalAmountPage(username: widget.username),
              ),
            );
          }
        },
      ),
    );
  }
}
