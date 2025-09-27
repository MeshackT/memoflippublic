import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/myColor.dart';

class PointsProgress extends StatefulWidget {
  final int currentPoints;
  final int pointsPerRound;

  const PointsProgress({
    super.key,
    required this.currentPoints,
    this.pointsPerRound = 20,
  });

  @override
  State<PointsProgress> createState() => _PointsProgressState();
}

class _PointsProgressState extends State<PointsProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<Star>? _stars;
  List<Star>? _barStars;
  int _oldPoints = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _generateStars();
    _controller.forward();
    _oldPoints = widget.currentPoints;
  }

  void _generateStars() {
    final random = Random();
    _stars = List.generate(115, (index) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = 80 + random.nextDouble() * 120; // wider spread
      final xOffset = (random.nextDouble() - 0.5) * 60;
      final yOffset = (random.nextDouble() - 0.5) * 60;
      return Star(
        direction: Offset(
          cos(angle) * distance + xOffset,
          sin(angle) * distance + yOffset,
        ),
        rotation: random.nextDouble() * 2 * pi,
        size: 14 + random.nextDouble() * 6,
      );
    });
  }

  void _generateBarStars() {
    final random = Random();
    _barStars = List.generate(50, (index) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = 40 + random.nextDouble() * 60;
      final xOffset = (random.nextDouble() - 0.5) * 40;
      final yOffset = (random.nextDouble() - 0.5) * 20;
      return Star(
        direction: Offset(
          cos(angle) * distance + xOffset,
          sin(angle) * distance + yOffset,
        ),
        rotation: random.nextDouble() * 2 * pi,
        size: 10 + random.nextDouble() * 4,
      );
    });
  }

  @override
  void didUpdateWidget(covariant PointsProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentPoints > oldWidget.currentPoints) {
      _generateStars();
      _controller.forward(from: 0);
      _oldPoints = oldWidget.currentPoints;

      if (widget.currentPoints >= widget.pointsPerRound) {
        _generateBarStars();
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Widget _buildStar(Star star, double progress, Offset center) {
  //   return Transform.translate(
  //     offset:
  //         center +
  //         star.direction * progress +
  //         Offset(0, 80 * progress * progress),
  //     child: Transform.rotate(
  //       angle: star.rotation * progress,
  //       child: Opacity(
  //         opacity: 1 - progress,
  //         child: Icon(
  //           Icons.star,
  //           size: star.size * (1 + 0.3 * progress),
  //           color: Colors.yellowAccent,
  //           shadows: const [
  //             Shadow(blurRadius: 4, color: Colors.orange, offset: Offset(0, 0)),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final int totalPoints = widget.currentPoints;
    final double progressValue = (totalPoints / widget.pointsPerRound).clamp(
      0.0,
      1.0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: _oldPoints, end: totalPoints),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Text(
                    'Points: $value',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: AppColors.glowCyan,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // if (_stars != null)
              //   AnimatedBuilder(
              //     animation: _controller,
              //     builder: (context, child) {
              //       final value = _controller.value;
              //       return LayoutBuilder(
              //         builder: (context, constraints) {
              //           final textWidth = constraints.maxWidth;
              //           final textHeight = 30.0;
              //           final center = Offset(textWidth / 2, textHeight / 2);
              //
              //           return Stack(
              //             children: _stars!
              //                 .map((star) => _buildStar(star, value, center))
              //                 .toList(),
              //           );
              //         },
              //       );
              //     },
              //   ),
            ],
          ),
          // const SizedBox(height: 8),
          // Stack(
          //   children: [
          //     // Glow effect behind progress bar
          //     // Container(
          //     //   decoration: BoxDecoration(
          //     //     borderRadius: BorderRadius.circular(12),
          //     //     boxShadow: [
          //     //       BoxShadow(
          //     //         color: AppColors.textOrange.withOpacity(0.6),
          //     //         blurRadius: 12,
          //     //         spreadRadius: 2,
          //     //         offset: const Offset(0, 0),
          //     //       ),
          //     //       BoxShadow(
          //     //         color: Colors.black.withOpacity(0.3),
          //     //         blurRadius: 6,
          //     //         offset: const Offset(0, 3),
          //     //       ),
          //     //     ],
          //     //   ),
          //     //   child: ClipRRect(
          //     //     borderRadius: BorderRadius.circular(10),
          //     //     child: LinearProgressIndicator(
          //     //       value: progressValue,
          //     //       minHeight: 8,
          //     //       backgroundColor: Colors.white24,
          //     //       valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOrange),
          //     //     ),
          //     //   ),
          //     // ),
          //     // Extra stars on the bar when max reached
          //     // if (_barStars != null)
          //     //   AnimatedBuilder(
          //     //     animation: _controller,
          //     //     builder: (context, child) {
          //     //       final value = _controller.value;
          //     //       return Positioned.fill(
          //     //         child: LayoutBuilder(
          //     //           builder: (context, constraints) {
          //     //             final barCenter = Offset(
          //     //               constraints.maxWidth / 2,
          //     //               constraints.maxHeight / 2,
          //     //             );
          //     //             return Stack(
          //     //               children: _barStars!
          //     //                   .map(
          //     //                     (star) => _buildStar(star, value, barCenter),
          //     //                   )
          //     //                   .toList(),
          //     //             );
          //     //           },
          //     //         ),
          //     //       );
          //     //     },
          //     //   ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

class Star {
  final Offset direction;
  final double rotation;
  final double size;

  Star({required this.direction, required this.rotation, required this.size});
}
