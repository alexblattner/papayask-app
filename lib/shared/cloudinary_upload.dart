import 'dart:io';

import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:image_picker/image_picker.dart';

import 'package:papayask_app/theme/colors.dart';
import 'package:papayask_app/shared/app_icon.dart';

class CloudinaryUploadWidget extends StatefulWidget {
  final String? currentImage;
  final Function updateImage;
  const CloudinaryUploadWidget(
      {super.key, this.currentImage, required this.updateImage});

  @override
  State<CloudinaryUploadWidget> createState() => _CloudinaryUploadWidgetState();
}

class _CloudinaryUploadWidgetState extends State<CloudinaryUploadWidget> {
  String? imageUrl;
  File? imageFile;
  double progress = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    if (widget.currentImage != null && widget.currentImage != '') {
      var cldImg = CloudinaryImage(
        '${FlutterConfig.get('CLOUDINARY_URL')}/${FlutterConfig.get('ENV')}/${widget.currentImage}',
      );
      imageUrl =
          cldImg.transform().width(250).height(250).crop('fill').generate();
    }
    super.initState();
  }

  Future<void> uploadToCloudinary() async {
    setState(() {
      progress = 0;
    });
    final preset = FlutterConfig.get('ENV') == 'development'
        ? 'development'
        : 'production';

    final cloudinary = Cloudinary.full(
      apiKey: FlutterConfig.get('CLOUDINARY_KEY'),
      apiSecret: FlutterConfig.get('CLOUDINARY_SECRET'),
      cloudName: 'snipcritics',
    );

    final response = await cloudinary.uploadResource(
      CloudinaryUploadResource(
        uploadPreset: preset,
        filePath: imageFile!.path,
        folder: preset,
        fileBytes: File(imageFile!.path).readAsBytesSync(),
        resourceType: CloudinaryResourceType.image,
        progressCallback: (count, total) {
          setState(() {
            progress = (count / total);
          });
        },
      ),
    );
    if (response.isSuccessful) {
      widget.updateImage(response.publicId!.replaceFirst('$preset/', ''));
    }
  }

  pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      uploadToCloudinary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              child: imageFile != null
                  ? Image.file(
                      imageFile!,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : imageUrl == null
                      ? Center(
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.cloud_upload,
                                  color: Colors.grey,
                                  size: 52,
                                ),
                                Text(
                                  'Upload Image',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Image.network(
                          imageUrl!,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
            ),
            if (progress > 0 && progress < 1)
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.4),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (imageFile != null || imageUrl != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imageFile = null;
                      imageUrl = null;
                    });
                    widget.updateImage('');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryColor
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const AppIcon(
                      src: 'delete',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (progress == 0)
          const SizedBox(
            height: 30,
          ),
        if (progress == 1)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: const Text(
              'Upload Complete',
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
              ),
            ),
          ),
        if (progress > 0 && progress < 1)
          Text(
            'Uploading... (${(progress * 100).toInt()}%)',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        if (progress > 0 && progress < 1)
          Container(
            width: 250,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: LinearProgressIndicator(
              value: progress,
            ),
          ),
      ],
    );
  }
}
