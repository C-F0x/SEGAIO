import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;

import '../chusan/path.dart';
import '../chusan/device.dart';
import '../chusan/network.dart';
import '../chusan/board.dart';
import '../chusan/io.dart';
import '../chusan/input.dart';
import '../chusan/led.dart';
import '../chusan/misc_hooks.dart';

class ModifyPage extends StatefulWidget {
  final String projectPath;
  final Map<String, dynamic> configData;
  final String searchKeyword;
  final bool isGlobalRelative;

  const ModifyPage({
    super.key,
    required this.projectPath,
    required this.configData,
    this.searchKeyword = "",
    required this.isGlobalRelative,
  });

  @override
  State<ModifyPage> createState() => ModifyPageState();
}

class ModifyPageState extends State<ModifyPage> {
  late GlobalKey<PathConfigState> _pathKey;
  late GlobalKey<DeviceConfigState> _deviceKey;
  late GlobalKey<NetworkConfigState> _networkKey;
  late GlobalKey<BoardConfigState> _boardKey;
  late GlobalKey<IoConfigState> _ioKey;
  late GlobalKey<InputConfigState> _inputKey;
  late GlobalKey<LedConfigState> _ledKey;
  late GlobalKey<MiscHooksConfigState> _miscKey;

  @override
  void initState() {
    super.initState();
    _generateKeys();
  }

  void _generateKeys() {
    _pathKey = GlobalKey();
    _deviceKey = GlobalKey();
    _networkKey = GlobalKey();
    _boardKey = GlobalKey();
    _ioKey = GlobalKey();
    _inputKey = GlobalKey();
    _ledKey = GlobalKey();
    _miscKey = GlobalKey();
  }

  void reloadData() {
    setState(() {
      _generateKeys();
    });
  }

  Future<bool> triggerSaveAll() async {
    final Map<String, Map<String, String>> fullConfig = {};

    fullConfig.addAll(_pathKey.currentState?.getConfigData() ?? {});
    fullConfig.addAll(_deviceKey.currentState?.getConfigData() ?? {});
    fullConfig.addAll(_networkKey.currentState?.getConfigData() ?? {});
    fullConfig.addAll(_boardKey.currentState?.getConfigData() ?? {});
    fullConfig.addAll(_ioKey.currentState?.getConfigData() ?? {});
    fullConfig.addAll(_inputKey.currentState?.getConfigData() ?? {});
    fullConfig.addAll(_ledKey.currentState?.getConfigData() ?? {});
    fullConfig.addAll(_miscKey.currentState?.getConfigData() ?? {});

    return await _saveIniFile(fullConfig);
  }

  Future<bool> _saveIniFile(Map<String, Map<String, String>> config) async {
    try {
      final file = File(p.join(widget.projectPath, 'segatools.ini'));
      StringBuffer buffer = StringBuffer();

      config.forEach((section, items) {
        if (items.isNotEmpty) {
          buffer.writeln('[$section]');
          items.forEach((key, value) {
            buffer.writeln('$key=$value');
          });
          buffer.writeln();
        }
      });

      await file.writeAsString(buffer.toString().trimRight() + '\n');
      return true;
    } catch (e) {
      debugPrint("Save error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      PathConfig(
        key: _pathKey,
        projectPath: widget.projectPath,
        searchKeyword: widget.searchKeyword,
        isGlobalRelative: widget.isGlobalRelative,
      ),
      DeviceConfig(
        key: _deviceKey,
        projectPath: widget.projectPath,
        searchKeyword: widget.searchKeyword,
        isGlobalRelative: widget.isGlobalRelative,
      ),
      NetworkConfig(
        key: _networkKey,
        projectPath: widget.projectPath,
        searchKeyword: widget.searchKeyword,
      ),
      BoardConfig(
        key: _boardKey,
        projectPath: widget.projectPath,
        searchKeyword: widget.searchKeyword,
      ),
      IoConfig(
        key: _ioKey,
        projectPath: widget.projectPath,
        searchKeyword: widget.searchKeyword,
        isGlobalRelative: widget.isGlobalRelative,
      ),
      InputConfig(
        key: _inputKey,
        projectPath: widget.projectPath,
        searchKeyword: widget.searchKeyword,
      ),
      LedConfig(
        key: _ledKey,
        projectPath: widget.projectPath,
        searchKeyword: widget.searchKeyword,
      ),
      MiscHooksConfig(
        key: _miscKey,
        projectPath: widget.projectPath,
        searchKeyword: widget.searchKeyword,
      ),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children.expand((widget) => [
            widget,
            const SizedBox(height: 16),
          ]).toList()..removeLast(),
        ),
      ),
    );
  }
}