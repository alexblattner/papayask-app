import 'package:flutter/material.dart';
import 'package:papayask_app/shared/language_select.dart';
import 'package:papayask_app/shared/badge.dart';

class LanguageForm extends StatefulWidget {
  final List languages;
  const LanguageForm({super.key, required this.languages});

  @override
  State<LanguageForm> createState() => _LanguageFormState();
}

class _LanguageFormState extends State<LanguageForm> {
  void removeLanguage(String language) {
    setState(() {
      widget.languages.remove(language);
    });
  }

  void onLanguageSelected(String language) {
    setState(() {
      widget.languages.add(language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: [
            for (final language in widget.languages)
              Badge(
                text: language,
                isRemovable: true,
                onRemove: removeLanguage,
              ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        LanguageSelect(
          onLanguageSelected: onLanguageSelected,
        )
      ],
    );
  }
}
