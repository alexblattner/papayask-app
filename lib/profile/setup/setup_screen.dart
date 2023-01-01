import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/profile/become_advisor_modal.dart';
import 'package:papayask_app/shared/cloudinary_upload.dart';
import 'package:papayask_app/shared/full_logo.dart';
import 'package:papayask_app/models/skill.dart';
import 'package:papayask_app/profile/form_title.dart';
import 'package:papayask_app/profile/skills_form.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/models/company.dart';
import 'package:papayask_app/models/education.dart';
import 'package:papayask_app/models/experience.dart';
import 'package:papayask_app/models/university.dart';
import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/profile/bio_form.dart';
import 'package:papayask_app/profile/education_form.dart';
import 'package:papayask_app/profile/experience_form.dart';
import 'package:papayask_app/profile/language_form.dart';
import 'package:papayask_app/profile/setup/footer.dart';
import 'package:papayask_app/profile/setup/pagination.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/shared/country_select.dart';
import 'package:papayask_app/theme/colors.dart';
import 'package:papayask_app/utils/format_date.dart';

class SetupScreen extends StatefulWidget {
  static const routeName = '/setup';
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  TextEditingController countryController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  var isAdvisorSetup = false;
  var isInit = false;
  var isLoading = false;
  var isSaving = false;
  late User user;
  var currentPage = 1;
  List<int> pagesDone = [1];

  var skills = <Skill>[];
  var userProfilePicture = '';
  var userTitle = '';
  var userBio = '';
  var userCountry = '';
  var userLanguages = [];
  var userEducation = <Education>[];
  var userExperience = <Experience>[];

  int get progress {
    int progress = 0;
    if (userTitle != '') {
      progress += 5;
    }
    if (userBio != '') {
      progress += 15;
    }
    if (userProfilePicture != '') {
      progress += 15;
    }
    if (skills.isNotEmpty) {
      for (var i = 0; i < skills.length; i++) {
        if (skills[i].educations.isNotEmpty ||
            skills[i].experiences.isNotEmpty) {
          progress += 10;
        } else {
          progress += 5;
        }
      }
    }
    if (userExperience.isNotEmpty) {
      progress += userExperience.length * 5;
    }
    if (userEducation.isNotEmpty) {
      progress += userEducation.length * 5;
    }
    return progress;
  }

  Education newEducation = Education(
    name: '',
    level: '',
    university: University(name: '', country: ''),
    startDate: DateTime.now(),
    endDate: DateTime.now(),
  );

  Experience newExperience = Experience(
    name: '',
    type: '',
    geographicSpecialization: [''],
    company: Company(name: ''),
    startDate: DateTime.now(),
    endDate: DateTime.now(),
  );

  void setCurrentPage(int page) {
    setState(() {
      currentPage = page;
      if (!pagesDone.contains(page)) {
        pagesDone.add(page);
      }
    });
  }

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

  void addEducation(Education education) {
    setState(() {
      userEducation.add(education);
      newEducation = Education(
        name: '',
        level: '',
        university: University(name: '', country: ''),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
    });
  }

  void addExperience(Experience experience) {
    setState(() {
      userExperience.add(experience);
      newExperience = Experience(
        name: '',
        type: '',
        geographicSpecialization: [''],
        company: Company(name: ''),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
    });
  }

  void onSelectedCountry(String country) {
    setState(() {
      countryController.text = country;
      userCountry = country;
    });
  }

  Future<void> apply() async {
    final authProvider = Provider.of<AuthService>(context, listen: false);
    var res = await authProvider.becomeAnAdvisor();
    if (!mounted) return;
    if (res == 'done') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Application submitted successfully',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> submit(String type) async {
    final authProvider = Provider.of<AuthService>(context, listen: false);

    if (type == 'submit' && progress < 75 && isAdvisorSetup) {
      showDialog(
        context: context,
        builder: ((context) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                content: SizedBox(
                  height: constraints.maxHeight * 0.3,
                  width: constraints.maxWidth * 0.8,
                  child: BecomeAdvisorModal(
                    progress: progress,
                    type: BecomeAdvisorModalType.submitWarning,
                  ),
                ),
                actions: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Keep Editing',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      submit('save');
                    },
                    child: const Text(
                      'Save Progress',
                    ),
                  ),
                ],
              );
            },
          );
        }),
      );
      return;
    }

    setState(() {
      if (type == 'submit') {
        isLoading = true;
      } else {
        isSaving = true;
      }
    });

    Map<String, dynamic> data = {
      'picture': userProfilePicture,
      'title': userTitle,
      'bio': userBio,
      'country': userCountry,
      'education': userEducation.map((e) {
        return {
          'name': e.name,
          'level': e.level,
          'university': e.university,
          'startDate': e.startDate.toIso8601String(),
          'endDate': e.endDate?.toIso8601String(),
        };
      }).toList(),
      'experience': userExperience.map((e) {
        return {
          'name': e.name,
          'type': e.type,
          'geographicSpecialization': e.geographicSpecialization,
          'company': e.company.toJson(),
          'startDate': e.startDate.toIso8601String(),
          'endDate': e.endDate?.toIso8601String(),
        };
      }).toList(),
      'languages': userLanguages,
      'skills': skills,
    };

    final res = await authProvider.updateUser(data);
    if (!mounted) return;
    if (res == 'done') {
      if (type == 'submit') {
        if (isAdvisorSetup) {
          apply();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile submitted successfully',
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Saved successfully',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
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
      isSaving = false;
    });
  }

  Widget _buildScreen() {
    switch (currentPage) {
      case 1:
        return _buildFirstScreen();
      case 2:
        return _buildSecondScreen();
      case 3:
        return _buildThirdScreen();
      case 4:
        return _buildFourthScreen();
      default:
        return _buildFirstScreen();
    }
  }

  @override
  void didChangeDependencies() {
    if (isInit) return;
    var args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    user = args['user'];
    isAdvisorSetup = args['isAdvisorSetup'];
    userTitle = user.title;
    titleController.text = user.title;
    userBio = user.bio;
    skills = user.skills;
    countryController.text = user.country;
    userProfilePicture = user.picture ?? '';
    userEducation = user.education;
    userExperience = user.experience;
    userLanguages = user.languages;
    userCountry = user.country;
    isInit = true;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    titleController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            isAdvisorSetup ? const Text('Become an advisor') : const FullLogo(),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Pagination(
            currentPage: currentPage,
            pagesDone: pagesDone,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildScreen(),
            ),
          ),
          Footer(
            currentPage: currentPage,
            setCurrentPage: setCurrentPage,
            submit: submit,
            isLoading: isLoading,
            isSaving: isSaving,
            isAdvisorSetup: isAdvisorSetup,
            progress: progress,
          ),
        ],
      ),
    );
  }

  Widget _buildFirstScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          CloudinaryUploadWidget(
            updateImage: updateProfilePicture,
            currentImage: userProfilePicture,
          ),
          const SizedBox(height: 24),
          const FormTitle(title: 'Job description'),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            onChanged: (value) {
              setState(() {
                userTitle = value;
              });
            },
          ),
          const SizedBox(height: 36),
          const FormTitle(title: 'Tell us about yourself'),
          const SizedBox(height: 12),
          BioForm(
            userBio: userBio,
            updateBio: updateBio,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormTitle(title: 'Education'),
          const SizedBox(height: 12),
          EducationForm(
            education: newEducation,
            addEducation: addEducation,
            isInSetup: true,
          ),
          const SizedBox(height: 12),
          for (var education in userEducation)
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
                Positioned(
                  right: 15,
                  top: 15,
                  child: GestureDetector(
                    child: AppIcon(
                      src: 'close',
                      size: 14,
                      color: Theme.of(context).colorScheme.primaryColor,
                    ),
                    onTap: () {
                      setState(() {
                        userEducation.remove(education);
                      });
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 36),
          const FormTitle(title: 'Experience'),
          const SizedBox(height: 12),
          ExperienceForm(
            experience: newExperience,
            addExperience: addExperience,
            isInSetup: true,
          ),
          const SizedBox(height: 12),
          for (var experience in userExperience)
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
                      src: 'close',
                      size: 14,
                      color: Theme.of(context).colorScheme.primaryColor,
                    ),
                    onTap: () {
                      setState(() {
                        userExperience.remove(experience);
                      });
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildThirdScreen() {
    return SkillsForm(
      skills: skills,
      education: userEducation,
      experience: userExperience,
    );
  }

  Widget _buildFourthScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const FormTitle(title: 'Country'),
          const SizedBox(height: 12),
          CountrySelect(
            onSelect: onSelectedCountry,
            countryController: countryController,
          ),
          const SizedBox(height: 36),
          const FormTitle(title: 'Languages'),
          const SizedBox(height: 12),
          LanguageForm(
            languages: userLanguages,
          ),
        ],
      ),
    );
  }
}
