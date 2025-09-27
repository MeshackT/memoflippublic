import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoflip/theme/myColor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../reuse/bouncingBalls.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = '/about';
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background4.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay for better readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textBlack.withValues(alpha: 0.6),
                  AppColors.textBlack.withValues(alpha: 0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Page title
                Text(
                  "About MemoFlip",
                  style: GoogleFonts.fredoka(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOrange,
                    letterSpacing: 2,
                    shadows: const [
                      Shadow(
                        blurRadius: 12,
                        color: AppColors.glowCyan,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Description box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.textOrange, width: 2),
                  ),
                  child: Text(
                    "MemoFlip is a fun and challenging memory game designed to test "
                    "your recall and concentration. Flip the cards, match pairs, "
                    "and advance through exciting levels with increasing difficulty. "
                    "Customize your experience with different themes and enjoy relaxing "
                    "background sounds as you play.",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,

                      color: AppColors.textWhite,
                      height: 1.5, //height
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // Features section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _featureItem(Icons.star, "Multiple Levels"),
                    _featureItem(Icons.favorite, "Customizable Themes"),
                    _featureItem(Icons.help_outline, "Fun Background Effects"),
                    _featureItem(Icons.music_note, "Background Music & Sounds"),
                    _featureItem(Icons.flash_on, "Increasing Challenge"),
                  ],
                ),
                const SizedBox(height: 60),

                // Bouncing icons at the bottom
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (index) => BouncingIcon(delay: index * 0.3),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse(
                      "https://github.com/MeshackT/Policies/blob/main/memoflip.md",
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Could not open the policy link"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
                    "Policy",
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Back button at top-left
          Positioned(
            top: 35,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.iconOrange),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.iconOrange, size: 28),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.fredoka(
              fontSize: 18,
              color: AppColors.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
