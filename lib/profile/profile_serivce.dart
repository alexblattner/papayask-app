import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';

import 'package:papayask_app/models/user.dart';

class ProfileService with ChangeNotifier {
  User? _profileUser;

  User? get profileUser => _profileUser;
  Future<void> getProfileUser(String userId) async {
    if (_profileUser?.id == userId) {
      return;
    }
    final response = await http.get(
      Uri.parse(
        '${FlutterConfig.get('API_URL')}/user/$userId',
      ),
    );
    if (response.statusCode == 200) {
      _profileUser = User.fromJson(json.decode(response.body));
      notifyListeners();
    } else {
      throw Exception('Failed to load user');
    }
  }

  void updateProfileUser(User user) {
    _profileUser = user;
    notifyListeners();
  }

  void resetProfileUser() {
    _profileUser = null;
    notifyListeners();
  }
}
