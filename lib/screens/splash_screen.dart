import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../home_screen.dart';
import 'auth_screen.dart';
import '../utils/quotes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late QuoteModel _randomQuote;

  @override
  void initState() {
    super.initState();

    // Get random quote
    _randomQuote = OsintQuotes.getRandomQuote();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..forward();

    // Navigate to auth screen after loading
    // Future.delayed(const Duration(milliseconds: 3000), () {
    Future.delayed(const Duration(milliseconds: 6500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with glow effect
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF94)
                            .withOpacity(0.3 + (_pulseController.value * 0.4)),
                        blurRadius: 30 + (_pulseController.value * 20),
                        spreadRadius: 5 + (_pulseController.value * 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 40),

            // App title
            const Text(
              'OSINT STALKER BY XNUVERS007/INDRA',
              style: TextStyle(
                color: Color(0xFF00FF94),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Advanced OSINT Toolkit',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

            const SizedBox(height: 50),

            // Loading indicator
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  // Progress bar
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _progressController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00FF94),
                                    Color(0xFF38BDF8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00FF94)
                                        .withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Loading text
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      String status = 'Initializing...';
                      if (_progressController.value > 0.3) {
                        status = 'Loading modules...';
                      }
                      if (_progressController.value > 0.6) {
                        status = 'Preparing engines...';
                      }
                      if (_progressController.value > 0.9) {
                        status = 'Ready!';
                      }
                      return Text(
                        status,
                        style: TextStyle(
                          color: _progressController.value > 0.9
                              ? const Color(0xFF00FF94)
                              : Colors.white38,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 500.ms),

            const SizedBox(height: 80),

            // Version
            const Text(
              'v3.1.0',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 12,
              ),
            ).animate().fadeIn(delay: 900.ms, duration: 500.ms),

            const SizedBox(height: 40),

            // Random quote
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151B2E).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00FF94).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.format_quote,
                    color: Color(0xFF00FF94),
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _randomQuote.quote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '— ${_randomQuote.author}',
                    style: const TextStyle(
                      color: Color(0xFF00FF94),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1100.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 40),

            // Developer social media links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  icon: FontAwesomeIcons.instagram,
                  color: const Color(0xFFE1306C),
                  url: 'https://instagram.com/Indradwi.25',
                  tooltip: 'Instagram',
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  icon: FontAwesomeIcons.facebook,
                  color: const Color(0xFF1877F2),
                  url: 'https://www.facebook.com/indradwi.25',
                  tooltip: 'Facebook',
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  icon: FontAwesomeIcons.github,
                  color: Colors.white,
                  url: 'https://github.com/Xnuvers007',
                  tooltip: 'GitHub',
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  icon: FontAwesomeIcons.tiktok,
                  color: Colors.white,
                  url: 'https://www.tiktok.com/@luckysora25',
                  tooltip: 'TikTok',
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  icon: FontAwesomeIcons.globe,
                  color: const Color(0xFF00FF94),
                  url: 'https://xnuvers007.github.io/myportfolio/',
                  tooltip: 'Portfolio',
                ),
              ],
            ).animate().fadeIn(delay: 1100.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 12),

            // Developer credit
            const Text(
              'Developed by Xnuvers007',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ).animate().fadeIn(delay: 1200.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required String url,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: FaIcon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
