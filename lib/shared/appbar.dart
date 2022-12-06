import 'package:flutter/material.dart';

import 'package:papayask_app/shared/full_logo.dart';
import 'package:papayask_app/theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.extended = true});
  final bool extended;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const FullLogo(),
      centerTitle: true,
      leading: extended
          ? IconButton(
              icon: const Icon(Icons.menu),
              color: Theme.of(context).colorScheme.primaryColor,
              onPressed: Scaffold.of(context).openDrawer,
            )
          : null,
    );
  }
}
