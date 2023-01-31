import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papayask_app/questions/question_screen.dart';
import 'package:papayask_app/utils/local_notifications_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:papayask_app/main/all_advisor_screen.dart';
import 'package:papayask_app/main/user_card_placeholder.dart';
import 'package:papayask_app/main/users_carousel.dart';
import 'package:papayask_app/main/advisor_service.dart';
import 'package:papayask_app/utils/sse.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/profile/become_advisor_modal.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/shared/app_drawer.dart';
import 'package:papayask_app/shared/appbar.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LocalNotificationsService.display(message);
}

class MainScreen extends StatefulWidget {
  static const routeName = '/home';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  var isLoading = false;
  var showModal = false;

  BecomeAdvisorModalType get _modalType {
    final authProvider = Provider.of<AuthService>(context, listen: false);
    if (authProvider.authUser!.advisorStatus == false &&
        authProvider.authUser!.progress >= 75) {
      return BecomeAdvisorModalType.info;
    } else if (authProvider.authUser!.advisorStatus == false &&
        authProvider.authUser!.progress < 75) {
      return BecomeAdvisorModalType.inComplete;
    } else if (authProvider.authUser!.advisorStatus == 'pending') {
      return BecomeAdvisorModalType.pendingApproval;
    } else {
      return BecomeAdvisorModalType.info;
    }
  }

  void onClose() {
    setState(() {
      showModal = false;
    });
  }

  Future<void> requestNotificationsPermision() async {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> connectToEventSource() async {
    final authProvider = Provider.of<AuthService>(context, listen: false);
    if (authProvider.authUser == null) return;
    final questionProvider =
        Provider.of<QuestionsService>(context, listen: false);
    if (authProvider.streamConnected) return;
    final stream = Sse.connect(
            uri: Uri.parse(
                "${FlutterConfig.get('API_URL')}/realtime-notifications/${authProvider.authUser!.id}"))
        .stream;
    authProvider.updateConnected(true);
    stream.listen((event) async {
      if (event.toString() != 'connection opened') {
        final data = jsonDecode(event.toString());
        if (data['type'] == 'question') {
          await questionProvider.fetchQuestions();
        } else if (data['type'] == 'notification') {
          await authProvider.getNotifications();
        }
      } else {
        await questionProvider.fetchQuestions();
        await authProvider.getNotifications();
      }
    });
  }

  Future<void> setFeedUsers() async {
    final feedService = Provider.of<AdvisorService>(context, listen: false);
    await feedService.fetchUsers();
  }

  @override
  void initState() {
    connectToEventSource();
    setFeedUsers();
    requestNotificationsPermision();
    LocalNotificationsService.initialize();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationsService.display(message);
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.pushNamed(
        context,
        QuestionScreen.routeName,
        arguments: {'questionId' : message.data['question']},
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context);
    final user = authProvider.authUser!;
    final feedUsers = Provider.of<AdvisorService>(context).users;
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const AppDrawer(),
      body: showModal
          ? BecomeAdvisorModal(
              type: _modalType,
              onClose: onClose,
              progress: user.progress,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.advisorStatus != 'approved')
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          showModal = true;
                        });
                      },
                      child: Text(
                        user.advisorStatus == 'pending'
                            ? 'Pending Approval'
                            : 'Become an Advisor',
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Advisors',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AllAdvisorScreen.routeName,
                          );
                        },
                        child: const Text('See all'),
                      )
                    ],
                  ),
                  if (feedUsers.isEmpty)
                    const SizedBox(
                      height: 300,
                      child: UserCardPlaceHolder(),
                    ),
                  if (feedUsers.isNotEmpty)
                    SizedBox(
                      height: 300,
                      child: UsersCarousel(
                        users: feedUsers.sublist(
                          0,
                          feedUsers.length > 9 ? 9 : feedUsers.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
