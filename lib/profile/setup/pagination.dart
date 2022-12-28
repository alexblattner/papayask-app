import 'package:flutter/material.dart';

import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/theme/colors.dart';

class Pagination extends StatefulWidget {
  final int currentPage;
  final List<int> pagesDone;
  final int pagesCount;
  const Pagination({
    super.key,
    required this.currentPage,
    required this.pagesDone,
    this.pagesCount = 4,
  });

  @override
  State<Pagination> createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  bool isCurrentPage(int index) {
    return widget.currentPage == index + 1;
  }

  bool isPageDone(int index) {
    return widget.pagesDone.contains(index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.pagesCount,
          (index) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (index != 0)
                Container(
                  width: 40,
                  height: 2,
                  color: (widget.currentPage > index + 1 ||
                          widget.pagesDone.contains(index + 1))
                      ? Theme.of(context).colorScheme.primaryColor
                      : Colors.white,
                ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPageDone(index) && !isCurrentPage(index)
                      ? Theme.of(context).colorScheme.primaryColor
                      : isCurrentPage(index)
                          ? Theme.of(context).colorScheme.primaryColor_L1
                          : Colors.white,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primaryColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isPageDone(index) && !isCurrentPage(index)
                      ? const AppIcon(
                          src: 'check',
                          color: Colors.white,
                          size: 14,
                        )
                      : Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            color: (widget.currentPage >= index + 1)
                                ? Colors.white
                                : Theme.of(context).colorScheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
