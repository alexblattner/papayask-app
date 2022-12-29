import 'package:flutter/material.dart';
import 'package:papayask_app/shared/app_icon.dart';

class UniversityLogo extends StatefulWidget {
  final String? logo;
  const UniversityLogo({super.key, this.logo});

  @override
  State<UniversityLogo> createState() => _UniversityLogoState();
}

class _UniversityLogoState extends State<UniversityLogo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.logo == null
          ? const AppIcon(
              src: 'study',
              size: 48,
              color: Colors.black,
            )
          : Image.network(
              widget.logo!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
    );
  }
}
