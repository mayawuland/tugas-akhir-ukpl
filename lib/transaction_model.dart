import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final List<Transaction> transactions;

  User({
    required this.username,
    required this.password,
    List<Transaction>? transactions,
  })  : transactions = transactions ?? [];
}

@HiveType(typeId: 1)
class Transaction {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime transactionDate;

  Transaction(
      this.id,
      this.category,
      this.description,
      this.amount,
      this.transactionDate,
      );
}
