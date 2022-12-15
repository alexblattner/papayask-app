import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/profile/update_profile.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/shared/badge.dart';
import 'package:papayask_app/shared/cloudinary_image.dart';
import 'package:papayask_app/shared/flag.dart';
import 'package:papayask_app/utils/format_date.dart';
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
  bool isOwnProfile = false;

  @override
  void didChangeDependencies() {
    final auth = Provider.of<AuthService>(context);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final profileId = args['profileId'];
    if (profileId == auth.authUser!.id) {
      profileUser = auth.authUser;
      isOwnProfile = true;
    } else {
      //TODO: fetch user from server
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(profileUser?.name ?? ''),
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
                  children: [
                    CloudinaryImage(
                      src: profileUser!.picture!,
                      size: 150,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profileUser!.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Flag(country: profileUser?.country ?? ''),
                      ],
                    ),
                    Text(
                      profileUser!.title,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildBio(context),
                    _buildEducation(context),
                    _buildExperience(context),
                    _buildSkills(context),
                    _buildLanguages(context),
                  ],
                ),
              ),
            ),
    );
  }

  Container _buildBio(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bio:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isOwnProfile)
                IconButton(
                  icon: AppIcon(
                    src: 'pencil_fill',
                    size: 22,
                    color: Theme.of(context).colorScheme.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      ProfileUpdatePage.routeName,
                      arguments: {
                        'currentScreen': CurrentScreen.bio,
                      },
                    );
                  },
                ),
            ],
          ),
          Text(
            profileUser!.bio,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Container _buildSkills(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skills:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.justify,
              ),
              if (isOwnProfile)
                IconButton(
                  icon: AppIcon(
                    src: 'pencil_fill',
                    size: 22,
                    color: Theme.of(context).colorScheme.primaryColor,
                  ),
                  onPressed: () {},
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in profileUser!.skills)
                Badge(text: skill['name'])
            ],
          ),
        ],
      ),
    );
  }

  Container _buildLanguages(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Languages:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.justify,
              ),
              if (isOwnProfile)
                IconButton(
                  icon: AppIcon(
                    src: 'pencil_fill',
                    size: 22,
                    color: Theme.of(context).colorScheme.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      ProfileUpdatePage.routeName,
                      arguments: {
                        'currentScreen': CurrentScreen.language,
                      },
                    );
                  },
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final language in profileUser!.languages)
                Badge(text: language)
            ],
          ),
        ],
      ),
    );
  }

  Container _buildEducation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Education:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.justify,
              ),
              if (isOwnProfile)
                IconButton(
                  icon: AppIcon(
                    src: 'plus',
                    size: 22,
                    color: Theme.of(context).colorScheme.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      ProfileUpdatePage.routeName,
                      arguments: {
                        'currentScreen': CurrentScreen.education,
                      },
                    );
                  },
                ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          for (final education in profileUser!.education)
            Stack(
              children: [
                Card(
                  child: ListTile(
                    isThreeLine: true,
                    leading: const AppIcon(
                      src: 'study',
                      size: 48,
                    ),
                    title: Text(education.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(education.university['name']),
                        Row(
                          children: [
                            Text(formatDate(education.startDate)),
                            const Text(' - '),
                            Text(formatDate(education.endDate)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 15,
                  child: GestureDetector(
                    child: AppIcon(
                      src: 'pencil_fill',
                      size: 22,
                      color: Theme.of(context).colorScheme.primaryColor,
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ProfileUpdatePage.routeName,
                        arguments: {
                          'currentScreen': CurrentScreen.education,
                          'oldEducation': education,
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Container _buildExperience(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Experience:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.justify,
              ),
              if (isOwnProfile)
                IconButton(
                  icon: AppIcon(
                    src: 'plus',
                    size: 22,
                    color: Theme.of(context).colorScheme.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      ProfileUpdatePage.routeName,
                      arguments: {
                        'currentScreen': CurrentScreen.experience,
                      },
                    );
                  },
                ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          for (final experience in profileUser!.experience)
            Stack(
              children: [
                Card(
                  child: ListTile(
                    isThreeLine: true,
                    leading: const AppIcon(
                      src: 'work',
                      size: 48,
                    ),
                    title: Text(experience.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(experience.company.name),
                        Row(
                          children: [
                            Text(formatDate(experience.startDate)),
                            const Text(' - '),
                            Text(formatDate(experience.endDate)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 15,
                  child: GestureDetector(
                    child: AppIcon(
                      src: 'pencil_fill',
                      size: 22,
                      color: Theme.of(context).colorScheme.primaryColor,
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ProfileUpdatePage.routeName,
                        arguments: {
                          'currentScreen': CurrentScreen.experience,
                          'oldExperience': experience,
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
