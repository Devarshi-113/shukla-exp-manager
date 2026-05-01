import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String title;
  final double amount;
  final String category;
  final String subCategory;
  final DateTime date;
  final String mode; // 'cash' or 'online'
  final String memberName;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.subCategory,
    required this.date,
    required this.mode,
    required this.memberName,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'subCategory': subCategory,
      'date': Timestamp.fromDate(date),
      'mode': mode,
      'memberName': memberName,
    };
  }

  factory Expense.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mode: data['mode'] ?? 'online',
      memberName: data['memberName'] ?? '',
    );
  }
}
