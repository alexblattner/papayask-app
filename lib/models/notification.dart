import 'package:papayask_app/models/question.dart';
import 'package:papayask_app/models/user.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final User sender;
  final DateTime createdAt;
  final Question? question;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.sender,
    required this.createdAt,
    required this.isRead,
    this.question,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'],
      title: json['title'],
      body: json['body'],
      sender: User.fromJson(json['sender']),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'],
      question:
          json['question'] != null ? Question.fromJson(json['question']) : null,
    );
  }
}
