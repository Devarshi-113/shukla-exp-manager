import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  ExpenseProvider() {
    _initExpenseStream();
  }

  void _initExpenseStream() {
    _firestore.collection('expenses').orderBy('date', descending: true).snapshots().listen((snapshot) {
      _expenses = snapshot.docs.map((doc) => Expense.fromDocument(doc)).toList();
      notifyListeners();
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _firestore.collection('expenses').add(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }

  // Analytics Helpers
  List<Expense> getFilteredExpenses(int year, int month) {
    return _expenses.where((exp) => exp.date.year == year && exp.date.month == month).toList();
  }

  double getTotalForList(List<Expense> list) {
    return list.fold(0, (sum, item) => sum + item.amount);
  }

  Map<String, double> getCategorySplit(List<Expense> list) {
    Map<String, double> map = {};
    for (var exp in list) {
      map[exp.category] = (map[exp.category] ?? 0) + exp.amount;
    }
    return map;
  }

  Map<String, double> getSubCategorySplit(List<Expense> list, String category) {
    Map<String, double> map = {};
    for (var exp in list.where((e) => e.category == category)) {
      map[exp.subCategory] = (map[exp.subCategory] ?? 0) + exp.amount;
    }
    return map;
  }

  Map<DateTime, double> getDailyTrend(int year, int month) {
    List<Expense> list = getFilteredExpenses(year, month);
    Map<DateTime, double> map = {};
    int daysInMonth = DateTime(year, month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      map[DateTime(year, month, i)] = 0.0;
    }
    for (var exp in list) {
      final expDate = DateTime(exp.date.year, exp.date.month, exp.date.day);
      if (map.containsKey(expDate)) {
        map[expDate] = map[expDate]! + exp.amount;
      }
    }
    return map;
  }

  Map<String, double> getPast6MonthsAggregate(int targetYear, int targetMonth) {
    Map<String, double> map = {};
    for (int i = 5; i >= 0; i--) {
      int m = targetMonth - i;
      int y = targetYear;
      while (m <= 0) {
        m += 12;
        y -= 1;
      }
      DateTime dt = DateTime(y, m, 1);
      String key = "${dt.year}-${dt.month.toString().padLeft(2, '0')}";
      map[key] = 0.0;
    }

    for (var exp in _expenses) {
      String key = "${exp.date.year}-${exp.date.month.toString().padLeft(2, '0')}";
      if (map.containsKey(key)) {
        map[key] = map[key]! + exp.amount;
      }
    }
    return map;
  }

  Map<String, double> getMemberWiseSplit(List<Expense> list) {
    Map<String, double> map = {};
    for (var exp in list) {
      map[exp.memberName] = (map[exp.memberName] ?? 0) + exp.amount;
    }
    return map;
  }
}
