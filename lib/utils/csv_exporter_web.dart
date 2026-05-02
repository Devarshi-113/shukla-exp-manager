import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

Future<void> saveCsvFile(BuildContext context, String csvData) async {
  final bytes = utf8.encode(csvData);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "expenses_export_${DateTime.now().millisecondsSinceEpoch}.csv")
    ..click();
  html.Url.revokeObjectUrl(url);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV Downloaded Successfully')),
    );
  }
}
