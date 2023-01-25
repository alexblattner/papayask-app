import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/main/filters_divider.dart';
import 'package:papayask_app/main/filters_widgets/education_filter.dart';
import 'package:papayask_app/main/applied_filters.dart';
import 'package:papayask_app/main/filters_widgets/location_filter.dart';
import 'package:papayask_app/main/filters_widgets/budget_filter.dart';
import 'package:papayask_app/main/filters_widgets/experience_filter.dart';
import 'package:papayask_app/main/advisor_service.dart';
import 'package:papayask_app/theme/colors.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  @override
  Widget build(BuildContext context) {
    final advisorService = Provider.of<AdvisorService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (advisorService.filters.isNotEmpty)
            TextButton(
              onPressed: () {
                advisorService.clearFilters();
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryColor,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          advisorService.setFilters();
          Navigator.of(context).pop();
        },
        label: Text('Show ${advisorService.tmpFilteredCount} advisors'),
      ),
      body: SafeArea(
        child: ListView(
          children: const [
            AppliedFilters(),
            BudgetFilter(),
            FiltersDivider(),
            ExperienceFilter(),
            
            LocationFilter(),
        
            EducationFilter(),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
