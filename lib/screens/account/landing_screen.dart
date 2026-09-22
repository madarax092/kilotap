import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'login_screen.dart';

// ─── Landing Screen ───
// Animated intro only — fades in the logo, then the motto, holds briefly,
// fades the motto back out, then slides up into the login screen. No
// buttons; this screen is not meant to be revisited (pushReplacement, no
// back navigation to it). The logo Hero-flies into the login header; the
// title/tagline instead fade out here and fade back in (smaller, with a
// new welcome line) on the login screen, since text doesn't Hero cleanly
// across different font sizes.

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _exitController;
  late final Animation<double> _logoFade;
  late final Animation<double> _mottoFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
    );
    _mottoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeIn),
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _startExitSequence();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode both images well ahead of the login-screen push so that work
    // doesn't land on the main thread right as the slide transition starts
    // (was causing the transition to stall and jump straight to its end).
    precacheImage(const AssetImage('assets/images/kilotap_logo.png'), context);
    precacheImage(const AssetImage('assets/images/google.png'), context);
  }

  Future<void> _startExitSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await _exitController.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: offset, child: child);
      },
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: const Hero(
                    tag: 'kilotap_logo',
                    child: _LogoBadge(size: 120),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: Listenable.merge([_controller, _exitController]),
                  builder: (context, child) {
                    final opacity = _mottoFade.value * (1 - _exitController.value);
                    return Opacity(opacity: opacity, child: child);
                  },
                  child: const _MottoText(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final double size;
  const _LogoBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(size * 0.233)),
      padding: EdgeInsets.all(size * 0.083),
      child: Image.asset('assets/images/kilotap_logo.png'),
    );
  }
}

class _MottoText extends StatelessWidget {
  const _MottoText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('KiloTap',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary)),
        SizedBox(height: 8),
        Text('Tap the app, trade the scrap.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }
}
