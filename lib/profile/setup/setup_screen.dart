import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import 'package:papayask_app/shared/appbar.dart';
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
  var isInit = false;
  var isLoading = false;
  late User user;
  var currentPage = 1;
  List<int> pagesDone = [1];
  var skills = <Skill>[];

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
      user.bio = bio;
    });
  }

  void addEducation(Education education) {
    setState(() {
      user.education.add(education);
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
      user.experience.add(experience);
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
      user.country = country;
    });
  }

  Future<void> submit() async {
    final authProvider = Provider.of<AuthService>(context, listen: false);

    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = {
      'title': user.title,
      'bio': user.bio,
      'country': user.country,
      'education': user.education.map((e) {
        return {
          'name': e.name,
          'level': e.level,
          'university': e.university,
          'startDate': e.startDate.toIso8601String(),
          'endDate': e.endDate?.toIso8601String(),
        };
      }).toList(),
      'experience': user.experience.map((e) {
        return {
          'name': e.name,
          'type': e.type,
          'geographicSpecialization': e.geographicSpecialization,
          'company': e.company.toJson(),
          'startDate': e.startDate.toIso8601String(),
          'endDate': e.endDate?.toIso8601String(),
        };
      }).toList(),
      'languages': user.languages,
      'skills': skills,
    };

    final res = await authProvider.updateUser(data);
    if (!mounted) return;
    if (res == 'done') {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Somthing went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
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
    user = ModalRoute.of(context)!.settings.arguments as User;
    titleController.text = user.title;
    skills = user.skills;
    countryController.text = user.country;
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
      appBar: const CustomAppBar(
        extended: false,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFirstScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const FormTitle(title: 'Job description'),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            onChanged: (value) {
              setState(() {
                user.title = value;
              });
            },
          ),
          const SizedBox(height: 36),
          const FormTitle(title: 'Tell us about yourself'),
          const SizedBox(height: 12),
          BioForm(
            userBio: user.bio,
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
          for (var education in user.education)
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
                        user.education.remove(education);
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
          for (var experience in user.experience)
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
                        user.experience.remove(experience);
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
      education: user.education,
      experience: user.experience,
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
            languages: user.languages,
          ),
        ],
      ),
    );
  }
}
