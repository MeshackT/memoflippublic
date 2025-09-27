import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoflip/home/about.dart';
import 'package:memoflip/level_selection/level_selection.dart';
import 'package:memoflip/reuse/reuse.dart';
import 'package:memoflip/theme/myColor.dart';

import '../reuse/bouncingBalls.dart';
import '../reuse/sound/sound.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _initSound();
  }

  Future<void> _initSound() async {
    await _soundService.init();
    if (_soundService.bgEnabledNotifier.value) {
      await _soundService.playBackground('background_sound.mp3');
    }
    // No setState needed; toggle is reactive
  }

  @override
  void dispose() {
    _soundService.stopBackground();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Center content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    "MemoFlip",
                    style: GoogleFonts.fredoka(
                      textStyle: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOrange,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: AppColors.glowCyan,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Play button
                  ElevatedButton(
                    onPressed: () {
                      navigateWithFade(context, LevelSelection());
                      // Navigator.pushNamed(context, '/level_selection');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.85,
                      ),
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "PLAY",
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // About button
                  ElevatedButton(
                    onPressed: () {
                      navigateWithFade(context, AboutScreen());

                      // Navigator.pushNamed(context, '/about');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btnSecondary.withValues(
                        alpha: 0.85,
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "ABOUT",
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sound toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SOUND',
                        style: GoogleFonts.fredoka(
                          fontSize: 14,
                          letterSpacing: 1,
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _soundService.bgEnabledNotifier,
                        builder: (context, value, _) {
                          return Switch(
                            value: value,
                            onChanged: (_) async {
                              await _soundService.toggleBackground();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // cards
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5, // number of icons
                (index) => BouncingIcon(delay: index * 0.8),
              ),
            ),
          ),

          // Bouncing circles at bottom
          // Positioned(
          //   bottom: 40,
          //   left: 0,
          //   right: 0,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: List.generate(
          //       3,
          //       (index) => BouncingCircle(delay: index * 0.2),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
