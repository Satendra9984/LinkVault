import 'package:flutter/services.dart';

class ClipboardService {
  ClipboardService._(); // Private constructor for singleton pattern

  static final ClipboardService instance = ClipboardService._();

  /// Copies the given text to the clipboard.
  Future<void> copyText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      print('Text copied to clipboard: $text');
    } catch (e) {
      print('Failed to copy text to clipboard: $e');
    }
  }

  /// Retrieves the current text from the clipboard.
  Future<String?> getClipboardText() async {
    try {
      final data = await Clipboard.getData('text/plain');
      return data?.text;
    } catch (e) {
      print('Failed to retrieve text from clipboard: $e');
      return null;
    }
  }
}
