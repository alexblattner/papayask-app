import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/theme/colors.dart';

class QuestionSettings extends StatefulWidget {
  const QuestionSettings({super.key});

  @override
  State<QuestionSettings> createState() => _QuestionSettingsState();
}

class _QuestionSettingsState extends State<QuestionSettings> {
  var isLoading = false;
  Map<String, dynamic> settings = {
    'cost': 0,
    'time_limit': {
      'days': 0,
      'hours': 0,
    },
    'concurrent': 0,
  };

  String get cost => settings['cost'] > 0 ? settings['cost'].toString() : '';
  String get days => settings['time_limit']['days'] > 0
      ? settings['time_limit']['days'].toString()
      : '';
  String get hours => settings['time_limit']['hours'] > 0
      ? settings['time_limit']['hours'].toString()
      : '';
  String get concurrent =>
      settings['concurrent'] > 0 ? settings['concurrent'].toString() : '';

  Future<void> saveSettings() async {
    setState(() {
      isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final res = await authService.updateSettings(settings);
    if (!mounted) return;
    if (res == 'done') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved', textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong', textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    final authService = Provider.of<AuthService>(context, listen: false);
    User user = authService.authUser!;
    if (user.requestSettings != null) {
      settings = user.requestSettings!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Settings'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'How much it is cost?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: cost,
                      onChanged: (value) {
                        if (value == '') {
                          settings['cost'] = 0;
                        } else {
                          settings['cost'] = double.parse(value);
                        }
                      },
                    ),
                  ),
                  Text(
                    '\$',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'How long it takes?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Days',
                      ),
                      initialValue: days,
                      onChanged: (value) {
                        if (value == '') {
                          settings['time_limit']['days'] = 0;
                        } else {
                          settings['time_limit']['days'] = int.parse(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Hours',
                      ),
                      initialValue: hours,
                      onChanged: (value) {
                        if (value == '') {
                          settings['time_limit']['hours'] = 0;
                        } else {
                          settings['time_limit']['hours'] = int.parse(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'How many questions at once?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: concurrent,
                      onChanged: (value) {
                        if (value == '') {
                          settings['concurrent'] = 0;
                        } else {
                          settings['concurrent'] = int.parse(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? () {} : saveSettings,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Save'),
                    if (isLoading) const SizedBox(width: 8),
                    if (isLoading)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
