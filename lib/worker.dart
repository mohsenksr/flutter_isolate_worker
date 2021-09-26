@JS()
library sample;

import 'dart:html';
import 'package:js/js.dart';

@JS('self')
external DedicatedWorkerGlobalScope get self;

void main() {
  self.onMessage.listen((e) {
    print('Message received from main script');
    var workerResult = 'Result: ${e.data[0] * e.data[1]}';
    print('Posting message back to main script');
    self.postMessage(workerResult, null);
  });
}
