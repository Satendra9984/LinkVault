// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:typed_data';

class IsolateManager {
  late Isolate _isolate;
  late SendPort _sendPort;
  late ReceivePort _receivePort;
  final Queue<_IsolateTask> _taskQueue = Queue<_IsolateTask>();
  bool _isRunning = false;
  bool _isInitialized = false;
  Completer<void>? _initializationCompleter;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_initializationCompleter != null) {
      return _initializationCompleter!.future;
    }

    _initializationCompleter = Completer<void>();

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, _receivePort.sendPort);
    _sendPort = await _receivePort.first as SendPort;

    _receivePort.listen((message) {
      if (message == true) {
        _processNextTask();
      }
    });

    _isInitialized = true;
    _initializationCompleter!.complete();
  }

  void dispose() {
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
    _taskQueue.clear();
    _isRunning = false;
    _isInitialized = false;
    _initializationCompleter = null;
  }

  Future<Uint8List?> executeTask(
    Future<Uint8List?> Function(String imageUrl,
            {required int maxSize, required bool compressImage,})
        customFunction,
    String imageUrl,
    int maxSize,
    bool compressImage,
  ) async {
    await initialize();

    final completer = Completer<Uint8List?>();
    final task = _IsolateTask(customFunction, imageUrl, maxSize, compressImage, completer);
    _taskQueue.add(task);
    if (!_isRunning) {
      _isRunning = true;
      _processNextTask();
    }
    return completer.future;
  }

  void _processNextTask() {
    if (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      _sendPort.send(task);
    } else {
      _isRunning = false;
    }
  }

  static void _isolateEntry(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic message) async {
      final task = message as _IsolateTask;
      try {
        final result = await task.customFunction(
          task.imageUrl,
          maxSize: task.maxSize,
          compressImage: task.compressImage,
        );
        task.completer.complete(result);
      } catch (e) {
        task.completer.completeError(e);
      } finally {
        sendPort.send(true); // Signal task completion
      }
    });
  }
}

class _IsolateTask {

  _IsolateTask(this.customFunction, this.imageUrl, this.maxSize,
      this.compressImage, this.completer,);
  final Future<Uint8List?> Function(String imageUrl,
      {required int maxSize, required bool compressImage,}) customFunction;
  final String imageUrl;
  final int maxSize;
  final bool compressImage;
  final Completer<Uint8List?> completer;
}
