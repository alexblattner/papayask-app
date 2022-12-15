import 'package:flutter/material.dart';

import 'package:papayask_app/theme/colors.dart';

class Badge extends StatelessWidget {
  final String text;
  final bool isRemovable;
  final Function? onRemove;
  const Badge({
    super.key,
    required this.text,
    this.isRemovable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          if (isRemovable)
            const SizedBox(
              width: 8,
            ),
          if (isRemovable && onRemove != null)
            GestureDetector(
              onTap: () => onRemove!(text),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
