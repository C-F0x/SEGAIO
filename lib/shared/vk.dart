import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'vk_lib.dart';

class VKMapper {
  static String parse(String? hex, {KeyEvent? event}) {
    if (hex == null || !hex.startsWith("0x") || hex == "0x00") return "Not Set";
    try {
      int vk = int.parse(hex.substring(2), radix: 16);

      if (event != null) {
        final label = event.logicalKey.keyLabel;
        if (label.isNotEmpty && !label.startsWith('Key ')) return label;
      }

      if (VKLibrary.specialNames.containsKey(vk)) {
        return VKLibrary.specialNames[vk]!;
      }

      if ((vk >= 0x30 && vk <= 0x39) || (vk >= 0x41 && vk <= 0x5A)) {
        return String.fromCharCode(vk);
      }

      return "Key $hex";
    } catch (_) {
      return "Not Set";
    }
  }

  static void scan(BuildContext context, Function(String hex) onDetected) {
    bool isHandled = false;
    bool handler(KeyEvent event) {
      if (isHandled || event is! KeyDownEvent) return false;

      isHandled = true;

      int vk = 0;
      final int keyId = event.logicalKey.keyId;

      if (VKLibrary.flutterToWinVK.containsKey(keyId)) {
        vk = VKLibrary.flutterToWinVK[keyId]!;
      } else {
        final int plane = keyId & 0xFF000000000;
        if (plane == 0x00000000000) {
          vk = keyId & 0x000FFFFFFFF;
          if (vk >= 97 && vk <= 122) vk -= 32;
        } else {
          vk = keyId & 0xFF;
        }
      }

      final String hex = "0x${vk.toRadixString(16).padLeft(2, '0').toUpperCase()}";

      onDetected(hex);

      if (Navigator.canPop(context)) Navigator.pop(context);
      HardwareKeyboard.instance.removeHandler(handler);

      return true;
    }

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Now Waiting...'),
        content: const Text('Press any button to bind'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () {
              HardwareKeyboard.instance.removeHandler(handler);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );

    HardwareKeyboard.instance.addHandler(handler);
  }
}