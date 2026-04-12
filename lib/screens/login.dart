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
  bool _loading = false;

  late final AnimationController _ctrl;
  late final Animation<double> _panelSlide;
  late final Animation<double> _brandFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _panelSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _brandFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 640;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Anime background ─────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/anime.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Layered dark overlays ────────────────────────────────────
          // Base dim
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.78)),
          ),
          // Gradient: darker at bottom where the panel lives
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          isWide
              ? _WideLayout(
                  ctrl: _ctrl,
                  brandFade: _brandFade,
                  panelSlide: _panelSlide,
                  loading: _loading,
                  onGoogle: _signInWithGoogle,
                  onGuest: _continueAsGuest,
                )
              : _MobileLayout(
                  brandFade: _brandFade,
                  panelSlide: _panelSlide,
                  loading: _loading,
                  onGoogle: _signInWithGoogle,
                  onGuest: _continueAsGuest,
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE LAYOUT  ·  Branding up top, sign-in panel pinned to bottom
// ─────────────────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final Animation<double> brandFade;
  final Animation<double> panelSlide;
  final bool loading;
  final VoidCallback onGoogle;
  final VoidCallback onGuest;

  const _MobileLayout({
    required this.brandFade,
    required this.panelSlide,
    required this.loading,
    required this.onGoogle,
    required this.onGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Branding ─────────────────────────────────────────────────────
        Expanded(
          child: SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: brandFade,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _AppIcon(),
                    SizedBox(height: 22),
                    _Wordmark(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Sign-in panel ─────────────────────────────────────────────────
        AnimatedBuilder(
          animation: panelSlide,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, panelSlide.value),
            child: child,
          ),
          child: _SignInPanel(
            loading: loading,
            onGoogle: onGoogle,
            onGuest: onGuest,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDE LAYOUT  ·  Centered card for desktop / tablet
// ─────────────────────────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final AnimationController ctrl;
  final Animation<double> brandFade;
  final Animation<double> panelSlide;
  final bool loading;
  final VoidCallback onGoogle;
  final VoidCallback onGuest;

  const _WideLayout({
    required this.ctrl,
    required this.brandFade,
    required this.panelSlide,
    required this.loading,
    required this.onGoogle,
    required this.onGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
        child: AnimatedBuilder(
          animation: panelSlide,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, panelSlide.value * 0.5),
            child: child,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AppIcon(),
                  const SizedBox(height: 24),
                  const _Wordmark(),
                  const SizedBox(height: 40),
                  _SignInPanel(
                    loading: loading,
                    onGoogle: onGoogle,
                    onGuest: onGuest,
                    elevated: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP ICON
// ─────────────────────────────────────────────────────────────────────────────
class _AppIcon extends StatelessWidget {
  const _AppIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: 52,
      errorBuilder: (ctx, e, st) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Icon(Icons.videocam_rounded,
            color: Colors.white70, size: 26),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WORDMARK
// ─────────────────────────────────────────────────────────────────────────────
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MeetUp',
          style: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.8,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Fast. Private. Open.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.40),
            fontSize: 14.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIGN-IN PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _SignInPanel extends StatelessWidget {
  final bool loading;
  final VoidCallback onGoogle;
  final VoidCallback onGuest;

  /// [elevated] — true on desktop: adds a border/background so the panel
  /// sits against the blurred scene rather than a dark column bottom.
  final bool elevated;

  const _SignInPanel({
    required this.loading,
    required this.onGoogle,
    required this.onGuest,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Heading
          Text(
            'Sign in to continue',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Create or join meetings instantly.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),

          // ── Google button ──────────────────────────────────────────
          _GoogleButton(loading: loading, onPressed: onGoogle),

          const SizedBox(height: 12),

          // ── Divider ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                    height: 0.5,
                    color: Colors.white.withOpacity(0.10)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                    height: 0.5,
                    color: Colors.white.withOpacity(0.10)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Guest button ──────────────────────────────────────────
          _GuestButton(loading: loading, onPressed: onGuest),

          const SizedBox(height: 24),

          // ── Legal ─────────────────────────────────────────────────
          Text(
            'By continuing you agree to our Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.18),
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );

    if (!elevated) {
      // Mobile: dark surface anchored to the bottom, rounded top corners
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E1C),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: SafeArea(
          top: false,
          child: content,
        ),
      );
    }

    // Desktop: bordered card sitting in the scene
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GOOGLE BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _GoogleButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onPressed;
  const _GoogleButton({required this.loading, required this.onPressed});

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) {
          _press.reverse();
          if (!widget.loading) widget.onPressed();
        },
        onTapCancel: () => _press.reverse(),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black54),
                )
              else ...[
                Image.asset(
                  'assets/images/google_icon.png',
                  width: 18,
                  height: 18,
                  errorBuilder: (ctx, e, st) => const Icon(Icons.login,
                      size: 18, color: Colors.black54),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.loading ? 'Signing in…' : 'Continue with Google',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GUEST BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _GuestButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  const _GuestButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border:
              Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Center(
          child: Text(
            'Continue as guest',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}