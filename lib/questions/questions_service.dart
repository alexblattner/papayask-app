import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';
import 'package:papayask_app/models/note.dart';

import 'package:papayask_app/models/question.dart';
import 'package:papayask_app/models/user.dart' as user_model;

class QuestionsService with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final Map<String, List<Question>> _questions = {};
  int newQuestionsCount = 0;

  void updateNewQuestionsCount(int count) {
    newQuestionsCount = count;
    notifyListeners();
  }

  Future<void> fetchQuestions() async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return;
    }
    try {
      final res = await http.get(
        Uri.parse('${FlutterConfig.get('API_URL')}/questions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        _questions.clear();
        data.forEach((key, value) {
          _questions[key] =
              (value as List).map((e) => Question.fromJson(e)).toList();
        });
        sortQuestions();
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Map<String, List<Question>> get questions => _questions;

  void sortQuestions() {
    _questions['received']!.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    _questions['sent']!.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  Future<String> rejectQuestion(String questionId, String reason) async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return 'not logged in';
    }
    try {
      final res = await http.post(
        Uri.parse(
            '${FlutterConfig.get('API_URL')}/question/update-status/$questionId/'),
        body: {'reason': reason, 'action': 'rejected'},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        //replace question in list
        final index = _questions['received']!
            .indexWhere((element) => element.id == questionId);
        _questions['received']![index].status['action'] = 'rejected';
        _questions['received']![index].status['reason'] = reason;
        _questions['received']![index].status['donr'] = true;
        notifyListeners();
        return 'Success';
      }
      return 'Error';
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  Future<String> acceptQuestion(String questionId) async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return 'not logged in';
    }
    try {
      final res = await http.post(
        Uri.parse(
            '${FlutterConfig.get('API_URL')}/question/update-status/$questionId/'),
        body: {'action': 'accepted'},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        //replace question in list
        final index = _questions['received']!
            .indexWhere((element) => element.id == questionId);
        _questions['received']![index].status['action'] = 'accepted';
        notifyListeners();
        return 'Success';
      }
      return 'Error';
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  Future<String> addNote(
    String questionId,
    String content,
    user_model.User user,
  ) async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return 'not logged in';
    }

    Note newNote = Note(
      id: '',
      content: content,
      createdAt: DateTime.now(),
      user: user,
      updatedAt: DateTime.now(),
      question: questionId,
    );

    final index = _questions['received']!
        .indexWhere((element) => element.id == questionId);
    _questions['received']![index].notes.add(newNote);
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('${FlutterConfig.get('API_URL')}/note'),
        body: {'questionId': questionId, 'content': content},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        _questions['received']![index].notes.last.id =
            jsonDecode(res.body)['_id'];
        notifyListeners();
        return 'Success';
      }
      return 'Error';
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  Future<String> finishAnswer(
    String questionId,
    String content,
    user_model.User user,
  ) async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return 'not logged in';
    }
    if (content.isNotEmpty) {
      await addNote(questionId, content, user);
    }
    try {
      final res = await http.post(
        Uri.parse('${FlutterConfig.get('API_URL')}/question/finish'),
        body: {'questionId': questionId},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final index = _questions['received']!
            .indexWhere((element) => element.id == questionId);
        _questions['received']![index].status['done'] = true;
        notifyListeners();
        return 'Success';
      }
      return 'Error';
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  Future<String> deleteNote(Note note) async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return 'not logged in';
    }

    try {
      final res = await http.delete(
          Uri.parse('${FlutterConfig.get('API_URL')}/note/${note.id}'),
          headers: {
            'Authorization': 'Bearer $token',
          });
      if (res.statusCode == 200) {
        final index = _questions['received']!
            .indexWhere((element) => element.id == note.question);
        _questions['received']![index].notes.remove(note);
        notifyListeners();
        return 'Success';
      }
      return 'Error';
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  Future<String> updateNote(
    Note note,
    String content,
  ) async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return 'not logged in';
    }

    try {
      final res = await http.patch(
        Uri.parse('${FlutterConfig.get('API_URL')}/note'),
        body: {'id': note.id, 'content': content},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final index = _questions['received']!
            .indexWhere((element) => element.id == note.question);
        _questions['received']![index]
            .notes
            .firstWhere((element) => element.id == note.id)
            .content = content;
        notifyListeners();
        return 'Success';
      }
      return 'Error';
    } catch (e) {
      print(e);
      return 'Error';
    }
  }
}
