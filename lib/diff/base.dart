import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class BaseConfigPage extends StatefulWidget {
  final String projectPath;
  final String variety;
  final bool isEmbedded;
  final String searchKeyword;

  const BaseConfigPage({
    super.key,
    required this.projectPath,
    required this.variety,
    this.isEmbedded = false,
    this.searchKeyword = "",
  });

  @override
  State<BaseConfigPage> createState() => BaseConfigPageState();
}

class BaseConfigPageState extends State<BaseConfigPage> {
  final TextEditingController _amfsController = TextEditingController();
  final TextEditingController _optionController = TextEditingController();
  final TextEditingController _appdataController = TextEditingController();
  final TextEditingController _aimePathController = TextEditingController();
  final TextEditingController _scanController = TextEditingController();
  final TextEditingController _dnsDefaultController = TextEditingController();
  final TextEditingController _keychipIdController = TextEditingController();
  final TextEditingController _keychipSubnetController = TextEditingController();
  final TextEditingController _pcbidController = TextEditingController();
  final TextEditingController _aimeioPathController = TextEditingController();

  bool _isLoading = true;
  bool _aimeEnable = false;
  bool _highBaud = false;
  bool _vfdEnable = false;
  bool _netenvEnable = false;
  double _netenvAddrSuffix = 11.0;
  bool _sysEnable = false;
  bool _sysFreeplay = false;
  int? _sysDipsw1;
  int? _sysDipsw2;
  int? _sysDipsw3;
  bool _isKeychipVisible = false;

  String? _amfsError, _optionError, _appdataError, _keychipIdError;
  String _scanKeyName = "Unset";
  String _selectedDns = "Custom";

  final Map<String, String> _dnsPresets = {
    "Local": "127.0.0.1",
    "AquaDX": "aquadx.hydev.org",
    "RIN-NET": "aqua.naominet.live",
    "Yuzu-net": "aime.yuzunet.cn",
    "Custom": "",
  };

  @override
  void initState() {
    super.initState();
    _loadIni();
  }
  Future<bool> saveConfig() async {
    return await _saveIni();
  }
  Future<void> _loadIni() async {
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
            case "[vfs]":
              if (k == 'amfs') _amfsController.text = v;
              if (k == 'option') _optionController.text = v;
              if (k == 'appdata') _appdataController.text = v;
              break;
            case "[aime]":
              if (k == 'enable') _aimeEnable = v == '1';
              if (k == 'aimePath') _aimePathController.text = v;
              if (k == 'scan') {
                _scanController.text = v;
                _scanKeyName = _getKeyNameFromHex(v);
              }
              if (k == 'highBaud') _highBaud = v == '1';
              break;
            case "[vfd]":
              if (k == 'enable') _vfdEnable = v == '1';
              break;
            case "[dns]":
              if (k == 'default') {
                _dnsDefaultController.text = v;
                _selectedDns = "Custom";
                _dnsPresets.forEach((name, val) {
                  if (v == val && name != "Custom") _selectedDns = name;
                });
              }
              break;
            case "[netenv]":
              if (k == 'enable') _netenvEnable = v == '1';
              if (k == 'addrSuffix') _netenvAddrSuffix = double.tryParse(v) ?? 11.0;
              break;
            case "[keychip]":
              if (k == 'id') _keychipIdController.text = v;
              if (k == 'subnet') _keychipSubnetController.text = v;
              break;
            case "[pcbid]":
              if (k == 'serialNo') _pcbidController.text = v;
              break;
            case "[system]":
              if (k == 'enable') _sysEnable = v == '1';
              if (k == 'freeplay') _sysFreeplay = v == '1';
              if (k == 'dipsw1') _sysDipsw1 = int.tryParse(v);
              if (k == 'dipsw2') _sysDipsw2 = int.tryParse(v);
              if (k == 'dipsw3') _sysDipsw3 = int.tryParse(v);
              break;
            case "[aimeio]":
              if (k == 'path') _aimeioPathController.text = v;
              break;
          }
        }
      }
      _validateAll();
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  Widget _buildDivider() {
    if (widget.searchKeyword.isNotEmpty) return const SizedBox.shrink();
    return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider());
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
  void _validateAll() {
    setState(() {
      _amfsError = _checkDirContent(_amfsController.text, ['ICF1', 'ICF2']);
      _optionError = _checkDirContent(_optionController.text, ['A001']);
      _appdataError = _checkDirContent(_appdataController.text, ['amdaemon.exe']);
      if (_keychipIdController.text.isNotEmpty && !RegExp(r'^A\d{2}[EX]-(01|20)[ABCDEU]\d{8}$').hasMatch(_keychipIdController.text)) {
        _keychipIdError = "Keychip ID 格式不规范";
      } else {
        _keychipIdError = null;
      }
    });
  }

  String? _checkDirContent(String path, List<String> items) {
    if (path.isEmpty) return "Cant be Blank";
    final dir = Directory(path);
    if (!dir.existsSync()) return "Directory does not exist";
    try {
      final entities = dir.listSync().map((e) => p.basename(e.path).toLowerCase()).toList();
      for (var item in items) {
        if (!entities.contains(item.toLowerCase())) return "Core files not found.: $item";
      }
    } catch (e) { return "Read failed"; }
    return null;
  }

  String _getKeyNameFromHex(String hex) {
    try {
      int vk = int.parse(hex.substring(2), radix: 16);
      final key = LogicalKeyboardKey.findKeyByKeyId(vk) ?? LogicalKeyboardKey.findKeyByKeyId(0x110000000 | vk);
      return key?.keyLabel ?? "Key $hex";
    } catch (_) { return "未设置"; }
  }

  void _showScanKeyCapture() {
    bool isHandled = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ContentDialog(
        title: const Text('按键绑定'),
        content: const Text('请在键盘上按下你要绑定刷卡的按键...'),
        actions: [Button(child: const Text('取消'), onPressed: () { isHandled = true; Navigator.pop(context); })],
      ),
    );
    HardwareKeyboard.instance.addHandler((KeyEvent event) {
      if (isHandled) return false;
      if (event is KeyDownEvent) {
        isHandled = true;
        setState(() {
          _scanController.text = "0x${(event.logicalKey.keyId & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase()}";
          _scanKeyName = event.logicalKey.keyLabel;
        });
        Navigator.pop(context);
        return true;
      }
      return false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: ProgressRing());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("File Path [vfs]", FluentIcons.folder_open),
        _buildSettingItem(
          label: "AMFS Path",
          error: _amfsError,
          child: Row(children: [
            Expanded(child: TextBox(controller: _amfsController, onChanged: (_)=>_validateAll())),
            const SizedBox(width: 8),
            Button(child: const Icon(FluentIcons.folder_search), onPressed: () async { String? p = await FilePicker.platform.getDirectoryPath(); if (p != null) { _amfsController.text = p; _validateAll(); } })
          ]),
        ),
        _buildSettingItem(
          label: "Option Path",
          error: _optionError,
          child: Row(children: [
            Expanded(child: TextBox(controller: _optionController, onChanged: (_)=>_validateAll())),
            const SizedBox(width: 8),
            Button(child: const Icon(FluentIcons.folder_search), onPressed: () async { String? p = await FilePicker.platform.getDirectoryPath(); if (p != null) { _optionController.text = p; _validateAll(); } })
          ]),
        ),
        _buildSettingItem(
          label: "AppData Path",
          error: _appdataError,
          child: Row(children: [
            Expanded(child: TextBox(controller: _appdataController, onChanged: (_)=>_validateAll())),
            const SizedBox(width: 8),
            Button(child: const Icon(FluentIcons.folder_search), onPressed: () async { String? p = await FilePicker.platform.getDirectoryPath(); if (p != null) { _appdataController.text = p; _validateAll(); } })
          ]),
        ),

        _buildDivider(),
        _buildSectionHeader("Card Emu [aime]", FluentIcons.contact_card),
        _buildSettingItem(
          label: "Status",
          child: Checkbox(checked: _aimeEnable, onChanged: (v) => setState(() => _aimeEnable = v!), content: const Text("Emulate")),
        ),
        if (widget.variety.toLowerCase() == 'chusan')
          _buildSettingItem(
            label: "HighBaud",
            child: Checkbox(checked: _highBaud, onChanged: (v) => setState(() => _highBaud = v!), content: const Text("")),
          ),
        _buildSettingItem(
          label: "Aime Path (*.txt)",
          child: Row(children: [
            Expanded(child: TextBox(controller: _aimePathController, enabled: _aimeEnable)),
            const SizedBox(width: 8),
            Button(onPressed: _aimeEnable ? () async {
              var r = await FilePicker.platform.pickFiles();
              if (r != null) { _aimePathController.text = r.files.single.path!; _validateAll(); }
            } : null, child: const Icon(FluentIcons.file_template)),
          ]),
        ),
        _buildSettingItem(
          label: "Button ($_scanKeyName)",
          child: Row(children: [
            Expanded(child: TextBox(controller: _scanController, readOnly: true, enabled: _aimeEnable)),
            const SizedBox(width: 8),
            Button(onPressed: _aimeEnable ? _showScanKeyCapture : null, child: const Icon(FluentIcons.edit)),
          ]),
        ),

        _buildDivider(),
        _buildSectionHeader("VFD Emu [vfd]", FluentIcons.t_v_monitor),
        _buildSettingItem(
          label: "Status",
          child: Checkbox(checked: _vfdEnable, onChanged: (v) => setState(() => _vfdEnable = v!), content: const Text("Emulate")),
        ),

        _buildDivider(),
        _buildSectionHeader("Server  (DNS)", FluentIcons.network_tower),
        _buildSettingItem(
          label: "Address",
          child: Row(
            children: [
              SizedBox(width: 150, child: ComboBox<String>(
                value: _selectedDns,
                items: _dnsPresets.keys.map((e) => ComboBoxItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() {
                  _selectedDns = v!;
                  if (v != "Custom") _dnsDefaultController.text = _dnsPresets[v]!;
                }),
              )),
              const SizedBox(width: 8),
              Expanded(child: TextBox(
                controller: _dnsDefaultController,
                placeholder: "127.0.0.1",
                enabled: _selectedDns == "Custom",
                onChanged: (_) => setState(() {}),
              )),
            ],
          ),
        ),

        _buildDivider(),
        _buildSectionHeader("Environment [netenv]", FluentIcons.network_tower),
        _buildSettingItem(
          label: "Simulate an ideal LAN environment",
          child: Checkbox(checked: _netenvEnable, onChanged: (v) => setState(() => _netenvEnable = v!), content: const Text("NetEnv")),
        ),
        _buildSettingItem(
          label: "IP Suffix (addrSuffix): ${_netenvAddrSuffix.toInt()}",
          child: Slider(
            value: _netenvAddrSuffix, min: 2, max: 254,
            onChanged: _netenvEnable ? (v) => setState(() => _netenvAddrSuffix = v) : null,
          ),
        ),

        _buildDivider(),
        _buildSectionHeader("Dog Tag [keychip]", FluentIcons.skype_check),
        _buildSettingItem(
          label: "Keychip ID",
          error: _keychipIdError,
          child: Row(children: [
            Expanded(child: TextBox(controller: _keychipIdController, obscureText: !_isKeychipVisible, onChanged: (_)=>_validateAll())),
            const SizedBox(width: 8),
            ToggleButton(checked: _isKeychipVisible, onChanged: (v) => setState(() => _isKeychipVisible = v), child: Icon(_isKeychipVisible ? FluentIcons.view : FluentIcons.hide)),
          ]),
        ),

        _buildDivider(),
        _buildSectionHeader("ALLS Settings  [system]  ", FluentIcons.settings),
        _buildSettingItem(
          label: "Freeplay",
          child: Checkbox(checked: _sysFreeplay, onChanged: (v) => setState(() => _sysFreeplay = v!), content: const Text("Status")),
        ),
        _buildSettingItem(
          label: "Main Cab (dipsw1)",
          child: Row(children: [
            RadioButton(checked: _sysDipsw1 == 0, onChanged: (v) => setState(() => _sysDipsw1 = 0), content: const Text("Slave (Off)")),
            const SizedBox(width: 16),
            RadioButton(checked: _sysDipsw1 == 1, onChanged: (v) => setState(() => _sysDipsw1 = 1), content: const Text("Benchmark (On)")),
          ]),
        ),

        _buildDivider(),
        _buildSectionHeader("Aime IO DLL [aimeio]", FluentIcons.plug),
        _buildSettingItem(
          label: "DLL path",
          child: TextBox(controller: _aimeioPathController, placeholder: "Leave blank if not needed."),
        ),

        if (!widget.isEmbedded && widget.searchKeyword.isEmpty) ...[
          const SizedBox(height: 40),
          SizedBox(width: double.infinity, height: 40, child: FilledButton(onPressed: saveConfig, child: const Text("保存基础配置"))),
        ]
      ],
    );
  }
  Future<bool> _saveIni() async {
    final file = File(p.join(widget.projectPath, 'segatools.ini'));
    Map<String, Map<String, String>> config = {
      'vfs': {'amfs': _amfsController.text, 'option': _optionController.text, 'appdata': _appdataController.text},
      'aime': {
        'enable': _aimeEnable ? '1' : '0',
        'aimePath': _aimePathController.text,
        'scan': _scanController.text,
        if (widget.variety.toLowerCase() == 'chusan') 'highBaud': _highBaud ? '1' : '0'
      },
      'vfd': {'enable': _vfdEnable ? '1' : '0'},
      'dns': {'default': _dnsDefaultController.text},
      'netenv': {'enable': _netenvEnable ? '1' : '0', 'addrSuffix': _netenvAddrSuffix.toInt().toString()},
      'keychip': {'id': _keychipIdController.text, 'subnet': _keychipSubnetController.text},
      'pcbid': {'serialNo': _pcbidController.text},
      'system': {
        'enable': _sysEnable ? '1' : '0',
        'freeplay': _sysFreeplay ? '1' : '0',
        if (_sysDipsw1 != null) 'dipsw1': _sysDipsw1.toString(),
        if (widget.variety.toLowerCase() == 'chusan' && _sysDipsw2 != null) 'dipsw2': _sysDipsw2.toString(),
        if (widget.variety.toLowerCase() == 'chusan' && _sysDipsw3 != null) 'dipsw3': _sysDipsw3.toString(),
      },
      'aimeio': {'path': _aimeioPathController.text},
    };

    try {
      List<String> output = [];
      Set<String> handledSections = {};
      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        String currentSec = "";
        Set<String> handledKeys = {};

        for (var line in lines) {
          String t = line.trim();
          if (t.startsWith('[') && t.endsWith(']')) {
            _appendKeys(output, currentSec, handledKeys, config);
            currentSec = t.substring(1, t.length - 1).toLowerCase();
            handledSections.add(currentSec);
            handledKeys = {};
            output.add(line);
          } else if (t.contains('=') && !t.startsWith(';')) {
            String k = t.split('=')[0].trim();
            if (config.containsKey(currentSec) && config[currentSec]!.containsKey(k)) {
              output.add('$k=${config[currentSec]![k]}');
              handledKeys.add(k);
            } else { output.add(line); }
          } else { output.add(line); }
        }
        _appendKeys(output, currentSec, handledKeys, config);
      }

      config.forEach((sec, keys) {
        if (!handledSections.contains(sec)) {
          output.add('\n[$sec]');
          keys.forEach((k, v) { if (v.isNotEmpty) output.add('$k=$v'); });
        }
      });

      await file.writeAsString(output.join('\n'));
      return true;
    } catch (e) {
      return false;
    }
  }

  void _appendKeys(List<String> out, String sec, Set<String> handled, Map<String, Map<String, String>> map) {
    if (map.containsKey(sec)) {
      map[sec]!.forEach((k, v) { if (!handled.contains(k) && v.isNotEmpty) out.add('$k=$v'); });
    }
  }
}