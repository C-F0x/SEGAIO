import 'package:flutter/material.dart';
import 'dart:typed_data';

class ChusanPage extends StatelessWidget {
  const ChusanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mockSlider = List<int>.filled(32, 0);
    final mockAir = List<int>.filled(6, 0);
    final mockCard = Uint8List(10);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            flex: 40,
            child: _buildTopSection(context, mockAir, mockCard, isDark),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 60,
            child: _buildSliderSection(context, mockSlider, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, List<int> airData, Uint8List card, bool isDark) {
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    final sideButtons = [
      {'label': 'COIN', 'val': 0},
      {'label': 'SERV', 'val': 0},
      {'label': 'TEST', 'val': 0},
      {'label': 'CODE', 'val': 0},
    ];

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Column(
            children: sideButtons.map((btn) {
              bool active = (btn['val'] as int) > 0;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: active ? Colors.amberAccent : baseColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                  ),
                  child: Center(
                    child: Text(
                      btn['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: active ? Colors.black : (isDark ? Colors.white24 : Colors.black26),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: List.generate(6, (index) {
              int logicNum = 6 - index;
              bool active = airData[logicNum - 1] > 0;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: active ? Colors.cyanAccent : baseColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                  ),
                  child: Center(
                    child: Text(
                      "AIR $logicNum",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: active ? Colors.black : (isDark ? Colors.white24 : Colors.black26),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        _buildAccessCodePanel(" ", isDark),
      ],
    );
  }

  Widget _buildAccessCodePanel(String code, bool isDark) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
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
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection(BuildContext context, List<int> sliderData, bool isDark) {
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Column(
      children: List.generate(2, (row) {
        return Expanded(
          child: Row(
            children: List.generate(16, (col) {
              int logicIndex = (15 - col) * 2 + (row + 1);
              bool active = sliderData[logicIndex - 1] > 0;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: active ? Colors.amberAccent : baseColor,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                  ),
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        "$logicIndex",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: active ? Colors.black : (isDark ? Colors.white24 : Colors.black26),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}