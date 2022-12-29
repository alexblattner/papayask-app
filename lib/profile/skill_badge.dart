import 'package:flutter/material.dart';

import 'package:papayask_app/models/skill.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/theme/colors.dart';
import 'package:papayask_app/utils/format_date.dart';

class SkillBadge extends StatefulWidget {
  final Skill skill;
  const SkillBadge({super.key, required this.skill});

  @override
  State<SkillBadge> createState() => _SkillBadgeState();
}

class _SkillBadgeState extends State<SkillBadge>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryColor_L2,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
                isExpanded ? _controller.forward() : _controller.reverse();
              });
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.skill.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primaryColor_D1,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                    child: AppIcon(
                      src: 'arrow',
                      color: Theme.of(context).colorScheme.primaryColor_D1,
                      size: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            SizeTransition(
              sizeFactor: _animation,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.skill.experiences.isNotEmpty)
                      Text(
                        'Experience',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    for (final experience in widget.skill.experiences)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
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
                                  DateTime.parse(
                                      experience['experience']['startDate']),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const Text(' - '),
                              Text(
                                formatDate(
                                  experience['experience']['endDate'] != null
                                      ? DateTime.parse(
                                          experience['experience']['endDate'])
                                      : DateTime.now(),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '·',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${experience['years'].toString()} years',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    if (widget.skill.educations.isNotEmpty)
                      const SizedBox(height: 16),
                    if (widget.skill.educations.isNotEmpty)
                      Text(
                        'Education',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    for (final education in widget.skill.educations)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
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
                                  DateTime.parse(
                                      education['education']['startDate']),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const Text(' - '),
                              Text(
                                formatDate(
                                  education['education']['endDate'] != null
                                      ? DateTime.parse(
                                          education['education']['endDate'])
                                      : DateTime.now(),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '·',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${education['years'].toString()} years',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
