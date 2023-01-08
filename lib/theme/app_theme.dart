import 'package:flutter/material.dart';

import 'package:papayask_app/theme/colors.dart';

ThemeData appTheme(BuildContext context) {
  return ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      labelStyle: const TextStyle(
        color: Colors.grey,
      ),
      floatingLabelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
    ),
    appBarTheme: AppBarTheme(
      elevation: 1,
      color: Colors.white,
      titleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.primaryColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        foregroundColor: Theme.of(context).colorScheme.primaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primaryColor,
          width: 1,
        ),
        foregroundColor: Theme.of(context).colorScheme.primaryColor,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Theme.of(context).colorScheme.primaryColor,
      linearTrackColor: Theme.of(context).colorScheme.secondaryColor,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade400,
      thickness: 1,
      space: 25,
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.primaryColor,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Theme.of(context).colorScheme.primaryColor,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primaryColor,
            width: 2,
          ),
        ),
      ),
    ),
  );
}
