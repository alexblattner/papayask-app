import 'package:flutter/material.dart';

import 'package:papayask_app/theme/colors.dart';

class FormTitle extends StatelessWidget {
  final String title;
  final Color? color;
  const FormTitle({super.key, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.primaryColor,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
