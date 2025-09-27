// import 'dart:async';
// import 'dart:math';
//
// import 'package:confetti/confetti.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:memoflip/level_selection/level_selection.dart';
//
// import '../../reuse/sound/sound.dart';
// import '../../theme/myColor.dart';
// import '../game_bloc.dart';
// import '../game_event.dart';
// import '../game_state.dart';
//
// class GameScreen extends StatefulWidget {
//   final int level;
//   final int gridSize;
//   final String levelType;
//
//   const GameScreen({
//     super.key,
//     this.level = 1,
//     this.gridSize = 4,
//     this.levelType = 'numbers',
//   });
//
//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
//   final SoundService _soundService = SoundService();
//   late final ConfettiController _confettiController;
//   late final AnimationController _shuffleController;
//   late final GameBloc _gameBloc;
//
//   bool _gridVisible = true;
//   bool _gameOverDialogShown = false;
//   bool _winDialogShown = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(
//       duration: const Duration(seconds: 1),
//     );
//     _shuffleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//
//     _gameBloc = GameBloc();
//     _gameBloc.add(
//       InitializeGame(
//         levelType: widget.levelType,
//         level: widget.level,
//         gridSize: widget.gridSize,
//       ),
//     );
//
//     _shuffleController.forward(from: 0);
//   }
//
//   @override
//   void dispose() {
//     _confettiController.dispose();
//     _shuffleController.dispose();
//     _gameBloc.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _gameBloc,
//       child: Scaffold(
//         extendBody: true,
//         extendBodyBehindAppBar: true,
//         drawer: _drawer(),
//         body: Stack(
//           children: [
//             SizedBox.expand(
//               child: Image.asset(
//                 _getBackgroundForLevel(widget.level),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             SafeArea(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Builder(
//                     builder: (context) => IconButton(
//                       icon: Icon(Icons.menu, color: AppColors.iconWhite),
//                       onPressed: () => Scaffold.of(context).openDrawer(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirectionality: BlastDirectionality.explosive,
//               shouldLoop: false,
//               colors: const [
//                 Colors.orange,
//                 Colors.yellow,
//                 Colors.green,
//                 Colors.blue,
//               ],
//               emissionFrequency: 0.05,
//               numberOfParticles: 20,
//             ),
//             Positioned.fill(
//               top: 100,
//               child: BlocConsumer<GameBloc, GameState>(
//                 listener: (context, state) async {},
//                 builder: (context, state) {
//                   return Column(
//                     children: [
//                       _buildInfoBar(state),
//                       const SizedBox(height: 16),
//                       // todo When pressed I want to retry playing again on the same round same level.
//                       IconButton(
//                         icon: const Icon(Icons.refresh, color: Colors.white),
//                         onPressed: () {
//                           //   When pressed I want to retry playing again on the same round same level.
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       Expanded(
//                         child: AnimatedOpacity(
//                           opacity: _gridVisible ? 1 : 0,
//                           duration: const Duration(milliseconds: 500),
//                           child: GridView.builder(
//                             padding: const EdgeInsets.all(16),
//                             gridDelegate:
//                                 SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: widget.gridSize,
//                                   crossAxisSpacing: 8,
//                                   mainAxisSpacing: 8,
//                                 ),
//                             itemCount: state.flipped.length,
//                             itemBuilder: (context, index) {
//                               final isFlipped = state.flipped[index];
//                               final isMatched = state.matched[index];
//                               final cardValue = state.cards[index];
//
//                               return GestureDetector(
//                                 onTap: () {
//                                   if (!isFlipped && !isMatched) {
//                                     context.read<GameBloc>().add(
//                                       FlipCard(index),
//                                     );
//                                   }
//                                 },
//                                 child: AnimatedSwitcher(
//                                   duration: const Duration(milliseconds: 400),
//                                   transitionBuilder: (child, animation) {
//                                     final rotate = Tween(
//                                       begin: pi,
//                                       end: 0.0,
//                                     ).animate(animation);
//                                     return AnimatedBuilder(
//                                       animation: rotate,
//                                       child: child,
//                                       builder: (context, child) {
//                                         final tilt = rotate.value > pi / 2
//                                             ? pi - rotate.value
//                                             : rotate.value;
//                                         return Transform(
//                                           transform: Matrix4.rotationY(tilt),
//                                           alignment: Alignment.center,
//                                           child: child,
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: isFlipped || isMatched
//                                       ? _buildCardFront(cardValue, index)
//                                       : _buildCardBack(index),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoBar(GameState state) {
//     final minutes = state.seconds ~/ 60;
//     final seconds = state.seconds % 60;
//     final timeText =
//         '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Level ${state.level} | Round ${state.currentRound}/${state.roundsPerLevel}',
//             style: GoogleFonts.fredoka(
//               fontSize: 16,
//               color: AppColors.textWhite,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 'Moves: ${state.moves}',
//                 style: GoogleFonts.fredoka(
//                   fontSize: 16,
//                   color: AppColors.textWhite,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 'Time: $timeText',
//                 style: GoogleFonts.fredoka(
//                   fontSize: 16,
//                   color: AppColors.textWhite,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCardFront(String value, int index) {
//     Widget content;
//     if (value.startsWith('num_')) {
//       content = Text(
//         value.replaceAll('num_', ''),
//         style: GoogleFonts.fredoka(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textOrange,
//         ),
//       );
//     } else if (value.startsWith('icon_')) {
//       content = Image.asset(
//         'assets/images/game/$value.jpg',
//         fit: BoxFit.contain,
//       );
//       // content = Icon(
//       //   _mapStringToIcon(value),
//       //   color: AppColors.textGreen,
//       //   size: 28,
//       // );
//     } else if (value.startsWith('img_')) {
//       content = Image.asset(
//         'assets/images/game/$value.jpg',
//         fit: BoxFit.contain,
//       );
//     } else {
//       content = const SizedBox.shrink();
//     }
//
//     return Container(
//       key: ValueKey('front$index'),
//       decoration: BoxDecoration(
//         color: AppColors.btnWhite,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(child: content),
//     );
//   }
//
//   Widget _buildCardBack(int index) => Container(
//     key: ValueKey('back$index'),
//     decoration: BoxDecoration(
//       color: AppColors.primary,
//       borderRadius: BorderRadius.circular(8),
//     ),
//   );
//
//   // change background based on level ease, medium and hard selection
//   String _getBackgroundForLevel(int level) {
//     final backgrounds = [
//       'assets/images/background1.jpg',
//       'assets/images/background2.jpg',
//       'assets/images/background3.jpg',
//     ];
//     return backgrounds[(level - 1) % backgrounds.length];
//   }
//
//   // drawer
//   Widget _drawer() {
//     return Drawer(
//       backgroundColor: AppColors.backgroundLight,
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           SizedBox(
//             height: 150,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Image.asset('assets/images/menu.webp', fit: BoxFit.cover),
//                 Container(color: Colors.black38),
//                 DrawerHeader(
//                   decoration: const BoxDecoration(color: Colors.transparent),
//                   margin: EdgeInsets.zero,
//                   padding: const EdgeInsets.all(16),
//                   child: Align(
//                     alignment: Alignment.bottomLeft,
//                     child: Text(
//                       'Menu',
//                       style: GoogleFonts.fredoka(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textWhite,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.grid_view, color: AppColors.textOrange),
//             title: Text(
//               'Level Selection',
//               style: GoogleFonts.fredoka(color: AppColors.textOrange),
//             ),
//             onTap: () => Navigator.pushNamed(context, '/level_selection'),
//           ),
//           Divider(height: 2, color: AppColors.dividerOrange),
//           ListTile(
//             leading: Icon(
//               _soundService.isPlaying ? Icons.volume_up : Icons.volume_off,
//               color: AppColors.iconOrange,
//             ),
//             title: Text(
//               _soundService.isPlaying ? 'Sound ON' : 'Sound OFF',
//               style: GoogleFonts.fredoka(color: AppColors.textOrange),
//             ),
//             onTap: () => setState(() => _soundService.toggleSound()),
//           ),
//           Divider(height: 2, color: AppColors.dividerOrange),
//           ListTile(
//             leading: const Icon(Icons.restart_alt, color: AppColors.iconOrange),
//             title: Text(
//               "Reset Game",
//               style: GoogleFonts.fredoka(color: AppColors.textOrange),
//             ),
//             onTap: () {
//               final bloc = context.read<GameBloc>();
//               final state = bloc.state;
//
//               // Reset UI flags
//               setState(() {
//                 _gameOverDialogShown = false;
//                 _winDialogShown = false;
//                 _gridVisible = true; // make grid visible immediately
//               });
//
//               // Clear flipped indices
//               bloc.resetFlippedIndices();
//
//               // Restart the current level
//               bloc.add(
//                 ResetGame(
//                   gridSize: bloc.getGridSizeForLevel(state.level),
//                   levelType: bloc.getLevelTypeForLevel(state.level),
//                   level: state.level,
//                 ),
//               );
//
//               // Close the drawer
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // game over dialog
//   Future<void> _showGameOverDialog() async {
//     final bloc = context.read<GameBloc>();
//     final state = bloc.state;
//     final maxLevel = bloc.maxLevelsPerMode[state.levelType] ?? 1;
//     final isLastLevel = state.level >= maxLevel;
//
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.backgroundLight,
//         title: Column(
//           children: [
//             Center(
//               child: Text(
//                 '⏰ Time\'s Up!',
//                 style: GoogleFonts.fredoka(
//                   fontSize: 28,
//                   fontWeight: FontWeight.w800,
//                   color: AppColors.textRed,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Image.asset('assets/images/gameover.jpg', height: 80, width: 100),
//           ],
//         ),
//         content: Text(
//           'You ran out of time! What would you like to do?',
//           textAlign: TextAlign.center,
//           style: GoogleFonts.fredoka(fontSize: 16, color: AppColors.textWhite),
//         ),
//         actionsAlignment: MainAxisAlignment.spaceEvenly,
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Close',
//               style: GoogleFonts.fredoka(
//                 fontWeight: FontWeight.w800,
//                 fontSize: 14,
//                 color: AppColors.textRed,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               final bloc = context.read<GameBloc>();
//               final state = bloc.state;
//               final maxLevel = bloc.maxLevelsPerMode[state.levelType] ?? 1;
//               final isLastLevel = state.level >= maxLevel;
//
//               // Close the dialog first
//               Navigator.pop(context);
//
//               if (!mounted) return;
//
//               // Hide grid for smooth transition
//               setState(() => _gridVisible = false);
//
//               await Future.delayed(const Duration(milliseconds: 500));
//               if (!mounted) return;
//
//               // Reset flags
//               _gameOverDialogShown = false;
//               _winDialogShown = false;
//
//               if (!isLastLevel) {
//                 // Clear flipped indices
//                 bloc.resetFlippedIndices();
//
//                 // Restart current level properly
//                 bloc.add(
//                   ResetGame(
//                     gridSize: bloc.getGridSizeForLevel(state.level),
//                     levelType: bloc.getLevelTypeForLevel(state.level),
//                     level: state.level,
//                   ),
//                 );
//
//                 // Show grid again after state emits
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   if (mounted) setState(() => _gridVisible = true);
//                 });
//               } else {
//                 // If last level, navigate to LevelSelection
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => LevelSelection()),
//                 );
//               }
//             },
//             child: Text(
//               isLastLevel ? 'Go to Levels' : 'Restart',
//               style: GoogleFonts.fredoka(
//                 fontWeight: FontWeight.w800,
//                 fontSize: 14,
//                 color: isLastLevel ? AppColors.textRed : AppColors.textGreen,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // wining and moving on to the next round
//   Future _dialogBox(int moves, int level) async {
//     final bloc = context.read<GameBloc>();
//     final state = bloc.state;
//     final isLastLevel = state.allLevelsCompleted;
//
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.backgroundLight,
//         title: Align(
//           alignment: Alignment.center,
//           child: Text(
//             isLastLevel ? '🏆 All Levels Completed!' : '🎉 You Win! 🎉',
//             style: GoogleFonts.fredoka(
//               fontSize: 32,
//               fontWeight: FontWeight.w800,
//               color: isLastLevel ? AppColors.textGreen : AppColors.glowYellow,
//             ),
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Moves: $moves',
//               style: GoogleFonts.fredoka(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w800,
//                 color: AppColors.textOrange,
//               ),
//             ),
//             Text(
//               'Time: ${state.seconds} s',
//               style: GoogleFonts.fredoka(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w800,
//                 color: AppColors.textOrange,
//               ),
//             ),
//             if (isLastLevel)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0),
//                 child: Image.asset(
//                   'assets/images/sad_face.png',
//                   width: 100,
//                   height: 100,
//                 ),
//               ),
//           ],
//         ),
//         actions: [
//           if (!isLastLevel)
//             TextButton(
//               onPressed: () async {
//                 final bloc = context.read<GameBloc>();
//                 final state = bloc.state;
//
//                 // Hide grid for transition
//                 setState(() => _gridVisible = false);
//                 await Future.delayed(const Duration(milliseconds: 500));
//                 if (!mounted) return;
//
//                 // Reset dialog flag
//                 _winDialogShown = false;
//
//                 // Clear flipped indices
//                 bloc.resetFlippedIndices();
//
//                 // Navigate to next level
//                 final nextLevel = state.level + 1;
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => GameScreen(
//                         level: nextLevel,
//                         gridSize: bloc.getGridSizeForLevel(level),
//                         levelType: bloc.getLevelTypeForLevel(level),
//                       ),
//                     ),
//                   );
//                 });
//               },
//               child: Text(
//                 'Next',
//                 style: GoogleFonts.fredoka(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 14,
//                   color: AppColors.textOrange,
//                 ),
//               ),
//             ),
//
//           // REPLAY BUTTON
//           TextButton(
//             onPressed: () async {
//               final bloc = context.read<GameBloc>();
//               final state = bloc.state;
//
//               // Hide grid for smooth exit
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
//               // Restart current level
//               bloc.add(
//                 ResetGame(
//                   gridSize: bloc.getGridSizeForLevel(state.level),
//                   levelType: bloc.getLevelTypeForLevel(state.level),
//                   level: state.level,
//                 ),
//               );
//
//               // Close dialog
//               Navigator.pop(context);
//
//               // Wait a frame for the new state to emit, then show the grid
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (mounted) {
//                   setState(() => _gridVisible = true);
//                 }
//               });
//             },
//             child: Text(
//               isLastLevel ? 'Go to Levels' : 'Replay',
//               style: GoogleFonts.fredoka(
//                 fontWeight: FontWeight.w800,
//                 fontSize: 14,
//                 color: isLastLevel ? AppColors.textRed : AppColors.textGreen,
//               ),
//             ),
//           ),
//
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.fredoka(
//                 fontWeight: FontWeight.w800,
//                 fontSize: 14,
//                 color: AppColors.textWhite,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//Future<void> _onCompleteRound(
//     CompleteRound event,
//     Emitter<GameState> emit,
//   ) async {
//     stopTimer();
//
//     int nextRound = state.currentRound + 1;
//     int nextLevel = state.level;
//
//     bool completed = false;
//     bool allDone = false;
//
//     if (nextRound > roundsPerLevel) {
//       nextRound = 1;
//       nextLevel++;
//       if (nextLevel > (maxLevelsPerMode[state.levelType] ?? 1)) {
//         completed = true;
//         allDone = true;
//       }
//     }
//
//     final newState = state.copyWith(
//       currentRound: nextRound,
//       level: nextLevel,
//       isCompleted: completed,
//       allLevelsCompleted: allDone,
//     );
//
//     emit(newState);
//     _saveProgress(newState);
//
//     if (!completed) {
//       add(
//         InitializeGame(
//           level: nextLevel,
//           gridSize: getGridSizeForLevel(nextLevel),
//           levelType: getLevelTypeForLevel(nextLevel),
//         ),
//       );
//     }
//   }

// on<CompleteRound>(_onCompleteRound);

// // Level completed animation/dialog
// if (state.isCompleted && !state.allLevelsCompleted) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       backgroundColor: AppColors.primary,
//       content: Text(
//         "Level ${state.level - 1} Completed!",
//         style: GoogleFonts.fredoka(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textBlack,
//         ),
//       ),
//       duration: const Duration(seconds: 1),
//     ),
//   );
// }
