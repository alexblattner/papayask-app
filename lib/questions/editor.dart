import 'package:flutter/material.dart';

import 'package:html_editor_enhanced/html_editor.dart';
import 'package:papayask_app/theme/colors.dart';

class NoteEditor extends StatelessWidget {
  final Function setContent;
  final HtmlEditorController controller;
  const NoteEditor({
    super.key,
    required this.setContent,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlEditor(
      controller: controller,
      callbacks: Callbacks(
        onChangeContent: (value) {
          if (value != null) {
            setContent(value);
          }
        },
      ),
      htmlEditorOptions: const HtmlEditorOptions(
        hint: 'Type your note here',
        shouldEnsureVisible: true,
      ),
      htmlToolbarOptions: HtmlToolbarOptions(
        buttonSelectedColor: Theme.of(context).colorScheme.primaryColor,
        buttonFocusColor: Theme.of(context).colorScheme.primaryColor,
        buttonFillColor: Theme.of(context).colorScheme.primaryColor_L2,
        defaultToolbarButtons: [
          const ListButtons(listStyles: false),
          const FontSettingButtons(
            fontName: false,
            fontSizeUnit: false,
          ),
          const FontButtons(
            strikethrough: false,
            subscript: false,
            superscript: false,
            clearAll: false,
          ),
        ],
      ),
      otherOptions: OtherOptions(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 2,
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
