import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;

class NetworkConfig extends StatefulWidget {
  final String projectPath;
  final String searchKeyword;

  const NetworkConfig({
    super.key,
    required this.projectPath,
    this.searchKeyword = "",
  });

  @override
  State<NetworkConfig> createState() => NetworkConfigState();
}

class NetworkConfigState extends State<NetworkConfig> {
  final TextEditingController _dnsDefaultController = TextEditingController();

  bool _isLoading = true;
  bool _netenvEnable = false;
  double _netenvAddrSuffix = 11.0;
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
              if (k == 'addrSuffix') {
                _netenvAddrSuffix = double.tryParse(v) ?? 11.0;
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
    return {
      'dns': {
        'default': _dnsDefaultController.text,
      },
      'netenv': {
        'enable': _netenvEnable ? '1' : '0',
        'addrSuffix': _netenvAddrSuffix.toInt().toString(),
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

    final List<String> searchTargets = [
      "Network Settings",
      "Server Address",
      "Status",
      "Enable NetEnv",
      "IP Suffix"
    ];

    final bool hasMatch = widget.searchKeyword.isEmpty ||
        searchTargets.any((l) => l.toLowerCase().contains(widget.searchKeyword.toLowerCase()));

    if (!hasMatch) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Network Settings", FluentIcons.network_tower),
        _buildSettingItem(
          label: "Server Address",
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: ComboBox<String>(
                  value: _selectedDns,
                  items: _dnsPresets.keys
                      .map((e) => ComboBoxItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedDns = v!;
                    if (v != "Custom") _dnsDefaultController.text = _dnsPresets[v]!;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextBox(
                  controller: _dnsDefaultController,
                  placeholder: "127.0.0.1",
                  enabled: _selectedDns == "Custom",
                ),
              ),
            ],
          ),
        ),
        _buildSettingItem(
          label: "Status",
          child: ToggleSwitch(
            checked: _netenvEnable,
            onChanged: (v) => setState(() => _netenvEnable = v),
            content: const Text("Enable NetEnv"),
          ),
        ),
        _buildSettingItem(
          label: "IP Suffix: ${_netenvAddrSuffix.toInt()}",
          child: Slider(
            value: _netenvAddrSuffix,
            min: 2,
            max: 254,
            onChanged: _netenvEnable
                ? (v) => setState(() => _netenvAddrSuffix = v)
                : null,
          ),
        ),
      ],
    );
  }
}