import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';

class SliverFillRemaiings extends StatefulWidget {
  const SliverFillRemaiings({
    super.key,
    required this.errors,
    required this.hasScrollBodys,
  });

  final String errors;
  final bool hasScrollBodys;

  @override
  State<SliverFillRemaiings> createState() => _SliverFillRemaiingsState();
}

class _SliverFillRemaiingsState extends State<SliverFillRemaiings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isInternetCheck =>
      widget.errors == cekInternet ||
      widget.errors.toLowerCase().contains('internet');

  bool get _isServerDown =>
      widget.errors == serverDown ||
      widget.errors.toLowerCase().contains('server');

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: widget.hasScrollBodys,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _isInternetCheck
              ? _InternetCheckAnimated(
                  message: widget.errors,
                  controller: _controller,
                )
              : _isServerDown
              ? _ServerDownAnimated(
                  message: widget.errors,
                  controller: _controller,
                )
              : _GenericErrorContent(message: widget.errors),
        ),
      ),
    );
  }
}

class _InternetCheckAnimated extends StatelessWidget {
  const _InternetCheckAnimated({
    required this.message,
    required this.controller,
  });

  final String message;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = context.textSecondary;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pulse = (math.sin(controller.value * 2 * math.pi) + 1) / 2;
        final textOpacity = 0.55 + pulse * 0.45;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96 + pulse * 12,
                    height: 96 + pulse * 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: clrOrange.withValues(alpha: 0.08 + pulse * 0.06),
                    ),
                  ),
                  CustomPaint(
                    size: const Size(88, 88),
                    painter: _WifiSignalPainter(
                      progress: controller.value,
                      color: clrOrange,
                    ),
                  ),
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 36,
                    color: clrOrange.withValues(alpha: 0.35 + pulse * 0.25),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: textOpacity,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.isDarkMode ? Colors.white : clrBlack,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _AnimatedDots(controller: controller, color: subtitleColor),
            const SizedBox(height: 6),
            Text(
              context.s.waitingConnection,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: subtitleColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ServerDownAnimated extends StatelessWidget {
  const _ServerDownAnimated({
    required this.message,
    required this.controller,
  });

  final String message;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final pulse = (math.sin(controller.value * 2 * math.pi) + 1) / 2;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.92 + pulse * 0.08,
              child: Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: clrOrange.withValues(alpha: 0.5 + pulse * 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GenericErrorContent extends StatelessWidget {
  const _GenericErrorContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 48,
          color: clrOrange.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({
    required this.controller,
    required this.color,
  });

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final phase = (controller.value + index * 0.2) % 1.0;
          final opacity = 0.25 + (math.sin(phase * 2 * math.pi) + 1) / 2 * 0.75;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WifiSignalPainter extends CustomPainter {
  _WifiSignalPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final arcPhase = (progress + i * 0.33) % 1.0;
      final opacity = 0.15 + (math.sin(arcPhase * 2 * math.pi) + 1) / 2 * 0.85;
      final radius = 18.0 + i * 14.0;

      paint.color = color.withValues(alpha: opacity);
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi * 0.75,
        math.pi * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WifiSignalPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
