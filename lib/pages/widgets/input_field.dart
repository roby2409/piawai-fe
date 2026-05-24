import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String hint;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? minLines; // ← tambah ini
  final int? maxLength; // ← tambah ini
  final void Function(String)? onChanged;

  const InputField({
    super.key,
    required this.controller,
    this.label,
    required this.hint,
    this.keyboardType,
    this.prefixIcon,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.minLines, // ← tambah ini
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: context.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: context.textSecondary, fontSize: 14),
        labelStyle: TextStyle(color: context.textSecondary, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: context.primary, size: 18)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: context.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.black87),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
