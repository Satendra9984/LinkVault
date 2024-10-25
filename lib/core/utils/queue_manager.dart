import 'dart:collection';

class AsyncQueueManager {

  AsyncQueueManager({this.maxConcurrentTasks = 5});
  final int maxConcurrentTasks;
  final Queue<Future<void> Function()> _taskQueue = Queue();
  int _activeTasks = 0;

  void addTask(Future<void> Function() task) {
    _taskQueue.add(task);
    _runNextTask();
  }

  void _runNextTask() {
    if (_activeTasks < maxConcurrentTasks && _taskQueue.isNotEmpty) {
      _activeTasks++;
      final task = _taskQueue.removeFirst();
      task().whenComplete(() {
        _activeTasks--;
        _runNextTask();
      });
    }
  }
}

