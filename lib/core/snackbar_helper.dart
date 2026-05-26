import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';

class SnackBarHelper {
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    bool floating = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.replaceAll('Exception: ', ''),
          style: TextStyle(
            color: textColor ?? context.white,
          ),
        ),
        backgroundColor: backgroundColor ?? Colors.redAccent,
        behavior: floating ? SnackBarBehavior.floating : null,
        shape: floating ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : null,
      ),
    );
  }

  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    bool floating = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor ?? Colors.white,
          ),
        ),
        backgroundColor: backgroundColor ?? Colors.green,
        behavior: floating ? SnackBarBehavior.floating : null,
        shape: floating ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : null,
      ),
    );
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    bool floating = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor ?? Colors.white,
          ),
        ),
        backgroundColor: backgroundColor ?? Colors.grey,
        behavior: floating ? SnackBarBehavior.floating : null,
        shape: floating ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : null,
      ),
    );
  }
}
