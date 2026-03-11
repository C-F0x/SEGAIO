import 'package:fluent_ui/fluent_ui.dart';
import 'demo1.dart';

class SelectorPage extends StatefulWidget {
  const SelectorPage({super.key});

  @override
  State<SelectorPage> createState() => _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage> {
  final Map<String, List<String>> _typeData = {
    'Chusan': ['Rustnithm', 'Laverita', 'TASOLLER', 'TASOLLER+', 'Custom'],
    'Mu3': ['Yuangeki', 'ONTROLLER', 'Custom'],
    'Mai2': ['ADX', 'NDX', 'MAITROLLER', 'Custom'],
  };

  String? _selectedMajor = 'Chusan';
  String? _selectedMinor = 'Rustnithm';
  bool _isLogicEnabled = false;
  final TextEditingController _customInputController = TextEditingController();

  @override
  void dispose() {
    _customInputController.dispose();
    super.dispose();
  }

  Widget _buildTargetView() {
    if (!_isLogicEnabled) {
      return const Center(
        child: Text('Switch is OFF', style: TextStyle(color: Colors.grey)),
      );
    }
    return const Demo1Page();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Revealer'),
            const SizedBox(width: 20),
            SizedBox(
              width: 100,
              child: ComboBox<String>(
                value: _selectedMajor,
                items: _typeData.keys.map((e) => ComboBoxItem(value: e, child: Text(e))).toList(),
                onChanged: (v) {
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
                onChanged: (v) => setState(() => _selectedMinor = v),
              ),
            ),
            const SizedBox(width: 12),
            if (_selectedMinor == 'Custom')
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: TextBox(
                    controller: _customInputController,
                    placeholder: 'Enter custom info...',
                  ),
                ),
              )
            else
              const Spacer(),

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
                  color: FluentTheme.of(context).cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildTargetView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}