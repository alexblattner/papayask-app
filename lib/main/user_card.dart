import 'package:flutter/material.dart';

import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/profile/profile.dart';
import 'package:papayask_app/shared/profile_picture.dart';
import 'package:papayask_app/utils/format_amount.dart';

class UserCard extends StatelessWidget {
  final User user;
  const UserCard({super.key, required this.user});

  double get totalYears {
    double totalYears = 0;
    for (var exp in user.experience) {
      DateTime start = exp.startDate;
      DateTime end = exp.endDate ?? DateTime.now();
      totalYears += end.difference(start).inDays / 365;
    }
    return totalYears;
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.5;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ProfileScreen.routeName,
          arguments: {'profileId': user.id},
        );
      },
      child: SizedBox(
        width: cardWidth,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfilePicture(
                  src: user.picture ?? '',
                  isCircle: true,
                  size: 100,
                ),
                Column(
                  children: [
                    Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${totalYears.toStringAsFixed(1)} years of experience',
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Set of skills:'),
                    const SizedBox(width: 5),
                    Text(user.skills.length.toString()),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formatAmount(user.requestSettings!['cost'].toInt()),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
