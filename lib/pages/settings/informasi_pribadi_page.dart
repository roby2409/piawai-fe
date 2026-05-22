import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/services/user_services.dart';

// ─────────────────────────────────────────
// INFORMASI PRIBADI PAGE — username only
// ─────────────────────────────────────────
class InformasiPribadiPage extends StatefulWidget {
  final String currentUsername;
  const InformasiPribadiPage({super.key, required this.currentUsername});

  @override
  State<InformasiPribadiPage> createState() => _InformasiPribadiPageState();
}

class _InformasiPribadiPageState extends State<InformasiPribadiPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  late final TextEditingController _usernameCtrl;

  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  bool get _usernameChanged =>
      _usernameCtrl.text.trim() != widget.currentUsername;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_usernameChanged) {
      setState(() => _errorMessage = 'Username sama dengan yang sekarang.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _userService.updateUsername(_usernameCtrl.text.trim());
      if (mounted) {
        setState(() {
          _successMessage = 'Username berhasil diupdate.';
          _isSaving = false;
          isUpdated = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (mounted) Navigator.pop(context, isUpdated);
          },
        ),
        title: const Text(
          'Informasi Pribadi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_errorMessage != null) ...[
              _Banner(message: _errorMessage!, isError: true),
              const SizedBox(height: 12),
            ],
            if (_successMessage != null) ...[
              _Banner(message: _successMessage!, isError: false),
              const SizedBox(height: 12),
            ],

            _SectionCard(
              title: 'Username',
              subtitle: 'settings.account_settings.username_description'.tr(),
              child: InputField(
                controller: _usernameCtrl,
                label: 'fields.username'.tr(),
                hint: 'Masukkan username baru',
                prefixIcon: Icons.alternate_email,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'validator.username_required'.tr();
                  }
                  if (val.trim().length < 3) {
                    return 'validator.username_min'.tr();
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(val.trim())) {
                    return 'validator.username_invalid'.tr();
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kPrimary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'general.save_changes'.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final bool isError;

  const _Banner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
