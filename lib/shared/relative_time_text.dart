import 'package:flutter/material.dart';

class RelativeTimeText extends StatelessWidget {
  final DateTime dateTime;

  const RelativeTimeText({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Text(getRelativeTime());
  }

  String getRelativeTime() {
    final now = DateTime.now();
    final duration = now.difference(dateTime);
    if (duration.inDays > 7) {
      return '${duration.inDays ~/ 7} weeks ago';
    } else if (duration.inDays > 1) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 1) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 1) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}
