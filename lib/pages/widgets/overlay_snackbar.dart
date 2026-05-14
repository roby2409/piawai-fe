import 'package:flutter/material.dart';

void showOverlaySnackbar(
  BuildContext context,
  String msg, {
  bool isError = false,
}) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 50,
      left: 16,
      right: 16,
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: isError ? Colors.red.shade700 : Colors.green.shade700,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(msg, style: const TextStyle(color: Colors.white)),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3), () => entry.remove());
}
