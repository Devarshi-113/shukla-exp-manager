import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/static_translations.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'expenses_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.wifi];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final List<Widget> _screens = [
    const ExpensesScreen(),
    const DashboardScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    Connectivity().checkConnectivity().then(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  bool get _isOffline => _connectionStatus.contains(ConnectivityResult.none);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_isOffline)
            Container(
              color: Colors.red,
              width: double.infinity,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 8, left: 16, right: 16),
              child: Text(
                StaticTranslations.get(context, 'offlineMessage'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: StaticTranslations.get(context, 'expensesTab'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: StaticTranslations.get(context, 'dashboardTab'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: StaticTranslations.get(context, 'settingsTab'),
          ),
        ],
      ),
    );
  }
}
