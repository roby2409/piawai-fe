import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/auth/forgot_password_screen.dart';
import 'package:piawai/pages/main_page.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/services/auth_services.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailRegController = TextEditingController();
  final _passwordRegController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Services
  final _authService = AuthService();

  bool _isLoading = false;
  bool _showLoginPassword = false;
  bool _showRegisterPassword = false;
  bool _showConfirmRegisterPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _emailRegController.dispose();
    _passwordRegController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Google Sign In ───────────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final data = await _authService.signInWithGoogle();
      if (!mounted) return;

      final isNewUser = data['is_new_user'] == true;

      _showSnackbar(
        isNewUser
            ? 'success_messages.register_account_success'.tr()
            : 'success_messages.welcome_back'.tr(),
        isError: false,
      );

      // TODO: Navigate ke halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    } catch (e) {
      _showSnackbar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Email Login ──────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('email_password_required'.tr());
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.login(email, password);
      if (!mounted) return;

      _showSnackbar('success_messages.login_success'.tr(), isError: false);
      // TODO: Navigate ke halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    } catch (e) {
      _showSnackbar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Email Register ───────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailRegController.text.trim();
    final password = _passwordRegController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar('validator.semua_fields_required'.tr());
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar('validator.password_not_match'.tr());
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.register(username, email, password);
      if (!mounted) return;

      _showSnackbar('success_messages.register_success'.tr(), isError: false);
      _tabController.animateTo(0); // Switch ke tab login
    } catch (e) {
      _showSnackbar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                const Column(
                  children: [
                    Image(
                      height: 80,
                      width: 80,
                      image: AssetImage("assets/icons/logo.png"),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Piawai',
                      style: TextStyle(
                        fontSize: 28,
                        color: kPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: kPrimary,
                  dividerColor: Colors.grey[300],
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: kPrimary,
                  tabs: [
                    Tab(text: 'general.masuk'.tr()),
                    Tab(text: 'general.daftar'.tr()),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildLoginTab(), _buildRegisterTab()],
                  ),
                ),
              ],
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Login Tab ─────────────────────────────────────────────────────────────

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const SizedBox(height: 20),

          // Google Sign In Button
          _GoogleSignInButton(
            text: 'sign_in_with_google'.tr(),
            onPressed: _isLoading ? null : _handleGoogleSignIn,
          ),

          const SizedBox(height: 20),
          orDivider(),
          const SizedBox(height: 20),

          InputField(
            label: 'fields.email_or_username'.tr(),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            hint: 'field_hints.email'.tr(),
            prefixIcon: Icons.email,
          ),
          const SizedBox(height: 20),

          InputField(
            controller: _passwordController,
            label: 'fields.password'.tr(),
            hint: 'field_hints.password'.tr(),
            prefixIcon: Icons.lock_outline,
            obscure: !_showLoginPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showLoginPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: kPrimary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _showLoginPassword = !_showLoginPassword),
            ),
            validator: (val) {
              if (val == null || val.isEmpty)
                return 'validator.password_required'.tr();
              return null;
            },
          ),
          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(
                'lupa_password'.tr(),
                style: TextStyle(color: kPrimary, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              disabledBackgroundColor: const Color(0xFFD1D5DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('general.masuk'.tr(), style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'belum_punya_akun'.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: 'daftar_sekarang'.tr(),
                      style: const TextStyle(color: kPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget orDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'general.or'.tr(),
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1.5)),
      ],
    );
  }

  // ─── Register Tab ──────────────────────────────────────────────────────────

  Widget _buildRegisterTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const SizedBox(height: 20),

          // Google Sign Up Button
          _GoogleSignInButton(
            text: 'sign_up_with_google'.tr(),
            onPressed: _isLoading ? null : _handleGoogleSignIn,
          ),

          const SizedBox(height: 20),
          orDivider(),
          const SizedBox(height: 20),

          InputField(
            label: 'fields.username'.tr(),
            controller: _usernameController,
            keyboardType: TextInputType.text,
            hint: 'field_hints.username_example'.tr(),
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 20),

          InputField(
            label: 'fields.email'.tr(),
            controller: _emailRegController,
            keyboardType: TextInputType.emailAddress,
            hint: 'field_hints.email_example'.tr(),
            prefixIcon: Icons.email,
          ),
          const SizedBox(height: 20),

          InputField(
            controller: _passwordController,
            label: 'fields.password'.tr(),
            hint: 'field_hints.password'.tr(),
            prefixIcon: Icons.lock_outline,
            obscure: !_showRegisterPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showRegisterPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: kPrimary,
                size: 20,
              ),
              onPressed: () => setState(
                () => _showRegisterPassword = !_showRegisterPassword,
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'validator.password_required'.tr();
              }
              if (val.length < 6) {
                return 'validator.password_min'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          InputField(
            controller: _confirmPasswordController,
            label: 'fields.confirm_password'.tr(),
            hint: 'field_hints.confirm_password'.tr(),
            prefixIcon: Icons.lock_outline,
            obscure: !_showConfirmRegisterPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmRegisterPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: kPrimary,
                size: 20,
              ),
              onPressed: () => setState(
                () => _showConfirmRegisterPassword =
                    !_showConfirmRegisterPassword,
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty)
                return 'validator.confirm_password_required'.tr();
              if (val != _confirmPasswordController.text)
                return 'validator.password_not_match'.tr();
              return null;
            },
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: kPrimary.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('general.daftar'.tr()),
          ),

          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: () => _tabController.animateTo(0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: "sudah_punya_akun".tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: "masuk_sekarang".tr(),
                      style: const TextStyle(color: kPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Google Button ───────────────────────────────────────────────────
// Mengganti flutter_signin_button yang kadang bermasalah

class _GoogleSignInButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _GoogleSignInButton({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.grey[50],
        disabledBackgroundColor: const Color(0xFFD1D5DB),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: kPrimary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google logo SVG-style dengan warna asli
          Image(
            height: 23,
            width: 23,
            image: AssetImage("assets/icons/google-logo.png"),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
        ],
      ),
    );
  }
}
