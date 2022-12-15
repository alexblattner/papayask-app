import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CountrySelect extends StatefulWidget {
  final TextEditingController countryController;
  final Function onSelect;
  const CountrySelect({super.key, required this.onSelect, required this.countryController});

  @override
  State<CountrySelect> createState() => _CountrySelectState();
}

class _CountrySelectState extends State<CountrySelect> {

  List<String> countries = [];

  Future<void> loadJson() async {
    final json = await rootBundle.loadString('assets/countries.json');
    final data = List<Map<String, dynamic>>.from(jsonDecode(json));
    final countries = data.map((e) => e['name'] as String).toList();
    setState(() {
      this.countries = countries;
    });
  }

  @override
  void initState() {
    loadJson();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      hideOnEmpty: true,
      minCharsForSuggestions: 1,
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget.countryController,
        decoration: const InputDecoration(
          labelText: 'Country',
        ),
      ),
      suggestionsCallback: ((pattern) {
        return countries.where(
          (String option) {
            return option.toLowerCase().contains(pattern.toLowerCase());
          },
        );
      }),
      itemBuilder: (context, String suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (String suggestion) {
        widget.onSelect(suggestion);
        widget.countryController.text = suggestion;
      },
    );
  }
}
