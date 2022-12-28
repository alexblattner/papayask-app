import 'package:flutter/material.dart';

import 'package:papayask_app/models/education.dart';
import 'package:papayask_app/models/university.dart';
import 'package:papayask_app/shared/country_select.dart';
import 'package:papayask_app/shared/university_select.dart';

class EducationForm extends StatefulWidget {
  final Education education;
  final bool isEditing;
  final Function? addEducation;
  final bool isInSetup;
  const EducationForm({
    super.key,
    required this.education,
    this.isEditing = false,
    this.addEducation,
    this.isInSetup = false,
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
    widget.education.university = University(
      country: university['country'],
      name: university['name'],
      id: university['_id'],
      rank: university['rank'],
    );
  }

  void onChangeUniversity(String value) {
    widget.education.university.name = value;
  }

  void selectCountry(String country) {
    countryController.text = country;
    widget.education.university.country = country;
  }

  void resetControllers() {
    universityController.clear();
    fieldOfStudyController.clear();
    levelController.clear();
    countryController.clear();
    startDateController.clear();
    endDateController.clear();
  }

  @override
  void didChangeDependencies() {
    universityController.text = widget.education.university.name;
    fieldOfStudyController.text = widget.education.name;
    levelController.text = widget.education.level;
    countryController.text = widget.education.university.country;
    startDateController.text =
        widget.education.startDate.toString().substring(0, 10) ==
                DateTime.now().toString().substring(0, 10)
            ? ''
            : widget.education.startDate.toString().substring(0, 10);
    endDateController.text = widget.education.endDate == null ||
            widget.education.endDate.toString().substring(0, 10) ==
                DateTime.now().toString().substring(0, 10)
        ? ''
        : widget.education.endDate.toString().substring(0, 10);

    super.didChangeDependencies();
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
                  setState(() {
                    widget.education.name = value;
                  });
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
        if (widget.isInSetup) const SizedBox(height: 12),
        if (widget.isInSetup)
          ElevatedButton(
            onPressed: () {
              widget.addEducation!(widget.education);
              resetControllers();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('ADD'),
              ],
            ),
          ),
      ],
    );
  }
}
