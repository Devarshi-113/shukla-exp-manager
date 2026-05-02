import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

import 'csv_exporter_stub.dart'
    if (dart.library.io) 'csv_exporter_io.dart'
    if (dart.library.html) 'csv_exporter_web.dart';

class CSVExporter {
  static Future<void> exportToCSV(BuildContext context, List<Expense> expenses) async {
    try {
      List<List<dynamic>> rows = [];
      // Headers
      rows.add([
        "ID", "Title", "Amount", "Category", 
        "Sub-Category", "Date", "Mode", "Member Name"
      ]);

      // Data
      for (var expense in expenses) {
        rows.add([
          expense.id ?? '',
          expense.title,
          expense.amount,
          expense.category,
          expense.subCategory,
          DateFormat('yyyy-MM-dd').format(expense.date),
          expense.mode,
          expense.memberName
        ]);
      }

      String csvData = csv.encode(rows);

      await saveCsvFile(context, csvData);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting CSV: $e')),
        );
      }
    }
  }
}
