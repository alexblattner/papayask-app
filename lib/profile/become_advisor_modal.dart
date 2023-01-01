import 'package:flutter/material.dart';

import 'package:papayask_app/theme/colors.dart';

enum BecomeAdvisorModalType {
  submitWarning,
  pendingApproval,
  info,
  inComplete,
}

class BecomeAdvisorModal extends StatelessWidget {
  final BecomeAdvisorModalType type;
  final int? progress;
  const BecomeAdvisorModal({
    super.key,
    this.progress,
    required this.type,
  });

  _biuldContent(BuildContext context) {
    switch (type) {
      case BecomeAdvisorModalType.submitWarning:
        return Column(
          children: [
            Text(
              'You haven\'t completed your set up!',
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
                    text: '$progress%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case BecomeAdvisorModalType.pendingApproval:
        return Column(
          children: [
            Text(
              'Your application is pending!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Please be aware that the review process can take some time.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'We appreciate your patience and will be in touch with you as soon as a decision has been made regarding your application.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              ' In the meantime, you can continue to edit your profile and add more information.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        );
      case BecomeAdvisorModalType.info:
        return Column(
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
              'In order to ensure that we are able to provide the best possible service to our clients, we carefully review all applications to become an advisor.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              ' We appreciate your patience as we review your information and make a decision on your application.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        );
      case BecomeAdvisorModalType.inComplete:
        return Column();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _biuldContent(context),
    );
  }
}
