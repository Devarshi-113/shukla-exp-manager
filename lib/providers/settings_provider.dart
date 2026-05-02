import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _selectedMember = 'Arkesh'; 
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  String get selectedMember => _selectedMember;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  // Updated family members list
  final List<String> familyMembers = [
    'Arkesh',
    'Avni',
    'Dushyant',
    'Pratham',
    'Radha',
    'Sarla'
  ];

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final member = prefs.getString('selectedMember');
    if (member != null && familyMembers.contains(member)) {
      _selectedMember = member;
    }
    
    final langCode = prefs.getString('languageCode');
    if (langCode != null) {
      _locale = Locale(langCode);
    }

    final themeStr = prefs.getString('themeMode');
    if (themeStr != null) {
      if (themeStr == 'light') _themeMode = ThemeMode.light;
      if (themeStr == 'dark') _themeMode = ThemeMode.dark;
      if (themeStr == 'system') _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setSelectedMember(String member) async {
    if (familyMembers.contains(member)) {
      _selectedMember = member;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedMember', member);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (['en', 'gu'].contains(newLocale.languageCode)) {
      _locale = newLocale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', newLocale.languageCode);
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode newTheme) async {
    _themeMode = newTheme;
    final prefs = await SharedPreferences.getInstance();
    String themeStr = 'system';
    if (newTheme == ThemeMode.light) themeStr = 'light';
    if (newTheme == ThemeMode.dark) themeStr = 'dark';
    await prefs.setString('themeMode', themeStr);
    notifyListeners();
  }
}
