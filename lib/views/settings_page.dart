import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('App Appearance'),
            subtitle: const Text('Light / Dark Mode'),
            onTap: () {
              // TODO: Implement Theme Switching
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language Preference'),
            subtitle: const Text('English'),
            onTap: () {
              // TODO: Implement Language Selection
            },
          ),
        ],
      ),
    );
  }
}
