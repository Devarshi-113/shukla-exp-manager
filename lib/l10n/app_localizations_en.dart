// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Family Expense Manager';

  @override
  String get expensesTab => 'Expenses';

  @override
  String get dashboardTab => 'Dashboard';

  @override
  String get settingsTab => 'Settings';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get title => 'Title';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get subCategory => 'Sub-Category';

  @override
  String get date => 'Date';

  @override
  String get mode => 'Mode';

  @override
  String get cash => 'Cash';

  @override
  String get online => 'Online';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get selectMember => 'Select Member';

  @override
  String get language => 'Language';

  @override
  String get exportCSV => 'Export to CSV';

  @override
  String get noExpenses => 'No expenses logged yet.';

  @override
  String get total => 'Total';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get offlineMessage =>
      'No Internet Connection. Edits will be saved locally.';
}
