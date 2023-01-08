import 'package:papayask_app/models/note.dart';
import 'package:papayask_app/models/user.dart';

class Question {
  String id;
  User sender;
  User receiver;
  String description;
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, dynamic> status;
  List<Note> notes;

  Question({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.notes,
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
      notes: (json['notes'] as List)
          .map((e) => Note.fromJson(e))
          .toList()
          .cast<Note>(),
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
