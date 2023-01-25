import 'package:flutter/material.dart';
import 'package:papayask_app/main/filters_divider.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/main/advisor_service.dart';
import 'package:papayask_app/theme/colors.dart';

class EducationFilter extends StatefulWidget {
  const EducationFilter({super.key});

  @override
  State<EducationFilter> createState() => _EducationFilterState();
}

class _EducationFilterState extends State<EducationFilter> {
  var showAllUniversities = false;
  var showAllDegrees = false;
  var showAllFields = false;

  void filterByUniversity() {
    final advsiorService = Provider.of<AdvisorService>(context, listen: false);
    var value = {'universities': []};
    for (Map<String, dynamic> university
        in advsiorService.universitiesAvailable) {
      if (university['selected']) {
        value['universities']!.add(university['name']);
      }
    }
    advsiorService.applyFilter(Filter.education, value);
  }

  void filterByDegree() {
    final advsiorService = Provider.of<AdvisorService>(context, listen: false);
    var value = {'degrees': []};
    for (Map<String, dynamic> degree in advsiorService.degreesAvailable) {
      if (degree['selected']) {
        value['degrees']!.add(degree['name']);
      }
    }
    advsiorService.applyFilter(Filter.education, value);
  }

  void filterByField() {
    final advsiorService = Provider.of<AdvisorService>(context, listen: false);
    var value = {'fieldsOfStudy': []};
    for (Map<String, dynamic> field in advsiorService.fieldsOfStudyAvailable) {
      if (field['selected']) {
        value['fieldsOfStudy']!.add(field['name']);
      }
    }
    advsiorService.applyFilter(Filter.education, value);
  }

  @override
  Widget build(BuildContext context) {
    final advsiorService = Provider.of<AdvisorService>(context);
    List<Map<String, dynamic>> universities =
        advsiorService.universitiesAvailable;
    List<Map<String, dynamic>> degrees = advsiorService.degreesAvailable;
    List<Map<String, dynamic>> fields = advsiorService.fieldsOfStudyAvailable;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (universities.isNotEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'University:',
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
            itemCount: universities.length < 3
                ? universities.length
                : showAllUniversities
                    ? universities.length
                    : 3,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(
                    '${universities[index]['name']} (${universities[index]['count']})'),
                value: universities[index]['selected'],
                onChanged: (value) {
                  advsiorService
                      .toggleUniversitySelection(universities[index]['name']);
                  filterByUniversity();
                },
              );
            },
          ),
          if (universities.length > 3)
            TextButton(
              onPressed: () {
                setState(() {
                  showAllUniversities = !showAllUniversities;
                });
              },
              child: Text(
                showAllUniversities ? 'Show less' : 'Show more',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryColor,
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (degrees.isNotEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Degree:',
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
            itemCount: degrees.length < 3
                ? degrees.length
                : showAllDegrees
                    ? degrees.length
                    : 3,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(
                    '${degrees[index]['name']} (${degrees[index]['count']})'),
                value: degrees[index]['selected'],
                onChanged: (value) {
                  advsiorService.toggleDegreeSelection(degrees[index]['name']);
                  filterByDegree();
                },
              );
            },
          ),
          if (degrees.length > 3)
            TextButton(
              onPressed: () {
                setState(() {
                  showAllDegrees = !showAllDegrees;
                });
              },
              child: Text(
                showAllDegrees ? 'Show less' : 'Show more',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryColor,
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (fields.isNotEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Field of Study:',
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
            itemCount: fields.length < 3
                ? fields.length
                : showAllFields
                    ? fields.length
                    : 3,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(
                    '${fields[index]['name']} (${fields[index]['count']})'),
                value: fields[index]['selected'],
                onChanged: (value) {
                  advsiorService
                      .toggleFieldOfStudySelection(fields[index]['name']);
                  filterByField();
                },
              );
            },
          ),
          if (fields.length > 3)
            TextButton(
              onPressed: () {
                setState(() {
                  showAllFields = !showAllFields;
                });
              },
              child: Text(
                showAllFields ? 'Show less' : 'Show more',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryColor,
                ),
              ),
            ),
          if (fields.isNotEmpty ||
              universities.isNotEmpty ||
              degrees.isNotEmpty)
            const FiltersDivider(),
        ],
      ),
    );
  }
}
