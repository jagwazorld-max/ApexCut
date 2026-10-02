import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppTheme.primary),
            title: const Text('App Version'),
            subtitle: Text(Branding.version),
          ),
          ListTile(
            leading: const Icon(Icons.business, color: AppTheme.primary),
            title: const Text('Developer'),
            subtitle: Text(Branding.byLine),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Always on (recommended for editors)'),
            value: true,
            onChanged: null,
            activeColor: AppTheme.primary,
          ),
          SwitchListTile(
            title: const Text('High Quality Preview'),
            subtitle: const Text('Uses more memory'),
            value: true,
            onChanged: (v) {},
            activeColor: AppTheme.primary,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text('Clear Cache'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Feedback'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
