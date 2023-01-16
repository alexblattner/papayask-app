import 'package:badges/badges.dart' as badge_lib;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:papayask_app/models/question.dart';
import 'package:papayask_app/models/favorites.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/profile/profile.dart';
import 'package:papayask_app/questions/question_screen.dart';
import 'package:papayask_app/shared/app_drawer.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/shared/profile_picture.dart';
import 'package:papayask_app/utils/relative_time_text.dart';
import 'package:papayask_app/theme/colors.dart';

class FavoritesScreen extends StatefulWidget {
  static const routeName = '/favorites';
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Map<String, dynamic> questionStatus(FavoriteQuestion question) {
    if (question.status['action'] == 'pending' &&
        !question.endAnswerTime.isBefore(DateTime.now())) {
      return {
        'text': 'Pending',
        'color': Theme.of(context).colorScheme.primaryColor
      };
    } else if (question.status['action'] == 'pending' &&
        question.endAnswerTime.isBefore(DateTime.now())) {
      return {'text': 'Timed out', 'color': Colors.red};
    } else if (question.status['action'] == 'accepted' &&
        !question.status['done'] &&
        !question.endAnswerTime.isBefore(DateTime.now())) {
      return {'text': 'Accepted', 'color': Colors.green};
    } else if (question.status['action'] == 'accepted' &&
        question.status['done']) {
      return {'text': 'Done', 'color': Colors.green};
    } else if (question.status['action'] == 'rejected') {
      return {'text': 'Rejected', 'color': Colors.red};
    } else {
      return {'text': '', 'color': Colors.transparent};
    }
  }

  Question getQuestion(String questionId) {
    final questionsProvider =
        Provider.of<QuestionsService>(context, listen: false);
    late Question currentQuestion;
    for (final question in questionsProvider.questions['sent']!) {
      if (question.id == questionId) {
        currentQuestion = question;
        break;
      }
    }
    for (final question in questionsProvider.questions['received']!) {
      if (question.id == questionId) {
        currentQuestion = question;
        break;
      }
    }
    return currentQuestion;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context);
    final questionsProvider = Provider.of<QuestionsService>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Favorites',
            ),
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
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: 'Users',
                ),
                Tab(
                  text: 'Questions',
                ),
              ],
            ),
          ),
          drawer: const AppDrawer(),
          body: TabBarView(
            children: [
              ListView.separated(
                separatorBuilder: (context, index) => Container(
                  width: double.infinity,
                  height: 0.5,
                  color: Theme.of(context)
                      .colorScheme
                      .primaryColor
                      .withOpacity(0.5),
                ),
                itemCount:
                    authProvider.authUser!.favorites['users']?.length ?? 0,
                itemBuilder: (context, index) {
                  FavoriteUser user =
                      authProvider.authUser!.favorites['users']?[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ProfileScreen.routeName,
                        arguments: {'profileId': user.id},
                      );
                    },
                    leading: ProfilePicture(
                      src: user.picture,
                      size: 50,
                    ),
                    isThreeLine: true,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user.name),
                      ],
                    ),
                    subtitle: Text(
                      user.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  );
                },
              ),
              ListView.separated(
                separatorBuilder: (context, index) => Container(
                  width: double.infinity,
                  height: 0.5,
                  color: Theme.of(context)
                      .colorScheme
                      .primaryColor
                      .withOpacity(0.5),
                ),
                itemCount:
                    authProvider.authUser!.favorites['questions']?.length ?? 0,
                itemBuilder: (context, index) {
                  FavoriteQuestion question =
                      authProvider.authUser!.favorites['questions']?[index];
                  return ListTile(
                    onTap: () {
                      Question currentQuestion = getQuestion(question.id);
                      Navigator.of(context).pushNamed(
                        QuestionScreen.routeName,
                        arguments: currentQuestion,
                      );
                    },
                    leading: ProfilePicture(
                      src: question.senderPicture,
                      size: 50,
                    ),
                    isThreeLine: true,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(question.senderName),
                        const VerticalDivider(
                          width: 5,
                          thickness: 10,
                        ),
                        Text(
                          questionStatus(question)['text'],
                          style: TextStyle(
                            color: questionStatus(question)['color'],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        RelativeTimeText(dateTime: question.createdAt),
                      ],
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }
}
