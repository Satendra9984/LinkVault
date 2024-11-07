import 'package:flutter/material.dart';

class Logger {
  Logger._();

  static void printLog(String message) {
    debugPrint('[log] : $message');
  }
}
