import 'package:flutter/material.dart';
import 'package:papayask_app/questions/creator.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badge_lib;

import 'package:papayask_app/profile/profile_serivce.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/shared/app_drawer.dart';
import 'package:papayask_app/profile/skill_badge.dart';
import 'package:papayask_app/shared/company_logo.dart';
import 'package:papayask_app/shared/university_logo.dart';
import 'package:papayask_app/profile/setup/setup_screen.dart';
import 'package:papayask_app/profile/update_profile.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/shared/badge.dart';
import 'package:papayask_app/shared/profile_picture.dart';
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
    if (profileUser != null) {
      return;
    }
    setProfileUser();

    super.didChangeDependencies();
  }

  Future<void> setProfileUser() async {
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final profileId = args['profileId'];
    if (profileId == auth.authUser!.id) {
      profileUser = auth.authUser;
      isOwnProfile = true;
    } else {
      await profileService.getProfileUser(profileId);
      setState(() {
        profileUser = profileService.profileUser;
      });
    }
  }

  bool get isUserFavorite {
    if (profileUser == null) {
      return false;
    }
    final authService = Provider.of<AuthService>(context, listen: false);
    for (final favorite in authService.authUser!.favorites['users']) {
      if (favorite.id == profileUser!.id) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final questionsProvider = Provider.of<QuestionsService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(profileUser?.name ?? ''),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: badge_lib.Badge(
              showBadge: questionsProvider.newQuestionsCount > 0,
              child: const Icon(Icons.menu),
            ),
            color: Theme.of(context).colorScheme.primaryColor,
            onPressed: Scaffold.of(context).openDrawer,
          );
        }),
        actions: [
          if (isOwnProfile)
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  SetupScreen.routeName,
                  arguments: {'user': profileUser, 'isAdvisorSetup': false},
                );
              },
              icon: AppIcon(
                src: 'pencil_fill',
                size: 18,
                color: Theme.of(context).colorScheme.primaryColor,
              ),
            ),
        ],
      ),
      drawer: const AppDrawer(),
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
                    const SizedBox(
                      height: 24,
                    ),
                    Stack(
                      children: [
                        ProfilePicture(
                          src: profileUser?.picture ?? '',
                          size: 150,
                        ),
                        if (isOwnProfile)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  ProfileUpdatePage.routeName,
                                  arguments: {
                                    'currentScreen':
                                        CurrentScreen.profilePicture,
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryColor
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const AppIcon(
                                  src: 'pencil_fill',
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
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
                    if (!isOwnProfile)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (profileUser!.advisorStatus == 'approved')
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  showGeneralDialog(
                                    context: context,
                                    pageBuilder: (_, __, ___) {
                                      return Creator(user: profileUser!);
                                    },
                                  );
                                },
                                icon: AppIcon(
                                  src: 'send',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          const SizedBox(
                            width: 16,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).colorScheme.primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Provider.of<AuthService>(context, listen: false)
                                    .favoriteUser(profileUser!);
                              },
                              icon: AppIcon(
                                src: isUserFavorite ? 'heart_fill' : 'heart',
                                color:
                                    Theme.of(context).colorScheme.primaryColor,
                                size: isUserFavorite ? 24 : 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),
                    _buildBio(context),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildEducation(context),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildExperience(context),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildSkills(context),
                    const SizedBox(
                      height: 16,
                    ),
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
                  icon: const AppIcon(
                    src: 'pencil_fill',
                    size: 22,
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
                  icon: const AppIcon(
                    src: 'pencil_fill',
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      ProfileUpdatePage.routeName,
                      arguments: {
                        'currentScreen': CurrentScreen.skills,
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
              for (final skill in profileUser!.skills) SkillBadge(skill: skill),
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
                  icon: const AppIcon(
                    src: 'pencil_fill',
                    size: 22,
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
                  icon: const AppIcon(
                    src: 'plus',
                    size: 22,
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
                    onTap: isOwnProfile
                        ? () {
                            Navigator.of(context).pushNamed(
                              ProfileUpdatePage.routeName,
                              arguments: {
                                'currentScreen': CurrentScreen.education,
                                'oldEducation': education,
                              },
                            );
                          }
                        : null,
                    isThreeLine: true,
                    leading: UniversityLogo(
                      logo: education.university.logo,
                    ),
                    title: Text(education.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(education.university.name),
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
                  icon: const AppIcon(
                    src: 'plus',
                    size: 22,
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
                    onTap: isOwnProfile
                        ? () {
                            Navigator.of(context).pushNamed(
                              ProfileUpdatePage.routeName,
                              arguments: {
                                'currentScreen': CurrentScreen.experience,
                                'oldExperience': experience,
                              },
                            );
                          }
                        : null,
                    isThreeLine: true,
                    leading: CompanyLogo(
                      logo: experience.company.logo,
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
              ],
            ),
        ],
      ),
    );
  }
}
