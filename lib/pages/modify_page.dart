import 'package:fluent_ui/fluent_ui.dart';
import '../diff/base.dart';
import '../diff/chusan.dart';

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
  final GlobalKey<BaseConfigPageState> _baseKey = GlobalKey<BaseConfigPageState>();
  final GlobalKey<ChusanConfigState> _chusanKey = GlobalKey<ChusanConfigState>();

  Future<bool> triggerSaveAll() async {
    final String variety = (widget.configData['variety'] ?? '').toString().toLowerCase();
    bool baseOk = await _baseKey.currentState?.saveConfig() ?? false;
    bool chusanOk = true;
    if (variety == 'chusan') {
      chusanOk = await _chusanKey.currentState?.saveConfig() ?? false;
    }

    return baseOk && chusanOk;
  }

  @override
  Widget build(BuildContext context) {
    final String variety = (widget.configData['variety'] ?? 'unknown').toString().toLowerCase();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BaseConfigPage(
              key: _baseKey,
              projectPath: widget.projectPath,
              variety: variety,
              isEmbedded: true,
              searchKeyword: widget.searchKeyword,
            ),
            if (variety == 'chusan') ...[
              const SizedBox(height: 8),
              ChusanConfig(
                key: _chusanKey,
                projectPath: widget.projectPath,
                isEmbedded: true,
                searchKeyword: widget.searchKeyword,
              ),
            ],
          ],
        ),
      ),
    );
  }
}