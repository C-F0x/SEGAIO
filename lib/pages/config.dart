import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Material;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import '../shared/project.dart';
import '../shared/database.dart';
import 'modify.dart';
import 'dialogs.dart';

class ConfigPage extends StatefulWidget {
  final String title;
  final Function(Project)? onProjectCreated;

  const ConfigPage({
    super.key,
    required this.title,
    this.onProjectCreated,
  });

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isSaving = false;
  String _searchKeyword = "";
  bool _isGlobalRelative = false;
  final GlobalKey<ModifyPageState> _modifyKey = GlobalKey<ModifyPageState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _openFolder(String path) async {
    final Uri uri = Uri.file(path);
    if (!await launchUrl(uri)) {
      if (mounted) {
        displayInfoBar(context, builder: (c, close) => const InfoBar(
            title: Text('Unable to open the path'),
            severity: InfoBarSeverity.error
        ));
      }
    }
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          color: Colors.transparent,
          child: DefaultTextStyle(
            style: FluentTheme.of(context).typography.body!.copyWith(inherit: true),
            child: child!,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedProject != null) {
      return ScaffoldPage(
        header: PageHeader(
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: () => setState(() {
                _selectedProject = null;
                _searchKeyword = "";
                _searchController.clear();
              }),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(_selectedProject!.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w600))),
              const SizedBox(width: 12),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200, minWidth: 80),
                  child: TextBox(
                    controller: _searchController,
                    placeholder: 'Search...',
                    suffix: _searchKeyword.isEmpty
                        ? const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(FluentIcons.search, size: 14))
                        : IconButton(
                      icon: const Icon(FluentIcons.clear, size: 10),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _searchKeyword = "";
                      }),
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
              CommandBarBuilderItem(
                builder: (context, mode, wrappedItem) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ToggleSwitch(
                    checked: _isGlobalRelative,
                    onChanged: (v) => setState(() => _isGlobalRelative = v),
                    content: Text(_isGlobalRelative ? "Relative" : "Absolute"),
                  ),
                ),
                wrappedItem: const CommandBarButton(icon: Icon(FluentIcons.switch_widget), onPressed: null),
              ),
              const CommandBarSeparator(),
              CommandBarButton(
                icon: const Icon(FluentIcons.refresh),
                label: const Text('RELOAD'),
                onPressed: () => _modifyKey.currentState?.reloadData(),
              ),
              CommandBarButton(
                icon: _isSaving ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2)) : const Icon(FluentIcons.save),
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
                    projectPath: _selectedProject!.path,
                    configData: _selectedProject!.toJson(),
                    searchKeyword: _searchKeyword,
                    isGlobalRelative: _isGlobalRelative,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildBottomBar(_selectedProject!),
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
          onPressed: () => ProjectDialogs.showCreateDialog(
            context: context,
            currentProjects: _projects,
            onSuccess: (newProject) async {
              setState(() => _projects.add(newProject));
              await JsonDbService.saveProjects(_projects);
              if (widget.onProjectCreated != null) widget.onProjectCreated!(newProject);
            },
          ),
        ),
      ),
      content: ReorderableListView.builder(
        // 关键点：禁用默认的拖拽句柄，防止出现两个图标
        buildDefaultDragHandles: false,
        proxyDecorator: _proxyDecorator,
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
                onPressed: () => setState(() => _selectedProject = item),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${item.type.toUpperCase()} | ${item.path}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(FluentIcons.delete, color: Colors.red.normal, size: 16),
                      onPressed: () => ProjectDialogs.confirmDelete(
                          context: context,
                          project: item,
                          onConfirm: (deleteIni) async {
                            if (deleteIni) {
                              final iniFile = File(p.join(item.path, 'segatools.ini'));
                              if (await iniFile.exists()) await iniFile.delete();
                            }
                            setState(() => _projects.removeWhere((p) => p.id == item.id));
                            await JsonDbService.saveProjects(_projects);
                          }
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 使用自定义句柄
                    ReorderableDragStartListener(
                      index: index,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Icon(
                          FluentIcons.gripper_bar_vertical,
                          color: FluentTheme.of(context).typography.caption?.color?.withOpacity(0.6),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                      Flexible(child: Text(project.path, style: TextStyle(fontSize: 12, color: FluentTheme.of(context).accentColor, decoration: TextDecoration.underline), overflow: TextOverflow.ellipsis)),
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