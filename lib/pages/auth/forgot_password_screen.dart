import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/core/snackbar_helper.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/services/auth_services.dart';

import 'verification_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _isButtonEnabled = _emailController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _kirimKode() async {
    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VerificationOtpScreen(email: _emailController.text.trim()),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          icon: Icon(Icons.arrow_back_ios, color: context.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'forgot_password.title'.tr(),
          style: TextStyle(
            color: context.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.mail_outline, color: context.primary, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Illustration
              Center(
                child: Image(
                  image: AssetImage("assets/images/forgot_password.png"),
                  width: 250,
                  height: 250,
                ),
              ),

              // Description Text
              Center(
                child: Text(
                  'forgot_password.description'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Email TextField
              InputField(
                controller: _emailController,
                hint: 'field_hints.email'.tr(),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // Kirim Kode Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isButtonEnabled && !_isLoading)
                      ? _kirimKode
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                              'forgot_password.button_send'.tr(),
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

              const SizedBox(height: 10),

              // Helper text
              Center(
                child: Text(
                  'forgot_password.button_hint'.tr(),
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
              ),

              const Spacer(),

              // Ingat Password? Masuk
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'forgot_password.ingat_password'.tr(),
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'forgot_password.masuk'.tr(),
                            style: const TextStyle(
                              color: Color(0xFF4DD9C0),
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
    );
  }
}
