import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:papayask_app/shared/logo.dart';

class CloudinaryImage extends StatelessWidget {
  final String src;
  final double size;
  const CloudinaryImage({super.key, required this.src, this.size = 250});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Stack(
            children: [
              Positioned(
                top: size / 2 - 30,
                left: size / 2 - 30,
                child: const Logo(
                  size: 60,
                ),
              ),
              Image.network(
                  '${FlutterConfig.get('CLOUDINARY_URL')}/c_scale,w_${size.toInt()},h_${size.toInt()}/${FlutterConfig.get('ENV')}/$src'),
            ],
          ),
        ),
      ),
    );
  }
}
