import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';

// ─────────────────────────────────────────
// ONBOARDING SCREEN
// ─────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Tanpa Ribet',
      subtitle:
          'Lupakan portofolio yang membingungkan. Temukan talenta terbaik berdasarkan keahlian di lokasi yang Anda inginkan dengan mudah.',
      badgeText: null,
      highlightText: null,
      layout: _OnboardingLayout.grid2x2Light,
    ),
    _OnboardingData(
      title: 'Buka Jasa Sekarang',
      subtitle:
          'Pasang jasa Anda dengan mudah. Kami menitikberatkan kemudahan bagi siapapun untuk mencari dan menawarkan talenta.',
      badgeText: null,
      highlightText: null,
      layout: _OnboardingLayout.grid2x2Dark,
      isDark: true,
      isLast: false,
    ),
    _OnboardingData(
      title: 'Koneksi Langsung',
      subtitle:
          'Langsung terhubung dengan penyedia jasa tanpa perantara. Tanpa rating, tanpa ulasan, hanya ',
      highlightText: 'komunikasi nyata.',
      badgeText: 'Tanpa Perantara',
      layout: _OnboardingLayout.handshake,
      isLast: true,
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinish();
    }
  }

  void _skip() => widget.onFinish();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isDark = page.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFFF0FBF4) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo (hanya di page 1)
                  if (!isDark)
                    Text(
                      'Piawai',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.primary,
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Lewati
                  GestureDetector(
                    onTap: _skip,
                    child: Text(
                      'Lewati',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Page content ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingPageContent(data: _pages[i]),
              ),
            ),

            // ── Dots + Button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? context.primary
                              : (isDark
                                    ? Colors.white30
                                    : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page.isLast ? 'Mulai Sekarang' : 'Lanjut',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),

                  // Footer text (hanya page terakhir)
                  if (page.isLast) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Piawai • Marketplace Jasa Terpercaya',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],

                  // Lewati text (hanya page 2 / dark)
                  if (isDark && !page.isLast) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _skip,
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// PAGE CONTENT
// ─────────────────────────────────────────
class _OnboardingPageContent extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPageContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Illustration area ──
          Expanded(
            child: _IllustrationArea(
              layout: data.layout,
              badgeText: data.badgeText,
            ),
          ),
          const SizedBox(height: 24),

          // ── Title ──
          Text(
            data.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: data.isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // ── Subtitle (dengan highlight opsional) ──
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: data.isDark ? Colors.white70 : Colors.grey.shade600,
              ),
              children: [
                TextSpan(text: data.subtitle),
                if (data.highlightText != null)
                  TextSpan(
                    text: data.highlightText,
                    style: TextStyle(
                      color: context.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// ILLUSTRATION AREA
// ─────────────────────────────────────────
class _IllustrationArea extends StatelessWidget {
  final _OnboardingLayout layout;
  final String? badgeText;

  const _IllustrationArea({required this.layout, this.badgeText});

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case _OnboardingLayout.grid2x2Light:
        return _Grid2x2Light();
      case _OnboardingLayout.grid2x2Dark:
        return _Grid2x2Dark(badgeText: badgeText);
      case _OnboardingLayout.handshake:
        return _HandshakeIllustration(badgeText: badgeText);
    }
  }
}

// ── Layout 1: Grid terang (Tanpa Ribet) ──
class _Grid2x2Light extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Kiri: peta placeholder
                Expanded(
                  child: _PlaceholderBox(
                    color: const Color(0xFFDDE8FF),
                    icon: Icons.location_on_outlined,
                    iconColor: context.primary,
                  ),
                ),
                const SizedBox(width: 10),
                // Kanan: foto profil placeholder
                Expanded(
                  child: _PlaceholderBox(
                    color: const Color(0xFFE8F0FE),
                    icon: Icons.person_outline,
                    iconColor: context.primary,
                    hasBottomLine: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Layout 2: Grid gelap (Buka Jasa) ──
class _Grid2x2Dark extends StatelessWidget {
  final String? badgeText;
  const _Grid2x2Dark({this.badgeText});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row atas: 2 kotak
        Expanded(
          flex: 5,
          child: Row(
            children: [
              // Kiri besar: foto placeholder dengan badge
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    _PlaceholderBox(
                      color: const Color(0xFF1e3a5f),
                      icon: Icons.handyman_outlined,
                      iconColor: Colors.white54,
                      borderRadius: 16,
                    ),
                    if (badgeText != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _Badge(text: badgeText!),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Kanan atas: icon biru
              Expanded(
                flex: 2,
                child: _PlaceholderBox(
                  color: context.primary,
                  icon: Icons.handshake_outlined,
                  iconColor: Colors.white,
                  borderRadius: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row bawah: 2 kotak
        Expanded(
          flex: 3,
          child: Row(
            children: [
              // Kiri: card dengan icon
              Expanded(
                flex: 3,
                child: _PlaceholderBox(
                  color: const Color(0xFF1e3a5f),
                  icon: Icons.camera_outlined,
                  iconColor: Colors.white54,
                  borderRadius: 16,
                  hasBottomLine: true,
                ),
              ),
              const SizedBox(width: 10),
              // Kanan: tools icon
              Expanded(
                flex: 2,
                child: _PlaceholderBox(
                  color: context.bgOuter,
                  icon: Icons.construction_outlined,
                  iconColor: Colors.white54,
                  borderRadius: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Layout 3: Handshake (Koneksi Langsung) ──
class _HandshakeIllustration extends StatelessWidget {
  final String? badgeText;
  const _HandshakeIllustration({this.badgeText});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background card besar
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE8FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(
              Icons.people_outline,
              size: 100,
              color: context.primary,
            ),
          ),
        ),

        // Chat bubble kanan atas
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),

        // Badge kiri bawah
        if (badgeText != null)
          Positioned(bottom: 16, left: 16, child: _Badge(text: badgeText!)),
      ],
    );
  }
}

// ─────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────
class _PlaceholderBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final double borderRadius;
  final bool hasBottomLine;

  const _PlaceholderBox({
    required this.color,
    required this.icon,
    required this.iconColor,
    this.borderRadius = 12,
    this.hasBottomLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: iconColor),
          if (hasBottomLine) ...[
            const SizedBox(height: 8),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 14, color: context.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────
enum _OnboardingLayout { grid2x2Light, grid2x2Dark, handshake }

class _OnboardingData {
  final String title;
  final String subtitle;
  final String? highlightText;
  final String? badgeText;
  final _OnboardingLayout layout;
  final bool isDark;
  final bool isLast;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    this.highlightText,
    this.badgeText,
    required this.layout,
    this.isDark = false,
    this.isLast = false,
  });
}
