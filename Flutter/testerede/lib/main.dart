import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Benchmark',
      home: NetworkBenchmarkPage(),
    );
  }
}

class NetworkBenchmarkPage extends StatefulWidget {
  @override
  _NetworkBenchmarkPageState createState() => _NetworkBenchmarkPageState();
}

class _NetworkBenchmarkPageState extends State<NetworkBenchmarkPage> {
  final String _url = 'https://jsonplaceholder.typicode.com/posts'; // Example API endpoint
  int _bytesReceived = 0;
  double _dataRate = 0.0; // Bytes per second
  StreamSubscription? _subscription;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
  }

  void _startReceiving() {
    _startTime = DateTime.now();
    _bytesReceived = 0;
    _dataRate = 0.0;

    _subscription?.cancel(); // Cancel any ongoing subscription

    _subscription = Stream.periodic(Duration(milliseconds: 1)).listen((_) async {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final currentTime = DateTime.now();
        final duration = currentTime.difference(_startTime!).inSeconds;
        final bytesReceived = response.bodyBytes.length;

        setState(() {
          _bytesReceived += bytesReceived;
          _dataRate = _bytesReceived / duration;
        });

        if (duration >= 5) {
          _subscription?.cancel();
        }
      }
    });
  }

  void _stopReceiving() {
    _subscription?.cancel();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Benchmark'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Data Rate: ${_dataRate.toStringAsFixed(2)} bytes/s',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Total Bytes Received: $_bytesReceived bytes',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startReceiving,
              child: Text('Start Receiving Data'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _stopReceiving,
              child: Text('Stop Receiving Data'),
            ),
          ],
        ),
      ),
    );
  }
}
