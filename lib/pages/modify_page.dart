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

  const ModifyPage({
    super.key,
    required this.projectPath,
    required this.configData,
    this.searchKeyword = "",
  });

  @override
  State<ModifyPage> createState() => ModifyPageState();
}

class ModifyPageState extends State<ModifyPage> {
  final GlobalKey<PathConfigState> _pathKey = GlobalKey();
  final GlobalKey<DeviceConfigState> _deviceKey = GlobalKey();
  final GlobalKey<NetworkConfigState> _networkKey = GlobalKey();
  final GlobalKey<BoardConfigState> _boardKey = GlobalKey();
  final GlobalKey<IoConfigState> _ioKey = GlobalKey();
  final GlobalKey<InputConfigState> _inputKey = GlobalKey();
  final GlobalKey<LedConfigState> _ledKey = GlobalKey();
  final GlobalKey<MiscHooksConfigState> _miscKey = GlobalKey();

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PathConfig(key: _pathKey, projectPath: widget.projectPath, searchKeyword: widget.searchKeyword),
            const SizedBox(height: 16),
            DeviceConfig(key: _deviceKey, projectPath: widget.projectPath, searchKeyword: widget.searchKeyword),
            const SizedBox(height: 16),
            NetworkConfig(key: _networkKey, projectPath: widget.projectPath, searchKeyword: widget.searchKeyword),
            const SizedBox(height: 16),
            BoardConfig(key: _boardKey, projectPath: widget.projectPath, searchKeyword: widget.searchKeyword),
            const SizedBox(height: 16),
            IoConfig(key: _ioKey, projectPath: widget.projectPath, searchKeyword: widget.searchKeyword),
            const SizedBox(height: 16),
            InputConfig(key: _inputKey, projectPath: widget.projectPath, searchKeyword: widget.searchKeyword),
            const SizedBox(height: 16),
            LedConfig(key: _ledKey, projectPath: widget.projectPath, searchKeyword: widget.searchKeyword),
            const SizedBox(height: 16),
            MiscHooksConfig(key: _miscKey, projectPath: widget.projectPath, searchKeyword: widget.searchKeyword),
          ],
        ),
      ),
    );
  }
}