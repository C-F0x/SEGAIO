import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;

class MiscHooksConfig extends StatefulWidget {
  final String projectPath;
  final String searchKeyword;

  const MiscHooksConfig({
    super.key,
    required this.projectPath,
    this.searchKeyword = "",
  });

  @override
  State<MiscHooksConfig> createState() => MiscHooksConfigState();
}

class MiscHooksConfigState extends State<MiscHooksConfig> {
  bool _isLoading = true;
  bool _gfxEnable = true;
  bool _windowed = true;
  bool _framed = false;
  bool _dpiAware = true;
  int _monitorValue = 0;

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

          if (currentSection == "[gfx]") {
            switch (k) {
              case 'enable': _gfxEnable = (v == '1'); break;
              case 'windowed': _windowed = (v == '1'); break;
              case 'framed': _framed = (v == '1'); break;
              case 'dpiAware': _dpiAware = (v == '1'); break;
              case 'monitor': _monitorValue = int.tryParse(v) ?? 0; break;
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
      'gfx': {
        'enable': _gfxEnable ? '1' : '0',
        'windowed': _windowed ? '1' : '0',
        'framed': _framed ? '1' : '0',
        'dpiAware': _dpiAware ? '1' : '0',
        'monitor': _monitorValue.toString(),
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

    final List<String> searchTargets = [
      "Misc. hooks settings",
      "Enable Graphics Hook",
      "Windowed Mode",
      "Show Window Frame",
      "DPI Awareness",
      "Target Monitor"
    ];

    final bool hasMatch = widget.searchKeyword.isEmpty ||
        searchTargets.any((l) => l.toLowerCase().contains(widget.searchKeyword.toLowerCase()));

    if (!hasMatch) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Misc. hooks settings", FluentIcons.video),
        _buildSwitchItem("Enable Graphics Hook", _gfxEnable, (v) => setState(() => _gfxEnable = v)),
        _buildSwitchItem("Windowed Mode", _windowed, (v) => setState(() => _windowed = v)),
        _buildSwitchItem("Show Window Frame", _framed, (v) => setState(() => _framed = v)),
        _buildSwitchItem("DPI Awareness", _dpiAware, (v) => setState(() => _dpiAware = v)),

        if (widget.searchKeyword.isEmpty || "target monitor".contains(widget.searchKeyword.toLowerCase()))
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: InfoLabel(
              label: "Target Monitor (Fullscreen only, 0=Primary)",
              child: SizedBox(
                width: 200,
                child: NumberBox<int>(
                  value: _monitorValue,
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _monitorValue = v);
                    }
                  },
                  min: 0,
                  max: 16,
                  mode: SpinButtonPlacementMode.inline,
                ),
              ),
            ),
          ),
      ],
    );
  }
}