import 'package:flutter/material.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/models/question.dart';
import 'package:papayask_app/questions/question_screen.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/shared/profile_picture.dart';
import 'package:papayask_app/utils/relative_time_text.dart';
import 'package:papayask_app/utils/time_passed.dart';
import 'package:provider/provider.dart';
import 'package:papayask_app/theme/colors.dart';

class QuestionTile extends StatefulWidget {
  final Question question;
  final String type;
  const QuestionTile({super.key, required this.question, required this.type});

  @override
  State<QuestionTile> createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> {
  Map<String, dynamic> get questionStatus {
    if (widget.question.status['action'] == 'pending' &&
        !isTimePassed(widget.question)) {
      return {
        'text': 'Pending',
        'color': Theme.of(context).colorScheme.primaryColor
      };
    } else if (widget.question.status['action'] == 'pending' &&
        isTimePassed(widget.question)) {
      return {'text': 'Timed out', 'color': Colors.red};
    } else if (widget.question.status['action'] == 'accepted' &&
        !widget.question.status['done'] &&
        !isTimePassed(widget.question)) {
      return {'text': 'Accepted', 'color': Colors.green};
    } else if (widget.question.status['action'] == 'accepted' &&
        widget.question.status['done']) {
      return {'text': 'Done', 'color': Colors.green};
    } else if (widget.question.status['action'] == 'rejected') {
      return {'text': 'Rejected', 'color': Colors.red};
    } else {
      return {'text': '', 'color': Colors.transparent};
    }
  }

  bool get isFavorited {
    final authService = Provider.of<AuthService>(context, listen: false);
    for (final favorite in authService.authUser!.favorites['questions']) {
      if (favorite.id == widget.question.id) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var user = widget.type == 'sent'
        ? widget.question.receiver
        : widget.question.sender;
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          QuestionScreen.routeName,
          arguments: widget.question,
        );
      },
      tileColor: widget.question.status['action'] == 'pending' &&
              !isTimePassed(widget.question)
          ? Theme.of(context).colorScheme.primaryColor.withOpacity(0.1)
          : Colors.white,
      leading: ProfilePicture(
        src: user.picture ?? '',
        size: 50,
      ),
      isThreeLine: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(user.name),
          const VerticalDivider(
            width: 5,
            thickness: 10,
          ),
          Text(
            questionStatus['text'],
            style: TextStyle(
              color: questionStatus['color'],
              fontSize: 14,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.description,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          RelativeTimeText(dateTime: widget.question.createdAt),
        ],
      ),
      trailing: SizedBox(
        height: 50,
        child: IconButton(
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).favoriteUQuestion(
              widget.question,
            );
          },
          icon: AppIcon(
            src: isFavorited ? 'star_fill' : 'star',
            size: 24,
            color: Theme.of(context).colorScheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
