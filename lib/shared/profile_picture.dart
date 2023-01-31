import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

class ProfilePicture extends StatelessWidget {
  final String src;
  final double size;
  final bool isCircle;
  const ProfilePicture(
      {super.key, required this.src, this.size = 250, this.isCircle = false});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCircle ? size / 2 : 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: src == ''
              ? Image.asset(
                  'assets/images/default.png',
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Image.asset(
                    'assets/images/default.png',
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/default.png',
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  ),
                  imageUrl: src.contains('https:')
                      ? src
                      : '${FlutterConfig.get('CLOUDINARY_URL')}/c_fill,w_${size.toInt()},h_${size.toInt()}/${FlutterConfig.get('ENV')}/$src',
                ),
        ),
      ),
    );
  }
}
