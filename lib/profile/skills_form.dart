import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:papayask_app/models/company.dart';

import 'package:papayask_app/models/education.dart';
import 'package:papayask_app/models/experience.dart';
import 'package:papayask_app/models/university.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/shared/badge.dart';
import 'package:papayask_app/theme/colors.dart';
import 'package:papayask_app/models/skill.dart';
import 'package:papayask_app/profile/form_title.dart';
import 'package:papayask_app/utils/format_date.dart';

class SkillsForm extends StatefulWidget {
  final List skills;
  final List<Education> education;
  final List<Experience> experience;
  const SkillsForm({
    super.key,
    required this.skills,
    required this.education,
    required this.experience,
  });

  @override
  State<SkillsForm> createState() => _SkillsFormState();
}

class _SkillsFormState extends State<SkillsForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController skillController = TextEditingController();
  final TextEditingController relatedExperienceController =
      TextEditingController();
  final TextEditingController relatedEducationController =
      TextEditingController();
  List<Experience> relatedExperience = [];
  List<Education> relatedEducation = [];
  var showSkills = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isSkillNameExist(String name) {
    return widget.skills.any((skill) => skill.name == name);
  }

  double numberOfYears(DateTime startDate, DateTime? endDate) {
    endDate ??= DateTime.now();
    int years = endDate.year - startDate.year;
    int startMonth = startDate.month;
    int endMonth = endDate.month;
    int months = endMonth - startMonth;
    if (endDate.day < startDate.day) {
      months--;
    }
    double fractionalYears =
        double.parse((years + (months / 12)).toStringAsFixed(1));
    return fractionalYears;
  }

  void removeRelatedCompany(String name) {
    relatedExperience.removeWhere((e) => e.company.name == name);
    setState(() {});
  }

  void removeRelatedUniversity(String name) {
    relatedEducation.removeWhere((e) => e.university.name == name);
    setState(() {});
  }

  void addSkill() {
    if (skillController.text.isEmpty ||
        isSkillNameExist(skillController.text)) {
      return;
    }
    List<Map<String, dynamic>> educations = relatedEducation
        .map((e) => {
              'education': {
                'id': e.id,
                'university': e.university.toJson(),
                'name': e.name,
                'level': e.level,
                'startDate': e.startDate.toIso8601String(),
                'endDate': e.endDate?.toIso8601String(),
              },
              'years': numberOfYears(e.startDate, e.endDate)
            })
        .toList();
    List<Map<String, dynamic>> experiences = relatedExperience
        .map((e) => {
              'experience': {
                'id': e.id,
                'company': e.company.toJson(),
                'name': e.name,
                'type': e.type,
                'geographicSpecialization': e.geographicSpecialization,
                'startDate': e.startDate.toIso8601String(),
                'endDate': e.endDate?.toIso8601String(),
              },
              'years': numberOfYears(e.startDate, e.endDate)
            })
        .toList();
    final skill = Skill(
      name: skillController.text,
      experiences: experiences,
      educations: educations,
    );
    widget.skills.add(skill);
    skillController.clear();
    relatedExperience = [];
    relatedEducation = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FormTitle(title: 'Add skill'),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Skill',
              ),
              controller: skillController,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  for (final edu in relatedEducation)
                    Badge(
                      text: edu.university.name,
                      isRemovable: true,
                      onRemove: removeRelatedCompany,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: relatedExperienceController,
                decoration: const InputDecoration(
                  labelText: 'Related education',
                ),
              ),
              suggestionsCallback: ((pattern) {
                return widget.education.where(
                  (Education option) {
                    return option.university.name
                        .toLowerCase()
                        .contains(pattern.toLowerCase());
                  },
                );
              }),
              itemBuilder: (context, Education suggestion) {
                if (relatedEducation.contains(suggestion)) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  title: Text(suggestion.university.name),
                );
              },
              onSuggestionSelected: (Education suggestion) {
                if (relatedEducation.contains(suggestion)) {
                  return;
                }
                relatedEducation.add(suggestion);
                relatedEducationController.text = '';
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  for (final exp in relatedExperience)
                    Badge(
                      text: exp.company.name,
                      isRemovable: true,
                      onRemove: removeRelatedUniversity,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: relatedExperienceController,
                decoration: const InputDecoration(
                  labelText: 'Related experience',
                ),
              ),
              suggestionsCallback: ((pattern) {
                return widget.experience.where(
                  (Experience option) {
                    return option.company.name
                        .toLowerCase()
                        .contains(pattern.toLowerCase());
                  },
                );
              }),
              itemBuilder: (context, Experience suggestion) {
                if (relatedExperience.contains(suggestion)) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  title: Text(suggestion.company.name),
                );
              },
              onSuggestionSelected: (Experience suggestion) {
                if (relatedExperience.contains(suggestion)) {
                  return;
                }
                relatedExperience.add(suggestion);
                relatedExperienceController.text = '';
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: addSkill,
          child: const Text('ADD'),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            setState(() {
              if (showSkills) {
                _controller.reverse(from: 0.5);
              } else {
                _controller.forward(from: 0.5);
              }
              showSkills = !showSkills;
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FormTitle(
                  title: 'Skills(${widget.skills.length})',
                  color: Colors.black,
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                  child: const AppIcon(
                    src: 'arrow',
                    color: Colors.black,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (showSkills)
          for (Skill skill in widget.skills)
            SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
                reverseCurve: Curves.easeInOut,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryColor_L2,
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 8,
                        right: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            skill.name,
                            style: TextStyle(
                              fontSize: 22,
                              color:
                                  Theme.of(context).colorScheme.primaryColor_D1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: AppIcon(
                              src: 'pencil_fill',
                              color: Theme.of(context).colorScheme.primaryColor,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                skillController.text = skill.name;
                                relatedEducation = skill.educations
                                    .map(
                                      (e) => Education(
                                        university: University.fromJson(
                                            e['education']['university']),
                                        name: e['education']['name'],
                                        level: e['education']['level'],
                                        startDate: DateTime.parse(
                                            e['education']['startDate']),
                                        endDate:
                                            e['education']['endDate'] != null
                                                ? DateTime.parse(
                                                    e['education']['endDate'])
                                                : null,
                                      ),
                                    )
                                    .toList();
                                relatedExperience = skill.experiences
                                    .map(
                                      (e) => Experience(
                                        company: Company.fromJson(
                                            e['experience']['company']),
                                        name: e['experience']['name'],
                                        type: e['experience']['type'],
                                        geographicSpecialization:
                                            List<String>.from(
                                          e['experience']
                                              ['geographic_specialization'],
                                        ),
                                        startDate: DateTime.parse(
                                            e['experience']['startDate']),
                                        endDate:
                                            e['experience']['endDate'] != null
                                                ? DateTime.parse(
                                                    e['experience']['endDate'])
                                                : null,
                                      ),
                                    )
                                    .toList();
                              });
                            },
                          ),
                          IconButton(
                            icon: AppIcon(
                              src: 'delete',
                              color: Theme.of(context).colorScheme.primaryColor,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                widget.skills.remove(skill);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    if (skill.experiences.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Experience:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    for (var experience in skill.experiences)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              experience['experience']['company']['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  formatDate(
                                    DateTime.tryParse(experience['experience']
                                            ['startDate'] ??
                                        ''),
                                  ),
                                ),
                                const Text('-'),
                                Text(
                                  formatDate(
                                    DateTime.tryParse(experience['experience']
                                            ['endDate'] ??
                                        ''),
                                  ),
                                ),
                                const Text(
                                  '·',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  '${experience['years'].toString()} years',
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    if (skill.educations.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Education:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    for (var education in skill.educations)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              education['education']['university']['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  formatDate(
                                    DateTime.tryParse(education['education']
                                            ['startDate'] ??
                                        ''),
                                  ),
                                ),
                                const Text('-'),
                                Text(
                                  formatDate(
                                    DateTime.tryParse(education['education']
                                            ['endDate'] ??
                                        ''),
                                  ),
                                ),
                                const Text(
                                  '·',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  '${education['years'].toString()} years',
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
