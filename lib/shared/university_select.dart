import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

class UniversitySelect extends StatefulWidget {
  final Function selectUniversity;
  final TextEditingController universityController;
  final Function onChangeUniversity;
  const UniversitySelect({
    super.key,
    required this.selectUniversity,
    required this.universityController,
    required this.onChangeUniversity,
  });

  @override
  State<UniversitySelect> createState() => _UniversitySelectState();
}

class _UniversitySelectState extends State<UniversitySelect> {
  Future<List<Map<String, dynamic>>> getUniversities(String query) async {
    final res = await http
        .get(Uri.parse('${FlutterConfig.get('API_URL')}/university/$query'));
    final data = List<Map<String, dynamic>>.from(jsonDecode(res.body));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      minCharsForSuggestions: 1,
      hideOnEmpty: true,
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget.universityController,
        decoration: const InputDecoration(
          labelText: 'University',
        ),
      ),
      suggestionsCallback: (pattern) async {
        return await getUniversities(pattern);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion['name']),
        );
      },
      onSuggestionSelected: (suggestion) {
        widget.selectUniversity(suggestion);
      },
    );
  }
}
