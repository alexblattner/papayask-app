import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/main/all_advisor_screen.dart';
import 'package:papayask_app/main/advisor_service.dart';
import 'package:papayask_app/favorites/favorites_screen.dart';
import 'package:papayask_app/notifications/notifications_screen.dart';
import 'package:papayask_app/profile/profile_serivce.dart';
import 'package:papayask_app/questions/question_screen.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/theme/app_theme.dart';
import 'package:papayask_app/questions/questions_screen.dart';
import 'package:papayask_app/profile/setup/setup_screen.dart';
import 'package:papayask_app/profile/update_profile.dart';
import 'package:papayask_app/auth/screens/auth_screen.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/firebase_options.dart';
import 'package:papayask_app/main/main_screen.dart';
import 'package:papayask_app/profile/profile.dart';
import 'package:papayask_app/splash_screen.dart';
import 'package:papayask_app/shared/scaffold_key.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'Papayask',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FlutterConfig.loadEnvVariables();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          ChangeNotifierProvider(
            create: (_) => ProfileService(),
          ),
          ChangeNotifierProvider(
            create: (_) => AdvisorService(),
          ),
          ChangeNotifierProvider(
            create: (_) => QuestionsService(),
          ),
        ],
        child: Consumer<AuthService>(
          builder: (context, auth, _) {
            return MaterialApp(
              scaffoldMessengerKey: scaffoldKey,
              navigatorKey: MyApp.navigatorKey,
              home: const HomeController(),
              theme: appTheme(context),
              routes: {
                AuthScreen.routeName: (context) => const AuthScreen(),
                MainScreen.routeName: (context) => const MainScreen(),
                ProfileScreen.routeName: (context) => const ProfileScreen(),
                SetupScreen.routeName: (context) => const SetupScreen(),
                AllAdvisorScreen.routeName: (context) =>
                    const AllAdvisorScreen(),
                QuestionsScreen.routeName: (context) => const QuestionsScreen(),
                QuestionScreen.routeName: (context) => const QuestionScreen(),
                FavoritesScreen.routeName: (context) => const FavoritesScreen(),
                NotificationsScreen.routeName: (context) =>
                    const NotificationsScreen(),
                ProfileUpdatePage.routeName: (context) =>
                    const ProfileUpdatePage(),
              },
            );
          },
        ),
      ),
    );
  }
}

class HomeController extends StatefulWidget {
  const HomeController({super.key});

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  late Stream<User?> stream;

  @override
  void initState() {
     final auth = Provider.of<AuthService>(context, listen: false);

    stream = auth.authStateChanges;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.data == null) {
          return const AuthScreen();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          final bool signedIn = auth.authUser?.id != null;
          return signedIn ? const MainScreen() : const SplashScreen();
        }
        return const SplashScreen();
      },
    );
  }
}
