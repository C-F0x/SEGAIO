import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

class PathConfig extends StatefulWidget {
  final String projectPath;
  final String searchKeyword;

  const PathConfig({
    super.key,
    required this.projectPath,
    this.searchKeyword = "",
  });

  @override
  State<PathConfig> createState() => PathConfigState();
}

class PathConfigState extends State<PathConfig> {
  final TextEditingController _amfsController = TextEditingController();
  final TextEditingController _optionController = TextEditingController();
  final TextEditingController _appdataController = TextEditingController();

  bool _isLoading = true;
  bool _isRelativeMode = false;
  String? _amfsError, _optionError, _appdataError;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    try {
      final file = File(p.join(widget.projectPath, 'segatools.ini'));
      if (await file.exists()) {
        final lines = await file.readAsLines();
        String currentSection = "";
        for (var line in lines) {
          final t = line.trim();
          if (t.isEmpty || t.startsWith(';')) continue;
          if (t.startsWith('[') && t.endsWith(']')) {
            currentSection = t.toLowerCase();
            continue;
          }
          final parts = t.split('=');
          if (parts.length < 2) continue;
          final k = parts[0].trim();
          final v = parts[1].trim();

          if (currentSection == "[vfs]") {
            if (k == 'amfs') _amfsController.text = v;
            if (k == 'option') _optionController.text = v;
            if (k == 'appdata') _appdataController.text = v;
          }
        }
      }
      _validateAll();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _validateAll() {
    setState(() {
      _amfsError = _checkDirContent(_amfsController.text, ['ICF1', 'ICF2']);
      _optionError = _checkDirContent(_optionController.text, ['A001']);
      _appdataError = _checkDirContent(_appdataController.text, ['bin', 'data']);
    });
  }

  String? _checkDirContent(String pathStr, List<String> items) {
    if (pathStr.isEmpty) return "Cant be Blank";
    String fullPath = pathStr;
    if (!p.isAbsolute(pathStr)) {
      fullPath = p.normalize(p.join(widget.projectPath, pathStr));
    }
    final dir = Directory(fullPath);
    if (!dir.existsSync()) return "Directory does not exist";
    try {
      final entities = dir.listSync().map((e) => p.basename(e.path).toLowerCase()).toList();
      for (var item in items) {
        if (!entities.contains(item.toLowerCase())) return "Core folders/files not found.: $item";
      }
    } catch (e) {
      return "Read failed";
    }
    return null;
  }

  String _formatPath(String pickedPath) {
    if (_isRelativeMode) {
      return p.relative(pickedPath, from: widget.projectPath);
    } else {
      return p.normalize(pickedPath);
    }
  }

  Map<String, Map<String, String>> getConfigData() {
    return {
      'vfs': {
        'amfs': _amfsController.text,
        'option': _optionController.text,
        'appdata': _appdataController.text,
      },
    };
  }

  Widget _buildHighlightedText(String text, String keyword) {
    if (keyword.isEmpty || !text.toLowerCase().contains(keyword.toLowerCase())) {
      return Text(text);
    }
    final String lowercaseText = text.toLowerCase();
    final String lowercaseKeyword = keyword.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;
    int index;
    while ((index = lowercaseText.indexOf(lowercaseKeyword, start)) != -1) {
      if (index > start) spans.add(TextSpan(text: text.substring(start, index)));
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: TextStyle(
          color: FluentTheme.of(context).accentColor,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + keyword.length;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return RichText(
      text: TextSpan(style: DefaultTextStyle.of(context).style, children: spans),
    );
  }

  Widget _buildSectionHeader(String t, IconData i) {
    if (widget.searchKeyword.isNotEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Row(
        children: [
          Icon(i, size: 20, color: FluentTheme.of(context).accentColor),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Text("SaveMode", style: TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          ToggleSwitch(
            checked: _isRelativeMode,
            onChanged: (v) => setState(() => _isRelativeMode = v),
            content: Text(_isRelativeMode ? "Relative" : "Absolute", style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({required String label, required Widget child, String? error}) {
    if (widget.searchKeyword.isNotEmpty &&
        !label.toLowerCase().contains(widget.searchKeyword.toLowerCase())) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(flex: 3, child: _buildHighlightedText(label, widget.searchKeyword)),
              const SizedBox(width: 16),
              Expanded(flex: 7, child: child),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(error, style: TextStyle(color: Colors.red.normal, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Path settings", FluentIcons.folder_open),
        _buildSettingItem(
          label: "AMFS Path",
          error: _amfsError,
          child: Row(children: [
            Expanded(child: TextBox(controller: _amfsController, onChanged: (_) => _validateAll())),
            const SizedBox(width: 8),
            Button(
              child: const Icon(FluentIcons.folder_search),
              onPressed: () async {
                String? selected = await FilePicker.platform.getDirectoryPath();
                if (selected != null) {
                  _amfsController.text = _formatPath(selected);
                  _validateAll();
                }
              },
            )
          ]),
        ),
        _buildSettingItem(
          label: "Option Path",
          error: _optionError,
          child: Row(children: [
            Expanded(child: TextBox(controller: _optionController, onChanged: (_) => _validateAll())),
            const SizedBox(width: 8),
            Button(
              child: const Icon(FluentIcons.folder_search),
              onPressed: () async {
                String? selected = await FilePicker.platform.getDirectoryPath();
                if (selected != null) {
                  _optionController.text = _formatPath(selected);
                  _validateAll();
                }
              },
            )
          ]),
        ),
        _buildSettingItem(
          label: "AppData Path",
          error: _appdataError,
          child: Row(children: [
            Expanded(child: TextBox(controller: _appdataController, onChanged: (_) => _validateAll())),
            const SizedBox(width: 8),
            Button(
              child: const Icon(FluentIcons.folder_search),
              onPressed: () async {
                String? selected = await FilePicker.platform.getDirectoryPath();
                if (selected != null) {
                  _appdataController.text = _formatPath(selected);
                  _validateAll();
                }
              },
            )
          ]),
        ),
      ],
    );
  }
}