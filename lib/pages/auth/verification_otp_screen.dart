import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/core/snackbar_helper.dart';
import 'package:piawai/pages/auth/verification_otp_success_screen.dart';
import 'package:piawai/services/auth_services.dart';

class VerificationOtpScreen extends StatefulWidget {
  final String email;

  const VerificationOtpScreen({super.key, this.email = 'email@contoh.com'});

  @override
  State<VerificationOtpScreen> createState() => _VerificationOtpScreenState();
}

class _VerificationOtpScreenState extends State<VerificationOtpScreen> {
  static const int _otpLength = 6;
  static const int _countdownSeconds = 59;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  final AuthService _authService = AuthService();
  int _remainingSeconds = _countdownSeconds;
  Timer? _timer;
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (int i = 0; i < _otpLength; i++) {
      _controllers[i].addListener(_checkOtpComplete);
    }
  }

  void _checkOtpComplete() {
    final filled = _controllers.every((c) => c.text.isNotEmpty);
    if (filled != _isButtonEnabled) {
      setState(() => _isButtonEnabled = filled);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = _countdownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _resendCode() async {
    if (_remainingSeconds != 0) return;
    try {
      await _authService.forgotPassword(widget.email);
      for (var c in _controllers) {
        c.clear();
      }
      _startTimer();
      _focusNodes[0].requestFocus();
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    final otp = _controllers.map((c) => c.text).join();
    try {
      final resetToken = await _authService.verifyOtp(widget.email, otp);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationOtpSuccessScreen(resetToken: resetToken),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _timerText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgOuter,
      appBar: AppBar(
        backgroundColor: context.bgContent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'verification_otp.title'.tr(),
          style: TextStyle(
            color: context.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF4DD9C0).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF4DD9C0),
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Illustration Card
              Center(
                child: Image(
                  image: AssetImage("assets/images/verification_otp.png"),
                  width: 250,
                  height: 250,
                ),
              ),

              // Title
              Text(
                'verification_otp.heading'.tr(),
                style: TextStyle(
                  color: context.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              RichText(
                text: TextSpan(
                  text: 'verification_otp.description'.tr(),
                  style: TextStyle(
                    color: context.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return _OtpBox(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: !_isLoading,
                    onChanged: (val) {
                      if (val.isNotEmpty && index < _otpLength - 1) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Resend countdown
              GestureDetector(
                onTap: _remainingSeconds == 0 ? _resendCode : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: context.black45,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'verification_otp.resend_countdown'.tr(),
                      style: TextStyle(color: context.black87, fontSize: 13),
                    ),
                    Text(
                      _timerText,
                      style: TextStyle(
                        color: _remainingSeconds == 0
                            ? const Color(0xFF4DD9C0)
                            : const Color(0xFF4DD9C0),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Verifikasi Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isButtonEnabled && !_isLoading)
                      ? _verifyOtp
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
                              'verification_otp.button_verify'.tr(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _isButtonEnabled
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: _isButtonEnabled
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ],
                        ),
                ),
              ),

              const Spacer(),

              // Ingat password? Masuk
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'verification_otp.ingat_password'.tr(),
                    style: TextStyle(color: context.black54, fontSize: 13),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'verification_otp.masuk'.tr(),
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

/// Single OTP input box
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        enabled: enabled,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: context.black87,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: context.bgCard,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4DD9C0), width: 1.8),
          ),
        ),
      ),
    );
  }
}

/// Email illustration with floating icons
class _EmailIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 10,
            child: Container(
              width: 100,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF4DD9C0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 42,
            child: CustomPaint(
              size: const Size(100, 36),
              painter: _FlapPainter(),
            ),
          ),
          Positioned(
            bottom: 38,
            child: Container(
              width: 56,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(Icons.code, color: Color(0xFF4DD9C0), size: 22),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 14,
            child: _FloatingIcon(
              icon: Icons.settings,
              color: const Color(0xFF4DD9C0),
            ),
          ),
          Positioned(
            top: 0,
            right: 18,
            child: _FloatingIcon(
              icon: Icons.description_outlined,
              color: Colors.blueAccent,
            ),
          ),
          Positioned(
            top: 22,
            right: 6,
            child: _FloatingIcon(
              icon: Icons.mail_outline,
              color: const Color(0xFF4DD9C0),
              size: 16,
            ),
          ),
          const Positioned(
            top: 10,
            child: Icon(
              Icons.keyboard_double_arrow_up,
              color: Color(0xFF4DD9C0),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _FloatingIcon({
    required this.icon,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

class _FlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3BCFB8)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
