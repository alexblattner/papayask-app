import 'package:flutter/material.dart';
import 'package:papayask_app/main/filters_divider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'package:papayask_app/main/advisor_service.dart';
import 'package:papayask_app/theme/colors.dart';

class ExperienceFilter extends StatefulWidget {
  const ExperienceFilter({super.key});

  @override
  State<ExperienceFilter> createState() => _ExperienceFilterState();
}

class _ExperienceFilterState extends State<ExperienceFilter> {
  var showAllPositions = false;
  void filterByYearsOfExperience(double min, double max) {
    final advisorService = Provider.of<AdvisorService>(context, listen: false);
    advisorService.applyFilter(Filter.experience, {
      'min': min,
      'max': max,
    });
  }

  void filterByPosition() {
    final advisorService = Provider.of<AdvisorService>(context, listen: false);
    var value = {'positions': []};
    for (Map<String, dynamic> position in advisorService.positionsAvailable) {
      if (position['selected']) {
        value['positions']!.add(position['name']);
      }
    }
    advisorService.applyFilter(Filter.experience, value);
  }

  @override
  Widget build(BuildContext context) {
    final advisorService = Provider.of<AdvisorService>(context);
    double max = advisorService.yearsOfExperienceSliderValues.last.toDouble();
    double min = advisorService.yearsOfExperienceSliderValues.first.toDouble();
    final values = advisorService.yearsOfExperienceSliderRangeValues;
    final positions = advisorService.positionsAvailable;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Years of Experience:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SfRangeSlider(
            min: min,
            max: max,
            values: values,
            startThumbIcon: Center(
              child: Text(
                values.start.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            endThumbIcon: Center(
              child: Text(
                values.end.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            activeColor: Theme.of(context).colorScheme.primaryColor,
            inactiveColor:
                Theme.of(context).colorScheme.primaryColor.withOpacity(0.2),
            onChanged: (value) {
              advisorService.setYearsOfExperienceSliderRangeValues(
                  value.start, value.end);
            },
            onChangeEnd: (value) {
              filterByYearsOfExperience(value.start, value.end);
            },
          ),
          const SizedBox(height: 16),
          if (positions.isNotEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Position:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 8),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: positions.length < 3
                ? positions.length
                : showAllPositions
                    ? positions.length
                    : 3,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(positions[index]['name']),
                value: positions[index]['selected'],
                onChanged: (value) {
                  advisorService
                      .togglePositionSelected(positions[index]['name']);
                  filterByPosition();
                },
              );
            },
          ),
          if (positions.length > 3)
            TextButton(
              onPressed: () {
                setState(() {
                  showAllPositions = !showAllPositions;
                });
              },
              child: Text(
                showAllPositions ? 'Show less' : 'Show more',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryColor,
                ),
              ),
            ),
          if (positions.isNotEmpty) const FiltersDivider(),
        ],
      ),
    );
  }
}
