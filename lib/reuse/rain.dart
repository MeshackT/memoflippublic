import 'dart:math';

import 'package:flutter/material.dart';

/// ------------------------
/// Reusable Rain Widget
/// ------------------------
class RainEffect extends StatefulWidget {
  final int numberOfDrops;
  final Color dropColor;
  final double minSpeed;
  final double maxSpeed;
  final double minLength;
  final double maxLength;
  final double width;
  final double height;

  const RainEffect({
    super.key,
    this.numberOfDrops = 200,
    this.dropColor = const Color.fromARGB(150, 0, 162, 255),
    this.minSpeed = 0.2,
    this.maxSpeed = 0.8,
    this.minLength = 0.01,
    this.maxLength = 0.03,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  State<RainEffect> createState() => _RainEffectState();
}

class _RainDrop {
  double x;
  double y;
  double speed;
  double length;
  double drift;

  _RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.drift,
  });
}

class _RainEffectState extends State<RainEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_RainDrop> _drops = [];
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();

    for (int i = 0; i < widget.numberOfDrops; i++) {
      _drops.add(
        _RainDrop(
          x: _rand.nextDouble(),
          y: _rand.nextDouble(),
          speed:
              widget.minSpeed +
              _rand.nextDouble() * (widget.maxSpeed - widget.minSpeed),
          length:
              widget.minLength +
              _rand.nextDouble() * (widget.maxLength - widget.minLength),
          drift: (_rand.nextDouble() - 0.5) * 0.002,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _RainPainter(
              _drops,
              _controller.lastElapsedDuration?.inMilliseconds ?? 0,
              widget.dropColor,
            ),
          );
        },
      ),
    );
  }
}

/// ------------------------
/// Painter
/// ------------------------
class _RainPainter extends CustomPainter {
  final List<_RainDrop> drops;
  final int elapsedMs;
  final Color dropColor;

  _RainPainter(this.drops, this.elapsedMs, this.dropColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dropColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final dt = elapsedMs / 1000;

    for (final drop in drops) {
      double y = (drop.y + drop.speed * dt) % 1;
      double x = (drop.x + drop.drift * dt) % 1;
      canvas.drawLine(
        Offset(x * size.width, y * size.height),
        Offset(x * size.width, (y + drop.length) * size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}

class DelayedFadeInRain extends StatefulWidget {
  const DelayedFadeInRain({super.key});

  @override
  State<DelayedFadeInRain> createState() => _DelayedFadeInRainState();
}

class _DelayedFadeInRainState extends State<DelayedFadeInRain> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Start fade-in after 2 seconds
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(seconds: 1), // fade-in duration
      child: const RainEffect(numberOfDrops: 300, dropColor: Colors.blueAccent),
    );
  }
}
