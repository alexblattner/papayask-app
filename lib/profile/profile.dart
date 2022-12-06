import 'package:flutter/material.dart';
import 'package:papayask_app/shared/cloudinary_image.dart';
import 'package:papayask_app/shared/flag.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/theme/colors.dart';
import 'package:papayask_app/models/user.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? profileUser;

  @override
  void didChangeDependencies() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final profileId = args['profileId'];
    if (profileId == auth.authUser!.id) {
      profileUser = auth.authUser;
    } else {
      //TODO: fetch user from server
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: profileUser == null
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primaryColor,
              ),
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CloudinaryImage(src: profileUser!.picture!),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profileUser!.name,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Flag(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profileUser!.title,
                      style: const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
