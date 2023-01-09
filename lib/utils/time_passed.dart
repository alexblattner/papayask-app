import 'package:papayask_app/models/question.dart';

bool isTimePassed(Question question) {
  return question.endAnswerTime.isBefore(DateTime.now());
}
