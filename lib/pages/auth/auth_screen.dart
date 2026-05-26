import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';
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
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _fullNameRegController = TextEditingController();
  final _usernameRegController = TextEditingController();
  final _emailRegController = TextEditingController();
  final _passwordRegController = TextEditingController();

  // Services
  final _authService = AuthService();

  bool _isLoading = false;
  bool _showLoginPassword = false;
  bool _showRegisterPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    _fullNameRegController.dispose();
    _usernameRegController.dispose();
    _emailRegController.dispose();
    _passwordRegController.dispose();
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
    final email = _emailOrUsernameController.text.trim();
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
    final fullName = _fullNameRegController.text.trim();
    final username = _usernameRegController.text.trim();
    final email = _emailRegController.text.trim();
    final password = _passwordRegController.text.trim();

    if (fullName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showSnackbar('validator.semua_fields_required'.tr());
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.register(fullName, username, email, password);
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
      backgroundColor: context.bgOuter,
      body: SafeArea(
        child: ColoredBox(
          color: context.bgOuter,
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Column(
                    children: [
                      Image(
                        height: 100,
                        width: 100,
                        image: AssetImage("assets/icons/logoapp.png"),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Piawai',
                        style: TextStyle(
                          fontSize: 28,
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: context.primary,
                    dividerColor: context.grey,
                    unselectedLabelColor: context.textSecondary,
                    indicatorColor: context.primary,
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
      ),
    );
  }

  // ─── Login Tab ─────────────────────────────────────────────────────────────

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const SizedBox(height: 40),

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
            controller: _emailOrUsernameController,
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
                color: context.primary,
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
                style: TextStyle(
                  color: context.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              disabledBackgroundColor: const Color(0xFFD1D5DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'general.masuk'.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.white,
              ),
            ),
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
                      style: TextStyle(color: context.textSecondary),
                    ),
                    TextSpan(
                      text: 'daftar_sekarang'.tr(),
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w600,
                      ),
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
        Expanded(child: Divider(color: context.grey, thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'general.or'.tr(),
            style: TextStyle(color: context.black87, fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: context.grey, thickness: 1.5)),
      ],
    );
  }

  // ─── Register Tab ──────────────────────────────────────────────────────────

  Widget _buildRegisterTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const SizedBox(height: 40),

          // Google Sign Up Button
          _GoogleSignInButton(
            text: 'sign_up_with_google'.tr(),
            onPressed: _isLoading ? null : _handleGoogleSignIn,
          ),

          const SizedBox(height: 20),
          orDivider(),
          const SizedBox(height: 20),

          InputField(
            label: 'fields.full_name'.tr(),
            controller: _fullNameRegController,
            keyboardType: TextInputType.text,
            hint: 'field_hints.full_name'.tr(),
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          InputField(
            label: 'fields.username'.tr(),
            controller: _usernameRegController,
            keyboardType: TextInputType.text,
            hint: 'field_hints.username_example'.tr(),
            prefixIcon: Icons.alternate_email_outlined,
          ),
          const SizedBox(height: 20),

          InputField(
            label: 'fields.email'.tr(),
            controller: _emailRegController,
            keyboardType: TextInputType.emailAddress,
            hint: 'field_hints.email'.tr(),
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),

          InputField(
            controller: _passwordRegController,
            label: 'fields.password'.tr(),
            hint: 'field_hints.password'.tr(),
            prefixIcon: Icons.lock_outline,
            obscure: !_showRegisterPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showRegisterPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.primary,
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

          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: context.primary.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'general.daftar'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: context.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                      style: TextStyle(color: context.textSecondary),
                    ),
                    TextSpan(
                      text: "masuk_sekarang".tr(),
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w600,
                      ),
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
        backgroundColor: context.bgOuter,
        disabledBackgroundColor: const Color(0xFFD1D5DB),
        foregroundColor: context.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: context.primary),
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
          Text(text, style: TextStyle(color: context.black87, fontSize: 14)),
        ],
      ),
    );
  }
}
