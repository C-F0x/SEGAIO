import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;
import '../shared/vk.dart';

class InputConfig extends StatefulWidget {
  final String projectPath;
  final String searchKeyword;

  const InputConfig({
    super.key,
    required this.projectPath,
    this.searchKeyword = "",
  });

  @override
  State<InputConfig> createState() => InputConfigState();
}

class InputConfigState extends State<InputConfig> {
  final Map<String, TextEditingController> _io3Controllers = {
    'test': TextEditingController(),
    'service': TextEditingController(),
    'coin': TextEditingController(),
    'ir': TextEditingController(),
  };

  final Map<String, TextEditingController> _irControllers =
  Map.fromIterable(List.generate(6, (i) => 'ir${i + 1}'),
      value: (_) => TextEditingController());

  final Map<String, TextEditingController> _sliderControllers =
  Map.fromIterable(List.generate(32, (i) => 'cell${i + 1}'),
      value: (_) => TextEditingController());

  bool _isLoading = true;
  bool _uiIrEnabled = false;
  bool _sliderEnable = false;

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

          if (currentSection == "[io3]") {
            if (_io3Controllers.containsKey(k)) _io3Controllers[k]!.text = v;
          } else if (currentSection == "[ir]") {
            if (_irControllers.containsKey(k)) {
              _irControllers[k]!.text = v;
              if (v != "0x00" && v.isNotEmpty) _uiIrEnabled = true;
            }
          } else if (currentSection == "[slider]") {
            if (k == 'enable') _sliderEnable = (v == '1');
            if (_sliderControllers.containsKey(k)) _sliderControllers[k]!.text = v;
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, Map<String, String>> getConfigData() {
    Map<String, Map<String, String>> result = {};
    result['io3'] = _io3Controllers.map((k, v) => MapEntry(k, v.text));
    if (_uiIrEnabled) {
      result['ir'] = _irControllers.map((k, v) => MapEntry(k, v.text));
    }
    Map<String, String> sliderData = {'enable': _sliderEnable ? '1' : '0'};
    sliderData.addAll(_sliderControllers.map((k, v) => MapEntry(k, v.text)));
    result['slider'] = sliderData;
    return result;
  }

  void _startListening(TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('等待按键录入'),
        content: const Text('请按下键盘上的任意按键...'),
        actions: [
          Button(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    VKMapper.listenForNextKey(
      onDetected: (hex, name) {
        if (mounted) {
          setState(() {
            controller.text = hex;
          });
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      },
      onCancel: () {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      },
    );
  }

  Widget _buildClickableBlock({
    required String label,
    required TextEditingController controller,
    required Color activeColor,
  }) {
    String keyName = VKMapper.getKeyNameFromHex(controller.text);
    bool hasKey = controller.text.isNotEmpty && controller.text != "0x00";

    return Expanded(
      child: GestureDetector(
        onTap: () => _startListening(controller),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: hasKey ? activeColor : FluentTheme.of(context).micaBackgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: hasKey ? FluentTheme.of(context).accentColor : FluentTheme.of(context).resources.surfaceStrokeColorDefault,
                width: 0.5,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: hasKey ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    if (hasKey)
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          keyName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

  Widget _buildIo3Item(String label, TextEditingController controller) {
    String keyName = VKMapper.getKeyNameFromHex(controller.text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(
            flex: 7,
            child: Row(
              children: [
                Expanded(child: TextBox(controller: controller, readOnly: true)),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: FluentTheme.of(context).resources.surfaceStrokeColorDefault),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(keyName, style: TextStyle(color: FluentTheme.of(context).accentColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Button(
                  child: const Icon(FluentIcons.keyboard_classic),
                  onPressed: () => _startListening(controller),
                ),
              ],
            ),
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
        _buildSectionHeader("Input settings", FluentIcons.button_control),
        ..._io3Controllers.entries.map((e) => _buildIo3Item(e.key.toUpperCase(), e.value)),

        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 15,
              child: Column(
                children: [
                  _buildSectionHeader("[ir]", FluentIcons.hands_free),
                  ToggleSwitch(
                    checked: _uiIrEnabled,
                    onChanged: (v) => setState(() => _uiIrEnabled = v),
                    content: const Text("Enable"),
                  ),
                  if (_uiIrEnabled)
                    Container(
                      height: 360,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: List.generate(6, (index) {
                          int num = 6 - index;
                          return _buildClickableBlock(
                            label: "AIR $num",
                            controller: _irControllers['ir$num']!,
                            activeColor: const Color(0xFF00FFFF).withOpacity(0.6),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 85,
              child: Column(
                children: [
                  _buildSectionHeader("[slider]", FluentIcons.touch),
                  ToggleSwitch(
                    checked: _sliderEnable,
                    onChanged: (v) => setState(() => _sliderEnable = v),
                    content: const Text("Enable"),
                  ),
                  if (_sliderEnable)
                    Container(
                      height: 360,
                      margin: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: List.generate(2, (row) {
                          return Expanded(
                            child: Row(
                              children: List.generate(16, (col) {
                                int cellNum = (15 - col) * 2 + (row + 1);
                                return _buildClickableBlock(
                                  label: "$cellNum",
                                  controller: _sliderControllers['cell$cellNum']!,
                                  activeColor: const Color(0xFFFFBF00).withOpacity(0.6),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}