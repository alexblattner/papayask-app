import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:papayask_app/utils/sse.dart';
import 'package:papayask_app/utils/awesome_notifications_service.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/auth/screens/auth_screen.dart';
import 'package:papayask_app/profile/become_advisor_modal.dart';
import 'package:papayask_app/profile/setup/setup_screen.dart';
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
  final authService = AuthService();
  var isLoading = false;

  BecomeAdvisorModalType get _modalType {
    if (authService.authUser!.advisorStatus == false &&
        authService.authUser!.progress >= 75) {
      return BecomeAdvisorModalType.info;
    } else if (authService.authUser!.advisorStatus == false &&
        authService.authUser!.progress < 75) {
      return BecomeAdvisorModalType.inComplete;
    } else if (authService.authUser!.advisorStatus == 'pending') {
      return BecomeAdvisorModalType.pendingApproval;
    } else {
      return BecomeAdvisorModalType.info;
    }
  }

  void becomeAdvisor() {
    final authProvider = Provider.of<AuthService>(context, listen: false);
    showDialog(
      context: context,
      builder: ((context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: SizedBox(
                height: constraints.maxHeight * 0.4,
                width: constraints.maxWidth * 0.8,
                child: BecomeAdvisorModal(
                  progress: authProvider.authUser!.progress,
                  type: _modalType,
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (authService.authUser!.advisorStatus == 'pending' ||
                        (authService.authUser!.advisorStatus == false &&
                            authService.authUser!.progress < 75)) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(
                        SetupScreen.routeName,
                        arguments: {
                          'user': authProvider.authUser,
                          'isAdvisorSetup':
                              authService.authUser!.advisorStatus == 'pending'
                                  ? false
                                  : true,
                        },
                      );
                    } else if (authService.authUser!.advisorStatus == false &&
                        authService.authUser!.progress >= 75) {
                      setState(() {
                        isLoading = true;
                      });
                      final res = await authService.becomeAnAdvisor();
                      if (!mounted) return;
                      Navigator.pop(context);
                      if (res == 'done') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Application submitted successfully',
                              textAlign: TextAlign.center,
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Something went wrong',
                              textAlign: TextAlign.center,
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        authService.authUser!.advisorStatus == 'pending' ||
                                (authService.authUser!.advisorStatus == false &&
                                    authService.authUser!.progress < 75)
                            ? 'Edit profile'
                            : 'Become an advisor',
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 10,
                        ),
                      if (isLoading)
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
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
          await authService.getNotifications();
        }
      } else {
        await questionProvider.fetchQuestions();
        await authService.getNotifications();
      }
    });
  }

  @override
  void initState() {
    connectToEventSource();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context);
    final user = authProvider.authUser;
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user?.advisorStatus != 'approved')
                    OutlinedButton(
                      onPressed: () {
                        becomeAdvisor();
                      },
                      child: Text(
                        user?.advisorStatus == 'pending'
                            ? 'Pending Approval'
                            : 'Become an Advisor',
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      authService.logout();
                      Navigator.of(context)
                          .pushReplacementNamed(AuthScreen.routeName);
                    },
                    child: const Text('logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
