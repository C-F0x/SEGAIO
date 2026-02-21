import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;

class LedConfig extends StatefulWidget {
  final String projectPath;
  final String searchKeyword;

  const LedConfig({
    super.key,
    required this.projectPath,
    this.searchKeyword = "",
  });

  @override
  State<LedConfig> createState() => LedConfigState();
}

class LedConfigState extends State<LedConfig> {
  bool _isLoading = true;
  bool _led15093Enable = false;
  bool _cabLedOutputPipe = false;
  bool _cabLedOutputSerial = false;
  bool _controllerLedOutputPipe = false;
  bool _controllerLedOutputSerial = false;
  bool _controllerLedOutputOpeNITHM = false;
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _baudController = TextEditingController();

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
          if (t.isEmpty) continue;

          String cleanLine = t;
          if (t.startsWith(';')) {
            cleanLine = t.substring(1).trim();
          }

          if (cleanLine.startsWith('[') && cleanLine.endsWith(']')) {
            currentSection = cleanLine.toLowerCase();
            continue;
          }

          final parts = cleanLine.split('=');
          if (parts.length < 2) continue;
          final k = parts[0].trim();
          final v = parts[1].trim();

          if (currentSection == "[led15093]") {
            if (k == 'enable') _led15093Enable = (v == '1');
          } else if (currentSection == "[led]") {
            switch (k) {
              case 'cabLedOutputPipe': _cabLedOutputPipe = (v == '1'); break;
              case 'cabLedOutputSerial': _cabLedOutputSerial = (v == '1'); break;
              case 'controllerLedOutputPipe': _controllerLedOutputPipe = (v == '1'); break;
              case 'controllerLedOutputSerial': _controllerLedOutputSerial = (v == '1'); break;
              case 'controllerLedOutputOpeNITHM': _controllerLedOutputOpeNITHM = (v == '1'); break;
              case 'serialPort': _portController.text = v; break;
              case 'serialBaud': _baudController.text = v; break;
            }
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, Map<String, String>> getConfigData() {
    return {
      'led15093': {
        'enable': _led15093Enable ? '1' : '0',
      },
      'led': {
        'cabLedOutputPipe': _cabLedOutputPipe ? '1' : '0',
        'cabLedOutputSerial': _cabLedOutputSerial ? '1' : '0',
        'controllerLedOutputPipe': _controllerLedOutputPipe ? '1' : '0',
        'controllerLedOutputSerial': _controllerLedOutputSerial ? '1' : '0',
        'controllerLedOutputOpeNITHM': _controllerLedOutputOpeNITHM ? '1' : '0',
        'serialPort': _portController.text.isEmpty ? 'COM5' : _portController.text,
        'serialBaud': _baudController.text.isEmpty ? '921600' : _baudController.text,
      }
    };
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

  Widget _buildSwitchItem(String label, bool value, Function(bool) onChanged) {
    if (widget.searchKeyword.isNotEmpty && !label.toLowerCase().contains(widget.searchKeyword.toLowerCase())) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ToggleSwitch(
        checked: value,
        onChanged: onChanged,
        content: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("LED settings", FluentIcons.lightbulb),
        _buildSwitchItem("Enable LED Emulation", _led15093Enable, (v) => setState(() => _led15093Enable = v)),
        InfoLabel(
          label: "Billboard LED",
          child: Row(
            children: [
              _buildSwitchItem("Pipe Output", _cabLedOutputPipe, (v) => setState(() => _cabLedOutputPipe = v)),
              const SizedBox(width: 20),
              _buildSwitchItem("Serial Output", _cabLedOutputSerial, (v) => setState(() => _cabLedOutputSerial = v)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        InfoLabel(
          label: "Controller LED",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSwitchItem("Pipe Output", _controllerLedOutputPipe, (v) => setState(() => _controllerLedOutputPipe = v)),
                  const SizedBox(width: 20),
                  _buildSwitchItem("Serial Output", _controllerLedOutputSerial, (v) => setState(() => _controllerLedOutputSerial = v)),
                ],
              ),
              _buildSwitchItem("Use OpeNITHM Protocol", _controllerLedOutputOpeNITHM, (v) => setState(() => _controllerLedOutputOpeNITHM = v)),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: InfoLabel(
                label: "Serial Port",
                child: TextBox(
                  controller: _portController,
                  placeholder: "COM5",
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: InfoLabel(
                label: "Baud Rate",
                child: TextBox(
                  controller: _baudController,
                  placeholder: "921600",
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}