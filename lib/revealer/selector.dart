import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'chusan.dart';
import 'mu3.dart';
import 'mai2.dart';
import 'ttyd.dart';
import 'demo1.dart';

class SelectorPage extends StatefulWidget {
  const SelectorPage({super.key});

  @override
  State<SelectorPage> createState() => _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage> {
  final Map<String, List<String>> _typeData = {
    'Chusan': ['Rustnithm', 'Laverita', 'YubiDeck', 'TASOLLER', 'TASOLLER+', 'Custom'],
    'Mu3': ['Yuangeki', 'ONTROLLER', 'Custom'],
    'Mai2': ['ADX', 'NDX', 'MAITROLLER', 'Custom'],
  };

  String? _selectedMajor = 'Chusan';
  String? _selectedMinor = 'Rustnithm';
  bool _isLogicEnabled = false;
  int _debugLevel = 0;

  final TextEditingController _freqController = TextEditingController(text: '10');
  final TextEditingController _customInputController = TextEditingController();

  @override
  void dispose() {
    _freqController.dispose();
    _customInputController.dispose();
    super.dispose();
  }

  Color _getDebugColor() {
    if (_debugLevel == 1) return Colors.yellow;
    if (_debugLevel == 2) return Colors.red;
    return Colors.grey;
  }

  Widget _buildTargetView() {
    if (_debugLevel == 1) {
      return const TtydPage();
    }
    switch (_selectedMajor) {
      case 'Chusan':
        return const ChusanPage();
      case 'Mu3':
        return const Mu3Page();
      case 'Mai2':
        return const Mai2Page();
      default:
        return const Demo1Page();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final bool isLocked = _isLogicEnabled;

    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Revealer'),
            const SizedBox(width: 24),
            SizedBox(
              width: 100,
              child: ComboBox<String>(
                value: _selectedMajor,
                items: _typeData.keys.map((e) => ComboBoxItem(value: e, child: Text(e))).toList(),
                onChanged: isLocked ? null : (v) {
                  if (v != null) {
                    setState(() {
                      _selectedMajor = v;
                      _selectedMinor = _typeData[v]!.first;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 130,
              child: ComboBox<String>(
                value: _selectedMinor,
                items: _typeData[_selectedMajor]!.map((e) => ComboBoxItem(value: e, child: Text(e))).toList(),
                onChanged: isLocked ? null : (v) => setState(() => _selectedMinor = v),
              ),
            ),
            const SizedBox(width: 12),
            if (_selectedMinor == 'Custom')
              SizedBox(
                width: 316,
                child: TextBox(
                  enabled: !isLocked,
                  controller: _customInputController,
                  placeholder: 'Enter Shared Memory Name...',
                ),
              ),
            const Spacer(),

            Tooltip(
              message: 'Sampling Interval (ms)',
              child: SizedBox(
                width: 40,
                child: TextBox(
                  controller: _freqController,
                  enabled: !isLocked,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  placeholder: 'ms',
                ),
              ),
            ),
            const SizedBox(width: 12),

            Tooltip(
              message: isLocked ? 'Configuration Locked' : 'Debug Mode: $_debugLevel',
              child: IconButton(
                icon: Icon(
                  _debugLevel == 0 ? FluentIcons.bug : FluentIcons.glimmer,
                  color: _getDebugColor().withOpacity(isLocked ? 0.3 : 1.0),
                  size: 20,
                ),
                onPressed: isLocked ? null : () {
                  setState(() {
                    _debugLevel = (_debugLevel + 1) % 3;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            ToggleSwitch(
              checked: _isLogicEnabled,
              onChanged: (v) => setState(() => _isLogicEnabled = v),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          children: [
            const Divider(),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.resources.surfaceStrokeColorDefault,
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildTargetView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}