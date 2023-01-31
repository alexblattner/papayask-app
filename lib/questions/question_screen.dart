import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/profile/profile.dart';
import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/questions/editor.dart';
import 'package:papayask_app/shared/app_icon.dart';
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
  HtmlEditorController controller = HtmlEditorController();
  HtmlEditorController editController = HtmlEditorController();
  var content = '';
  var editingContent = '';
  Question? question;
  String rejectReason = '';
  var isLoading = false;
  var isDeleting = false;
  var questionLoaded = false;
  var error = '';
  String editingNote = '';

  @override
  void didChangeDependencies() {
    if (question != null) return;
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final questionsService =
        Provider.of<QuestionsService>(context, listen: false);
    if (args['question'] != null) {
      question = args['question'];
      questionLoaded = true;
    } else {
      questionsService.getQuestion(args['questionId']).then((value) {
        if (value != null) {
          setState(() {
            question = value;
            questionLoaded = true;
          });
        } else {
          setState(() {
            error = 'Something went wrong';
          });
        }
      });
    }
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
    return question!.status['action'] == 'accepted' &&
        question!.status['done'] == false &&
        !isTimePassed(question!);
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
      setContent('');
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
      editingNote = '';
    });
  }

  Future<void> saveNote() async {
    Navigator.of(context).pop();
    if (editingNote == '' && (content == '<p><br></p>' || content == '') ||
        (editingNote != '' &&
            (editingContent == '' || editingContent == '<p></br></p>'))) return;

    final questionsService =
        Provider.of<QuestionsService>(context, listen: false);
    final authUser = Provider.of<AuthService>(context, listen: false).authUser;
    if (editingNote == '') {
      questionsService.addNote(
        question!.id,
        content,
        authUser!,
      );
    }
  }

  void setContent(String value) {
    setState(() {
      content = value;
    });
  }

  void setEditingContent(String value) {
    setState(() {
      editingContent = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthService>(context).authUser;
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
      body: error.isNotEmpty
          ? Center(
              child: Text(error),
            )
          : question == null
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
                          endTime: question!.endAnswerTime,
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            ProfileScreen.routeName,
                            arguments: {'profileId': question!.sender.id},
                          );
                        },
                        child: Row(
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
                          question?.receiver.id == authUser!.id &&
                          !isTimePassed(question!))
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      ProfileScreen.routeName,
                                      arguments: {'profileId': note.user.id},
                                    );
                                  },
                                  child: Row(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          !question!.status['done'] &&
                                          editingNote != '')
                                        IconButton(
                                          onPressed: () {
                                            final questionsService =
                                                Provider.of<QuestionsService>(
                                                    context,
                                                    listen: false);
                                            questionsService.updateNote(
                                              note,
                                              editingContent,
                                            );
                                            setState(() {
                                              editingNote = '';
                                              note.content = editingContent;
                                            });
                                          },
                                          icon: const Icon(Icons.save_outlined),
                                        ),
                                      if (note.user.id == authUser.id &&
                                          !question!.status['done'])
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (editingNote == note.id) {
                                                editingNote = '';
                                              } else {
                                                editingNote = note.id;
                                              }
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
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                editingNote != '' && editingNote == note.id
                                    ? NoteEditor(
                                        setContent: setEditingContent,
                                        controller: editController,
                                        initialText: note.content,
                                      )
                                    : HtmlWidget(note.content),
                                const Divider(),
                              ],
                            ),
                          ),
                      if (isQuestionActive &&
                          question?.receiver.id == authUser!.id)
                        Column(
                          children: [
                            if (editingNote == '')
                              NoteEditor(
                                setContent: setContent,
                                controller: controller,
                              ),
                            const SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () {
                                  sendNote(
                                    question!.id,
                                    content,
                                    authUser,
                                  );
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
                ),
    );
  }
}
