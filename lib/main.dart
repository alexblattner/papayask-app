import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/auth/screens/auth_screen.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/firebase_options.dart';
import 'package:papayask_app/main/main_screen.dart';
import 'package:papayask_app/profile/profile.dart';
import 'package:papayask_app/splash_screen.dart';
import 'package:papayask_app/theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterConfig.loadEnvVariables();
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
              home: const HomeController(),
              theme: ThemeData(
                appBarTheme: AppBarTheme(
                  elevation: 1,
                  color: Theme.of(context).colorScheme.secondaryColor_L1,
                  titleTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              routes: {
                AuthScreen.routeName: (context) => const AuthScreen(),
                MainScreen.routeName: (context) => const MainScreen(),
                ProfileScreen.routeName: (context) => const ProfileScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  const HomeController({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? const MainScreen() : const AuthScreen();
        }
        return const SplashScreen();
      },
    );
  }
}
