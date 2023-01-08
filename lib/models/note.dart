import 'package:papayask_app/models/user.dart';

class Note {
  String id;
  User user;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  String question;
  Map<String, dynamic>? coordinates;
  int? order;

  Note({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.question,
    this.coordinates,
    this.order,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    Note note = Note(
      id: json['_id'],
      user: User.fromJson(json['user']),
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      question: json['question'],
      coordinates: json['coordinates'],
      order: json['order'],
    );
    return note;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'question': question,
      'coordinates': coordinates,
      'order': order,
    };
  }
}
