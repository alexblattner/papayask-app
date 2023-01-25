import 'package:flutter/material.dart';
import 'package:papayask_app/theme/colors.dart';

class FiltersDivider extends StatelessWidget {
  const FiltersDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryColor.withOpacity(0.1),
    );
  }
}
