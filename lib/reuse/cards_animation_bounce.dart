import 'dart:math';

import 'package:flutter/material.dart';

class BouncingRotatingCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double delay; // delay in seconds

  const BouncingRotatingCard({
    super.key,
    required this.icon,
    required this.color,
    this.delay = 0,
  });

  @override
  State<BouncingRotatingCard> createState() => _BouncingRotatingCardState();
}

class _BouncingRotatingCardState extends State<BouncingRotatingCard>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _fadeBounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Rotation controller
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Fade + bounce controller
    _fadeBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeBounceController,
      curve: Curves.easeIn,
    );

    _bounceAnimation =
        Tween<double>(
          begin: 0,
          end: (-15 - _random.nextInt(10)).toDouble(), // <-- add toDouble()
        ).animate(
          CurvedAnimation(
            parent: _fadeBounceController,
            curve: Curves.elasticOut,
          ),
        );

    // Staggered/random delay before starting
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _fadeBounceController.forward();
    });
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _fadeBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _rotateController,
        builder: (_, child) {
          double angle = _rotateController.value * 2 * pi;
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(angle),
              child: child,
            ),
          );
        },
        child: Container(
          width: 60,
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(widget.icon, size: 36, color: Colors.white),
        ),
      ),
    );
  }
}
