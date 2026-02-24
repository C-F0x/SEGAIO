import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../l10n/generated/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeModeChange;
  final Function(Locale) onLocaleChange;

  const SettingsPage({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChange,
    required this.onLocaleChange,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _openAppDataDir() async {
    try {
      final appData = Platform.environment['APPDATA'];
      if (appData == null) return;
      final path = p.join(appData, 'segacfg');
      final dir = Directory(path);
      if (!await dir.exists()) await dir.create(recursive: true);
      await Process.run('explorer.exe', [path]);
    } catch (e) {
      if (mounted) {
        displayInfoBar(context, builder: (context, close) => InfoBar(
          title: const Text('Error'),
          content: Text(e.toString()),
          severity: InfoBarSeverity.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(title: Text(loc.settings)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: PageHeader.horizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(text: loc.appearance),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(FluentIcons.color),
                          title: Text(loc.themeMode),
                          trailing: ComboBox<ThemeMode>(
                            value: widget.currentThemeMode,
                            items: [
                              ComboBoxItem(value: ThemeMode.system, child: Text(loc.systemMode)),
                              ComboBoxItem(value: ThemeMode.light, child: Text(loc.lightMode)),
                              ComboBoxItem(value: ThemeMode.dark, child: Text(loc.darkMode)),
                            ],
                            onChanged: (mode) => widget.onThemeModeChange(mode!),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(FluentIcons.locale_language),
                          title: Text(loc.language),
                          trailing: ComboBox<Locale>(
                            value: currentLocale,
                            items: const [
                              ComboBoxItem(value: Locale('zh'), child: Text('简体中文')),
                              ComboBoxItem(value: Locale('zh', 'TW'), child: Text('繁体中文')),
                              ComboBoxItem(value: Locale('en'), child: Text('English')),
                            ],
                            onChanged: (locale) {
                              if (locale != null) widget.onLocaleChange(locale);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  _Header(text: loc.dataManagement),
                  Card(
                    child: ListTile(
                      leading: const Icon(FluentIcons.folder_search),
                      title: Text(loc.configFolder),
                      subtitle: Text(loc.configFolderDesc),
                      trailing: HyperlinkButton(
                        onPressed: _openAppDataDir,
                        child: Text(loc.openFolder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8.0, start: 4.0),
      child: Text(text, style: FluentTheme.of(context).typography.subtitle),
    );
  }
}