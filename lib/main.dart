import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';


void main() async {
  runApp(MyApp());
}





class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Step Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({ Key? key,  required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  int _stepCount = 0;
  int _currentStepCount = 0;
  bool _isCounting = false;
  late StreamSubscription<StepCount> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    super.dispose();
    _stopListening();
  }

  void _startListening() {
    _streamSubscription = Pedometer.stepCountStream.listen((event) {
      setState(() {
        _stepCount = event.steps;
        if (_isCounting) {
          _currentStepCount = event.steps - _initialStepCount;
        }
      });
    }, onError: (error) {
      print('Error: $error');
    }, onDone: () {
      print('Stream closed');
    }, cancelOnError: true);
  }

  void _stopListening() {
    _streamSubscription.cancel();
  }

  void _resetSteps() {
    _stopListening();
    setState(() {
      _stepCount = 0;
      _currentStepCount = 0;
      _isCounting = false;
    });

    _startListening();
  }

  void _startCounting() {
    setState(() {
      _initialStepCount = _stepCount;
      _isCounting = true;
    });
  }

  void _stopCounting() {
    setState(() {
      _isCounting = false;
      _currentStepCount = _stepCount - _initialStepCount;
    });
  }

  int _initialStepCount = 0;

  String get _sensorStatus {
    return _streamSubscription.isPaused ? 'Not listening' : 'Listening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Total step count:',
            ),
            Text(
              '$_stepCount',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20),
            Text(
              'Current step count:',
            ),
            Text(
              '$_currentStepCount',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20),
            Text(
              'Sensor status: $_sensorStatus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCounting ? null : _startCounting,
              child: Text('Start Counting'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isCounting ? _stopCounting : null,
              child: Text('Stop Counting'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _resetSteps,
              child: Text('Reset Steps'),
            ),
          ],
        ),
      ),
    );
  }
}
