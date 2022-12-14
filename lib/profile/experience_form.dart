import 'package:flutter/material.dart';
import 'package:papayask_app/models/company.dart';
import 'package:papayask_app/models/experience.dart';
import 'package:papayask_app/shared/company_select.dart';
import 'package:papayask_app/shared/country_select.dart';
import 'package:select_form_field/select_form_field.dart';

class ExperienceForm extends StatefulWidget {
  final Experience experience;
  final bool isEditing;
  final Function? addExperience;
  final bool isInSetup;
  const ExperienceForm({
    super.key,
    required this.experience,
    this.isEditing = false,
    this.addExperience,
    this.isInSetup = false,
  });

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  final TextEditingController positionController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  void selectCountry(String country) {
    countryController.text = country;
    widget.experience.geographicSpecialization = [country];
  }

  void resetControllers() {
    positionController.clear();
    levelController.clear();
    companyController.clear();
    countryController.clear();
    startDateController.clear();
    endDateController.clear();
  }

  @override
  void didChangeDependencies() {
    positionController.text = widget.experience.name;
    levelController.text = widget.experience.type;
    companyController.text = widget.experience.company.name;
    countryController.text =
        widget.experience.geographicSpecialization.isNotEmpty
            ? widget.experience.geographicSpecialization[0]
            : '';
    startDateController.text =
        widget.experience.startDate.toString().substring(0, 10) ==
                DateTime.now().toString().substring(0, 10)
            ? ''
            : widget.experience.startDate.toString().substring(0, 10);
    endDateController.text = widget.experience.endDate == null ||
            widget.experience.endDate.toString().substring(0, 10) ==
                DateTime.now().toString().substring(0, 10)
        ? ''
        : widget.experience.endDate.toString().substring(0, 10);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    positionController.dispose();
    levelController.dispose();
    companyController.dispose();
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
              child: TextField(
                controller: positionController,
                onChanged: (value) {
                  widget.experience.name = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Position',
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              child: SelectFormField(
                type: SelectFormFieldType.dropdown,
                controller: levelController,
                labelText: 'Experience Type',
                items: const [
                  {'value': 'Employee', 'label': 'Employee'},
                  {'value': 'Freelance', 'label': 'Freelance'},
                  {'value': 'Owner', 'label': 'Owner'},
                ],
                onChanged: (val) => widget.experience.type = val,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        CompanySelect(
          selectCompany: (Map<String, dynamic> company) {
            widget.experience.company = Company.fromJson(company);
            companyController.text = company['name'];
          },
          companyController: companyController,
          onChangeCompany: (String value) {
            widget.experience.company.name = value;
          },
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
                      widget.experience.startDate = value;
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
                      widget.experience.endDate = value;
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
              widget.addExperience!(widget.experience);
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
