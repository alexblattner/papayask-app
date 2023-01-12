import 'package:badges/badges.dart' as badge_lib;
import 'package:flutter/material.dart';
import 'package:papayask_app/questions/question_tile.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/shared/app_drawer.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/theme/colors.dart';

class QuestionsScreen extends StatefulWidget {
  static const routeName = '/questions';
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
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
              onRefresh: questionsProvider.fetchQuestions,
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
                  return QuestionTile(question: question!, type: 'received');
                },
              ),
            ),
            ListView.separated(
              separatorBuilder: (context, index) => Container(
                width: double.infinity,
                height: 0.5,
                color:
                    Theme.of(context).colorScheme.primaryColor.withOpacity(0.5),
              ),
              itemCount: questions['sent']?.length ?? 0,
              itemBuilder: (context, index) {
                final question = questions['sent']?[index];
                return QuestionTile(question: question!, type: 'sent');
              },
            ),
          ],
        ),
      ),
    );
  }
}
