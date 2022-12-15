import 'package:flutter/material.dart';

import 'package:papayask_app/auth/screens/auth_screen.dart';
import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/auth/widgets/form_devider.dart';
import 'package:papayask_app/auth/widgets/social_icons.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  final Function changeMode;
  const LoginScreen({super.key, required this.changeMode});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService();
  var showPassword = false;
  var isLoading = false;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  final Map<String, dynamic> _formErrors = {
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

    final response = await authService.login(
      _authData['email']!,
      _authData['password']!,
    );

    if (response != 'done') {
      if (response == 'invalid-email') {
        setState(() {
          _formErrors['email'] = 'Invalid email';
        });
      } else if (response == 'user-not-found') {
        setState(() {
          _formErrors['email'] = 'User not found';
        });
      } else if (response == 'wrong-password') {
        setState(() {
          _formErrors['password'] = 'Wrong password';
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'Sign in',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          const SocialIconsContainer(),
          const SizedBox(
            height: 25,
          ),
          const FormDivider(),
          _buildField('Email or Username', 'email', updateAuthData),
          _buildField('Password', 'password', updateAuthData),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryColor,
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
                if (isLoading)
                  const SizedBox(
                    width: 10,
                  ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(0),
            ),
            child: Text(
              'Forgot My Password',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Don\'t have an account? ',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              InkWell(
                child: Text(
                  'Join us now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primaryColor,
                  ),
                ),
                onTap: () {
                  widget.changeMode(AuthMode.signup);
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
          height: 20,
        ),
        TextField(
          onChanged: (value) {
            updateField(field, value);
          },
          obscureText: field == 'password' && !showPassword,
          decoration: InputDecoration(
            labelText: label,
           
            errorText: _formErrors[field],
            errorStyle: const TextStyle(
              fontSize: 16,
            ),
            suffixIcon: field != 'password'
                ? _formErrors[field] != null
                    ? const Icon(
                        Icons.close,
                        color: Colors.red,
                      )
                    : null
                : IconButton(
                    icon: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: AppIcon(
                        src: showPassword ? 'See' : 'Hide',
                        size: 30,
                        color: Theme.of(context).colorScheme.primaryColor,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
