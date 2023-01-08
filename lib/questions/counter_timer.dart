import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime startTime;
  final int days;
  final int hours;

  const CountdownTimer({
    super.key,
    required this.startTime,
    required this.days,
    required this.hours,
  });

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer> {
  Timer _timer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String formatedDays(int days) {
    if (days == 1) {
      return '1 day';
    }
    if (days > 1) {
      return '$days days';
    }
    return '';
  }

  String formatedHours(int hours) {
    if (hours == 1) {
      return '1 hour';
    }
    if (hours > 1) {
      return '$hours hours';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final endTime =
        widget.startTime.add(Duration(days: widget.days, hours: widget.hours));
    final duration = endTime.difference(now);
    if (duration.isNegative) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            'You can no longer work on this question',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      );
    }
    final days = duration.inDays;
    final hours = duration.inHours - days * 24;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.access_time,
        ),
        const SizedBox(
          width: 4,
        ),
        if (days > 0 || hours > 0)
          Text(
            '${formatedDays(days)} ${days > 0 ? 'and' : ''} ${formatedHours(hours)} remaining',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (days == 0 && hours == 0)
          const Text(
            'Less than an hour remaining',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
