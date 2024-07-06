import 'package:flutter/material.dart';

class Logger {
  Logger._();

  static printLog(String message) {
    debugPrint('[log] : $message');
  }
}
