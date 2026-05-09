import 'package:flutter/material.dart';
import 'package:piawai/pages/main_page.dart';
import 'package:piawai/services/auth_services.dart';

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
            ? 'Selamat datang! Akun berhasil dibuat 🎉'
            : 'Selamat datang kembali! ✅',
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
      _showSnackbar('Email dan password wajib diisi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.login(email, password);
      if (!mounted) return;

      _showSnackbar('Login berhasil ✅', isError: false);
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
      _showSnackbar('Semua field wajib diisi');
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar('Password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.register(username, email, password);
      if (!mounted) return;

      _showSnackbar('Registrasi berhasil! Silakan masuk ✅', isError: false);
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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                const Column(
                  children: [
                    Icon(Icons.compare_arrows, size: 50, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Piawai',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(text: 'Masuk'),
                    Tab(text: 'Daftar'),
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
            text: 'Sign in with Google',
            onPressed: _isLoading ? null : _handleGoogleSignIn,
          ),

          const SizedBox(height: 20),
          const Center(child: Text('atau masuk dengan email')),
          const SizedBox(height: 20),

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Lupa password?'),
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Masuk'),
          ),
          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('Belum punya akun? Daftar'),
            ),
          ),
        ],
      ),
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
            text: 'Sign up with Google',
            onPressed: _isLoading ? null : _handleGoogleSignIn,
          ),

          const SizedBox(height: 20),
          const Center(child: Text('atau daftar dengan email')),
          const SizedBox(height: 20),

          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _emailRegController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _passwordRegController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Daftar'),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google logo SVG-style dengan warna asli
          SizedBox(
            width: 24,
            height: 24,
            child: CustomPaint(painter: _GoogleLogoPainter()),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Gambar lingkaran latar
    paint.color = Colors.white;
    canvas.drawCircle(center, radius, paint);

    // Huruf G sederhana dengan warna Google
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
