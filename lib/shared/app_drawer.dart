import 'package:flutter/material.dart';

import 'package:papayask_app/auth/auth_service.dart';

import 'package:papayask_app/profile/profile.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/shared/full_logo.dart';
import 'package:papayask_app/theme/colors.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
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
                    leading: AppIcon(
                      src: 'user',
                      size: 24,
                      color: Theme.of(context).colorScheme.primaryColor,
                    ),
                    title: const Text(
                      'Profile',
                      style: TextStyle(fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(
                        ProfileScreen.routeName,
                        arguments: auth.authUser!.id,
                      );
                    },
                  ),
                  ListTile(
                    leading: AppIcon(
                      src: 'send',
                      size: 24,
                      color: Theme.of(context).colorScheme.primaryColor,
                    ),
                    title: const Text(
                      'Requests',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: AppIcon(
                      src: 'bell',
                      size: 24,
                      color: Theme.of(context).colorScheme.primaryColor,
                    ),
                    title: const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: AppIcon(
                      src: 'heart',
                      size: 24,
                      color: Theme.of(context).colorScheme.primaryColor,
                    ),
                    title: const Text(
                      'Favorites',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
