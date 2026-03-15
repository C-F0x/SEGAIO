import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

class TtydPage extends StatelessWidget {
  const TtydPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String mockHexStream = List.generate(64, (line) {
      final addr = (line * 16).toRadixString(16).padLeft(4, '0').toUpperCase();
      final hexLine = List.generate(16, (i) => '00').join(' ');
      return '$addr | $hexLine';
    }).join('\n');

    return Container(
      color: isDark
          ? Colors.black.withOpacity(0.4)
          : Colors.grey[40].withOpacity(0.1),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            child: Row(
              children: [
                Icon(
                    FluentIcons.command_prompt,
                    size: 10,
                    color: isDark ? Colors.grey[100] : Colors.grey[120]
                ),
                const SizedBox(width: 10),
                Text(
                  'DEBUG TERMINAL - HEX MIRROR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[100] : Colors.grey[120],
                    letterSpacing: 0.5,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const Spacer(),
                Text(
                  'SAMPLING: 1ms',
                  style: TextStyle(
                      fontSize: 9,
                      color: isDark ? Colors.grey[120] : Colors.grey[140],
                      fontFamily: 'Consolas'
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: material.SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const material.BouncingScrollPhysics(),
              child: SelectableText(
                mockHexStream,
                style: TextStyle(
                  color: isDark ? const Color(0xFFD1D1D1) : const Color(0xFF454545),
                  fontFamily: 'Consolas',
                  fontSize: 12,
                  height: 1.5,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}