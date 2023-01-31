import 'package:flutter/material.dart';
import 'package:papayask_app/models/notification.dart';
import 'package:papayask_app/questions/question_screen.dart';
import 'package:papayask_app/shared/profile_picture.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/utils/relative_time_text.dart';
import 'package:papayask_app/theme/colors.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  void readNotifications() {
    final authService = Provider.of<AuthService>(context, listen: false);
    List<AppNotification> nots = [];
    for (var not in authService.notifications) {
      if (not.question == null && !not.isRead) {
        nots.add(not);
      }
    }
    authService.readNotifications(nots);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            readNotifications();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: authService.getNotifications,
        child: ListView.separated(
          separatorBuilder: (context, index) => Container(
            width: double.infinity,
            height: 0.5,
            color: Theme.of(context).colorScheme.primaryColor.withOpacity(0.5),
          ),
          itemCount: authService.notifications.length,
          itemBuilder: (context, index) {
            final notification = authService.notifications[index];
            return ListTile(
              onTap: () {
                if (notification.question != null) {
                  if (!notification.isRead) {
                    authService.readNotifications([notification]);
                  }
                  Navigator.of(context).pushNamed(
                    QuestionScreen.routeName,
                    arguments: {'question' : notification.question},
                  );
                }
              },
              tileColor: !notification.isRead
                  ? Theme.of(context).colorScheme.primaryColor.withOpacity(0.2)
                  : null,
              leading: ProfilePicture(
                src: notification.sender.picture ?? '',
                size: 50,
              ),
              isThreeLine: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(notification.title),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.body,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  RelativeTimeText(dateTime: notification.createdAt),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
