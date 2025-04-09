import 'package:flutter/material.dart';
import 'dart:async';

// Function to show a confirmation dialog before sending a crash alert
// with a 10-second timer that automatically confirms if no action is taken
Future<bool> showCrashConfirmationTimerDialog(BuildContext context) async {
  Completer<bool> completer = Completer<bool>();

  // For whole-second countdown display
  int remainingSeconds = 10;

  // For smooth animation (updates more frequently)
  double remainingTime = 10.0;
  const updateInterval = 100; // milliseconds (10 updates per second)
  final decrementPerUpdate = 0.1; // 10 updates per second × 0.1 = 1 second reduction

  // Create a stream controller for smooth UI updates
  final streamController = StreamController<_TimerData>();
  streamController.add(_TimerData(remainingSeconds, remainingTime / 10));

  // Start the timer
  Timer? timer = Timer.periodic(Duration(milliseconds: updateInterval), (Timer t) {
    remainingTime -= decrementPerUpdate;

    // Update the whole-second count when we cross a second boundary
    final newWholeSeconds = remainingTime.ceil();
    if (newWholeSeconds < remainingSeconds) {
      remainingSeconds = newWholeSeconds;
    }

    // Update the UI
    if (!streamController.isClosed) {
      streamController.add(_TimerData(remainingSeconds, remainingTime / 10));
    }

    // When time is up, auto-confirm and close dialog
    if (remainingTime <= 0) {
      t.cancel();
      streamController.close();
      if (!completer.isCompleted) {
        Navigator.of(context).pop();
        completer.complete(true); // Auto-confirm
      }
    }
  });

  // Show the dialog
  showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return WillPopScope(
        // Prevent back button from dismissing without handling the timer
        onWillPop: () async {
          timer?.cancel();
          streamController.close();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
          return true;
        },
        child: StreamBuilder<_TimerData>(
          stream: streamController.stream,
          initialData: _TimerData(remainingSeconds, 1.0),
          builder: (context, snapshot) {
            final data = snapshot.data!;

            // Get color based on the remaining seconds (three distinct colors)
            final Color timerColor = _getTimerColor(data.seconds);

            return AlertDialog(
              title: const Text("Confirm Crash Alert"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Are you sure you want to send a crash alert? "
                      "Your emergency contacts will be notified of your crash."),
                  const SizedBox(height: 20),
                  // Timer display - whole seconds only
                  Text(
                    "Auto-sending in ${data.seconds} seconds",
                    style: TextStyle(
                      color: timerColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Smooth progress indicator with discrete colors
                  LinearProgressIndicator(
                    value: data.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    streamController.close();
                    Navigator.of(context).pop();
                    if (!completer.isCompleted) {
                      completer.complete(false); // User canceled
                    }
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    streamController.close();
                    Navigator.of(context).pop();
                    if (!completer.isCompleted) {
                      completer.complete(true); // User confirmed
                    }
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Send", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ),
      );
    },
  );

  // Clean up if dialog is dismissed another way
  Timer(const Duration(milliseconds: 100), () {
    if (!context.mounted && !completer.isCompleted) {
      timer?.cancel();
      streamController.close();
      completer.complete(false);
    }
  });

  return completer.future;
}

// Get the appropriate color based on the remaining seconds
Color _getTimerColor(int seconds) {
  if (seconds >= 8) {
    return Colors.orange; // Orange: 10-8 seconds
  } else if (seconds >= 4) {
    return Colors.orange.shade700; // Orange-red: 7-4 seconds
  } else {
    return Colors.red; // Red: 3-0 seconds
  }
}

// Helper class to bundle timer data
class _TimerData {
  final int seconds;    // Whole seconds for display
  final double progress; // Progress value (0.0 to 1.0)

  _TimerData(this.seconds, this.progress);
}