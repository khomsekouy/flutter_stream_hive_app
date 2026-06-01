import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/router/app_router.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/gen/assets.gen.dart';
import 'package:go_router/go_router.dart';

/// Animated launch screen, shown as the app's initial route.
///
/// The OS splash (the frame shown before Flutter boots) is necessarily static;
/// this in-app screen is what lets us animate. The logo fades + scales in, the
/// wordmark follows, then a timer auto-navigates to the home route.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// How long the splash stays up before navigating home.
  static const Duration _hold = Duration(milliseconds: 2200);

  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1, curve: Curves.easeIn),
    );

    unawaited(_controller.forward());
    _navTimer = Timer(_hold, _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    context.goNamed(AppRoute.home);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Assets.images.launchImage.image(
                  width: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.live_tv_rounded,
                    size: 120,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textFade,
              child: Text(
                'StreamHive',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _textFade,
              child: Text(
                'Live sport, anywhere',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
