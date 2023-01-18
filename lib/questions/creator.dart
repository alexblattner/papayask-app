import 'package:flutter/material.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:papayask_app/shared/full_logo.dart';
import 'package:papayask_app/questions/paypal_payment.dart';
import 'package:papayask_app/shared/scaffold_key.dart';

class Creator extends StatefulWidget {
  final User user;
  const Creator({super.key, required this.user});

  @override
  State<Creator> createState() => _CreatorState();
}

class _CreatorState extends State<Creator> {
  GlobalKey key = GlobalKey<ScaffoldState>();
  var isLoading = false;
  var question = '';
  String get firstName => widget.user.name.split(' ').first;

  String get answerTime {
    final int days = widget.user.requestSettings!['time_limit']['days'];
    final int hours = widget.user.requestSettings!['time_limit']['hours'];

    return '${days > 0 ? '$days day${days > 1 ? 's' : ''} and' : ''} ${hours > 0 ? '$hours hour${hours > 1 ? 's' : ''}' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    var cost = widget.user.requestSettings!['cost'];
    final questionsService = Provider.of<QuestionsService>(context);
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: const FullLogo(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text(
              'Ask $firstName a question',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will cost you \$${widget.user.requestSettings!['cost']}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$firstName will answer your question within $answerTime',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: 20,
              onChanged: (value) {
                setState(() {
                  question = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3b7bbf),
              ),
              onPressed: isLoading || question.isEmpty
                  ? () {}
                  : () {
                      setState(() {
                        isLoading = true;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext ctx) => PaypalPayment(
                            onFinish: (paypalResult) async {
                              setState(() {
                                isLoading = false;
                              });
                              if (paypalResult == 'created') {
                                final res = await questionsService.sendQuestion(
                                    question, widget.user.id);
                                if (!mounted) return;
                                if (res == 'Done') {
                                  scaffoldKey.currentState?.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Question send successfully',
                                        textAlign: TextAlign.center,
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  scaffoldKey.currentState?.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Something went wrong',
                                        textAlign: TextAlign.center,
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            payment: cost.toDouble(),
                          ),
                        ),
                      );
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon(
                    src: 'paypal',
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  const Text('Pay with PayPal'),
                  if (isLoading) const SizedBox(width: 8),
                  if (isLoading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
