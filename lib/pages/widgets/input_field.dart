import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';

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
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[800], fontSize: 14),
        labelStyle: TextStyle(color: Colors.grey[800], fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: kPrimary, size: 18)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
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
