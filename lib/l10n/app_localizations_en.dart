// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Note';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get addRecord => 'Add Record';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get name => 'Name';

  @override
  String get value => 'Value';

  @override
  String get category => 'Category';

  @override
  String get note => 'Note';

  @override
  String get optional => 'Optional';

  @override
  String get save => 'Save';

  @override
  String get importData => 'Import Data';

  @override
  String get exportData => 'Export Data';

  @override
  String get appAppearance => 'App Appearance';

  @override
  String get languagePreference => 'Language Preference';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get deleteRecord => 'Delete Record?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get importSuccess => 'Import Success';

  @override
  String get error => 'Error';

  @override
  String get close => 'Close';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get importJson => 'Import JSON';

  @override
  String get pasteJson => 'Paste JSON here';

  @override
  String get dailySummary => 'Daily Summary';

  @override
  String get netEarnings => 'Net Earnings';

  @override
  String daysAverage(int days) {
    return '$days days average';
  }

  @override
  String get type => 'Type';
}
