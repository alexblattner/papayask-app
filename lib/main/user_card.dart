import 'package:flutter/material.dart';

import 'package:papayask_app/models/skill.dart';
import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/profile/profile.dart';
import 'package:papayask_app/shared/profile_picture.dart';

class UserCard extends StatelessWidget {
  final User user;
  UserCard({super.key, required this.user});

  double topSkillYears = 0;
  Skill? get topSkill {
    if (user.skills.isEmpty) {
      return null;
    }
    Skill topSkill = user.skills[0];
    double maxYears = 0;
    for (var skill in user.skills) {
      double totalYears =
          skill.experiences.map((e) => e['years']).fold(0, (a, b) => a + b);
      if (totalYears > maxYears) {
        maxYears = totalYears;
        topSkill = skill;
      }
    }
    topSkillYears = maxYears;
    return topSkill;
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.7;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ProfileScreen.routeName,
          arguments: {'profileId': user.id},
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 15),
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfilePicture(
                  src: user.picture ?? '',
                  isCircle: true,
                  size: 100,
                ),
                const SizedBox(height: 25),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 16),
                if (topSkill != null)
                  Text(
                    topSkill?.name ?? 'No skills',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(width: 5),
                Text(
                  '$topSkillYears years of experience',
                ),
                if (topSkill == null)
                  Container(
                    height: 53,
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Set of skills:'),
                    const SizedBox(width: 5),
                    Text(user.skills.length.toString()),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${user.requestSettings!['cost']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
