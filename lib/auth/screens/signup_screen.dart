import 'package:flutter/material.dart';

import 'package:papayask_app/auth/screens/auth_screen.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/auth/widgets/form_devider.dart';
import 'package:papayask_app/auth/widgets/social_icons.dart';
import 'package:papayask_app/shared/app_icon.dart';

class SignupScreen extends StatefulWidget {
  final Function changeMode;
  const SignupScreen({super.key, required this.changeMode});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final authService = AuthService();
  var showPassword = false;
  var isLoading = false;
  final Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
  };

  final Map<String, dynamic> _formErrors = {
    'username': null,
    'email': null,
    'password': null,
  };

  void updateAuthData(String key, String value) {
    _authData[key] = value;
  }

  Future<void> submit() async {
    setState(() {
      _authData.forEach((key, value) {
        _formErrors[key] = null;
      });
    });
    if (_authData['username']!.isEmpty) {
      setState(() {
        _formErrors['username'] = 'Username is required';
      });
      return;
    }
    if (_authData['email']!.isEmpty) {
      setState(() {
        _formErrors['email'] = 'Email is required';
      });
      return;
    }
    if (_authData['password']!.isEmpty) {
      setState(() {
        _formErrors['password'] = 'Password is required';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });
    final response = await authService.signup(
      _authData['email']!,
      _authData['password']!,
      _authData['username']!,
    );

    if (response != 'done') {
      if (response == 'email-already-in-use') {
        setState(() {
          _formErrors['email'] = 'Email already in use';
        });
      } else if (response == 'weak-password') {
        setState(() {
          _formErrors['password'] = 'Password must be at least 6 characters';
        });
      } else {
        setState(() {
          _formErrors['email'] = 'Invalid email';
        });
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'Join us',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const SocialIconsContainer(
            type: 'signup',
          ),
          const SizedBox(
            height: 20,
          ),
          const FormDivider(),
          _buildField('User Name', 'username', updateAuthData),
          _buildField('Email', 'email', updateAuthData),
          _buildField('Password', 'password', updateAuthData),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: isLoading ? null : submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Let\'s Go!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoading) const SizedBox(width: 10),
                if (isLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              InkWell(
                child: Text(
                  'Come in',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onTap: () {
                  widget.changeMode(AuthMode.login);
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  _buildField(String label, String field, Function updateField) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15,
        ),
        TextField(
          onChanged: (value) {
            updateField(field, value);
          },
          obscureText: field == 'password' && !showPassword,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            floatingLabelStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            errorText: _formErrors[field],
            errorStyle: const TextStyle(
              fontSize: 16,
            ),
            suffixIcon: field != 'password'
                ? _formErrors[field] == null
                    ? null
                    : const Icon(
                        Icons.close,
                        color: Colors.red,
                      )
                : IconButton(
                    icon: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: AppIcon(
                        src: showPassword ? 'See' : 'Hide',
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          ),
        ),
      ],
    );
  }
}
