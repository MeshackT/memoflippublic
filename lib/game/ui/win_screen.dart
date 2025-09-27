import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../theme/myColor.dart';

class WinScreen extends StatefulWidget {
  const WinScreen({super.key});

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen> {
  late ConfettiController _confettiController;
  late int moves;
  late int time;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    moves = args?['moves'] ?? 0;
    time = args?['time'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            numberOfParticles: 30,
            gravity: 0.3,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🎉 You Win! 🎉',
                style: TextStyle(
                  color: AppColors.glowYellow,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.white,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Moves: $moves',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Time: $time s',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // replay
                },
                child: const Text(
                  'Replay',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Home',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //   icons
  IconData _mapStringToIcon(String iconStr) {
    switch (iconStr) {
      case 'icon_home':
        return Icons.home;
      case 'icon_star':
        return Icons.star;
      case 'icon_face':
        return Icons.face;
      case 'icon_pets':
        return Icons.pets;
      case 'icon_sports':
        return Icons.sports_soccer;
      case 'icon_music':
        return Icons.music_note;
      case 'icon_camera':
        return Icons.camera_alt;
      default:
        return Icons.help;
    }
  }
  // IconButton(
  // icon: const Icon(Icons.refresh, color: Colors.white),
  // onPressed: () => _dialogBox(state.moves, state.level),
  // ),

  // Positioned.fill(
  // top: 100,
  // child: BlocConsumer<GameBloc, GameState>(
  // listener: (context, state) async {
  //
  // if (state.isCompleted && !_winDialogShown) {
  // _winDialogShown = true;
  // _confettiController.play();
  //
  // await _dialogBox(state.moves, state.level);
  //
  // // Reset the flag so it can trigger again on next level
  // if (mounted) {
  // _winDialogShown = false;
  // }
  // }
  // // GAME OVER DIALOG
  // else if (state.seconds == 0 && !_gameOverDialogShown) {
  // _gameOverDialogShown = true;
  //
  // await _showGameOverDialog();
  //
  // // Reset the flag after dialog closes
  // if (mounted) {
  // _gameOverDialogShown = false;
  // }
  // }
  // },

  // game win and los dialog

  // game over dialog
  // Future<void> _showGameOverDialog() async {
  //   final bloc = context.read<GameBloc>();
  //   final state = bloc.state;
  //   final maxLevel = bloc.maxLevelsPerMode[state.levelType] ?? 1;
  //   final isLastLevel = state.level >= maxLevel;
  //
  //   await showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: AppColors.backgroundLight,
  //       title: Column(
  //         children: [
  //           Center(
  //             child: Text(
  //               '⏰ Time\'s Up!',
  //               style: GoogleFonts.fredoka(
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.w800,
  //                 color: AppColors.textRed,
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           Image.asset('assets/images/gameover.jpg', height: 80, width: 100),
  //         ],
  //       ),
  //       content: Text(
  //         'You ran out of time! What would you like to do?',
  //         textAlign: TextAlign.center,
  //         style: GoogleFonts.fredoka(fontSize: 16, color: AppColors.textWhite),
  //       ),
  //       actionsAlignment: MainAxisAlignment.spaceEvenly,
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Close',
  //             style: GoogleFonts.fredoka(
  //               fontWeight: FontWeight.w800,
  //               fontSize: 14,
  //               color: AppColors.textRed,
  //             ),
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             final bloc = context.read<GameBloc>();
  //             final state = bloc.state;
  //             final maxLevel = bloc.maxLevelsPerMode[state.levelType] ?? 1;
  //             final isLastLevel = state.level >= maxLevel;
  //
  //             // Close the dialog first
  //             Navigator.pop(context);
  //
  //             if (!mounted) return;
  //
  //             // Hide grid for smooth transition
  //             setState(() => _gridVisible = false);
  //
  //             await Future.delayed(const Duration(milliseconds: 500));
  //             if (!mounted) return;
  //
  //             // Reset flags
  //             _gameOverDialogShown = false;
  //             _winDialogShown = false;
  //
  //             if (!isLastLevel) {
  //               // Clear flipped indices
  //               bloc.resetFlippedIndices();
  //
  //               // Restart current level properly
  //               bloc.add(
  //                 ResetGame(
  //                   gridSize: bloc.getGridSizeForLevel(state.level),
  //                   levelType: bloc.getLevelTypeForLevel(state.level),
  //                   level: state.level,
  //                 ),
  //               );
  //
  //               // Show grid again after state emits
  //               WidgetsBinding.instance.addPostFrameCallback((_) {
  //                 if (mounted) setState(() => _gridVisible = true);
  //               });
  //             } else {
  //               // If last level, navigate to LevelSelection
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(builder: (_) => LevelSelection()),
  //               );
  //             }
  //           },
  //           child: Text(
  //             isLastLevel ? 'Go to Levels' : 'Restart',
  //             style: GoogleFonts.fredoka(
  //               fontWeight: FontWeight.w800,
  //               fontSize: 14,
  //               color: isLastLevel ? AppColors.textRed : AppColors.textGreen,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // wining and moving on to the next round
  // Future _dialogBox(int moves, int level) async {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: AppColors.backgroundLight,
  //       title: Align(alignment: Alignment.center, child: Text()),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           if (isLastLevel)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 16.0),
  //               child: Image.asset(
  //                 'assets/images/sad_face.png',
  //                 width: 100,
  //                 height: 100,
  //               ),
  //             ),
  //         ],
  //       ),
  //       actions: [
  //         if (!isLastLevel)
  //           TextButton(
  //             onPressed: () async {
  //               final bloc = context.read<GameBloc>();
  //               final state = bloc.state;
  //
  //               // Hide grid for transition
  //               setState(() => _gridVisible = false);
  //               await Future.delayed(const Duration(milliseconds: 500));
  //               if (!mounted) return;
  //
  //               // Reset dialog flag
  //               _winDialogShown = false;
  //
  //               // Clear flipped indices
  //               bloc.resetFlippedIndices();
  //
  //               // Navigate to next level
  //               final nextLevel = state.level + 1;
  //               WidgetsBinding.instance.addPostFrameCallback((_) {
  //                 Navigator.pushReplacement(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (_) => GameScreen(
  //                       level: nextLevel,
  //                       gridSize: bloc.getGridSizeForLevel(level),
  //                       levelType: bloc.getLevelTypeForLevel(level),
  //                     ),
  //                   ),
  //                 );
  //               });
  //             },
  //             child: Text(
  //               'Next',
  //               style: GoogleFonts.fredoka(
  //                 fontWeight: FontWeight.w800,
  //                 fontSize: 14,
  //                 color: AppColors.textOrange,
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }
}
