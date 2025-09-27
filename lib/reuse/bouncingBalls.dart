import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memoflip/theme/myColor.dart';

class FloatingBouncingIcons extends StatelessWidget {
  final int numberOfIcons;
  final double areaWidth;
  final double areaHeight;

  const FloatingBouncingIcons({
    super.key,
    this.numberOfIcons = 15,
    this.areaWidth = double.infinity,
    this.areaHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: areaWidth,
      height: areaHeight,
      child: Stack(
        children: List.generate(numberOfIcons, (index) {
          // Randomize initial delay, size, horizontal position
          final random = Random();
          final delay = random.nextDouble() * 2; // 0-2s delay
          final left =
              random.nextDouble() * (areaWidth - 30); // horizontal position
          final size = 20.0 + random.nextDouble() * 20; // icon size
          return Positioned(
            left: left,
            bottom: 0,
            child: BouncingIcon(delay: delay, size: size),
          );
        }),
      ),
    );
  }
}

class BouncingIcon extends StatefulWidget {
  final double delay;
  final double size;

  const BouncingIcon({super.key, this.delay = 0, this.size = 28});

  @override
  State<BouncingIcon> createState() => _BouncingIconState();
}

class _BouncingIconState extends State<BouncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  final Random _random = Random();
  late Color _color;
  late double _maxHeight;
  late IconData _icon;

  @override
  void initState() {
    super.initState();

    // Random icon
    List<IconData> icons = [Icons.star, Icons.favorite, Icons.help_outline];
    _icon = icons[_random.nextInt(icons.length)];

    // Random color
    List<Color> colors = [
      AppColors.iconGreen,
      AppColors.textOrange,
      AppColors.iconWhite,
      AppColors.glowCyan,
      Colors.pinkAccent,
      Colors.yellowAccent,
    ];
    _color = colors[_random.nextInt(colors.length)];

    // Random bounce height
    _maxHeight = 20.0 + _random.nextDouble() * 20;

    // Animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000 + _random.nextInt(800)),
    );

    // Bounce animation (up and down)
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: -_maxHeight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start animation after delay
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.repeat(reverse: true);
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
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: child,
        );
      },
      child: Icon(_icon, color: _color, size: widget.size),
    );
  }
}
