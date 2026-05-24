import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';

extension AppColors on BuildContext {
  Color get primary => Theme.of(this).brightness == Brightness.dark ? kDarkPrimary : kPrimary;
  Color get secondary => Theme.of(this).brightness == Brightness.dark ? kDarkSecondary : kSecondary;
  Color get bgOuter => Theme.of(this).brightness == Brightness.dark ? kDarkBgOuter : kBgOuter;
  Color get bgContent => Theme.of(this).brightness == Brightness.dark ? kDarkBgContent : kBgContent;
  Color get bgCard => Theme.of(this).brightness == Brightness.dark ? kDarkBgCard : kBgCard;
  Color get divider => Theme.of(this).brightness == Brightness.dark ? kDarkDivider : kDivider;
  Color get textPrimary => Theme.of(this).brightness == Brightness.dark ? kDarkTextPrimary : kTextPrimary;
  Color get textSecondary => Theme.of(this).brightness == Brightness.dark ? kDarkTextSecondary : kTextSecondary;
  Color get white => kWhite;
  Color get red => kRed;
  Color get green => kGreen;
  Color get orange => kOrange;
  Color get blue => kBlue;
  Color get grey => Theme.of(this).brightness == Brightness.dark ? kDarkTextSecondary : kGrey;
  Color get black => Theme.of(this).brightness == Brightness.dark ? kDarkTextPrimary : kTextPrimary;
  Color get black87 => Theme.of(this).brightness == Brightness.dark ? kDarkTextPrimary : const Color(0xDD000000);
  Color get black54 => Theme.of(this).brightness == Brightness.dark ? kDarkTextSecondary.withOpacity(0.54) : const Color(0x8A000000);
  Color get black45 => Theme.of(this).brightness == Brightness.dark ? kDarkTextSecondary.withOpacity(0.45) : const Color(0x73000000);
  Color get black38 => Theme.of(this).brightness == Brightness.dark ? kDarkTextSecondary.withOpacity(0.38) : const Color(0x61000000);
  Color get white60 => kWhite.withOpacity(0.6);
  Color get transparent => Colors.transparent;
}

