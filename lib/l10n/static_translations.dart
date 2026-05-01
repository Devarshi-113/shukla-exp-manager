import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class StaticTranslations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Family Expense Manager',
      'expensesTab': 'Expenses',
      'dashboardTab': 'Dashboard',
      'settingsTab': 'Settings',
      'addExpense': 'Add Expense',
      'title': 'Title',
      'amount': 'Amount',
      'category': 'Category',
      'subCategory': 'Sub-Category',
      'date': 'Date',
      'mode': 'Mode',
      'cash': 'Cash',
      'online': 'Online',
      'save': 'Save',
      'cancel': 'Cancel',
      'selectMember': 'Select Member',
      'language': 'Language',
      'exportCSV': 'Export to CSV',
      'noExpenses': 'No expenses logged yet.',
      'total': 'Total',
      'chooseLanguage': 'Choose Language',
      'offlineMessage': 'No Internet Connection. Edits will be saved locally.',
      'monthlyAggregate': 'Monthly Aggregate',
      'monthlyTargetProgress': 'Monthly Target Progress',
      'ofTarget': 'of',
      'past6Months': 'Past 6 Months',
      'memberWiseExpense': 'Member wise expense',
      'noData': 'No Data',
      'monthlyTrend': 'Monthly Trend',
      'expensesByCategory': 'Expenses by category',
    },
    'gu': {
      'appTitle': 'કૌટુંબિક ખર્ચ મેનેજર',
      'expensesTab': 'ખર્ચાઓ',
      'dashboardTab': 'ડેશબોર્ડ',
      'settingsTab': 'સેટિંગ્સ',
      'addExpense': 'ખર્ચ ઉમેરો',
      'title': 'શીર્ષક',
      'amount': 'રકમ',
      'category': 'શ્રેણી',
      'subCategory': 'ઉપ-શ્રેણી',
      'date': 'તારીખ',
      'mode': 'માધ્યમ',
      'cash': 'રોકડા',
      'online': 'ઓનલાઈન',
      'save': 'દાખલ કરો',
      'cancel': 'રદ કરો',
      'selectMember': 'સભ્ય પસંદ કરો',
      'language': 'ભાષા',
      'exportCSV': 'CSV માં નિકાસ કરો',
      'noExpenses': 'હજી સુધી કોઈ ખર્ચ લૉગ નથી.',
      'total': 'કુલ',
      'chooseLanguage': 'ભાષા પસંદ કરો',
      'offlineMessage': 'કોઈ ઈન્ટરનેટ કનેક્શન નથી. સંપાદનો સ્થાનિક રીતે સાચવવામાં આવશે.',
      'monthlyAggregate': 'માસિક કુલ',
      'monthlyTargetProgress': 'માસિક લક્ષ્ય',
      'ofTarget': 'of',
      'past6Months': 'છેલ્લા 6 મહિના',
      'memberWiseExpense': 'સભ્ય મુજબ ખર્ચ',
      'noData': 'કોઈ ડેટા નથી',
      'monthlyTrend': 'માસિક વલણ',
      'expensesByCategory': 'શ્રેણી મુજબ ખર્ચ',
    }
  };

  static String get(BuildContext context, String key) {
    final langCode = Provider.of<SettingsProvider>(context).locale.languageCode;
    return _localizedValues[langCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
