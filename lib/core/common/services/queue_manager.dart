import 'dart:collection';

class AsyncQueueManager {
  final Queue<Function> _taskQueue = Queue();
  bool _isProcessing = false;

  void addTask(Function task) {
    _taskQueue.add(task);
    _processNext();
  }

  Future<void> _processNext() async {
    if (_isProcessing || _taskQueue.isEmpty) return;

    _isProcessing = true;

    final task = _taskQueue.removeFirst();
    await task();

    _isProcessing = false;
    await _processNext();
  }
}
