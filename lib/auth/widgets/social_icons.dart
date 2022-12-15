import 'package:flutter/material.dart';

import 'package:papayask_app/auth/auth_service.dart';
import 'package:papayask_app/shared/app_icon.dart';
import 'package:papayask_app/theme/colors.dart';

class SocialIconsContainer extends StatefulWidget {
  final String type;
  const SocialIconsContainer({
    Key? key,
    this.type = 'login',
  }) : super(key: key);

  @override
  State<SocialIconsContainer> createState() => _SocialIconsContainerState();
}

class _SocialIconsContainerState extends State<SocialIconsContainer> {
  final Map<String, bool> _isloading = {
    'facebook': false,
    'google': false,
    'apple': false,
  };

  void toggleLoading(String provider) {
    setState(() {
      _isloading[provider] = !_isloading[provider]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            toggleLoading('facebook');
            await authService.signInWithFacebook();
            toggleLoading('facebook');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 35,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.blue,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const AppIcon(
                    src: 'facebook_f',
                    size: 15,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),
                Text(
                  '${widget.type == 'login' ? 'Sign' : 'Join'} in with Facebook',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_isloading['facebook']!)
                  const SizedBox(
                    width: 10,
                  ),
                if (_isloading['facebook']!)
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
        ),
        const SizedBox(
          height: 16,
        ),
        GestureDetector(
          onTap: () async {
            toggleLoading('google');
            await authService.signInWithGoogle();
            toggleLoading('google');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 35,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppIcon(
                  src: 'google',
                  size: 25,
                  color: Theme.of(context).colorScheme.primaryColor,
                ),
                const SizedBox(
                  width: 25,
                ),
                Text(
                  '${widget.type == 'login' ? 'Sign' : 'Join'} in with Google',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primaryColor,
                  ),
                ),
                if (_isloading['google']!)
                  const SizedBox(
                    width: 10,
                  ),
                if (_isloading['google']!)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        GestureDetector(
          onTap: () async {},
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 35,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const AppIcon(
                  src: 'apple_white',
                  size: 25,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 25,
                ),
                Text(
                  '${widget.type == 'login' ? 'Sign' : 'Join'} in with Apple',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_isloading['apple']!)
                  const SizedBox(
                    width: 10,
                  ),
                if (_isloading['apple']!)
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
        ),
      ],
    );
  }
}
