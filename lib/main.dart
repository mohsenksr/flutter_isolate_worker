import 'dart:async';
import 'dart:html';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;
  String message = 'no message found';

  getMessage() {
    setState(() {});
  }

  isolateCompleted(String newMessage) {
    setState(() {
      message = newMessage;
      loading = false;
    });
  }

  void runIsolate() async {
    setState(() {
      loading = true;
    });
    if (kIsWeb) {
      querySelector('#output').text = 'Your Dart app is running.';

      var myWorker = new Worker('worker.js');

      myWorker.onMessage.listen((e) {
        print('Message received from worker: ${e.data}');
      });

      myWorker.postMessage([42, 17]);
      print('Message posted to worker');
      return;
    }
    Isolate isolate;
    ReceivePort receivePort;

    spawnNewIsolate(isolate, receivePort);
    // await Future.delayed(Duration(seconds: 6));
  }

  void spawnNewIsolate(isolate, receivePort) async {
    receivePort = ReceivePort();

    try {
      isolate = await Isolate.spawn(
          sayHello, [receivePort.sendPort, 'salam chitori?']);

      print("Isolate: $isolate");

      receivePort.listen((dynamic newMessage) {
        print('New message from Isolate: $newMessage');
        isolateCompleted(newMessage);
        receivePort.close();

        isolate.kill();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  //spawn accepts only static methods or top-level functions

  static void sayHello(List<Object> arguments) async {
    SendPort sendPort = arguments[0];
    await Future.delayed(Duration(seconds: 5));
    sendPort.send(arguments[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Isolate Demo"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: Text('Run isolate'),
              onPressed: runIsolate,
            ),
            Text(message),
            loading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
    );
  }
}
