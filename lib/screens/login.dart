/*import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meetup/resources/auth_methods.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final AuthMethods _authMethods = AuthMethods();
  late final AnimationController _animController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    bool res = await _authMethods.signInWithGoogle(context);
    setState(() => _loading = false);
    if (res) {
      Navigator.pushNamed(context, '/home');
    }
  }

  Widget _logo() {
    // put your logo at assets/images/logo.png (fallback to FlutterLogo)
    return Image.asset(
      'assets/images/logo.png',
      height: 92,
      errorBuilder: (ctx, e, st) => const FlutterLogo(size: 92),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Animated shifting gradient background
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final t = _animController.value;
              final begin = Alignment(-1 + 2 * t, -1);
              final end = Alignment(1 - 2 * t, 1);
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: const [
                      Color(0xFF052F4F),
                      Color(0xFF0B525B),
                      Color(0xFF0F9B8E),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),

          // subtle animated floating shapes
          IgnorePointer(
            child: CustomPaint(
              size: size,
              painter: _BlobsPainter(_animController),
            ),
          ),

          // content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card / Glass
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha:0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _logo(),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'MeetUp',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Fast. Private. Open.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Welcome text
                            const Text(
                              'Connect instantly — create or join video meetings in one tap.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),

                            const SizedBox(height: 24),

                            // Google button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _loading ? null : _signIn,
                                icon: _loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Image.asset(
                                        'assets/images/google_icon.png',
                                        height: 18,
                                        width: 18,
                                        errorBuilder: (ctx, e, st) => const Icon(Icons.login, size: 18),
                                      ),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    _loading ? 'Signing in...' : 'Continue with Google',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Secondary small buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/home'),
                                  child: const Text('Continue as guest', style: TextStyle(color: Colors.white70)),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () => showAboutDialog(
                                    context: context,
                                    applicationName: 'MeetUp',
                                    applicationVersion: '1.0',
                                    children: const [Text('Built with Flutter & Jitsi.')],
                                  ),
                                  child: const Text('About', style: TextStyle(color: Colors.white70)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Footer hint
                      const Text(
                        'By continuing you agree to our Terms & Privacy',
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle animated blobs for background (no external deps)
class _BlobsPainter extends CustomPainter {
  final Animation<double> animation;
  _BlobsPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final paint = Paint()..style = PaintingStyle.fill;

    // blob 1
    paint.color = Colors.white.withValues(alpha:0.03);
    final r1 = size.width * 0.28;
    final c1 = Offset(
      size.width * (0.1 + 0.3 * sin(t * 2 * pi)),
      size.height * (0.18 + 0.04 * cos(t * 2 * pi)),
    );
    canvas.drawCircle(c1, r1, paint);

    // blob 2
    paint.color = Colors.white.withValues(alpha:0.02);
    final r2 = size.width * 0.16;
    final c2 = Offset(
      size.width * (0.82 - 0.15 * cos(t * 2 * pi)),
      size.height * (0.75 - 0.05 * sin(t * 2 * pi)),
    );
    canvas.drawCircle(c2, r2, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter oldDelegate) => true;
}*/
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meetup/resources/auth_methods.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthMethods _authMethods = AuthMethods();
  late final AnimationController _animController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Navigation is handled purely by the auth StreamBuilder in main.dart.
  // These methods simply trigger auth state changes.

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    await _authMethods.signInWithGoogle(context);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _continueAsGuest() async {
    setState(() => _loading = true);
    await _authMethods.signInAsGuest(context);
    if (mounted) setState(() => _loading = false);
  }

  Widget _logo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 92,
      errorBuilder: (ctx, e, st) => const FlutterLogo(size: 92),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // ── Animated gradient background ──────────────────────────────
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final t = _animController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + 2 * t, -1),
                    end: Alignment(1 - 2 * t, 1),
                    colors: const [
                      Color(0xFF052F4F),
                      Color(0xFF0B525B),
                      Color(0xFF0F9B8E),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),

          // ── Subtle floating blobs ─────────────────────────────────────
          IgnorePointer(
            child: CustomPaint(
              size: size,
              painter: _BlobsPainter(_animController),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _logo(),
                                const SizedBox(width: 14),
                                const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MeetUp',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Fast. Private. Open.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              'Connect instantly — create or join\nvideo meetings in one tap.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),

                            const SizedBox(height: 24),

                            // ── Google sign-in button ─────────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _loading ? null : _signInWithGoogle,
                                icon: _loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : Image.asset(
                                        'assets/images/google_icon.png',
                                        height: 18,
                                        width: 18,
                                        errorBuilder: (ctx, e, st) =>
                                            const Icon(Icons.login, size: 18),
                                      ),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  child: Text(
                                    _loading
                                        ? 'Signing in...'
                                        : 'Continue with Google',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  // Uses anonymous Firebase auth — no null crash risk
                                  onPressed:
                                      _loading ? null : _continueAsGuest,
                                  child: const Text('Continue as guest',
                                      style:
                                          TextStyle(color: Colors.white70)),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () => showAboutDialog(
                                    context: context,
                                    applicationName: 'MeetUp',
                                    applicationVersion: '1.0',
                                    children: const [
                                      Text('Built with Flutter & Jitsi.')
                                    ],
                                  ),
                                  child: const Text('About',
                                      style:
                                          TextStyle(color: Colors.white70)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'By continuing you agree to our Terms & Privacy',
                        style:
                            TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlobsPainter extends CustomPainter {
  final Animation<double> animation;
  _BlobsPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.white.withValues(alpha: 0.03);
    canvas.drawCircle(
      Offset(
        size.width * (0.1 + 0.3 * sin(t * 2 * pi)),
        size.height * (0.18 + 0.04 * cos(t * 2 * pi)),
      ),
      size.width * 0.28,
      paint,
    );

    paint.color = Colors.white.withValues(alpha: 0.02);
    canvas.drawCircle(
      Offset(
        size.width * (0.82 - 0.15 * cos(t * 2 * pi)),
        size.height * (0.75 - 0.05 * sin(t * 2 * pi)),
      ),
      size.width * 0.16,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter oldDelegate) => true;
}