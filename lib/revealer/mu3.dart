import 'package:flutter/material.dart';

class Mu3Page extends StatelessWidget {
  const Mu3Page({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final int stickValue = 0;
    final List<bool> buttonStates = List.generate(9, (_) => false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SizedBox(
            height: 100,
            child: Row(
              children: [
                _buildSideButtons(isDark),
                const Expanded(child: SizedBox()),
                _buildAccessCodePanel(isDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                _buildStickMonitorBar(stickValue, isDark),
                const Spacer(flex: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRectButton("L", buttonStates[1], isDark),
                    const SizedBox(width: 40),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _buildSquareButton("7", buttonStates[7], isDark),
                            const SizedBox(width: 140),
                            _buildSquareButton("8", buttonStates[8], isDark),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: List.generate(6, (i) => _buildSquareButton("${i + 1}", buttonStates[i + 1], isDark)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    _buildRectButton("R", buttonStates[2], isDark),
                  ],
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideButtons(bool isDark) {
    final labels = ['COIN', 'SERV', 'TEST', 'CODE'];
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    return SizedBox(
      width: 70,
      child: Column(
        children: labels.map((l) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Center(
                child: Text(
                    l,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white24 : Colors.black26)
                )
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildAccessCodePanel(bool isDark) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("ACCESS CODE", style: TextStyle(fontSize: 8, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "00000\n00000\n00000\n00000",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: isDark ? Colors.white10 : Colors.black12, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildStickMonitorBar(int stickVal, bool isDark) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Center(
        child: Text(
          "STICK / MENU 0 : $stickVal",
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Consolas',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton(String label, bool active, bool isDark) {
    return Container(
      width: 75,
      height: 75,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: active ? Colors.blueAccent : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Center(
        child: Text(label, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white12 : Colors.black12)),
      ),
    );
  }

  Widget _buildRectButton(String label, bool active, bool isDark) {
    return Container(
      width: 75,
      height: 170,
      decoration: BoxDecoration(
        color: active ? Colors.redAccent.withValues(alpha: 0.7) : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 2),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white10)),
      ),
    );
  }
}