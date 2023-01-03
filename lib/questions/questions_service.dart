import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';

import 'package:papayask_app/models/question.dart';

class QuestionsService with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final Map<String, List<Question>> _questions = {};

  int get newQuestionsCount {
    if (_questions['received'] == null) {
      return 0;
    }
    int count = _questions['received']!
        .where((element) => element.status['action'] == 'pending')
        .length;
    return count;
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
}
