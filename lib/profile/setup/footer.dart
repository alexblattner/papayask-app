import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int currentPage;
  final Function setCurrentPage;
  final Function submit;
  final bool isLoading;
  final bool isSaving;
  final bool isAdvisorSetup;
  final int progress;
  const Footer({
    super.key,
    required this.currentPage,
    required this.setCurrentPage,
    required this.submit,
    required this.isLoading,
    required this.isSaving,
    required this.isAdvisorSetup,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isAdvisorSetup)
              ElevatedButton(
                onPressed: () {
                  submit('save');
                },
                child: Row(
                  children: [
                    Text('SAVE ($progress%)'),
                    if (isSaving) const SizedBox(width: 8),
                    if (isSaving)
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
            const Spacer(),
            TextButton(
              onPressed: () {
                if (currentPage > 1) {
                  setCurrentPage(currentPage - 1);
                }
              },
              child: const Text('BACK'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (currentPage < 4) {
                  setCurrentPage(currentPage + 1);
                } else {
                  submit('submit');
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentPage < 4
                        ? 'NEXT'
                        : isAdvisorSetup
                            ? 'SUBMIT'
                            : 'SAVE',
                  ),
                  if (isLoading) const SizedBox(width: 8),
                  if (isLoading)
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
      ),
    );
  }
}
