import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:papayask_app/auth/screens/auth_screen.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/main/main_screen.dart';
import 'package:papayask_app/splash_screen.dart';
import 'package:papayask_app/theme/colors.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ThemeData theme = ThemeData();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthService(),
          ),
        ],
        child: Consumer<AuthService>(
          builder: (context, auth, _) {
            return MaterialApp(
              theme: ThemeData(
                primarySwatch: AppColors.primaryColor,
                colorScheme: theme.colorScheme.copyWith(
                  secondary: AppColors.secondaryColor,
                ),
                fontFamily: 'RedHatDisplay',
              ),
              home: StreamBuilder(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SplashScreen();
                  }
                  if (snapshot.hasData) {
                    return const MainScreen();
                  }
                  return const AuthScreen();
                },
                stream: auth.authStateChanges,
              ),
              routes: {
                AuthScreen.routeName: (context) => const AuthScreen(),
                MainScreen.routeName: (context) => const MainScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
