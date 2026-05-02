import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveCsvFile(BuildContext context, String csvData) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = "${directory.path}/expenses_export_${DateTime.now().millisecondsSinceEpoch}.csv";
  final file = File(path);
  await file.writeAsString(csvData);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to $path')),
    );
  }
}
