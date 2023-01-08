import 'package:flutter/material.dart';

import 'package:papayask_app/questions/question_screen.dart';
import 'package:papayask_app/questions/questions_service.dart';
import 'package:provider/provider.dart';

class RejectModal extends StatefulWidget {
  final String questionId;
  const RejectModal({super.key, required this.questionId});

  @override
  State<RejectModal> createState() => _RejectModalState();
}

class _RejectModalState extends State<RejectModal> {
  RejectReason? _rejectReason;
  String rejectString = '';
  final TextEditingController _otherController = TextEditingController();
  var isLoaging = false;

  void setRejectReason(String reason) {
    setState(() {
      rejectString = reason;
    });
  }

  Future<void> reject() async {
    final questionsProvider =
        Provider.of<QuestionsService>(context, listen: false);
    setState(() {
      isLoaging = true;
    });
    final res =
        await questionsProvider.rejectQuestion(widget.questionId, rejectString);
    setState(() {
      isLoaging = false;
    });
    if (!mounted) return;
    if (res == 'Success') {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Why did you choose to decline?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 32,
        ),
        RadioListTile<RejectReason>(
          title: const Text(
            'I don\'t have the time to complete this request.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          value: RejectReason.notEnoughTime,
          groupValue: _rejectReason,
          onChanged: (value) {
            setState(() {
              _rejectReason = value;
            });
            setRejectReason('I don\'t have the time to complete this request.');
          },
        ),
        RadioListTile<RejectReason>(
          title: const Text(
            'Out of my area of expertise.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          value: RejectReason.outOfScope,
          groupValue: _rejectReason,
          onChanged: (value) {
            setState(() {
              _rejectReason = value;
            });
            setRejectReason('Out of my area of expertise.');
          },
        ),
        RadioListTile<RejectReason>(
          title: const Text(
            'Too much effort',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          value: RejectReason.tooMuchWork,
          groupValue: _rejectReason,
          onChanged: (value) {
            setState(() {
              _rejectReason = value;
            });
            setRejectReason('Too much effort');
          },
        ),
        if (_rejectReason == RejectReason.other)
          const SizedBox(
            height: 32,
          ),
        if (_rejectReason == RejectReason.other)
          TextField(
            controller: _otherController,
            onChanged: (value) {
              setRejectReason(value);
            },
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Please specify',
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        if (_rejectReason != RejectReason.other)
          RadioListTile<RejectReason>(
            title: const Text(
              'Other',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            value: RejectReason.other,
            groupValue: _rejectReason,
            onChanged: (value) {
              setState(() {
                _rejectReason = value;
              });
            },
          ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoaging || rejectString == '' ? null : reject,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Reject',
                    ),
                    if (isLoaging)
                      const SizedBox(
                        width: 10,
                      ),
                    if (isLoaging)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
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
    );
  }
}
