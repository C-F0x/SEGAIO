import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;

class ChusanConfig extends StatefulWidget {
  final String projectPath;
  final bool isEmbedded;
  final String searchKeyword;

  const ChusanConfig({
    super.key,
    required this.projectPath,
    this.isEmbedded = false,
    this.searchKeyword = "",
  });

  @override
  State<ChusanConfig> createState() => ChusanConfigState();
}

class ChusanConfigState extends State<ChusanConfig> {
  final TextEditingController _chuniioPathController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChusanIni();
  }

  Future<void> _loadChusanIni() async {
    if (!mounted) return;
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
            case "[chuniio]":
              if (k == 'path') _chuniioPathController.text = v;
              break;
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> saveConfig() async {
    final file = File(p.join(widget.projectPath, 'segatools.ini'));

    Map<String, Map<String, String>> config = {
      'chuniio': {
        'path': _chuniioPathController.text,
      },
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
            } else {
              output.add(line);
            }
          } else {
            output.add(line);
          }
        }
        _appendKeys(output, currentSec, handledKeys, config);
      }

      config.forEach((sec, keys) {
        if (!handledSections.contains(sec)) {
          if (keys.values.any((v) => v.isNotEmpty)) {
            output.add('\n[$sec]');
            keys.forEach((k, v) {
              if (v.isNotEmpty) output.add('$k=$v');
            });
          }
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
      map[sec]!.forEach((k, v) {
        if (!handled.contains(k) && v.isNotEmpty) out.add('$k=$v');
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
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: TextStyle(
          color: FluentTheme.of(context).accentColor,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + keyword.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
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
  Widget _buildSettingItem(String label, Widget input) {
    if (widget.searchKeyword.isNotEmpty &&
        !label.toLowerCase().contains(widget.searchKeyword.toLowerCase())) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: _buildHighlightedText(label, widget.searchKeyword)
          ),
          const SizedBox(width: 16),
          Expanded(flex: 7, child: input),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    const String chuniioLabel = "ChuniIO DLL 路径";
    final bool isSearching = widget.searchKeyword.isNotEmpty;
    final bool labelMatches = chuniioLabel.toLowerCase().contains(widget.searchKeyword.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Chusan 专属 IO 插件 ([chuniio])", FluentIcons.game),
        if (!isSearching || labelMatches)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "注：此项控制 Chusan 专用的 IO 驱动 DLL，通常与 Base 层的 AimeIO 不同。",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

        _buildSettingItem(
          chuniioLabel,
          TextBox(
            controller: _chuniioPathController,
            placeholder: "例如: chuniio.dll",
          ),
        ),

        if (!widget.isEmbedded && !isSearching) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Button(
              onPressed: saveConfig,
              child: const Text("保存 Chusan 配置"),
            ),
          ),
        ]
      ],
    );
  }
}