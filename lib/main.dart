import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/utils/awesome_notifications_service.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'Papayask',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterConfig.loadEnvVariables();
  AwesomeNotificationsService.initialize();
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
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);

    super.initState();
  }

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
            create: (_) => QuestionsService(),
          ),
        ],
        child: Consumer<AuthService>(
          builder: (context, auth, _) {
            return MaterialApp(
              navigatorKey: MyApp.navigatorKey,
              home: const HomeController(),
              theme: appTheme(context),
              routes: {
                AuthScreen.routeName: (context) => const AuthScreen(),
                MainScreen.routeName: (context) => const MainScreen(),
                ProfileScreen.routeName: (context) => const ProfileScreen(),
                SetupScreen.routeName: (context) => const SetupScreen(),
                QuestionsScreen.routeName: (context) => const QuestionsScreen(),
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

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        QuestionsScreen.routeName,
        (route) =>
            (route.settings.name != QuestionsScreen.routeName) || route.isFirst,
        arguments: receivedAction);
  }
}
