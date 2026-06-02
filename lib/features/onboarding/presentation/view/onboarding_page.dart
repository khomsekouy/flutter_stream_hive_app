import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/router/app_router.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

class _Slide {
  const _Slide({
    required this.imageUrl,
    required this.titleTop,
    required this.titleBottom,
    required this.subtitle,
  });

  final String imageUrl;
  final String titleTop;
  final String titleBottom;
  final String subtitle;
}

/// The carousel content. Photos are the articles' share images (og:image),
/// loaded over the network and cached.
const List<_Slide> _slides = [
  _Slide(
    imageUrl:
        'https://images2.minutemediacdn.com/image/upload/c_crop,x_0,y_0,'
        'w_1919,h_1079/c_fill,w_720,ar_16:9,f_auto,q_auto,g_auto/images/'
        'voltaxMediaLibrary/production/si/01ksq015va0erx974eft.jpg',
    titleTop: 'Step into the game',
    titleBottom: 'Own the win',
    subtitle: 'Join the action, make your moves\nand claim your victory.',
  ),
  _Slide(
    imageUrl:
        'https://cdn.britannica.com/63/222663-050-58CCA884/'
        'Soccer-forward-Cristiano-Ronaldo-2018.jpg',
    titleTop: 'Feel every match',
    titleBottom: 'Live the moment',
    subtitle: 'Crystal-clear streams of the\ngames that matter most.',
  ),
  _Slide(
    imageUrl:
        'https://cdn.britannica.com/35/238335-004-567C1DB1/'
        'Lionel-Messi-Argentina-Netherlands-World-Cup-Qatar-2022.jpg',
    titleTop: 'Follow the greats',
    titleBottom: 'Never miss a play',
    subtitle: 'Your favourite stars, live\nwherever you are.',
  ),
];

/// Welcome / onboarding carousel.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  /// How long each slide stays up before auto-advancing.
  static const Duration _autoAdvance = Duration(seconds: 4);

  final PageController _controller = PageController();
  Timer? _autoTimer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// (Re)starts the auto-advance timer. Called on init and after every page
  void _startAutoSlide() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(_autoAdvance, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _slides.length;
      unawaited(
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  void _onPageChanged(int i) {
    setState(() => _index = i);
    // Reset the timer so the slide the user landed on gets its full dwell.
    _startAutoSlide();
  }

  /// Finger down: hold the current slide so it doesn't slide out from under
  void _pauseAutoSlide() => _autoTimer?.cancel();

  /// Finger up: give the current slide a fresh full dwell, then resume.
  void _resumeAutoSlide() => _startAutoSlide();

  void _enterApp() => context.goNamed(AppRoute.home);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Listener (not GestureDetector) so we see the raw pointer down/up
          // without competing with the PageView's own swipe gestures.
          Listener(
            onPointerDown: (_) => _pauseAutoSlide(),
            onPointerUp: (_) => _resumeAutoSlide(),
            onPointerCancel: (_) => _resumeAutoSlide(),
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
            ),
          ),
          // Fixed controls — they don't scroll with the photos.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  children: [
                    _PageDots(count: _slides.length, active: _index),
                    const Spacer(),
                    _GetStartedButton(onPressed: _enterApp),
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

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  static const TextStyle _headline = TextStyle(
    color: AppColors.white,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: slide.imageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          placeholder: (context, url) => const _HeroGradient(),
          errorWidget: (context, url, error) => const _HeroGradient(),
        ),
        // Scrim so the text stays legible over the photo.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, AppColors.black],
              stops: [0.3, 0.9],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: SafeArea(
            top: false,
            // Bottom padding clears the fixed controls row below.
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 84),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(slide.titleTop, style: _headline),
                  Text(slide.titleBottom, style: _headline),
                  const SizedBox(height: 14),
                  Text(
                    slide.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dark moss-green gradient shown while a photo loads or if it fails.
class _HeroGradient extends StatelessWidget {
  const _HeroGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C2A12), AppColors.black],
        ),
      ),
    );
  }
}

/// Page indicator: an active brand-purple pill plus inactive dots.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            // Brand purple for the active page (green is reserved for CTAs).
            color: isActive ? AppColors.primaryLight : Colors.white30,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// Green "Get started" pill with a circular arrow.
class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cta,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(22, 11, 11, 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get started',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.arrow_outward,
                    size: 16,
                    color: AppColors.cta,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
