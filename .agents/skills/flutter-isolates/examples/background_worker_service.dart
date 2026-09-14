import 'dart:async';
import 'dart:isolate';

class WorkerTask {
  final int payload;
  WorkerTask(this.payload);
}

class WorkerResponse {
  final int data;
  WorkerResponse({required this.data});
}

class BackgroundWorkerService {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;

  final _responseController = StreamController<WorkerResponse>.broadcast();
  Stream<WorkerResponse> get results => _responseController.stream;

  Future<void> init() async {
    if (_isolate != null) return;

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_workerEntryPoint, _receivePort!.sendPort);

    final events = _receivePort!.asBroadcastStream();
    _sendPort = await events.first as SendPort;

    events.listen((message) {
      if (message is WorkerResponse) {
        _responseController.add(message);
      }
    });
  }

  void sendTask(WorkerTask task) {
    final sendPort = _sendPort;
    if (sendPort == null) throw StateError('Worker is not initialized.');
    sendPort.send(task);
  }

  static void _workerEntryPoint(SendPort mainSendPort) {
    final workerReceivePort = ReceivePort();
    mainSendPort.send(workerReceivePort.sendPort);

    workerReceivePort.listen((message) {
      if (message is WorkerTask) {
        final result = WorkerResponse(data: message.payload * 2);
        mainSendPort.send(result);
      }
    });
  }

  void dispose() {
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _responseController.close();
  }
}
