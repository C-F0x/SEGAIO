import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

class IoConfig extends StatefulWidget {
  final String projectPath;
  final String searchKeyword;

  const IoConfig({
    super.key,
    required this.projectPath,
    this.searchKeyword = "",
  });

  @override
  State<IoConfig> createState() => IoConfigState();
}

class IoConfigState extends State<IoConfig> {
  final TextEditingController _aimeioPathController = TextEditingController();
  final TextEditingController _chuniioPathController = TextEditingController();
  final TextEditingController _chuniioPath32Controller = TextEditingController();
  final TextEditingController _chuniioPath64Controller = TextEditingController();

  bool _isLoading = true;
  bool _isDualDll = false;

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
        final reg = RegExp(r'^(;?)\s*([^=]+)\s*=\s*(.*)$');

        for (var line in lines) {
          final t = line.trim();
          if (t.isEmpty) continue;
          if (t.startsWith('[') && t.endsWith(']')) {
            currentSection = t.toLowerCase();
            continue;
          }

          final match = reg.firstMatch(t);
          if (match == null) continue;

          final bool isCommented = match.group(1) == ';';
          final String k = match.group(2)!.trim();
          final String v = match.group(3)!.trim();

          switch (currentSection) {
            case "[aimeio]":
              if (k == 'path') _aimeioPathController.text = v;
              break;
            case "[chuniio]":
              if (k == 'path') {
                if (v.isNotEmpty) _chuniioPathController.text = v;
                if (!isCommented) _isDualDll = false;
              }
              if (k == 'path32') {
                if (v.isNotEmpty) _chuniioPath32Controller.text = v;
                if (!isCommented) _isDualDll = true;
              }
              if (k == 'path64') {
                if (v.isNotEmpty) _chuniioPath64Controller.text = v;
                if (!isCommented) _isDualDll = true;
              }
              break;
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, Map<String, String>> getConfigData() {
    Map<String, String> chuniioData = {};

    if (_isDualDll) {
      chuniioData['path32'] = _chuniioPath32Controller.text;
      chuniioData['path64'] = _chuniioPath64Controller.text;
    } else {
      chuniioData['path'] = _chuniioPathController.text;
    }

    return {
      'aimeio': {
        'path': _aimeioPathController.text,
      },
      'chuniio': chuniioData,
    };
  }

  Future<void> _pickDll(TextEditingController controller) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['dll'],
    );
    if (result != null) {
      setState(() {
        controller.text = p.relative(result.files.single.path!, from: widget.projectPath);
      });
    }
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
        ],
      ),
    );
  }

  Widget _buildSettingItem({required String label, required Widget child}) {
    if (widget.searchKeyword.isNotEmpty &&
        !label.toLowerCase().contains(widget.searchKeyword.toLowerCase())) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildHighlightedText(label, widget.searchKeyword)),
          const SizedBox(width: 16),
          Expanded(flex: 7, child: Align(alignment: Alignment.centerLeft, child: child)),
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
        _buildSectionHeader("Custom IO settings", FluentIcons.game),
        _buildSettingItem(
          label: "AimeIO DLL Path [aimeio]",
          child: Row(children: [
            Expanded(child: TextBox(controller: _aimeioPathController, placeholder: "aimeio.dll")),
            const SizedBox(width: 8),
            Button(
              child: const Icon(FluentIcons.file_system),
              onPressed: () => _pickDll(_aimeioPathController),
            )
          ]),
        ),
        _buildSettingItem(
          label: "Dual DLL Mode (x86 + x64)",
          child: ToggleSwitch(
            checked: _isDualDll,
            onChanged: (v) => setState(() => _isDualDll = v),
            content: Text(_isDualDll ? "Dual DLL (path32/64)" : "Single DLL (path)"),
          ),
        ),
        if (!_isDualDll)
          _buildSettingItem(
            label: "32bit DLL Path (path)",
            child: Row(children: [
              Expanded(child: TextBox(controller: _chuniioPathController, placeholder: "chuniio.dll")),
              const SizedBox(width: 8),
              Button(
                child: const Icon(FluentIcons.file_system),
                onPressed: () => _pickDll(_chuniioPathController),
              )
            ]),
          )
        else ...[
          _buildSettingItem(
            label: "x86 DLL Path (path32)",
            child: Row(children: [
              Expanded(child: TextBox(controller: _chuniioPath32Controller, placeholder: "chuniio_x86.dll")),
              const SizedBox(width: 8),
              Button(
                child: const Icon(FluentIcons.file_system),
                onPressed: () => _pickDll(_chuniioPath32Controller),
              )
            ]),
          ),
          _buildSettingItem(
            label: "x64 DLL Path (path64)",
            child: Row(children: [
              Expanded(child: TextBox(controller: _chuniioPath64Controller, placeholder: "chuniio_x64.dll")),
              const SizedBox(width: 8),
              Button(
                child: const Icon(FluentIcons.file_system),
                onPressed: () => _pickDll(_chuniioPath64Controller),
              )
            ]),
          ),
        ],
      ],
    );
  }
}