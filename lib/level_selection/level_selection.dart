import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoflip/reuse/bouncingBalls.dart';

import '../game/ui/game_screen.dart';
import '../reuse/rain.dart';
import '../reuse/reuse.dart';
import '../theme/myColor.dart';

class LevelSelection extends StatefulWidget {
  const LevelSelection({super.key});

  @override
  State<LevelSelection> createState() => _LevelSelectionState();
}

class _LevelSelectionState extends State<LevelSelection> {
  void getTokenDev() async {
    String? token = await FirebaseMessaging.instance.getToken();
    logger.i("Device token: $token");
  }

  @override
  void initState() {
    super.initState();
    getTokenDev();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // Background Image
            SizedBox.expand(
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // const RainEffect(numberOfDrops: 300, dropColor: Colors.blueAccent),
            const DelayedFadeInRain(),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Select Your Level",
                    style: GoogleFonts.fredoka(
                      textStyle: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOrange,
                        letterSpacing: 3,
                      ),
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: AppColors.glowCyan,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // Easy Level
                  _levelButton(
                    context,
                    "Easy",
                    AppColors.btnPrimary,
                    '/game_screen',
                    4,
                    'numbers',
                  ),
                  const SizedBox(height: 20),
                  // Medium Level
                  _levelButton(
                    context,
                    "Medium",
                    AppColors.btnSecondary,
                    '/game_screen',
                    6,
                    'numbers_icons',
                  ),
                  const SizedBox(height: 20),
                  // Hard Level
                  _levelButton(
                    context,
                    "Hard",
                    AppColors.glowYellow,
                    '/game_screen',
                    8,
                    'numbers_icons_images',
                  ),
                ],
              ),
            ),
            // Bouncing circles at bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return BouncingIcon(delay: index * 0.2);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelButton(
    BuildContext context,
    String label,
    Color color,
    String route,
    int gridSize,
    String levelType, // NEW
  ) {
    return ElevatedButton(
      onPressed: () {
        navigateWithFade(
          context,
          GameScreen(
            level: 1,
            gridSize: gridSize, // comes from selection
            levelType: levelType, // comes from selection
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.textWhite,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.fredoka(fontSize: 14, color: AppColors.textWhite),
      ),
    );
  }
}
