import 'package:flutter/material.dart';

import 'package:papayask_app/theme/colors.dart';

class FormDivider extends StatelessWidget {
  const FormDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.primaryColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Theme.of(context).colorScheme.primaryColor,
          ),
        ),
      ],
    );
  }
}
