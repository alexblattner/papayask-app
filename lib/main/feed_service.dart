import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';

import 'package:papayask_app/models/user.dart' as user_model;

class FeedService with ChangeNotifier {
  final List<user_model.User> _users = [];
  final _auth = FirebaseAuth.instance;

  List<user_model.User> get users => [..._users];

  Future<void> fetchUsers() async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('${FlutterConfig.get('API_URL')}/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final decodedData = jsonDecode(res.body) as List<dynamic>;
        final users =
            decodedData.map((e) => user_model.User.fromJson(e)).toList();
        _users.clear();
        _users.addAll(users);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}
