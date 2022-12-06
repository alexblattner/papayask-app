import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Flag extends StatefulWidget {
  const Flag({super.key});

  @override
  State<Flag> createState() => _FlagState();
}

class _FlagState extends State<Flag> {
  Future<void> loadJson() async {
    final json = await rootBundle.loadString('assets/flags.json');
    final data = jsonDecode(json);
    print(data);
  }

  @override
  void initState() {
    loadJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
