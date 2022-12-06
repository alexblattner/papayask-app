import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/auth/screens/auth_screen.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/shared/app_drawer.dart';
import 'package:papayask_app/shared/appbar.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const AppDrawer(),
      body: !authProvider.isVerified
          ? Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 280,
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'We have sent you an email  to verify your account. Please check your email and click on the link to verify your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        authService.reload();
                        authService.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: ElevatedButton(
                  onPressed: () {
                    authService.logout();
                    Navigator.of(context)
                        .pushReplacementNamed(AuthScreen.routeName);
                  },
                  child: const Text('logout')),
            ),
    );
  }
}
