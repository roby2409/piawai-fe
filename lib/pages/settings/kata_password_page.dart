import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/services/user_services.dart';

// ─────────────────────────────────────────
// KATA SANDI & KEAMANAN PAGE — password only
// ─────────────────────────────────────────
class KataPasswordPage extends StatefulWidget {
  const KataPasswordPage({super.key});

  @override
  State<KataPasswordPage> createState() => _KataPasswordPageState();
}

class _KataPasswordPageState extends State<KataPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  bool _isSaving = false;
  bool _isLoadingMe = true;
  String? _errorMessage;
  String? _successMessage;

  bool _hasPassword = true;
  bool _isGoogleUser = false;

  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMe() async {
    try {
      final me = await _userService.getMe();
      if (mounted) {
        setState(() {
          _hasPassword = me['has_password'] == true;
          _isGoogleUser = me['is_google_user'] == true;
          _isLoadingMe = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMe = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _userService.updatePassword(
        oldPassword: _hasPassword ? _oldPasswordCtrl.text : null,
        newPassword: _newPasswordCtrl.text,
      );

      if (mounted) {
        setState(() {
          _successMessage = _hasPassword
              ? 'Password berhasil diupdate.'
              : 'Password berhasil dibuat.';
          _isSaving = false;
          _hasPassword = true;
          _oldPasswordCtrl.clear();
          _newPasswordCtrl.clear();
          _confirmPasswordCtrl.clear();
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
      backgroundColor: context.bgOuter,
      appBar: AppBar(
        backgroundColor: context.bgContent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.primary),
          onPressed: () {
            if (mounted) Navigator.pop(context, isUpdated);
          },
        ),
        title: Text(
          'Kata Sandi & Keamanan',
          style: TextStyle(
            color: context.black87,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingMe
          ? Center(child: CircularProgressIndicator(color: context.primary))
          : Form(
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
                    title: _hasPassword ? 'Ganti Password' : 'Buat Password',
                    subtitle: _hasPassword
                        ? null
                        : 'Buat password untuk bisa login dengan email/username',
                    child: Column(
                      children: [
                        // Info banner Google user belum punya password
                        if (_isGoogleUser && !_hasPassword) ...[
                          _Banner(
                            message:
                                'Akun Anda terhubung via Google. Buat password untuk bisa login tanpa Google.',
                            isError: false,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Field password lama — hanya kalau sudah punya password
                        if (_hasPassword) ...[
                          InputField(
                            controller: _oldPasswordCtrl,
                            label: 'Password Lama',
                            hint: 'Masukkan password saat ini',
                            prefixIcon: Icons.lock_outline,
                            obscure: !_showOldPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showOldPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _showOldPassword = !_showOldPassword,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Password lama wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],

                        InputField(
                          controller: _newPasswordCtrl,
                          label: _hasPassword
                              ? 'Password Baru'
                              : 'Buat Password',
                          hint: 'Minimal 8 karakter',
                          prefixIcon: Icons.lock_outline,
                          obscure: !_showNewPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _showNewPassword = !_showNewPassword,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Password wajib diisi';
                            if (val.length < 8) return 'Minimal 8 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        InputField(
                          controller: _confirmPasswordCtrl,
                          label: 'Konfirmasi Password',
                          hint: 'Ulangi password',
                          prefixIcon: Icons.lock_outline,
                          obscure: !_showConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () =>
                                  _showConfirmPassword = !_showConfirmPassword,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Konfirmasi password wajib diisi';
                            if (val != _newPasswordCtrl.text)
                              return 'Password tidak cocok';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: context.primary.withOpacity(
                          0.5,
                        ),
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
                              _hasPassword ? 'Ganti Password' : 'Buat Password',
                              style: const TextStyle(
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
        color: context.bgCard,
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.primary,
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
