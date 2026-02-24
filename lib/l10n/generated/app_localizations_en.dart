// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get systemMode => 'Follow System';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get createConfig => 'Create Config';

  @override
  String get manageConfig => 'Manage Config';

  @override
  String get noConfigFound => 'No configuration found';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get about => 'About Project';

  @override
  String get projectDescription =>
      'A GUI for editing configs of Dniel97-segatools.';

  @override
  String get version => 'Version';

  @override
  String get githubRepo => 'GitHub Repository';

  @override
  String get githubSub => 'View source code or submit issues';

  @override
  String get overview => 'Overview';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get configFolder => 'Config Storage Location';

  @override
  String get configFolderDesc =>
      'Project lists and logs are saved in %AppData%/segacfg';

  @override
  String get openFolder => 'Open Folder';
}
