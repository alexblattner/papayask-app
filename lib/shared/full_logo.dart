import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:papayask_app/theme/colors.dart';

class FullLogo extends StatelessWidget {
  const FullLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/icons/logo.svg', width: 30, height: 30),
        const SizedBox(width: 10),
        Text(
          'Papayask',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primaryColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
