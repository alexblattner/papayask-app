import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badge_lib;
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/questions/questions_service.dart';

import 'package:papayask_app/shared/full_logo.dart';
import 'package:papayask_app/theme/colors.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.extended = true, this.title});
  final bool extended;
  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final questionsProvider = Provider.of<QuestionsService>(context);
    final authProvider = Provider.of<AuthService>(context);
    return AppBar(
      title: title != null ? Text(title!) : const FullLogo(),
      centerTitle: true,
      leading: extended
          ? GestureDetector(
              onTap: Scaffold.of(context).openDrawer,
              child: badge_lib.Badge(
                showBadge: questionsProvider.newQuestionsCount > 0 ||
                    authProvider.notificationsCount > 0,
                position: badge_lib.BadgePosition.topEnd(top: 10, end: 6),
                child: Icon(
                  Icons.menu,
                  color: Theme.of(context).colorScheme.primaryColor,
                ),
              ),
            )
          : null,
    );
  }
}
