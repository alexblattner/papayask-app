import 'package:flutter/material.dart';
import 'package:papayask_app/main/filters_divider.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/main/advisor_service.dart';
import 'package:papayask_app/theme/colors.dart';

class AppliedFilters extends StatelessWidget {
  const AppliedFilters({super.key});

  String filterToString(Filter filter) {
    switch (filter) {
      case Filter.experience:
        return 'Experience';
      case Filter.budget:
        return 'Budget';
      case Filter.country:
        return 'Country';
      case Filter.language:
        return 'Language';
      case Filter.education:
        return 'Education';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final advisorService = Provider.of<AdvisorService>(context);
    List<Filter> filters = advisorService.filters;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filters.isNotEmpty)
            const Text(
              'Applied Filters:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (filters.isNotEmpty) const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            spacing: 8,
            children: [
              ...filters.map(
                (filter) => Chip(
                  label: Text(filterToString(filter)),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primaryColor,
                  ),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryColor
                      .withOpacity(0.2),
                  deleteIconColor: Theme.of(context).colorScheme.primaryColor,
                  onDeleted: () {
                    advisorService.removeFilter(filter);
                  },
                ),
              ),
            ],
          ),
          if (filters.isNotEmpty) const FiltersDivider(),
        ],
      ),
    );
  }
}
