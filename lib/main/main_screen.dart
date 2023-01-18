import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:papayask_app/main/users_carousel.dart';
import 'package:papayask_app/main/feed_service.dart';
import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/utils/sse.dart';
import 'package:papayask_app/utils/awesome_notifications_service.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/profile/become_advisor_modal.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/shared/app_drawer.dart';
import 'package:papayask_app/shared/appbar.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/home';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  var isLoading = false;
  var showModal = false;
  List<User> feedUsers = [];

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
          final message = {
            'body': '${data['object']['sender']['name']} sent you a question',
            'title': 'New Question',
            'id': data['object']['_id'],
          };
          AwesomeNotificationsService.showNotification(
            title: message['title'],
            body: message['body'],
            payload: message['id'],
          );
          await questionProvider.fetchQuestions();
        } else if (data['type'] == 'notification') {
          final message = {
            'body': data['object']['body'],
            'title': data['object']['title'],
            'id': data['object']['_id'],
          };
          AwesomeNotificationsService.showNotification(
            title: message['title'],
            body: message['body'],
            payload: message['id'],
          );
          await authProvider.getNotifications();
        }
      } else {
        await questionProvider.fetchQuestions();
        await authProvider.getNotifications();
      }
    });
  }

  Future<void> setFeedUsers() async {
    final feedService = Provider.of<FeedService>(context, listen: false);
    await feedService.fetchUsers();

    setState(() {
      feedUsers = feedService.users;
    });
  }

  @override
  void initState() {
    connectToEventSource();
    setFeedUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context);
    final user = authProvider.authUser!;
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
                        'Users',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      )
                    ],
                  ),
                  if (feedUsers.isNotEmpty)
                    SizedBox(
                      height: 350,
                      child: UsersCarousel(
                        users: feedUsers.sublist(
                            0, feedUsers.length > 9 ? 9 : feedUsers.length),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
