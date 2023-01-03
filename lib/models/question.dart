import 'package:papayask_app/models/user.dart';

class Question {
  String id;
  User sender;
  User receiver;
  String description;
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, dynamic> status;

  Question({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    Question question = Question(
      id: json['_id'],
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      status: Map<String, dynamic>.from(json['status']),
    );
    return question;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'receiver': receiver,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
    };
  }
}
