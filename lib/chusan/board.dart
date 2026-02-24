import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;

class BoardConfig extends StatefulWidget {
  final String projectPath;
  final String searchKeyword;

  const BoardConfig({
    super.key,
    required this.projectPath,
    this.searchKeyword = "",
  });

  @override
  State<BoardConfig> createState() => BoardConfigState();
}

class BoardConfigState extends State<BoardConfig> {
  final TextEditingController _keychipIdController = TextEditingController();
  final TextEditingController _keychipSubnetController = TextEditingController();
  final TextEditingController _pcbidController = TextEditingController();

  bool _isLoading = true;
  bool _systemEnable = true;
  bool _freeplay = false;
  int _dipsw1 = 1;
  int _dipsw2 = 1;
  int _dipsw3 = 1;

  String? _keychipIdError, _keychipSubnetError, _pcbidError;

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

          switch (currentSection) {
            case "[keychip]":
              if (k == 'id') _keychipIdController.text = v;
              if (k == 'subnet') _keychipSubnetController.text = v;
              break;
            case "[pcbid]":
              if (k == 'serialNo') _pcbidController.text = v;
              break;
            case "[system]":
              if (k == 'enable') _systemEnable = v == '1';
              if (k == 'freeplay') _freeplay = v == '1';
              if (k == 'dipsw1') _dipsw1 = int.tryParse(v) ?? 1;
              if (k == 'dipsw2') _dipsw2 = int.tryParse(v) ?? 1;
              if (k == 'dipsw3') _dipsw3 = int.tryParse(v) ?? 1;
              break;
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
      final id = _keychipIdController.text;
      if (id.isEmpty) {
        _keychipIdError = "Must print sth...";
      } else if (!RegExp(r'^A\d{2}[EX]-(01|20)[ABCDEU]\d{8}$').hasMatch(id)) {
        _keychipIdError = "Format ERR (e.g A69E-01A88888888)";
      } else {
        _keychipIdError = null;
      }

      final subnet = _keychipSubnetController.text;
      if (subnet.isEmpty) {
        _keychipSubnetError = "Print sth..";
      } else if (!RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(subnet)) {
        _keychipSubnetError = "Err IP";
      } else {
        _keychipSubnetError = null;
      }

      final pcbid = _pcbidController.text;
      if (pcbid.isEmpty) {
        _pcbidError = "Print Now";
      } else if (!RegExp(r'^[A-Z0-9]+$').hasMatch(pcbid)) {
        _pcbidError = "Null PCBID";
      } else {
        _pcbidError = null;
      }
    });
  }

  Map<String, Map<String, String>> getConfigData() {
    return {
      'keychip': {
        'id': _keychipIdController.text,
        'subnet': _keychipSubnetController.text,
      },
      'pcbid': {
        'serialNo': _pcbidController.text,
      },
      'system': {
        'enable': _systemEnable ? '1' : '0',
        'freeplay': _freeplay ? '1' : '0',
        'dipsw1': _dipsw1.toString(),
        'dipsw2': _dipsw2.toString(),
        'dipsw3': _dipsw3.toString(),
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
              Expanded(flex: 7, child: Align(alignment: Alignment.centerLeft, child: child)),
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

    final labels = [
      "Keychip ID",
      "Subnet Mask",
      "PCBID SerialNo",
      "Enable System",
      "Free Play",
      "LAN Install",
      "Monitor",
      "Cab Type"
    ];
    final bool hasMatch = widget.searchKeyword.isEmpty ||
        labels.any((l) => l.toLowerCase().contains(widget.searchKeyword.toLowerCase()));

    if (!hasMatch) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Board Settings", FluentIcons.settings),
        _buildSettingItem(
          label: "Keychip ID",
          error: _keychipIdError,
          child: TextBox(
            controller: _keychipIdController,
            onChanged: (_) => _validateAll(),
          ),
        ),
        _buildSettingItem(
          label: "Subnet Mask",
          error: _keychipSubnetError,
          child: TextBox(
            controller: _keychipSubnetController,
            onChanged: (_) => _validateAll(),
          ),
        ),
        _buildSettingItem(
          label: "PCBID SerialNo",
          error: _pcbidError,
          child: TextBox(
            controller: _pcbidController,
            onChanged: (_) => _validateAll(),
          ),
        ),
        _buildSettingItem(
          label: "Enable System",
          child: ToggleSwitch(
            checked: _systemEnable,
            onChanged: (v) => setState(() => _systemEnable = v),
          ),
        ),
        if (_systemEnable) ...[
          _buildSettingItem(
            label: "Free Play",
            child: ToggleSwitch(
              checked: _freeplay,
              onChanged: (v) => setState(() => _freeplay = v),
            ),
          ),
          _buildSettingItem(
            label: "LAN Install",
            child: ComboBox<int>(
              value: _dipsw1,
              items: const [
                ComboBoxItem(value: 1, child: Text("Server (1)")),
                ComboBoxItem(value: 0, child: Text("Client (0)")),
              ],
              onChanged: (v) => setState(() => _dipsw1 = v!),
            ),
          ),
          _buildSettingItem(
            label: "Monitor",
            child: ComboBox<int>(
              value: _dipsw2,
              items: const [
                ComboBoxItem(value: 0, child: Text("120 FPS")),
                ComboBoxItem(value: 1, child: Text("60 FPS")),
              ],
              onChanged: (v) => setState(() => _dipsw2 = v!),
            ),
          ),
          _buildSettingItem(
            label: "Cab Type",
            child: ComboBox<int>(
              value: _dipsw3,
              items: const [
                ComboBoxItem(value: 0, child: Text("SP")),
                ComboBoxItem(value: 1, child: Text("CVT")),
              ],
              onChanged: (v) => setState(() => _dipsw3 = v!),
            ),
          ),
        ],
      ],
    );
  }
}