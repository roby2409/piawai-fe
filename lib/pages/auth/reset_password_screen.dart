import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/pages/auth/reset_password_success_screen.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/services/auth_services.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken; // ← tambah ini

  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _isLoading = false; // ← tambah ini

  @override
  void dispose() {
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _simpanPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(
        widget.resetToken,
        _passwordController.text,
        _konfirmasiController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResetPasswordSuccesScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'reset_password.title'.tr(),
          style: TextStyle(
            color: context.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(Icons.lock_outline, color: context.primary, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Illustration Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _LockSuccessIllustration(),
                      const SizedBox(height: 12),
                      Text(
                        'reset_password.illustration_title'.tr(),
                        style: TextStyle(
                          color: context.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'reset_password.illustration_subtitle'.tr(),
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Title
                Text(
                  'reset_password.heading'.tr(),
                  style: TextStyle(
                    color: context.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'reset_password.description'.tr(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Password Baru
                InputField(
                  controller: _passwordController,
                  hint: 'field_hints.new_password'.tr(),
                  prefixIcon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'validator.password_required'.tr();
                    }
                    if (val.length < 8) {
                      return 'validator.password_min'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Konfirmasi Password
                InputField(
                  controller: _konfirmasiController,
                  hint: 'field_hints.confirm_password'.tr(),
                  prefixIcon: Icons.lock_outline,
                  obscure: _obscureKonfirmasi,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKonfirmasi
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _obscureKonfirmasi = !_obscureKonfirmasi,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'validator.confirm_password_required'.tr();
                    }
                    if (val != _passwordController.text) {
                      return 'validator.confirm_password_match'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Simpan Password Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _simpanPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'reset_password.button_save'.tr(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Ingat password? Masuk
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'reset_password.ingat_password'.tr(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Navigate to login
                            },
                            child: Text(
                              'reset_password.masuk'.tr(),
                              style: TextStyle(
                                color: context.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gembok + shield checkmark illustration
class _LockSuccessIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lock body
          Positioned(
            bottom: 0,
            child: Container(
              width: 80,
              height: 70,
              decoration: BoxDecoration(
                color: context.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Lock shackle (top arc)
          Positioned(
            top: 0,
            child: Container(
              width: 50,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: context.primary, width: 10),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                color: Colors.transparent,
              ),
            ),
          ),
          // Shield + check overlay
          Positioned(
            bottom: 10,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
