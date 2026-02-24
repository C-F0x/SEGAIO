import 'dart:convert';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:window_manager/window_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import 'pages/overview.dart';
import 'pages/settings.dart';
import 'pages/config.dart';
import 'shared/project.dart';
import 'shared/database.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutter_acrylic.Window.initialize();
  await windowManager.ensureInitialized();

  ThemeMode savedMode = await _loadSettings();
  bool isDark = savedMode == ThemeMode.system
      ? PlatformDispatcher.instance.platformBrightness == Brightness.dark
      : savedMode == ThemeMode.dark;

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.show();
    await flutter_acrylic.Window.setEffect(effect: flutter_acrylic.WindowEffect.mica, dark: isDark);
  });

  runApp(MyApp(initialThemeMode: savedMode));
}

Future<ThemeMode> _loadSettings() async {
  try {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/settings.json');
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString());
      return ThemeMode.values.firstWhere((e) => e.toString() == 'ThemeMode.${data['themeMode']}', orElse: () => ThemeMode.system);
    }
  } catch (_) {}
  return ThemeMode.system;
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('zh');
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void setLocale(Locale locale) => setState(() => _locale = locale);
  void setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    bool isDark = (mode == ThemeMode.dark) || (mode == ThemeMode.system && PlatformDispatcher.instance.platformBrightness == Brightness.dark);
    await flutter_acrylic.Window.setEffect(effect: flutter_acrylic.WindowEffect.mica, dark: isDark);
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: _themeMode,
      theme: FluentThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        navigationPaneTheme: const NavigationPaneThemeData(backgroundColor: Colors.transparent),
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        navigationPaneTheme: const NavigationPaneThemeData(backgroundColor: Colors.transparent),
      ),
      home: MainNavigation(
        onLocaleChange: setLocale,
        currentThemeMode: _themeMode,
        onThemeModeChange: setThemeMode,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeModeChange;

  const MainNavigation({super.key, required this.onLocaleChange, required this.currentThemeMode, required this.onThemeModeChange});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _refreshList();
  }
  Future<void> _refreshList() async {
    final list = await JsonDbService.loadProjects();
    setState(() {
      _projects = list;
    });
  }
  void _handleProjectChanged() {
    _refreshList();
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return NavigationView(
      appBar: const NavigationAppBar(
        height: 0,
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
              icon: const Icon(FluentIcons.home),
              title: Text(loc.overview),
              body: const OverviewPage()
          ),
          PaneItemExpander(
            key: const ValueKey('expander'),
            icon: const Icon(FluentIcons.page_list),
            title: Text(loc.manageConfig),
            body: ConfigPage(
              title: loc.manageConfig,
              onProjectCreated: (_) => _handleProjectChanged(),
              onProjectSelected: (project) {
                final projectIndex = _projects.indexWhere((p) => p.id == project.id);
                if (projectIndex != -1) {
                  setState(() {
                    _currentIndex = 1 + 1 + projectIndex;
                  });
                }
              },
            ),
            items: [
              ..._projects.map((p) => PaneItem(
                key: ValueKey(p.id),
                icon: const Icon(FluentIcons.document_set),
                title: Text(p.name),
                body: ConfigPage(
                  title: "编辑: ${p.name}",
                  onProjectCreated: (_) => _handleProjectChanged(),
                  onProjectSelected: null,
                ),
              )),
            ],
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: Text(loc.settings),
            body: SettingsPage(
              currentThemeMode: widget.currentThemeMode,
              onThemeModeChange: widget.onThemeModeChange,
              onLocaleChange: widget.onLocaleChange,
            ),
          ),
        ],
      ),
    );
  }
}