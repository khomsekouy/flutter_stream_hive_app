import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/content/home_content.dart';

/// The top hero: an auto-advancing carousel of marquee matches.
class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({required this.matches, this.onTap, super.key});

  final List<FeaturedMatch> matches;
  final ValueChanged<FeaturedMatch>? onTap;

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  static const Duration _autoAdvance = Duration(seconds: 5);

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

  void _startAutoSlide() {
    _autoTimer?.cancel();
    if (widget.matches.length < 2) return;
    _autoTimer = Timer.periodic(_autoAdvance, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.matches.length;
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
    _startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 11,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Listener(
                onPointerDown: (_) => _autoTimer?.cancel(),
                onPointerUp: (_) => _startAutoSlide(),
                onPointerCancel: (_) => _startAutoSlide(),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.matches.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, i) => _FeaturedSlide(
                    match: widget.matches[i],
                    onTap: widget.onTap,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 14,
                child: _Dots(count: widget.matches.length, active: _index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedSlide extends StatelessWidget {
  const _FeaturedSlide({required this.match, this.onTap});

  final FeaturedMatch match;
  final ValueChanged<FeaturedMatch>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(match),
      // The banner artwork already carries the match title and competition,
      // so we don't overlay our own text — only the LIVE pill (the dots are
      // drawn by the carousel above this slide).
      child: Stack(
        fit: StackFit.expand,
        children: [
          match.banner.image(
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const ColoredBox(
              color: AppColors.surfaceHigh,
            ),
          ),
          if (match.isLive)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 18),
                child: _LivePill(),
              ),
            ),
        ],
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.live,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: AppColors.white),
          SizedBox(width: 6),
          Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? AppColors.live : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
