import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/static_translations.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(StaticTranslations.get(context, 'settingsTab'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StaticTranslations.get(context, 'selectMember'),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: settingsProvider.familyMembers.map((member) {
                      final isSelected = settingsProvider.selectedMember == member;
                      return ChoiceChip(
                        label: Text(member),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            settingsProvider.setSelectedMember(member);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StaticTranslations.get(context, 'chooseLanguage'),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('English'),
                    trailing: Radio<String>(
                      value: 'en',
                      groupValue: settingsProvider.locale.languageCode,
                      onChanged: (val) {
                        if (val != null) settingsProvider.setLocale(Locale(val));
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('ગુજરાતી'),
                    trailing: Radio<String>(
                      value: 'gu',
                      groupValue: settingsProvider.locale.languageCode,
                      onChanged: (val) {
                        if (val != null) settingsProvider.setLocale(Locale(val));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('System Default'),
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: settingsProvider.themeMode,
                      onChanged: (val) {
                        if (val != null) settingsProvider.setThemeMode(val);
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Light'),
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.light,
                      groupValue: settingsProvider.themeMode,
                      onChanged: (val) {
                        if (val != null) settingsProvider.setThemeMode(val);
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Dark'),
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.dark,
                      groupValue: settingsProvider.themeMode,
                      onChanged: (val) {
                        if (val != null) settingsProvider.setThemeMode(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              "Made by Shri. Devarshi Dave",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
