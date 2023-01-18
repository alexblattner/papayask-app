import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/profile/setup/setup_screen.dart';
import 'package:papayask_app/theme/colors.dart';

enum BecomeAdvisorModalType {
  submitWarning,
  pendingApproval,
  info,
  inComplete,
}

class BecomeAdvisorModal extends StatefulWidget {
  final BecomeAdvisorModalType type;
  final int? progress;
  final Function onClose;
  const BecomeAdvisorModal({
    super.key,
    this.progress,
    required this.onClose,
    required this.type,
  });

  @override
  State<BecomeAdvisorModal> createState() => _BecomeAdvisorModalState();
}

class _BecomeAdvisorModalState extends State<BecomeAdvisorModal> {
  var isLoading = false;

  _biuldContent(BuildContext context) {
    switch (widget.type) {
      case BecomeAdvisorModalType.submitWarning:
        return Column(
          mainAxisSize: MainAxisSize.min,
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
                    text: '${widget.progress}%',
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
          mainAxisSize: MainAxisSize.min,
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
        return Column(
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
                      color: Theme.of(context).colorScheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context);
    User authUser = authProvider.authUser!;
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
                  _biuldContent(context),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          widget.onClose();
                        },
                        child: const Text(
                          'Cancel',
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (authUser.advisorStatus == 'pending' ||
                              (authUser.advisorStatus == false &&
                                  authUser.progress < 75)) {
                            widget.onClose();
                            Navigator.of(context).pushNamed(
                              SetupScreen.routeName,
                              arguments: {
                                'user': authProvider.authUser,
                                'isAdvisorSetup':
                                    authUser.advisorStatus == 'pending'
                                        ? false
                                        : true,
                              },
                            );
                          } else if (authUser.advisorStatus == false &&
                              authUser.progress >= 75) {
                            setState(() {
                              isLoading = true;
                            });
                            final res = await authProvider.becomeAnAdvisor();
                            if (!mounted) return;
                            if (res == 'done') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Application submitted successfully',
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
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
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              authUser.advisorStatus == 'pending' ||
                                      (authUser.advisorStatus == false &&
                                          authUser.progress < 75)
                                  ? 'Edit profile'
                                  : 'Become an advisor',
                            ),
                            if (isLoading)
                              const SizedBox(
                                width: 10,
                              ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
