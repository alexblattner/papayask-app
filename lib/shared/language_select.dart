import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class LanguageSelect extends StatefulWidget {
  final Function onLanguageSelected;
  const LanguageSelect({super.key, required this.onLanguageSelected});

  @override
  State<LanguageSelect> createState() => _LanguageSelectState();
}

class _LanguageSelectState extends State<LanguageSelect> {
  final TextEditingController typeAheadController = TextEditingController();

  List<String> languages = [];

  Future<void> loadJson() async {
    final json = await rootBundle.loadString('assets/languages.json');
    final data = List<Map<String, dynamic>>.from(jsonDecode(json));
    final languages = data.map((e) => e['name'] as String).toList();
    setState(() {
      this.languages = languages;
    });
  }

  @override
  void initState() {
    loadJson();
    super.initState();
  }

  @override
  void dispose() {
    typeAheadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      hideOnEmpty: true,
      minCharsForSuggestions: 1,
      textFieldConfiguration: TextFieldConfiguration(
        controller: typeAheadController,
        decoration: const InputDecoration(
          labelText: 'Language',
        ),
      ),
      suggestionsCallback: ((pattern) {
        return languages.where(
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
        widget.onLanguageSelected(suggestion);
        typeAheadController.text = '';
      },
    );
  }
}
