import 'dart:math';

import 'package:flutter/material.dart';

class SnowfallEffect extends StatefulWidget {
  final int numberOfFlakes;
  final double maxSize;
  final Color color;
  final double windStrength; // 0 = no wind, 1 = strong wind

  const SnowfallEffect({
    super.key,
    this.numberOfFlakes = 150,
    this.maxSize = 24,
    this.color = Colors.white70,
    this.windStrength = 0.002,
  });

  @override
  State<SnowfallEffect> createState() => _SnowfallEffectState();
}

class _SnowfallEffectState extends State<SnowfallEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  late List<_Snowflake> _flakes;

  @override
  void initState() {
    super.initState();
    _flakes = List.generate(
      widget.numberOfFlakes,
      (_) => _Snowflake(
        x: _rand.nextDouble(),
        y: _rand.nextDouble(),
        size: _rand.nextDouble() * widget.maxSize / 2 + 4,
        speed: _rand.nextDouble() * 0.003 + 0.001,
        drift: (_rand.nextDouble() - 0.5) * widget.windStrength,
      ),
    );

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 100))
          ..addListener(() {
            _updateFlakes();
          });
    _controller.repeat();
  }

  void _updateFlakes() {
    setState(() {
      for (var flake in _flakes) {
        // Apply vertical speed
        flake.y += flake.speed;

        // Apply horizontal drift + wind effect
        flake.x +=
            flake.drift + (_rand.nextDouble() - 0.5) * widget.windStrength / 2;

        // Wrap around screen
        if (flake.y > 1) {
          flake.y = 0;
          flake.x = _rand.nextDouble();
        }
        if (flake.x > 1) flake.x = 0;
        if (flake.x < 0) flake.x = 1;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          children: _flakes.map((flake) {
            return Positioned(
              left: flake.x * constraints.maxWidth,
              top: flake.y * constraints.maxHeight,
              child: Icon(
                Icons.ac_unit, // snowflake icon
                color: widget.color,
                size: flake.size,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Snowflake {
  double x;
  double y;
  double size;
  double speed;
  double drift;

  _Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
  });
}

/// ---------------------------
/// Delayed Fade-In Snowfall
/// ---------------------------
class DelayedFadeInSnowfall extends StatefulWidget {
  final int numberOfFlakes;
  final double maxSize;
  final Color color;
  final double windStrength;
  final Duration delay;
  final Duration duration;

  const DelayedFadeInSnowfall({
    super.key,
    this.numberOfFlakes = 150,
    this.maxSize = 24,
    this.color = Colors.white70,
    this.windStrength = 0.002,
    this.delay = const Duration(seconds: 1),
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<DelayedFadeInSnowfall> createState() => _DelayedFadeInSnowfallState();
}

class _DelayedFadeInSnowfallState extends State<DelayedFadeInSnowfall> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: widget.duration,
      child: SnowfallEffect(
        numberOfFlakes: widget.numberOfFlakes,
        maxSize: widget.maxSize,
        color: widget.color,
        windStrength: widget.windStrength,
      ),
    );
  }
}
