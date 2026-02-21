import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import '../shared/vk.dart';

class DeviceConfig extends StatefulWidget {
  final String projectPath;
  final String searchKeyword;

  const DeviceConfig({
    super.key,
    required this.projectPath,
    this.searchKeyword = "",
  });

  @override
  State<DeviceConfig> createState() => DeviceConfigState();
}

class DeviceConfigState extends State<DeviceConfig> {
  final TextEditingController _aimePathController = TextEditingController();
  final TextEditingController _scanController = TextEditingController();
    String _scanKeyName = "Default";

  bool _isLoading = true;
  bool _aimeEnable = false;
  bool _vfdEnable = false;
  bool _highBaud = false;

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

          if (currentSection == "[aime]") {
            if (k == 'enable') _aimeEnable = (v == '1');
            if (k == 'aimePath') _aimePathController.text = v;
            if (k == 'highBaud') _highBaud = (v == '1');
            if (k == 'scan') {
              _scanController.text = v;
              _scanKeyName = VKMapper.getKeyNameFromHex(v);
            }
          } else if (currentSection == "[vfd]") {
            if (k == 'enable') _vfdEnable = (v == '1');
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, Map<String, String>> getConfigData() {
    return {
      'aime': {
        'enable': _aimeEnable ? '1' : '0',
        'aimePath': _aimePathController.text,
        'highBaud': _highBaud ? '1' : '0',
        'scan': _scanController.text,
      },
      'vfd': {
        'enable': _vfdEnable ? '1' : '0',
      }
    };
  }

  void _startListening() {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Now Waiting...'),
        content: const Text('Press any button to bind'),
        actions: [
          Button(
              child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    VKMapper.listenForNextKey(
      onDetected: (hex, name) {
        if (mounted) {
          setState(() {
            _scanController.text = hex;
            _scanKeyName = name;
          });
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      },
      onCancel: () {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      },
    );
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
        style: TextStyle(color: FluentTheme.of(context).accentColor, fontWeight: FontWeight.bold),
      ));
      start = index + keyword.length;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return RichText(text: TextSpan(style: DefaultTextStyle.of(context).style, children: spans));
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
    if (widget.searchKeyword.isNotEmpty && !label.toLowerCase().contains(widget.searchKeyword.toLowerCase())) {
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

  Widget _buildKeyDisplay(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: FluentTheme.of(context).accentColor.withOpacity(0.3)),
      ),
      child: Text(name, style: TextStyle(color: FluentTheme.of(context).accentColor, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Device settings", FluentIcons.business_card),
        _buildSettingItem(
          label: "Enable Aime Reader",
          child: ToggleSwitch(
            checked: _aimeEnable,
            onChanged: (v) => setState(() => _aimeEnable = v),
          ),
        ),
        _buildSettingItem(
          label: "High Baud Rate",
          child: ToggleSwitch(
            checked: _highBaud,
            onChanged: (v) => setState(() => _highBaud = v),
          ),
        ),
        _buildSettingItem(
          label: "Aime Path (aimePath)",
          child: Row(children: [
            Expanded(child: TextBox(controller: _aimePathController)),
            const SizedBox(width: 8),
            Button(
              child: const Icon(FluentIcons.file_system),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    _aimePathController.text = p.relative(result.files.single.path!, from: widget.projectPath);
                  });
                }
              },
            )
          ]),
        ),
        _buildSettingItem(
          label: "Scan Key",
          child: Row(children: [
            Expanded(
              child: TextBox(
                controller: _scanController,
                readOnly: true,
              ),
            ),
            _buildKeyDisplay(_scanKeyName),
            Button(
              child: const Icon(FluentIcons.keyboard_classic),
              onPressed: _startListening,
            )
          ]),
        ),
        _buildSettingItem(
          label: "Enable VFD",
          child: ToggleSwitch(
            checked: _vfdEnable,
            onChanged: (v) => setState(() => _vfdEnable = v),
          ),
        ),
      ],
    );
  }
}