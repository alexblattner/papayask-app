import 'package:flutter/material.dart';

import 'package:papayask_app/auth/screens/login_screen.dart';
import 'package:papayask_app/auth/screens/signup_screen.dart';
import 'package:papayask_app/shared/full_logo.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { signup, login }

class _AuthScreenState extends State<AuthScreen> {
  AuthMode mode = AuthMode.login;
  void changeMode(AuthMode mode) {
    setState(() {
      this.mode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FullLogo(),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: mode == AuthMode.login
            ? LoginScreen(
                changeMode: changeMode,
              )
            : SignupScreen(
                changeMode: changeMode,
              ),
      ),
    );
  }
}
