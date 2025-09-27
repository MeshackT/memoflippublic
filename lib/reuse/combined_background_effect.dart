import 'package:flutter/material.dart';
import 'package:memoflip/reuse/rain.dart';
import 'package:memoflip/reuse/snow.dart';

import 'leaves.dart';

/// Background effect with fade-out → delay → fade-in on grid changes
class BackgroundEffect extends StatefulWidget {
  final int gridSize;

  const BackgroundEffect({super.key, required this.gridSize});

  @override
  State<BackgroundEffect> createState() => _BackgroundEffectState();
}

class _BackgroundEffectState extends State<BackgroundEffect> {
  int? _currentGridSize;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _currentGridSize = widget.gridSize;
    _startFadeIn();
  }

  @override
  void didUpdateWidget(covariant BackgroundEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gridSize != widget.gridSize) {
      _startFadeOutAndSwitch(widget.gridSize);
    }
  }

  void _startFadeIn() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  void _startFadeOutAndSwitch(int newGridSize) {
    setState(() => _visible = false); // fade out current effect
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentGridSize = newGridSize;
          _visible = false; // keep invisible until fade-in delay
        });
        _startFadeIn(); // restart fade-in after 5s
      }
    });
  }

  Widget _buildEffect() {
    if (_currentGridSize == 6) {
      return RainEffect(numberOfDrops: 300, dropColor: Colors.blueAccent);
    } else if (_currentGridSize == 4) {
      return SnowfallEffect(
        numberOfFlakes: 200,
        maxSize: 28,
        color: Colors.white70,
        windStrength: 0.004,
      );
    } else if (_currentGridSize != null && _currentGridSize! >= 8) {
      return const FallingObjectsEffect(
        numberOfObjects: 100,
        spritePaths: [
          'assets/images/petal1.png',
          'assets/images/petal2.png',
          'assets/images/petal3.png',
        ],
        maxSize: 30,
        minSize: 15,
        speed: 1.0,
        wind: 0.003,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(seconds: 2), // fade-out & fade-in duration
      curve: Curves.easeInOut,
      child: _buildEffect(),
    );
  }
}
