import 'dart:math';

import 'package:flutter/material.dart';

class FallingObjectsEffect extends StatefulWidget {
  final int numberOfObjects;
  final List<String> spritePaths; // Asset paths
  final double maxSize;
  final double minSize;
  final double speed;
  final double wind;

  const FallingObjectsEffect({
    super.key,
    required this.numberOfObjects,
    required this.spritePaths,
    this.maxSize = 40,
    this.minSize = 20,
    this.speed = 1.0,
    this.wind = 0.002,
  });

  @override
  State<FallingObjectsEffect> createState() => _FallingObjectsEffectState();
}

class _FallingObjectsEffectState extends State<FallingObjectsEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  late List<_FallingObject> _objects;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _objects = List.generate(widget.numberOfObjects, (_) {
      return _FallingObject(
        x: _rand.nextDouble(),
        y: _rand.nextDouble(),
        size:
            widget.minSize +
            _rand.nextDouble() * (widget.maxSize - widget.minSize),
        spritePath:
            widget.spritePaths[_rand.nextInt(widget.spritePaths.length)],
        rotation: _rand.nextDouble() * 2 * pi,
        rotationSpeed: (_rand.nextDouble() - 0.5) * 0.02,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _objects.map((obj) {
            // Update position
            obj.y += 0.002 * widget.speed;
            obj.x += (obj.x - 0.5) * widget.wind;

            if (obj.y > 1.0) {
              obj.y = 0;
              obj.x = _rand.nextDouble();
            }

            obj.rotation += obj.rotationSpeed;

            return Positioned(
              left: obj.x * MediaQuery.of(context).size.width,
              top: obj.y * MediaQuery.of(context).size.height,
              child: Transform.rotate(
                angle: obj.rotation,
                child: Image.asset(
                  obj.spritePath,
                  width: obj.size,
                  height: obj.size,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _FallingObject {
  double x;
  double y;
  final double size;
  final String spritePath;
  double rotation;
  final double rotationSpeed;

  _FallingObject({
    required this.x,
    required this.y,
    required this.size,
    required this.spritePath,
    required this.rotation,
    required this.rotationSpeed,
  });
}

/// ---------------------------
/// Delayed Fade-In Falling Objects
/// ---------------------------
class DelayedFadeInFallingObjects extends StatefulWidget {
  final int numberOfObjects;
  final List<String> spritePaths;
  final double maxSize;
  final double minSize;
  final double speed;
  final double wind;
  final Duration delay;
  final Duration duration;

  const DelayedFadeInFallingObjects({
    super.key,
    required this.numberOfObjects,
    required this.spritePaths,
    this.maxSize = 40,
    this.minSize = 20,
    this.speed = 1.0,
    this.wind = 0.002,
    this.delay = const Duration(seconds: 1),
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<DelayedFadeInFallingObjects> createState() =>
      _DelayedFadeInFallingObjectsState();
}

class _DelayedFadeInFallingObjectsState
    extends State<DelayedFadeInFallingObjects> {
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
      child: FallingObjectsEffect(
        numberOfObjects: widget.numberOfObjects,
        spritePaths: widget.spritePaths,
        maxSize: widget.maxSize,
        minSize: widget.minSize,
        speed: widget.speed,
        wind: widget.wind,
      ),
    );
  }
}
