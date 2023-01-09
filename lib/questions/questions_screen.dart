import 'package:badges/badges.dart' as badge_lib;
import 'package:flutter/material.dart';
import 'package:papayask_app/models/question.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/utils/time_passed.dart';
import 'package:papayask_app/questions/question_screen.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/shared/app_drawer.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/shared/profile_picture.dart';
import 'package:papayask_app/utils/relative_time_text.dart';
import 'package:papayask_app/theme/colors.dart';

class QuestionsScreen extends StatefulWidget {
  static const routeName = '/questions';
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
 
  Map<String, dynamic> questionStatus(Question question) {
    if (question.status['action'] == 'pending' && !isTimePassed(question)) {
      return {
        'text': 'Pending',
        'color': Theme.of(context).colorScheme.primaryColor
      };
    } else if (question.status['action'] == 'pending' &&
        isTimePassed(question)) {
      return {'text': 'Timed out', 'color': Colors.red};
    } else if (question.status['action'] == 'accepted' &&
        !question.status['done'] &&
        !isTimePassed(question)) {
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

  @override
  Widget build(BuildContext context) {
    final questionsProvider = Provider.of<QuestionsService>(context);
    final questions = questionsProvider.questions;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Questions',
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
                  text: 'Received',
                ),
                Tab(
                  text: 'Sent',
                ),
              ],
            ),
          ),
          drawer: const AppDrawer(),
          body: TabBarView(
            children: [
              RefreshIndicator(
                onRefresh:questionsProvider.fetchQuestions,
                child: ListView.separated(
                  separatorBuilder: (context, index) => Container(
                    width: double.infinity,
                    height: 0.5,
                    color: Theme.of(context)
                        .colorScheme
                        .primaryColor
                        .withOpacity(0.5),
                  ),
                  itemCount: questions['received']?.length ?? 0,
                  itemBuilder: (context, index) {
                    final question = questions['received']?[index];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          QuestionScreen.routeName,
                          arguments: question,
                        );
                      },
                      tileColor: question?.status['action'] == 'pending' &&
                              !isTimePassed(question!)
                          ? Theme.of(context)
                              .colorScheme
                              .primaryColor
                              .withOpacity(0.2)
                          : null,
                      leading: ProfilePicture(
                        src: question?.sender.picture ?? '',
                        size: 50,
                      ),
                      isThreeLine: true,
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(question?.sender.name ?? ''),
                          const VerticalDivider(
                            width: 5,
                            thickness: 10,
                          ),
                          Text(
                            questionStatus(question!)['text'],
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
                      trailing: SizedBox(
                        height: 50,
                        child: AppIcon(
                          src: 'star',
                          size: 24,
                          color: Theme.of(context).colorScheme.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
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
                itemCount: questions['sent']?.length ?? 0,
                itemBuilder: (context, index) {
                  final question = questions['sent']?[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        QuestionScreen.routeName,
                        arguments: question,
                      );
                    },
                    leading: ProfilePicture(
                      src: question?.receiver.picture ?? '',
                      size: 50,
                    ),
                    isThreeLine: true,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(question?.receiver.name ?? ''),
                        const VerticalDivider(
                          width: 5,
                          thickness: 10,
                        ),
                        Text(
                          questionStatus(question!)['text'],
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
                    trailing: SizedBox(
                      height: 50,
                      child: AppIcon(
                        src: 'star',
                        size: 24,
                        color: Theme.of(context).colorScheme.primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }
}
