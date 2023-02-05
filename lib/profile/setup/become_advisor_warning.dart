import 'package:flutter/material.dart';

import 'package:papayask_app/theme/colors.dart';
import 'package:papayask_app/profile/become_advisor_modal.dart';

class BecomeAdvisorWarning extends StatefulWidget {
  final BecomeAdvisorModalType type;
  final int? progress;
  final Function onClose;
  final Function submit;
  final bool isSaving;
  const BecomeAdvisorWarning({
    super.key,
    required this.type,
    this.progress,
    required this.onClose,
    required this.submit,
    required this.isSaving,
  });

  @override
  State<BecomeAdvisorWarning> createState() => _BecomeAdvisorWarningState();
}

class _BecomeAdvisorWarningState extends State<BecomeAdvisorWarning> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                widget.onClose();
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Thank you for your interest in becoming an advisor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'In order to become an advisor your have to complete at least 75% of the process',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 32),
                      RichText(
                        text: TextSpan(
                          text: 'Current progress: ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${widget.progress}%',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Keep Editing',
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          widget.onClose();
                          widget.submit('save');
                        },
                        child: Row(
                          children: [
                            const Text(
                              'Save Progress',
                            ),
                            if (widget.isSaving) const SizedBox(width: 8),
                            if (widget.isSaving)
                              const SizedBox(
                                height: 16,
                                width: 16,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
