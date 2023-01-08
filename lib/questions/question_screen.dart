import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/models/note.dart';
import 'package:papayask_app/models/question.dart';
import 'package:papayask_app/questions/counter_timer.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/questions/reject_modal.dart';
import 'package:papayask_app/shared/profile_picture.dart';
import 'package:papayask_app/utils/time_passed.dart';

enum RejectReason {
  notEnoughTime,
  outOfScope,
  tooMuchWork,
  other,
}

class QuestionScreen extends StatefulWidget {
  static const routeName = '/questions/question';
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Question? question;
  String rejectReason = '';
  var isLoading = false;
  var isDeleting = false;
  String editingNote = '';
  final TextEditingController noteController = TextEditingController();
  final TextEditingController editingNoteController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (question != null) return;
    var args = ModalRoute.of(context)?.settings.arguments as Question;
    question = args;
    super.didChangeDependencies();
  }

  String getFirstName(String name) {
    var fullName = name.split(' ');
    if (fullName.length > 1) {
      return fullName[0];
    }
    return name;
  }

  bool get isQuestionActive {
    final authService = Provider.of<AuthService>(context, listen: false);
    return question!.status['action'] == 'accepted' &&
        question!.status['done'] == false &&
        !isTimePassed(question!, authService.authUser!);
  }

  void rejectQuestion(String questionId) {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              content: SizedBox(
                height: constraints.maxHeight * 0.6,
                width: constraints.maxWidth * 0.8,
                child: RejectModal(
                  questionId: questionId,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> acceptQuestion(String questionId) async {
    final questionsService =
        Provider.of<QuestionsService>(context, listen: false);
    setState(() {
      question!.status['action'] = 'accepted';
    });
    questionsService.acceptQuestion(question!.id);
  }

  bool get showTimer {
    final authService = Provider.of<AuthService>(context, listen: false);
    return question!.receiver.id == authService.authUser!.id &&
        (question!.status['action'] == 'pending' ||
            (question!.status['action'] == 'accepted' &&
                question!.status['done'] == false));
  }

  bool get showNotes {
    final authService = Provider.of<AuthService>(context, listen: false);
    return question!.receiver.id == authService.authUser!.id ||
        (question!.receiver.id != authService.authUser!.id &&
            question!.status['action'] == 'accepted' &&
            question!.status['done']);
  }

  Future<void> sendNote(
    String questionId,
    String content,
    User user,
  ) async {
    setState(() {
      isLoading = true;
    });
    final questionsService =
        Provider.of<QuestionsService>(context, listen: false);
    final res = await questionsService.finishAnswer(
      questionId,
      content,
      user,
    );
    if (!mounted) return;
    if (res == 'Success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Answer sent successfully',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isLoading = false;
    });

    noteController.clear();
  }

  Future<void> delete(Note note) async {
    setState(() {
      isDeleting = true;
    });
    final questionsService =
        Provider.of<QuestionsService>(context, listen: false);
    final res = await questionsService.deleteNote(note);
    if (!mounted) return;
    if (res == 'Success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Deleted successfully',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isDeleting = false;
    });
  }

  Future<void> saveNote() async {
    Navigator.of(context).pop();
    if (editingNote == '' && noteController.text.isEmpty ||
        (editingNote != '' && editingNoteController.text.isEmpty)) return;
    final questionsService =
        Provider.of<QuestionsService>(context, listen: false);
    final authUser = Provider.of<AuthService>(context, listen: false).authUser;
    if (editingNote == '') {
      questionsService.addNote(
        question!.id,
        noteController.text,
        authUser!,
      );
    } else {
      final note =
          question!.notes.firstWhere((element) => element.id == editingNote);
      questionsService.updateNote(
        note,
        editingNoteController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthService>(context).authUser;
    final questionsService = Provider.of<QuestionsService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${getFirstName(question!.sender.name)}\'s Question',
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            saveNote();
          },
        ),
      ),
      body: question == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (showTimer)
                    CountdownTimer(
                      startTime: question!.createdAt,
                      days: authUser!.requestSettings!['time_limit']['days'],
                      hours: authUser.requestSettings!['time_limit']['hours'],
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      ProfilePicture(
                        src: question!.sender.picture ?? '',
                        size: 50,
                        isCircle: true,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question!.sender.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (question!.sender.title != '')
                            Text(
                              question!.sender.title,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    question!.description,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const Divider(),
                  if (question?.status['action'] == 'rejected')
                    Text(
                      '${question?.receiver.id == authUser!.id ? 'You' : getFirstName(question!.receiver.name)} have rejected this question, for the reason: \n"${question?.status['reason']}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (question?.status['action'] == 'pending' &&
                      !isTimePassed(question!, authUser!))
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => rejectQuestion(question!.id),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              acceptQuestion(question!.id);
                            },
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  if (showNotes)
                    for (Note note in question!.notes)
                      Opacity(
                        opacity: isDeleting ? 0.5 : 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                ProfilePicture(
                                  src: note.user.picture ?? '',
                                  size: 50,
                                  isCircle: true,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.user.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (note.user.title != '')
                                      Text(
                                        note.user.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                if (note.user.id == authUser!.id &&
                                    !question!.status['done'])
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        editingNoteController.text =
                                            editingNote == note.id
                                                ? ''
                                                : note.content;
                                        editingNote = editingNote == note.id
                                            ? ''
                                            : note.id;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: AppIcon(
                                        src: 'pencil_fill',
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                if (note.user.id == authUser.id &&
                                    !question!.status['done'])
                                  GestureDetector(
                                    onTap: () {
                                      delete(note);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: AppIcon(
                                        src: 'delete',
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            editingNote == note.id
                                ? TextField(
                                    decoration: const InputDecoration(),
                                    maxLines: null,
                                    controller: editingNoteController,
                                  )
                                : HtmlWidget(note.content),
                            const Divider(),
                          ],
                        ),
                      ),
                  if (isQuestionActive && question?.receiver.id == authUser!.id)
                    Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(),
                          maxLines: null,
                          controller: noteController,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  sendNote(
                                    question!.id,
                                    noteController.text,
                                    authUser,
                                  );
                                  noteController.clear();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Send'),
                                    if (isLoading)
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    if (isLoading)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
