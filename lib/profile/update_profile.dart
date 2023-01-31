import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/shared/cloudinary_upload.dart';
import 'package:papayask_app/models/university.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/profile/skills_form.dart';
import 'package:papayask_app/models/education.dart';
import 'package:papayask_app/models/company.dart';
import 'package:papayask_app/models/experience.dart';
import 'package:papayask_app/profile/bio_form.dart';
import 'package:papayask_app/profile/experience_form.dart';
import 'package:papayask_app/profile/language_form.dart';
import 'package:papayask_app/profile/education_form.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/models/user.dart';

enum CurrentScreen {
  bio,
  education,
  experience,
  language,
  skills,
  profilePicture,
}

class ProfileUpdatePage extends StatefulWidget {
  static const routeName = '/profile-update';
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  CurrentScreen currentScreen = CurrentScreen.bio;
  late User user;
  var userBio = '';
  var userLanguages = [];
  var newExperience = Experience(
    name: '',
    type: '',
    company: Company(name: ''),
    geographicSpecialization: [''],
    startDate: DateTime.now(),
  );
  var isEditingEducation = false;
  var isEditingExperience = false;
  var newEducation = Education(
    name: '',
    level: '',
    university: University(name: '', country: ''),
    startDate: DateTime.now(),
  );
  var userSkills = [];
  var userProfilePicture = '';

  var isLoading = false;
  var isDeleting = false;

  void updateBio(String bio) {
    setState(() {
      userBio = bio;
    });
  }

  void updateProfilePicture(String profilePicture) {
    setState(() {
      userProfilePicture = profilePicture;
    });
  }

  @override
  void initState() {
    final authProvider = Provider.of<AuthService>(context, listen: false);
    user = authProvider.authUser!;
    userBio = user.bio;
    userLanguages = user.languages;
    userSkills = user.skills;
    userProfilePicture = user.picture ?? '';
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    currentScreen = args['currentScreen'] as CurrentScreen;
    if (args['oldEducation'] != null) {
      newEducation = args['oldEducation'] as Education;
      isEditingEducation = true;
    }
    if (args['oldExperience'] != null) {
      newExperience = args['oldExperience'] as Experience;
      isEditingExperience = true;
    }
    super.didChangeDependencies();
  }

  String get getCurrentScreen {
    switch (currentScreen) {
      case CurrentScreen.bio:
        return 'Bio';
      case CurrentScreen.education:
        return 'Education';
      case CurrentScreen.experience:
        return 'Experience';
      case CurrentScreen.language:
        return 'Language';
      case CurrentScreen.profilePicture:
        return 'Profile Picture';
      case CurrentScreen.skills:
        return 'Skills';
    }
  }

  Widget get getScreen {
    switch (currentScreen) {
      case CurrentScreen.bio:
        return BioForm(userBio: userBio, updateBio: updateBio);
      case CurrentScreen.education:
        return EducationForm(
          education: newEducation,
          isEditing: isEditingEducation,
        );
      case CurrentScreen.experience:
        return ExperienceForm(
          experience: newExperience,
          isEditing: isEditingExperience,
        );
      case CurrentScreen.language:
        return LanguageForm(
          languages: userLanguages,
        );
      case CurrentScreen.skills:
        return SkillsForm(
          skills: userSkills,
          education: user.education,
          experience: user.experience,
        );
      case CurrentScreen.profilePicture:
        return CloudinaryUploadWidget(
          updateImage: updateProfilePicture,
          currentImage: userProfilePicture,
        );
    }
  }

  Future<void> _updateProfile() async {
    final authProvider = Provider.of<AuthService>(context, listen: false);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final setProfileUser = args['setProfileUser'] as Function;
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = {};
    if (currentScreen == CurrentScreen.bio) {
      data = {
        'bio': userBio,
      };
    }
    if (currentScreen == CurrentScreen.language) {
      data = {
        'languages': user.languages,
      };
    }
    if (currentScreen == CurrentScreen.experience) {
      List<Experience> experienceList = [];
      if (isEditingExperience) {
        experienceList = [...user.experience];
        var currentExperienceIndex = experienceList
            .indexWhere((element) => element.isEqual(newExperience));
        experienceList[currentExperienceIndex] = newExperience;
      } else {
        experienceList = [...user.experience, newExperience];
      }
      data = {
        'experience': experienceList
            .map((e) => {
                  'name': e.name,
                  'type': e.type,
                  'company': e.company.toJson(),
                  'geographic_specialization': e.geographicSpecialization,
                  'startDate': e.startDate.toIso8601String(),
                  'endDate': e.endDate?.toIso8601String() ?? '',
                })
            .toList(),
      };
    }

    if (currentScreen == CurrentScreen.education) {
      List<Education> educationList = [];
      if (isEditingEducation) {
        educationList = [...user.education];
        var currentEducationIndex = educationList
            .indexWhere((element) => element.isEqual(newEducation));
        educationList[currentEducationIndex] = newEducation;
      } else {
        educationList = [...user.education, newEducation];
      }

      data = {
        'education': educationList
            .map((e) => {
                  'name': e.name,
                  'level': e.level,
                  'university': e.university,
                  'startDate': e.startDate.toIso8601String(),
                  'endDate':
                      e.endDate == null ? '' : e.endDate!.toIso8601String(),
                })
            .toList(),
      };
    }

    if (currentScreen == CurrentScreen.skills) {
      data = {
        'skills': userSkills,
      };
    }

    if (currentScreen == CurrentScreen.profilePicture) {
      data = {
        'picture': userProfilePicture,
      };
    }

    final res = await authProvider.updateUser(data);
    if (!mounted) return;
    if (res == 'done') {
      setProfileUser();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Somthing went wrong',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _delete(Education? education, Experience? experience) async {
    var educationList = [...user.education];
    var experienceList = [...user.experience];
    setState(() {
      isDeleting = true;
    });
    if (education != null) {
      final newEducation = user.education
          .where((element) => !element.isEqual(education))
          .toList();
      educationList = newEducation;
    }
    if (experience != null) {
      final newExperience = user.experience
          .where((element) => !element.isEqual(experience))
          .toList();
      experienceList = newExperience;
    }
    final authProvider = Provider.of<AuthService>(context, listen: false);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final setProfileUser = args['setProfileUser'] as Function;
    Map<String, dynamic> data = {};
    if (isEditingEducation) {
      data = {
        'education': educationList
            .map((e) => {
                  'name': e.name,
                  'level': e.level,
                  'university': e.university,
                  'startDate': e.startDate.toIso8601String(),
                  'endDate': e.endDate?.toIso8601String(),
                })
            .toList(),
      };
    } else if (isEditingExperience) {
      data = {
        'experience': experienceList
            .map((e) => {
                  'name': e.name,
                  'type': e.type,
                  'company': e.company.toJson(),
                  'geographicSpecialization': e.geographicSpecialization,
                  'startDate': e.startDate.toIso8601String(),
                  'endDate': e.endDate?.toIso8601String(),
                })
            .toList(),
      };
    }
    final res = await authProvider.updateUser(data);
    if (!mounted) return;
    if (res == 'done') {
      setProfileUser();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Somthing went wrong',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isDeleting = false;
    });
  }

  String get updateButtonText {
    var text = '';
    if (currentScreen != CurrentScreen.education &&
        currentScreen != CurrentScreen.experience) {
      text = 'Update';
    } else {
      if (isEditingEducation || isEditingExperience) {
        text = 'Update';
      } else {
        text = 'Add';
      }
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        actions: [
          if (currentScreen == CurrentScreen.education ||
              currentScreen == CurrentScreen.experience)
            if (isEditingEducation || isEditingExperience)
              IconButton(
                onPressed: isDeleting || isLoading
                    ? () {}
                    : () {
                        _delete(
                          isEditingEducation ? newEducation : null,
                          isEditingExperience ? newExperience : null,
                        );
                      },
                icon: const AppIcon(
                  src: 'delete',
                  color: Colors.red,
                  size: 24,
                ),
              ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Your $getCurrentScreen',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Expanded(child: getScreen),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isLoading || isDeleting ? () {} : _updateProfile,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              updateButtonText,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            if (isLoading)
                              const SizedBox(
                                width: 10,
                              ),
                            if (isLoading)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isDeleting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
