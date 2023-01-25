import 'package:badges/badges.dart' as badge_lib;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/auth/screens/auth_screen.dart';
import 'package:papayask_app/favorites/favorites_screen.dart';
import 'package:papayask_app/notifications/notifications_screen.dart';
import 'package:papayask_app/main/main_screen.dart';
import 'package:papayask_app/questions/questions_screen.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/profile/profile.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/shared/full_logo.dart';
import 'package:papayask_app/theme/colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Color textColor(String route, BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == route || (currentRoute == '/home' && route == '/')) {
      return Theme.of(context).colorScheme.primaryColor;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final questionsProvider = Provider.of<QuestionsService>(context);
    int newQuestions = questionsProvider.newQuestionsCount;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 70,
              child: DrawerHeader(
                child: FullLogo(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.home_outlined,
                        size: 28,
                        color: Theme.of(context).colorScheme.primaryColor,
                      ),
                      title: Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor('/', context),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          MainScreen.routeName,
                        );
                      },
                    ),
                    ListTile(
                      leading: AppIcon(
                        src: 'user',
                        size: 24,
                        color: Theme.of(context).colorScheme.primaryColor,
                      ),
                      title: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor('/profile', context),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          ProfileScreen.routeName,
                          arguments: {'profileId': auth.authUser!.id},
                        );
                      },
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          QuestionsScreen.routeName,
                        );
                      },
                      leading: badge_lib.Badge(
                        position: badge_lib.BadgePosition.topEnd(
                          top: -15,
                          end: -10,
                        ),
                        badgeContent: Text(
                          newQuestions.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        showBadge: newQuestions > 0,
                        child: AppIcon(
                          src: 'send',
                          size: 24,
                          color: Theme.of(context).colorScheme.primaryColor,
                        ),
                      ),
                      title: Text(
                        'Questions',
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor('/questions', context),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: badge_lib.Badge(
                        position: badge_lib.BadgePosition.topEnd(
                          top: -15,
                          end: -10,
                        ),
                        badgeContent: Text(
                          auth.notificationsCount.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        showBadge: auth.notificationsCount > 0,
                        child: AppIcon(
                          src: 'bell',
                          size: 24,
                          color: Theme.of(context).colorScheme.primaryColor,
                        ),
                      ),
                      title: const Text(
                        'Notifications',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          NotificationsScreen.routeName,
                        );
                      },
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          FavoritesScreen.routeName,
                        );
                      },
                      leading: AppIcon(
                        src: 'heart',
                        size: 24,
                        color: Theme.of(context).colorScheme.primaryColor,
                      ),
                      title: Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor('/favorites', context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                auth.logout();
                Navigator.of(context).pushReplacementNamed(
                  AuthScreen.routeName,
                );
              },
              child: const Text('logout'),
            ),
          ],
        ),
      ),
    );
  }
}
