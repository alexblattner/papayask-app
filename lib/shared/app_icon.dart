import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  final String src;
  final int size;
  final Color color;
  const AppIcon({
    Key? key,
    required this.src,
    this.size = 40,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
   String picture = 'assets/icons/$src.svg';
    final Widget svg = SvgPicture.asset(
      picture,
      semanticsLabel: 'app logo',
      width: size.toDouble(),
      height: size.toDouble(),
      color: color,
    );
    return Container(
      child: svg,
    );
  }
}
