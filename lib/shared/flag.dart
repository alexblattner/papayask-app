import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Flag extends StatefulWidget {
  final String country;
  const Flag({super.key, required this.country});

  @override
  State<Flag> createState() => _FlagState();
}

class _FlagState extends State<Flag> {
  var flag = '';

  Future<void> loadJson() async {
    final json = await rootBundle.loadString('assets/flags.json');
    final data = Map<String, dynamic>.from(jsonDecode(json));
    final country = data.entries.firstWhere((element) {
      return element.value['name'] == widget.country;
    });
    setState(() {
      flag = country.value['emoji'];
    });
  }

  @override
  void initState() {
    loadJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      flag,
      style: const TextStyle(fontSize: 32),
    );
  }
}
