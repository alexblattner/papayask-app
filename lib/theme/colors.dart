// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

// @immutable
// class AppColors extends ThemeExtension<AppColors> {
//   const AppColors({
//     required this.primaryColor,
//     required this.primaryColor_D1,
//     required this.primaryColor_D2,
//     required this.primaryColor_L1,
//     required this.primaryColor_L2,
//     required this.secondaryColor,
//     required this.secondaryColor_D1,
//     required this.secondaryColor_D2,
//     required this.secondaryColor_L1,
//     required this.secondaryColor_L2,
//   });
//   final Color primaryColor;
//   final Color primaryColor_D1;
//   final Color primaryColor_D2;
//   final Color primaryColor_L1;
//   final Color primaryColor_L2;
//   final Color secondaryColor;
//   final Color secondaryColor_D1;
//   final Color secondaryColor_D2;
//   final Color secondaryColor_L1;
//   final Color secondaryColor_L2;

//   @override
//   AppColors copyWith({
//     Color? primaryColor,
//     Color? primaryColor_D1,
//     Color? primaryColor_D2,
//     Color? primaryColor_L1,
//     Color? primaryColor_L2,
//     Color? secondaryColor,
//     Color? secondaryColor_D1,
//     Color? secondaryColor_D2,
//     Color? secondaryColor_L1,
//     Color? secondaryColor_L2,
//   }) {
//     return AppColors(
//       primaryColor: primaryColor ?? this.primaryColor,
//       primaryColor_D1: primaryColor_D1 ?? this.primaryColor_D1,
//       primaryColor_D2: primaryColor_D2 ?? this.primaryColor_D2,
//       primaryColor_L1: primaryColor_L1 ?? this.primaryColor_L1,
//       primaryColor_L2: primaryColor_L2 ?? this.primaryColor_L2,
//       secondaryColor: secondaryColor ?? this.secondaryColor,
//       secondaryColor_D1: secondaryColor_D1 ?? this.secondaryColor_D1,
//       secondaryColor_D2: secondaryColor_D2 ?? this.secondaryColor_D2,
//       secondaryColor_L1: secondaryColor_L1 ?? this.secondaryColor_L1,
//       secondaryColor_L2: secondaryColor_L2 ?? this.secondaryColor_L2,
//     );
//   }

//   @override
//   AppColors lerp(ThemeExtension<AppColors>? other, double t) {
//     if (other is! AppColors) return this;
//     return AppColors(
//       primaryColor: primaryColor,
//       primaryColor_D1: primaryColor_D1,
//       primaryColor_D2: primaryColor_D2,
//       primaryColor_L1: primaryColor_L1,
//       primaryColor_L2: primaryColor_L2,
//       secondaryColor: secondaryColor,
//       secondaryColor_D1: secondaryColor_D1,
//       secondaryColor_D2: secondaryColor_D2,
//       secondaryColor_L1: secondaryColor_L1,
//       secondaryColor_L2: secondaryColor_L2,
//     );
//   }

//   @override
//   String toString() {
//     'AppColors(primaryColor: $primaryColor, primaryColor_D1: $primaryColor_D1, primaryColor_D2: $primaryColor_D2, primaryColor_L1: $primaryColor_L1, primaryColor_L2: $primaryColor_L2, secondaryColor: $secondaryColor, secondaryColor_D1: $secondaryColor_D1, secondaryColor_D2: $secondaryColor_D2, secondaryColor_L1: $secondaryColor_L1, secondaryColor_L2: $secondaryColor_L2)';
//     return super.toString();
//   }

//   static const light = AppColors(
//     primaryColor: Color(0xffE9635D),
//     primaryColor_D1: Color(0xff9B423E),
//     primaryColor_D2: Color(0xff4E211F),
//     primaryColor_L1: Color(0xffF09793),
//     primaryColor_L2: Color(0xffF8CBC9),
//     secondaryColor: Color(0xff898989),
//     secondaryColor_D1: Color(0xff898989),
//     secondaryColor_D2: Color(0xff444444),
//     secondaryColor_L1: Color(0xffdedede),
//     secondaryColor_L2: Color(0xffeeeeee),
//   );
// }

extension AppColors on ColorScheme {
  Color get primaryColor => const Color(0xffE9635D);
  Color get primaryColor_D1 => const Color(0xff9B423E);
  Color get primaryColor_D2 => const Color(0xff4E211F);
  Color get primaryColor_L1 => const Color(0xffF09793);
  Color get primaryColor_L2 => const Color(0xffF8CBC9);
  Color get secondaryColor => const Color(0xffcdcdcd);
  Color get secondaryColor_D1 => const Color(0xff898989);
  Color get secondaryColor_D2 => const Color(0xff444444);
  Color get secondaryColor_L1 => const Color(0xffdedede);
  Color get secondaryColor_L2 => const Color(0xffeeeeee);
}
