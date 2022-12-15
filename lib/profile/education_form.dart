import 'package:flutter/material.dart';

import 'package:papayask_app/models/education.dart';
import 'package:papayask_app/shared/country_select.dart';
import 'package:papayask_app/shared/university_select.dart';

class EducationForm extends StatefulWidget {
  final Education education;
  final bool isEditing;
  const EducationForm({
    super.key,
    required this.education,
    this.isEditing = false,
  });

  @override
  State<EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  final TextEditingController universityController = TextEditingController();
  final TextEditingController fieldOfStudyController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  void selectUniversity(Map<String, dynamic> university) {
    universityController.text = university['name'];
    countryController.text = university['country'];
    widget.education.university = {
      'name': university['name'],
      'country': university['country'],
      '_id': university['_id'],
    };
  }

  void onChangeUniversity(String value) {
    widget.education.university['name'] = value;
  }

  void selectCountry(String country) {
    countryController.text = country;
    widget.education.university['country'] = country;
  }

  @override
  void initState() {
    if (widget.isEditing) {
      universityController.text = widget.education.university['name'];
      fieldOfStudyController.text = widget.education.name;
      levelController.text = widget.education.level;
      countryController.text = widget.education.university['country'];
      startDateController.text =
          widget.education.startDate.toString().substring(0, 10);
      endDateController.text =
          widget.education.endDate.toString().substring(0, 10);
    }
    super.initState();
  }

  @override
  void dispose() {
    universityController.dispose();
    fieldOfStudyController.dispose();
    levelController.dispose();
    countryController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              flex: 2,
              child: TextField(
                controller: fieldOfStudyController,
                onChanged: (value) {
                  widget.education.name = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Field of study',
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              child: TextField(
                controller: levelController,
                onChanged: (value) {
                  widget.education.level = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Level',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        UniversitySelect(
          selectUniversity: selectUniversity,
          universityController: universityController,
          onChangeUniversity: onChangeUniversity,
        ),
        const SizedBox(
          height: 20,
        ),
        CountrySelect(
          countryController: countryController,
          onSelect: selectCountry,
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Flexible(
              child: TextField(
                controller: startDateController,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: endDateController.text.isNotEmpty
                        ? DateTime.parse(endDateController.text)
                        : DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: endDateController.text.isNotEmpty
                        ? DateTime.parse(endDateController.text)
                        : DateTime.now(),
                  ).then((value) {
                    if (value != null) {
                      startDateController.text = value.toString().split(' ')[0];
                      widget.education.startDate = value;
                    }
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              child: TextField(
                controller: endDateController,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: startDateController.text.isNotEmpty
                        ? DateTime.parse(startDateController.text)
                        : DateTime.now(),
                    firstDate: startDateController.text.isNotEmpty
                        ? DateTime.parse(startDateController.text)
                        : DateTime(1900),
                    lastDate: DateTime.now(),
                  ).then((value) {
                    if (value != null) {
                      endDateController.text = value.toString().split(' ')[0];
                      widget.education.endDate = value;
                    }
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'End Date',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
