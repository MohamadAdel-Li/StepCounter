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

  late Timer _timer;
  int _elapsedSeconds = 0;

  bool _isMoving = false; // declare _isMoving
  int _previousStepCount = 0; // declare _previousStepCount

  Widget timerWidget() {
    String formattedTime = formatDuration(Duration(seconds: _elapsedSeconds));

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: Colors.blue,
          ),
          SizedBox(width: 5),
          Text(
            'Elapsed Time:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox(width: 5),
          Text(
            formattedTime,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String hours = (duration.inHours % 24).toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }


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

        // Infer whether the device is moving or not based on step count
        if (_previousStepCount != event.steps) {
          _isMoving = true;
        } else {
          _isMoving = false;
        }

        _previousStepCount = event.steps;
      });
    }, onError: (error) {
      print('Error: $error');
    }, onDone: () {
      print('Stream closed');
    }, cancelOnError: true);

    // Periodically check step count to infer whether the device is moving or not
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (_previousStepCount != _stepCount) {
        setState(() {
          _isMoving = true;
        });
      } else {
        setState(() {
          _isMoving = false;
        });
      }
      _previousStepCount = _stepCount;
    });
  }


  void _stopListening() {
    _streamSubscription.cancel();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
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
      _startTimer(); // Start the timer
    });
  }

  void _stopCounting() {
    setState(() {
      _isCounting = false;
      _currentStepCount = _stepCount - _initialStepCount;
      _stopTimer(); // Stop the timer
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
              'Device Status:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10),
            Icon(
              _isMoving ? Icons.directions_walk : Icons.accessibility,
              size: 50,
              color: _isMoving ? Colors.green : Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Total Step Count:',
            ),
            Text(
              '$_stepCount',
              style: Theme
                  .of(context)
                  .textTheme
                  .headline4,
            ),
            SizedBox(height: 20),
            Text(
              'Current Step Count:',
            ),
            Text(
              '$_currentStepCount',
              style: Theme
                  .of(context)
                  .textTheme
                  .headline4,
            ),
            SizedBox(height: 20),
            Text(
              'Sensor Status: $_sensorStatus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 20),
            if (_isCounting) timerWidget(),
            // Display the timer only when counting
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isCounting ? _stopCounting : _startCounting,
              icon: Icon(
                _isCounting ? Icons.stop : Icons.play_arrow,
                color: Colors.white,
              ),
              label: Text(
                _isCounting ? 'Stop Counting' : 'Start Counting',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: _isCounting ? Colors.red : Colors.blue,
              ),
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