import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

class CompanySelect extends StatefulWidget {
  final Function selectCompany;
  final TextEditingController companyController;
  final Function onChangeCompany;
  const CompanySelect({
    super.key,
    required this.selectCompany,
    required this.companyController,
    required this.onChangeCompany,
  });

  @override
  State<CompanySelect> createState() => _CompanySelectState();
}

class _CompanySelectState extends State<CompanySelect> {
  Future<List<Map<String, dynamic>>> getUniversities(String query) async {
    final res = await http
        .get(Uri.parse('${FlutterConfig.get('API_URL')}/company/$query'));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final comapnyList = List<Map<String, dynamic>>.from(data['companies']);
    return comapnyList;
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      minCharsForSuggestions: 1,
      hideOnEmpty: true,
      hideOnLoading: true,
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget.companyController,
        decoration: const InputDecoration(
          labelText: 'Company',
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
        widget.selectCompany(suggestion);
      },
    );
  }
}
