import 'package:flutter/services.dart';

class VKMapper {
  static String getKeyNameFromHex(String hex, {KeyEvent? event}) {
    try {
      if (!hex.startsWith("0x")) return "未设置";
      int vk = int.parse(hex.substring(2), radix: 16);

      if (event != null) {
        final label = event.logicalKey.keyLabel;
        if (label.isNotEmpty && !label.startsWith('Key ')) {
          return label;
        }
      }

      if (vk == 0x01) return "Mouse Left";
      if (vk == 0x02) return "Mouse Right";
      if (vk == 0x04) return "Mouse Middle";

      if ((vk >= 0x30 && vk <= 0x39) || (vk >= 0x41 && vk <= 0x5A)) {
        return String.fromCharCode(vk);
      }

      return "Key $hex";
    } catch (_) {
      return "未设置";
    }
  }

  static String getHexFromKey(KeyEvent event) {
    int vk = 0;
    final int plane = event.logicalKey.keyId & 0xFF000000000;

    if (plane == 0x02000000000) {
      vk = event.logicalKey.keyId & 0x000FFFFFFFF;
    } else if (plane == 0x00000000000) {
      int code = event.logicalKey.keyId & 0x000FFFFFFFF;
      vk = (code >= 97 && code <= 122) ? code - 32 : code;
    } else {
      vk = event.logicalKey.keyId & 0xFF;
    }

    return "0x${vk.toRadixString(16).padLeft(2, '0').toUpperCase()}";
  }

  static void listenForNextKey({
    required Function(String hex, String name) onDetected,
    required Function() onCancel,
  }) {
    bool isHandled = false;

    bool handler(KeyEvent event) {
      if (isHandled || event is! KeyDownEvent) return false;
      isHandled = true;

      final String hex = getHexFromKey(event);
      final String name = getKeyNameFromHex(hex, event: event);

      onDetected(hex, name);
      HardwareKeyboard.instance.removeHandler(handler);
      return true;
    }

    HardwareKeyboard.instance.addHandler(handler);
  }
}