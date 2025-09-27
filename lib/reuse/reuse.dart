import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

import '../theme/myColor.dart';

Logger logger = Logger(printer: PrettyPrinter(colors: true));

/// -------------------------
/// Navigation
/// -------------------------
void navigateWithFade(BuildContext context, Widget page) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 600),
    ),
  );
}

void navigateWithFadeReplacement(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 600),
    ),
  );
}

/// -------------------------
/// Reusable Delayed Fade-In
/// -------------------------
class DelayedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const DelayedFadeIn({
    super.key,
    required this.child,
    this.delay = const Duration(seconds: 2),
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<DelayedFadeIn> createState() => _DelayedFadeInState();
}

class _DelayedFadeInState extends State<DelayedFadeIn> {
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
      child: widget.child,
    );
  }
}

/// ---------------------
/// Switch buttons
/// ---------------------
class SoundToggleTile extends StatelessWidget {
  final String title;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final ValueNotifier<bool> notifier;
  final VoidCallback onToggle;

  const SoundToggleTile({
    super.key,
    required this.title,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.notifier,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, _) => ListTile(
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            value ? activeIcon : inactiveIcon,
            key: ValueKey(value),
            color: AppColors.iconOrange,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.fredoka(color: AppColors.textOrange),
        ),
        trailing: GestureDetector(
          onTap: onToggle,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              value ? Icons.toggle_on : Icons.toggle_off,
              key: ValueKey(value),
              size: 36,
              color: AppColors.iconOrange,
            ),
          ),
        ),
      ),
    );
  }
}

/// ----------------
/// Icon glow
/// ---------------
class GlowingIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double glowRadius;
  final Color glowColor;
  final double size;

  const GlowingIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.iconWhite,
    this.glowRadius = 2,
    this.glowColor = AppColors.iconOrange,
    this.size = 20,
  });

  @override
  State<GlowingIconButton> createState() => _GlowingIconButtonState();
}

class _GlowingIconButtonState extends State<GlowingIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _animation.value),
                blurRadius: widget.glowRadius,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(widget.icon, color: widget.color, size: widget.size),
            onPressed: widget.onPressed,
          ),
        );
      },
    );
  }
}
