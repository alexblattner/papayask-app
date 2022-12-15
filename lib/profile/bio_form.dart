import 'package:flutter/material.dart';

class BioForm extends StatefulWidget {
  final String userBio;
  final Function updateBio;
  const BioForm({super.key, required this.userBio, required this.updateBio});

  @override
  State<BioForm> createState() => _BioFormState();
}

class _BioFormState extends State<BioForm> {
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    bioController.text = widget.userBio;
    super.initState();
  }

  @override
  void dispose() {
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          maxLines: null,
          minLines: 7,
          keyboardType: TextInputType.multiline,
          controller: bioController,
          onChanged: (value) {
            widget.updateBio(value);
          
          },
        ),
      ],
    );
  }
}
