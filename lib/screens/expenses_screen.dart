import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/static_translations.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_expense_bottom_sheet.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddExpenseBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(StaticTranslations.get(context, 'appTitle'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: expenseProvider.expenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 80, color: theme.colorScheme.primaryContainer),
                  const SizedBox(height: 16),
                  Text(StaticTranslations.get(context, 'noExpenses'), style: theme.textTheme.titleMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenseProvider.expenses.length,
              itemBuilder: (context, index) {
                final expense = expenseProvider.expenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Icon(
                        expense.mode == 'online' ? Icons.phonelink_ring : Icons.money,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${expense.memberName} • ${expense.category}\n${DateFormat('dd/MM/yyyy').format(expense.date)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      '₹${expense.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseModal(context),
        icon: const Icon(Icons.add),
        label: Text(StaticTranslations.get(context, 'addExpense')),
      ),
    );
  }
}
