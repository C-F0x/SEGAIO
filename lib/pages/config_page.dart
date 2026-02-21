import 'dart:convert';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'modify_page.dart';
class Project {
  final String id;
  final String name;
  final String path;
  final String type;
  final String createdAt;
  int sortIndex;
  final int errState;

  Project({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.createdAt,
    required this.sortIndex,
    required this.errState,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    path: json['path'] ?? '',
    type: json['variety'] ?? '',
    createdAt: json['create_at'] ?? '',
    sortIndex: json['sort_index'] ?? 0,
    errState: json['err_state'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'variety': type,
    'create_at': createdAt,
    'sort_index': sortIndex,
    'err_state': errState,
  };
}
class JsonDbService {
  static Future<File> _getProjectFile() async {
    final appData = Platform.environment['APPDATA'];
    final dirPath = p.join(appData!, 'configui');
    final directory = Directory(dirPath);
    if (!await directory.exists()) await directory.create(recursive: true);
    return File(p.join(dirPath, 'projects.json'));
  }

  static Future<List<Project>> loadProjects() async {
    try {
      final file = await _getProjectFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      List<Project> projects = jsonList.map((e) => Project.fromJson(e)).toList();
      projects.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      return projects;
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveProjects(List<Project> projects) async {
    try {
      final file = await _getProjectFile();
      projects.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(projects.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}

class ConfigPage extends StatefulWidget {
  final String title;
  final Function(Project)? onProjectCreated;
  final Function(Project)? onProjectSelected;

  const ConfigPage({
    super.key,
    required this.title,
    this.onProjectCreated,
    this.onProjectSelected,
  });

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  List<Project> _projects = [];
  bool _isSaving = false;
  String _searchKeyword = "";
  final GlobalKey<ModifyPageState> _modifyKey = GlobalKey<ModifyPageState>();

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    final loaded = await JsonDbService.loadProjects();
    if (!mounted) return;
    setState(() => _projects = loaded);
  }

  Future<void> _handleGlobalSave() async {
    setState(() => _isSaving = true);
    try {
      final bool ok = await _modifyKey.currentState?.triggerSaveAll() ?? false;
      if (mounted && ok) {
        displayInfoBar(context, builder: (c, close) => const InfoBar(
          title: Text('Saved'),
          content: Text('Synced'),
          severity: InfoBarSeverity.success,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final Project item = _projects.removeAt(oldIndex);
      _projects.insert(newIndex, item);
      for (int i = 0; i < _projects.length; i++) {
        _projects[i].sortIndex = i;
      }
    });
    await JsonDbService.saveProjects(_projects);
  }

  Future<void> _confirmDelete(BuildContext context, Project project) async {
    bool deleteIniFile = false;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ContentDialog(
          title: const Text('Confirm Deleting?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sure about deleting "${project.name}" '),
              const SizedBox(height: 16),
              Checkbox(
                checked: deleteIniFile,
                onChanged: (v) => setDialogState(() => deleteIniFile = v ?? false),
                content: const Text('BTW Delete binded segatools.ini'),
              ),
            ],
          ),
          actions: [
            Button(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, 'cancel')),
            FilledButton(
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
              onPressed: () => Navigator.pop(context, 'delete'),
              child: const Text('Confirm Deleting'),
            ),
          ],
        ),
      ),
    );

    if (result == 'delete') {
      try {
        if (deleteIniFile) {
          final iniFile = File(p.join(project.path, 'segatools.ini'));
          if (await iniFile.exists()) await iniFile.delete();
        }
        setState(() => _projects.removeWhere((p) => p.id == project.id));
        await JsonDbService.saveProjects(_projects);
        if (widget.onProjectCreated != null) widget.onProjectCreated!(project);
      } catch (_) {}
    }
  }

  Future<void> _openFolder(String path) async {
    final Uri uri = Uri.file(path);
    if (!await launchUrl(uri)) {
      if (mounted) displayInfoBar(context, builder: (c, close) => const InfoBar(title: Text('Unable to open the path'), severity: InfoBarSeverity.error));
    }
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final pathController = TextEditingController();
    String selectedType = 'chusan';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return ContentDialog(
            title: const Text('Create New Config'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoLabel(
                  label: 'VARIETY',
                  child: ComboBox<String>(
                    isExpanded: true,
                    value: selectedType,
                    items: const [ComboBoxItem(value: 'chusan', child: Text('Chusan'))],
                    onChanged: (v) => setDialogState(() => selectedType = v!),
                  ),
                ),
                const SizedBox(height: 16),
                InfoLabel(label: 'NAME', child: TextBox(controller: nameController, placeholder: 'e.g init')),
                const SizedBox(height: 16),
                InfoLabel(
                  label: 'PATH',
                  child: Row(
                    children: [
                      Expanded(child: TextBox(controller: pathController, placeholder: 'where segatools.ini')),
                      const SizedBox(width: 8),
                      Button(
                        child: const Icon(FluentIcons.folder_search),
                        onPressed: () async {
                          String? result = await FilePicker.platform.getDirectoryPath();
                          if (result != null) setDialogState(() => pathController.text = result);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Button(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || pathController.text.isEmpty) return;
                  try {
                    final String targetPath = p.join(pathController.text, 'segatools.ini');
                    if (!await File(targetPath).exists()) {
                      final String template = await rootBundle.loadString('assets/chusan.ini');
                      await File(targetPath).writeAsString(template);
                    }
                    final newProject = Project(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      path: pathController.text,
                      type: selectedType,
                      createdAt: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                      sortIndex: _projects.length,
                      errState: 0,
                    );
                    setState(() => _projects.add(newProject));
                    await JsonDbService.saveProjects(_projects);
                    if (mounted) Navigator.pop(context);
                    if (widget.onProjectCreated != null) widget.onProjectCreated!(newProject);
                  } catch (_) {}
                },
                child: const Text('Create && Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.title.startsWith("编辑: ");
    final bool isCreating = widget.title.contains("创建");

    if (isCreating) {
      return ScaffoldPage(
        header: const PageHeader(title: Text("NEW")),
        content: Center(
          child: FilledButton(child: const Text("Constantly Create"), onPressed: () => _showCreateDialog(context)),
        ),
      );
    }

    if (isEditing) {
      final projectName = widget.title.replaceFirst("编辑: ", "");
      Project? currentProject;
      try {
        currentProject = _projects.firstWhere((p) => p.name == projectName);
      } catch (_) {
        return const ScaffoldPage(content: Center(child: ProgressRing()));
      }

      return ScaffoldPage(
        header: PageHeader(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  currentProject.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200, minWidth: 80),
                  child: TextBox(
                    placeholder: 'Search...',
                    suffix: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(FluentIcons.search, size: 14),
                    ),
                    onChanged: (v) => setState(() => _searchKeyword = v),
                  ),
                ),
              ),
            ],
          ),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            primaryItems: [
              CommandBarButton(
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
                    : const Icon(FluentIcons.save),
                label: const Text('SAVE'),
                onPressed: _isSaving ? null : _handleGlobalSave,
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  child: ModifyPage(
                    key: _modifyKey,
                    projectPath: currentProject.path,
                    configData: currentProject.toJson(),
                    searchKeyword: _searchKeyword,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildBottomBar(currentProject),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    }

    return ScaffoldPage(
      header: PageHeader(
        title: Text(widget.title),
        commandBar: Button(
          child: const Row(children: [Icon(FluentIcons.add), SizedBox(width: 8), Text('Create')]),
          onPressed: () => _showCreateDialog(context),
        ),
      ),
      content: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        itemCount: _projects.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final item = _projects[index];
          return Padding(
            key: ValueKey(item.id),
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              padding: EdgeInsets.zero,
              child: ListTile(
                onPressed: () {
                  if (widget.onProjectSelected != null) {
                    widget.onProjectSelected!(item);
                  }
                },
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${item.type.toUpperCase()} | ${item.path}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        FluentIcons.delete,
                        color: Colors.red.normal,
                        size: 16,
                      ),
                      onPressed: () => _confirmDelete(context, item),
                    ),
                    const SizedBox(width: 8),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(FluentIcons.gripper_bar_vertical, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(Project project) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Tooltip(
              message: 'Click to Open With File Explorer',
              child: GestureDetector(
                onTap: () => _openFolder(project.path),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.folder_open, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          project.path,
                          style: TextStyle(fontSize: 12, color: FluentTheme.of(context).accentColor, decoration: TextDecoration.underline),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text("Created at : ${project.createdAt}", style: TextStyle(fontSize: 12, color: Colors.orange)),
        ],
      ),
    );
  }
}