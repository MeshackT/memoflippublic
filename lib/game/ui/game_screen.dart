import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoflip/game/ui/points_earned.dart';
import 'package:memoflip/level_selection/level_selection.dart';

import '../../home/drawer.dart';
import '../../reuse/combined_background_effect.dart';
import '../../reuse/reuse.dart';
import '../../reuse/sound/sound.dart';
import '../../theme/myColor.dart';
import '../game_bloc.dart';
import '../game_event.dart';
import '../game_state.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final int gridSize;
  final String levelType;

  const GameScreen({
    super.key,
    this.level = 1,
    this.gridSize = 4,
    this.levelType = 'numbers',
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final SoundService _soundService = SoundService();
  late final ConfettiController _confettiController;
  late final AnimationController _shuffleController;
  late final GameBloc _gameBloc;

  bool _gridVisible = true;
  bool _gameOverDialogShown = false;
  bool _winDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _gameBloc = GameBloc();
    _initializeGame(widget.level, widget.gridSize, widget.levelType);

    _shuffleController.forward(from: 0);
  }

  void _initializeGame(int level, int gridSize, String levelType) {
    _gameBloc.add(
      InitializeGame(level: level, gridSize: gridSize, levelType: levelType),
    );
  }

  void _pauseGame() => _gameBloc.add(PauseTimer());
  void _resumeGame() => _gameBloc.add(ResumeTimer());

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    _shuffleController.dispose();
    _pauseGame();
    _gameBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      _resumeGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameBloc,
      child: SafeArea(
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          drawer: AnimatedDrawer(
            gameBloc: _gameBloc,
            gridSize: widget.gridSize.toDouble(),
            levelType: widget.levelType,
          ),

          onDrawerChanged: (isOpen) {
            if (isOpen) {
              _pauseGame();
            } else {
              _resumeGame();
            }
          },
          body:
              // Stack(
              //   children: [
              //     // Background Image
              //     SizedBox.expand(
              //       child: Image.asset(
              //         _getBackgroundForLevel(widget.levelType, widget.gridSize),
              //         fit: BoxFit.cover,
              //       ),
              //     ),
              //
              //     // Background effect
              //     BackgroundEffect(gridSize: widget.gridSize),
              //
              //     // Main Game Content
              //     BlocConsumer<GameBloc, GameState>(
              //       listener: (context, state) async {
              //         if (_gameOverDialogShown || _winDialogShown) return;
              //         if (state.isGameOver && state.seconds == 0) {
              //           _gameOverDialogShown = true;
              //           await _showGameOverDialog(context, state);
              //         } else if (state.allLevelsCompleted) {
              //           _winDialogShown = true;
              //           _confettiController.play();
              //           await _showWinDialog(context);
              //         }
              //       },
              //       builder: (context, state) {
              //         return Column(
              //           children: [
              //             _buildInfoBar(),
              //             const SizedBox(height: 5),
              //             Wrap(
              //               crossAxisAlignment: WrapCrossAlignment.start,
              //               children: [
              //                 _buildLevelProgressBar(state),
              //                 const SizedBox(height: 5),
              //                 PointsProgress(
              //                   currentPoints: state.totalPoints,
              //                   pointsPerRound: 10,
              //                 ),
              //                 // _buildRoundControls(context, state),
              //               ],
              //             ),
              //             const SizedBox(height: 10),
              //
              //             // Grid fills remaining space
              //             Flexible(
              //               child: GridView.builder(
              //                 padding: const EdgeInsets.all(16),
              //                 gridDelegate:
              //                     SliverGridDelegateWithFixedCrossAxisCount(
              //                       crossAxisCount: state.gridSize,
              //                       crossAxisSpacing: 8,
              //                       mainAxisSpacing: 8,
              //                     ),
              //                 itemCount: state.cards.length,
              //                 itemBuilder: (context, index) {
              //                   final isFlipped = state.flipped[index];
              //                   final isMatched = state.matched[index];
              //                   final cardValue = state.cards[index];
              //
              //                   return GestureDetector(
              //                     onTap: () {
              //                       if (!isFlipped && !isMatched) {
              //                         _soundService.playTap('tap.wav');
              //                         context.read<GameBloc>().add(FlipCard(index));
              //                       }
              //                     },
              //                     child: AnimatedSwitcher(
              //                       duration: const Duration(milliseconds: 400),
              //                       transitionBuilder: (child, animation) {
              //                         final rotate = Tween(
              //                           begin: pi,
              //                           end: 0.0,
              //                         ).animate(animation);
              //                         return AnimatedBuilder(
              //                           animation: rotate,
              //                           child: child,
              //                           builder: (context, child) {
              //                             final tilt = rotate.value > pi / 2
              //                                 ? pi - rotate.value
              //                                 : rotate.value;
              //                             return Transform(
              //                               transform: Matrix4.rotationY(tilt),
              //                               alignment: Alignment.center,
              //                               child: child,
              //                             );
              //                           },
              //                         );
              //                       },
              //                       child: isFlipped || isMatched
              //                           ? _buildCardFront(cardValue, index)
              //                           : _buildCardBack(index),
              //                     ),
              //                   );
              //                 },
              //               ),
              //             ),
              //           ],
              //         );
              //       },
              //     ),
              //
              //     // BlocConsumer<GameBloc, GameState>(
              //     //   listener: (context, state) async {
              //     //     logger.i(
              //     //       "GridSize: ${state.gridSize}, Cards: ${state.cards.length}",
              //     //     );
              //     //     print(
              //     //       "Grid visible? $_gridVisible, gridSize: ${state.gridSize}, cards: ${state.cards.length}",
              //     //     );
              //     //   },
              //     //   builder: (context, state) {
              //     //     return GridView.builder(
              //     //       padding: const EdgeInsets.all(16),
              //     //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //     //         crossAxisCount: state.gridSize,
              //     //         crossAxisSpacing: 8,
              //     //         mainAxisSpacing: 8,
              //     //       ),
              //     //       itemCount: state.cards.length,
              //     //       itemBuilder: (context, index) {
              //     //         return Container(
              //     //           color: Colors.blue,
              //     //           margin: const EdgeInsets.all(4),
              //     //         );
              //     //       },
              //     //     );
              //     //   },
              //     // ),
              //   ],
              // ),
              Stack(
                children: [
                  // -------------------------
                  // Background Image
                  // -------------------------
                  SizedBox.expand(
                    child: Image.asset(
                      _getBackgroundForLevel(widget.levelType, widget.gridSize),
                      fit: BoxFit.cover,
                    ),
                  ),

                  // -------------------------
                  // Background effect
                  // -------------------------
                  BackgroundEffect(gridSize: widget.gridSize),

                  // -------------------------
                  // Main Game Content
                  // -------------------------
                  SafeArea(
                    child: BlocConsumer<GameBloc, GameState>(
                      listener: (context, state) async {
                        // Avoid showing multiple dialogs
                        if (_gameOverDialogShown || _winDialogShown) return;

                        // Game over (time ran out)
                        if (state.isGameOver && state.seconds == 0) {
                          _gameOverDialogShown = true;
                          await _showGameOverDialog(context, state);
                          return;
                        }

                        // All levels completed → show win dialog
                        if (state.allLevelsCompleted) {
                          _winDialogShown = true; // Only set for final game win
                          _confettiController.play();
                          await _showWinDialog(context);
                          return;
                        }

                        // Current level completed → show level complete dialog
                        // Only if there are more levels to play
                        final maxLevel =
                            _gameBloc.maxLevelsPerMode[state.levelType] ?? 1;
                        final lastRound =
                            state.currentRound >= state.roundsPerLevel;

                        if (state.levelCompleted &&
                            state.level < maxLevel &&
                            lastRound) {
                          _confettiController.play();
                          await _showLevelComplete(context);
                          return;
                        }
                      },

                      builder: (context, state) {
                        return Column(
                          children: [
                            // /// -------------------------
                            // /// drawer button
                            // /// -------------------------
                            // AnimatedDrawer(
                            //   gameBloc: _gameBloc,
                            //   gridSize: widget.gridSize.toDouble(),
                            //   levelType: widget.levelType,
                            // ),
                            const SizedBox(height: 16),

                            // -------------------------
                            // Top info bar
                            // -------------------------
                            _buildInfoBar(),
                            const SizedBox(height: 5),

                            // -------------------------
                            // Level progress + points
                            // -------------------------
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                _buildLevelProgressBar(state),
                                const SizedBox(height: 5),
                                PointsProgress(
                                  currentPoints: state.totalPoints,
                                  pointsPerRound: 10,
                                ),
                                _buildRoundControls(context, state),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // -------------------------
                            // GridView fills remaining space
                            // -------------------------
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: state.gridSize,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemCount: state.cards.length,
                                itemBuilder: (context, index) {
                                  final isFlipped = state.flipped[index];
                                  final isMatched = state.matched[index];
                                  final cardValue = state.cards[index];

                                  return GestureDetector(
                                    onTap: () {
                                      if (!isFlipped && !isMatched) {
                                        _soundService.playTap('tap.wav');
                                        context.read<GameBloc>().add(
                                          FlipCard(index),
                                        );
                                      }
                                    },
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        final rotate = Tween(
                                          begin: pi,
                                          end: 0.0,
                                        ).animate(animation);
                                        return AnimatedBuilder(
                                          animation: rotate,
                                          child: child,
                                          builder: (context, child) {
                                            final tilt = rotate.value > pi / 2
                                                ? pi - rotate.value
                                                : rotate.value;
                                            return Transform(
                                              transform: Matrix4.rotationY(
                                                tilt,
                                              ),
                                              alignment: Alignment.center,
                                              child: child,
                                            );
                                          },
                                        );
                                      },
                                      child: isFlipped || isMatched
                                          ? _buildCardFront(cardValue, index)
                                          : _buildCardBack(index),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // button drawer
                            // button drawer
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 20,
                              ), // <-- 20px bottom margin
                              child: Align(
                                alignment:
                                    Alignment.bottomLeft, // <-- flush left
                                child: GestureDetector(
                                  onTap: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  child: Container(
                                    width: 35,
                                    height: 70, // adjust as needed
                                    decoration: BoxDecoration(
                                      color: AppColors.iconOrange,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(100),
                                        bottomRight: Radius.circular(100),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColors.iconWhite,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
    // -------------------
    // BlocConsumer listener
    // -------------------
    // BlocConsumer<GameBloc, GameState>(
    //   listener: (context, state) async {
    //     // Game Over Dialog
    //     if (state.isGameOver && state.seconds == 0 && !_gameOverDialogShown) {
    //       _gameOverDialogShown = true;
    //       await _showGameOverDialog(context, state);
    //     }
    //
    //     // Level Completed
    //     if (state.isCompleted && !state.allLevelsCompleted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text("Level ${state.level - 1} Completed!"),
    //           duration: const Duration(seconds: 1),
    //         ),
    //       );
    //     }
    //
    //     // Win Dialog
    //     if (state.allLevelsCompleted && !_winDialogShown) {
    //       _winDialogShown = true;
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         _confettiController.play();
    //         _showWinDialog(context);
    //       });
    //     }
    //   },
    //   builder: (context, state) {
    //     return Column(
    //       children: [
    //         _buildInfoBar(),
    //         const SizedBox(height: 5),
    //         Wrap(
    //           crossAxisAlignment: WrapCrossAlignment.start,
    //           children: [
    //             _buildLevelProgressBar(state),
    //             const SizedBox(height: 5),
    //             PointsProgress(
    //               currentPoints: state.totalPoints,
    //               pointsPerRound: 10,
    //             ),
    //             _buildRoundControls(context, state),
    //           ],
    //         ),
    //         const SizedBox(height: 5),
    //         Expanded(
    //           child: AnimatedOpacity(
    //             opacity: _gridVisible ? 1 : 0,
    //             duration: const Duration(milliseconds: 500),
    //             child: GridView.builder(
    //               padding: const EdgeInsets.all(16),
    //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //                 crossAxisCount: widget.gridSize,
    //                 crossAxisSpacing: 8,
    //                 mainAxisSpacing: 8,
    //               ),
    //               itemCount: state.flipped.length,
    //               itemBuilder: (context, index) {
    //                 final isFlipped = state.flipped[index];
    //                 final isMatched = state.matched[index];
    //                 final cardValue = state.cards[index];
    //
    //                 return GestureDetector(
    //                   onTap: () {
    //                     if (!isFlipped && !isMatched) {
    //                       _soundService.playTap('tap.wav');
    //                       context.read<GameBloc>().add(FlipCard(index));
    //                     }
    //                   },
    //                   child: AnimatedSwitcher(
    //                     duration: const Duration(milliseconds: 400),
    //                     transitionBuilder: (child, animation) {
    //                       final rotate = Tween(
    //                         begin: pi,
    //                         end: 0.0,
    //                       ).animate(animation);
    //                       return AnimatedBuilder(
    //                         animation: rotate,
    //                         child: child,
    //                         builder: (context, child) {
    //                           final tilt = rotate.value > pi / 2
    //                               ? pi - rotate.value
    //                               : rotate.value;
    //                           return Transform(
    //                             transform: Matrix4.rotationY(tilt),
    //                             alignment: Alignment.center,
    //                             child: child,
    //                           );
    //                         },
    //                       );
    //                     },
    //                     child: isFlipped || isMatched
    //                         ? _buildCardFront(cardValue, index)
    //                         : _buildCardBack(index),
    //                   ),
    //                 );
    //               },
    //             ),
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  /// -------------------------
  /// Show dialog lose
  /// -------------------------
  Future<void> _showGameOverDialog(
    BuildContext context,
    GameState state,
  ) async {
    _soundService.playFail('fail.wav');

    final result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Time's Up",
      pageBuilder: (context, animation, secondaryAnimation) {
        // This is just a placeholder; the real content is in transitionBuilder
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: curvedAnimation,
            child: AlertDialog(
              backgroundColor: AppColors.backgroundLight,
              title: Column(
                children: [
                  Center(
                    child: Text(
                      '⏰ Time\'s Up!',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/images/gameover.jpg',
                    height: 80,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              content: Text(
                'You ran out of time! What would you like to do?',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: AppColors.textOrange,
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'selection'),
                      child: Text(
                        "Selection Screen",
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textOrange,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'retry'),
                      child: Text(
                        "Retry",
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                // Align(
                //   alignment: Alignment.center,
                //   child: TextButton(
                //     onPressed: () => Navigator.pop(context, 'video'),
                //     child: Text(
                //       "Watch a Video",
                //       style: GoogleFonts.fredoka(
                //         fontWeight: FontWeight.w800,
                //         fontSize: 14,
                //         color: AppColors.textOrange,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );

    final bloc = context.read<GameBloc>();

    switch (result) {
      case 'retry':
        bloc.add(
          RetryRound(
            levelType: widget.levelType,
            gridSize: widget.gridSize,
            level: widget.level,
            round: state.currentRound,
          ),
        );
        _gameOverDialogShown = false;
        break;

      case 'video':
        // TODO: Play video ad and then add extra time if watched completely
        // Example:
        // bloc.add(AddTime(duration: 60)); // add 1 minute
        break;

      case 'selection':
      default:
        await bloc.box?.delete(
          bloc.progressKey(
            widget.levelType,
            widget.gridSize,
            widget.level,
            state.currentRound,
          ),
        );
        navigateWithFadeReplacement(context, LevelSelection());
        break;
    }
  }

  /// ------------------------
  /// Show dialog winner
  /// ------------------------
  Future<void> _showWinDialog(BuildContext context) async {
    _soundService.playVictory('next_level.wav');

    await showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Win",
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink(); // placeholder
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: curvedAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AlertDialog(
                  backgroundColor: AppColors.backgroundLight,
                  title: Column(
                    children: [
                      Text(
                        '🎉 Congratulations!',
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/images/win.jpg',
                        height: 100,
                        width: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  content: Text(
                    'You completed all levels!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      color: AppColors.textOrange,
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.btnGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        navigateWithFadeReplacement(context, LevelSelection());
                      },
                      child: Text(
                        "Next Level",
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),

                /// Confetti overlay
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                  ],
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                ),
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _showLevelComplete(BuildContext context) async {
    _soundService.playVictory('next_level.wav');

    await showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Level Complete",
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: curvedAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AlertDialog(
                  backgroundColor: AppColors.backgroundLight,
                  title: Column(
                    children: [
                      Text(
                        '🎉 Yey!, let\'s go!',
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/images/win.jpg',
                        height: 100,
                        width: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  content: Text(
                    'You completed a level!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      color: AppColors.textOrange,
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.btnGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Continue",
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),

                /// Confetti overlay
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                  ],
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                ),
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  ///--------------------------
  /// Restart the game / reset
  /// -------------------------
  Future<String?> showFirstRoundDialog(BuildContext context) {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "FirstRound",
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink(); // placeholder, content is in transitionBuilder
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: curvedAnimation,
            child: AlertDialog(
              backgroundColor: AppColors.backgroundLight,
              title: Center(
                child: Text(
                  '⚠️ First Round',
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textRed,
                  ),
                ),
              ),
              content: Text(
                'You are already at the first round.\nWhat would you like to do?',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: AppColors.textOrange,
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, "select"),
                  child: Text(
                    "Go to Selection",
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, "restart"),
                  child: Text(
                    "Restart Level",
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  /// -------------------------
  /// Round Controls Helper
  /// -------------------------
  Widget _buildRoundControls(BuildContext context, GameState state) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 🔙 Previous button
            GlowingIconButton(
              icon: Icons.skip_previous,
              onPressed: () async {
                if (state.currentRound > 1) {
                  final prevRound = state.currentRound - 1;
                  final replay = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.backgroundLight,
                      title: Center(
                        child: Text(
                          '🔙 Previous Round',
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textOrange,
                          ),
                        ),
                      ),
                      content: Text(
                        'Do you want to replay the previous round?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          color: AppColors.textOrange,
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.btnGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text(
                            "No, Skip",
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.btnGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text(
                            "Yes, replay",
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (replay == true) {
                    context.read<GameBloc>().add(
                      RetryRound(
                        levelType: widget.levelType,
                        gridSize: widget.gridSize,
                        level: widget.level,
                        round: prevRound,
                      ),
                    );
                  } else {
                    context.read<GameBloc>().add(
                      NextRound(
                        levelType: widget.levelType,
                        gridSize: widget.gridSize,
                        level: widget.level,
                        currentRound: prevRound,
                      ),
                    );
                  }
                } else {
                  // Already at first round
                  final choice = await showDialog<String>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.backgroundLight,
                      title: Center(
                        child: Text(
                          '⚠️ First Round',
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textRed,
                          ),
                        ),
                      ),
                      content: Text(
                        'You are already at the first round.\nWhat would you like to do?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          color: AppColors.textOrange,
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.btnGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, "select");
                          },
                          child: Text(
                            "Selection",
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.btnGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, "restart");
                          },
                          child: Text(
                            "Retry Level",
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (choice == "restart") {
                    context.read<GameBloc>().add(
                      RetryRound(
                        levelType: widget.levelType,
                        gridSize: widget.gridSize,
                        level: widget.level,
                        round: state.currentRound,
                      ),
                    );
                  } else if (choice == "select") {
                    navigateWithFadeReplacement(context, LevelSelection());
                    // await Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const LevelSelection()),
                    //   (_) => false,
                    // );
                  }
                }
              },
            ),

            const SizedBox(width: 10),

            // 🔄 Retry button
            GlowingIconButton(
              icon: Icons.refresh,
              onPressed: () {
                context.read<GameBloc>().add(
                  RetryRound(
                    levelType: widget.levelType,
                    gridSize: widget.gridSize,
                    level: widget.level,
                    round: state.currentRound,
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            GlowingIconButton(
              icon: Icons.skip_next,
              onPressed: () {
                context.read<GameBloc>().add(
                  NextRound(
                    levelType: widget.levelType,
                    gridSize: widget.gridSize,
                    level: widget.level,
                    currentRound: state.currentRound,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------
/// Show information Time, moves, level  & rounds
/// ------------------------
Widget _buildInfoBar() {
  return BlocBuilder<GameBloc, GameState>(
    builder: (context, state) {
      final minutes = state.seconds ~/ 60;
      final seconds = state.seconds % 60;
      final timeText =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with timer and play/pause
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MemoFlip',
                  style: GoogleFonts.fredoka(
                    textStyle: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOrange,
                      letterSpacing: 2,
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

                ///----------------
                /// build time
                /// ---------------
                _buildPauseTime(state, context),
              ],
            ),

            const SizedBox(height: 8),

            // Level, round, and moves info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level ${state.level} | Round ${state.currentRound}/${state.roundsPerLevel}',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: AppColors.textOrange,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Moves: ${state.moves}',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: AppColors.textOrange,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

///---------------
/// pause and play
///---------------
Widget _buildPauseTime(GameState state, BuildContext context) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.6, end: 1.0),
    duration: const Duration(seconds: 1),
    curve: Curves.easeInOut,
    builder: (context, glowOpacity, child) {
      return Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          border: Border.all(color: AppColors.textOrange, width: 2),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: glowOpacity),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Timer
            Text(
              '${(state.seconds ~/ 60).toString().padLeft(2, '0')}:${(state.seconds % 60).toString().padLeft(2, '0')}',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            // const SizedBox(width: 10),
            // // Pause/Resume Icon
            // GestureDetector(
            //   onTap: () {
            //     if (state.isPaused) {
            //       context.read<GameBloc>().add(ResumeTimer());
            //     } else {
            //       context.read<GameBloc>().add(PauseTimer());
            //     }
            //   },
            //   child: Icon(
            //     state.isPaused ? Icons.play_arrow : Icons.pause,
            //     color: AppColors.iconWhite,
            //     size: 25,
            //   ),
            // ),
          ],
        ),
      );
    },
  );
}

Widget _buildLevelProgressBar(GameState state) {
  final int maxPoints =
      state.roundsPerLevel * 10; // or your pointsPerRound value
  final double progress = (state.totalPoints / maxPoints).clamp(0.0, 1.0);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.iconOrange, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.iconOrange.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: Colors.white24,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOrange),
        ),
      ),
    ),
  );
}

/// ------------------------
/// build cards front
/// ------------------------
Widget _buildCardFront(String value, int index) {
  Widget content;

  if (value.startsWith('num_')) {
    // Numbers → just render text
    final number = value.split('_').last;
    content = Text(
      number,
      style: GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textOrange,
      ),
    );
  } else if (value.startsWith('icon_')) {
    // Icons → use the matching image file
    final imageName = value.replaceFirst('icon_', '');
    content = Image.asset(
      'assets/images/game/icon_$imageName.jpg',
      fit: BoxFit.contain,
    );
  } else if (value.startsWith('img_')) {
    // Images → use the matching image file
    final imageName = value.replaceFirst('img_', '');
    content = Image.asset(
      'assets/images/game/img_$imageName.jpg',
      fit: BoxFit.contain,
    );
  } else {
    // fallback if nothing matches
    content = const Icon(Icons.help_outline, color: Colors.grey);
  }

  return Container(
    key: ValueKey('front$index'),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(child: content),
  );
}

/// ------------------------
/// Build cards back
/// ------------------------
Widget _buildCardBack(int index) => Container(
  key: ValueKey('back$index'),
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(8),
  ),
);

/// ------------------------
/// change background based on level ease, medium and hard selection
/// ------------------------
/// Map background images based on level type and grid size
String _getBackgroundForLevel(String levelType, int gridSize) {
  // Example mapping; adjust asset paths as needed
  final Map<String, Map<int, String>> backgrounds = {
    'numbers': {
      4: 'assets/images/background1.jpg', // Easy
      6: 'assets/images/background1.jpg', // Medium
      8: 'assets/images/background1.jpg', // Hard
    },
    'numbers_icons': {
      4: 'assets/images/background4.jpg',
      6: 'assets/images/background4.jpg',
      8: 'assets/images/background4.jpg',
    },
    'numbers_icons_images': {
      4: 'assets/images/background2.jpg',
      6: 'assets/images/background2.jpg',
      8: 'assets/images/background2.jpg',
    },
  };

  // Return the mapped background or a default
  return backgrounds[levelType]?[gridSize] ?? 'assets/images/background1.jpg';
}

/// -------------------
/// animation dialog
/// -------------------
Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool barrierDismissible,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54, // background fade
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Builder(builder: builder);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
