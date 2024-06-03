import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'hive_database.dart';
import 'transaction_model.dart';
import 'total_amount.dart';
import 'note_list.dart';

class AddNotePage extends StatefulWidget {
  final String username;

  AddNotePage({required this.username});

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _descriptionController = TextEditingController();
  late String _selectedCategory = 'expenses';
  final TextEditingController _amountController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _addTransaction() async {
    String description = _descriptionController.text.trim();
    String amountText = _amountController.text;

    if (description.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (description.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Description is too long. Maximum length is 50 characters')),
      );
      return;
    }

    double? amount;
    try {
      amount = double.parse(amountText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    DateTime transactionDate = _selectedDate;

    Transaction newTransaction = Transaction(
      DateTime.now().millisecondsSinceEpoch,
      _selectedCategory,
      description,
      amount,
      transactionDate,
    );

    try {
      // Ambil data pengguna dari database
      User? user = await HiveDatabase.getUser(widget.username);

      if (user != null) {
        // Tambahkan transaksi ke daftar transaksi pengguna
        user.transactions.add(newTransaction);

        // Simpan kembali pengguna ke database
        await HiveDatabase.updateUser(user);

        _descriptionController.clear();
        _amountController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      print('Error adding transaction: $e'); // Tambahkan pernyataan print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add transaction: $e')),
      );
    }
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () => _selectDate(context),
              child: Row(
                children: [
                  Icon(Icons.date_range),
                  SizedBox(width: 10),
                  Text(
                    'Transaction Date:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 10),
                  Text(
                    DateFormat.yMMMMd().format(_selectedDate),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField(
              value: _selectedCategory,
              items: ['income', 'expenses'].map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(fontSize: 16),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _addTransaction,
                child: Text(
                  'Add Transaction',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF8f14b8),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined, color: Colors.white),
            label: 'Add Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined, color: Colors.grey),
            label: 'Show List Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.balance, color: Colors.grey),
            label: 'Show List Notes',
          ),
        ],
        onTap: (int index) async {
          if (index == 0) {
            // Already on Add Notes page
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteListPage(username: widget.username),
              ),
            );
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
