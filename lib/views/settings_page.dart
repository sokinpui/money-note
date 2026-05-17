import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.appAppearance),
            subtitle: Text(_getThemeName(themeMode, l10n)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(l10n.selectTheme),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                        Navigator.pop(context);
                      },
                      child: Text(l10n.system),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                        Navigator.pop(context);
                      },
                      child: Text(l10n.light),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                        Navigator.pop(context);
                      },
                      child: Text(l10n.dark),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.languagePreference),
            subtitle: Text(locale.languageCode == 'en' ? l10n.english : l10n.chinese),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(l10n.selectLanguage),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                        Navigator.pop(context);
                      },
                      child: Text(l10n.english),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(localeProvider.notifier).setLocale(const Locale('zh'));
                        Navigator.pop(context);
                      },
                      child: Text(l10n.chinese),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.system;
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
    }
  }
}
