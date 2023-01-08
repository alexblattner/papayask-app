import 'package:papayask_app/models/question.dart';
import 'package:papayask_app/models/user.dart';

bool isTimePassed(Question question, User user) {
  return question.createdAt
      .add(Duration(
          days: user.requestSettings!['time_limit']['days'],
          hours: user.requestSettings!['time_limit']['hours']))
      .isBefore(DateTime.now());
}