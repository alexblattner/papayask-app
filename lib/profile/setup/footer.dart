import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int currentPage;
  final Function setCurrentPage;
  final Function submit;
  final bool isLoading;
  const Footer({
    super.key,
    required this.currentPage,
    required this.setCurrentPage,
    required this.submit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
                submit();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentPage == 4 ? 'FINISH' : 'NEXT'),
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
    );
  }
}
