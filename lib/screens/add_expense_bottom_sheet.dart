import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/static_translations.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../models/expense.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  const AddExpenseBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _category = 'Housing';
  String? _subCategory;
  DateTime _selectedDate = DateTime.now();
  String _mode = 'online';

  // final Map<String, List<String>> _categoryMap = {
  //   'Housing': ['Housing', 'Mortgage', 'Property Tax', 'Home Insurance', 'Maintenance', 'Other'],
  //   'Utilities': ['Electricity', 'Water & Sewage', 'Gas', 'Internet & TV', 'Mobile Phone', 'Other'],
  //   'Food': ['Dining Out', 'Online ordering', 'Other'],
  //   'Vehicle / Transportation': ['Fuel', 'Maintenance', 'Public Transit', 'Parking & Tolls', 'Other'],
  //   'Family': ['Childcare', 'School Fees', 'Toys & Gear', 'Other'],
  //   'Healthcare': ['Medical Visits', 'Pharmacy', 'Dental', 'Vision', 'Other'],
  //   'Personal Care': ['Clothing', 'Hair & Grooming', 'Toiletries', 'Gym & Fitness', 'Other'],
  //   'Entertainment': ['Streaming', 'Movies & Events', 'Hobbies', 'Other'],
  //   'Home': ['Cleaning Supplies', 'Furniture', 'Repairs & Tools', 'Groceries', 'Other'],
  //   'Financial': ['Debt Payments', 'Savings', 'Life Insurance', 'Gifts & Charity', 'Miscellaneous', 'Other'],
  //   'Other': ['Other']
  // };

  final Map<String, List<String>> _categoryMap = {
    'Food & Drinks': [
      'Groceries', 
      'Restaurant', 
      'Online Ordering', 
      'Other'
    ],
    'Shopping': [
      'Clothes & Shoes', 
      'Electronics & Accessories', 
      'Gifts', 
      'Health & Beauty', 
      'Jewels & Accessories', 
      'Stationery / Tools', 
      'Home / Garden', 
      'Other'
    ],
    'Housing': [
      'Electricity', 
      'Gas', 
      'Rent', 
      'Maintenance', 
      'Repairs', 
      'Services', 
      'Other'
    ],
    'Transportation': [
      'Business Trips', 
      'Flights', 
      'Public Transport', 
      'Taxi', 
      'Other'
    ],
    'Vehicle': [
      'Fuel', 
      'Parking', 
      'Maintenance', 
      'Other'
    ],
    'Life & Entertainment': [
      'Sports / Fitness', 
      'Subscriptions', 
      'Cultural', 
      'Hobbies', 
      'Holiday / Trips / Hotels', 
      'Events / Functions', 
      'TV / Streaming', 
      'Wellness / Beauty', 
      'Other'
    ],
    'Communication': [
      'Internet', 
      'Phone', 
      'Software / Apps / Games', 
      'Other'
    ],
    'Financial': [
      'Advisory', 
      'Fees', 
      'Charges', 
      'Fines', 
      'Insurance', 
      'Loan / Interest', 
      'Taxes', 
      'Mortgage', 
      'Other'
    ],
    'Medical': [
      'Medicines', 
      'Doctor Visit', 
      'Operations / Surgery', 
      'Other'
    ],
    'Other': ['Other']
  };

  @override
  void initState() {
    super.initState();
    _subCategory = _categoryMap[_category]!.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final amount = double.parse(_amountController.text);
      final subCategory = _subCategory ?? '';
      final memberName = Provider.of<SettingsProvider>(context, listen: false).selectedMember;

      final expense = Expense(
        title: title,
        amount: amount,
        category: _category,
        subCategory: subCategory,
        date: _selectedDate,
        mode: _mode,
        memberName: memberName,
      );

      Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);
      Navigator.of(context).pop();
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                StaticTranslations.get(context, 'addExpense'),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: StaticTranslations.get(context, 'title'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: StaticTranslations.get(context, 'amount'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Invalid Number';
                  if (double.parse(val) <= 0) return 'Must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: StaticTranslations.get(context, 'category'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _categoryMap.keys.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) {
                  setState(() {
                    _category = val!;
                    _subCategory = _categoryMap[_category]!.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _subCategory,
                decoration: InputDecoration(
                  labelText: StaticTranslations.get(context, 'subCategory'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                ),
                items: _categoryMap[_category]!
                    .map((sub) => DropdownMenuItem(value: sub, child: Text(sub)))
                    .toList(),
                onChanged: (val) => setState(() => _subCategory = val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: StaticTranslations.get(context, 'date'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.blue),
                    onPressed: _presentDatePicker,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(StaticTranslations.get(context, 'online')),
                      value: 'online',
                      groupValue: _mode,
                      onChanged: (val) => setState(() => _mode = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(StaticTranslations.get(context, 'cash')),
                      value: 'cash',
                      groupValue: _mode,
                      onChanged: (val) => setState(() => _mode = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitData,
                child: Text(StaticTranslations.get(context, 'save'), style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
