import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter/material.dart';

import 'package:papayask_app/shared/app_icon.dart';

class CompanyLogo extends StatefulWidget {
  final String? logo;
  const CompanyLogo({super.key, this.logo});

  @override
  State<CompanyLogo> createState() => _CompanyLogoState();
}

class _CompanyLogoState extends State<CompanyLogo> {
  String? imageUrl;

  @override
  void initState() {
    if (widget.logo != null && widget.logo != '') {
      var cldImg = CloudinaryImage(
        '${FlutterConfig.get('CLOUDINARY_URL')}/${FlutterConfig.get('ENV')}/${widget.logo}',
      );
      imageUrl =
          cldImg.transform().width(48).height(48).crop('fill').generate();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: imageUrl == null
          ? const AppIcon(
              src: 'work',
              size: 48,
              color: Colors.black,
            )
          : Image.network(
              imageUrl!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
    );
  }
}
