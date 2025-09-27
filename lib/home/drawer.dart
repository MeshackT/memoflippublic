// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../game/game_bloc.dart';
// import '../game/game_event.dart';
// import '../level_selection/level_selection.dart';
// import '../reuse/reuse.dart';
// import '../reuse/sound/sound.dart';
// import '../theme/myColor.dart';
//
// class AnimatedDrawer extends StatefulWidget {
//   final GameBloc gameBloc;
//   final double gridSize;
//   final String levelType;
//
//   const AnimatedDrawer({
//     super.key,
//     required this.gameBloc,
//     required this.gridSize,
//     required this.levelType,
//   });
//
//   @override
//   State<AnimatedDrawer> createState() => _AnimatedDrawerState();
// }
//
// class _AnimatedDrawerState extends State<AnimatedDrawer>
//     with TickerProviderStateMixin, WidgetsBindingObserver {
//   late AnimationController _controller;
//   late Animation<double> _opacity;
//   late Animation<Offset> _slide;
//
//   bool _gridVisible = true;
//   bool _gameOverDialogShown = false;
//   bool _winDialogShown = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _opacity = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     _slide = Tween<Offset>(
//       begin: const Offset(-0.2, 0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//   }
//
//   void _pauseGame() => widget.gameBloc.add(PauseTimer());
//   void _resumeGame() => widget.gameBloc.add(ResumeTimer());
//
//   void handleDrawerChange(bool isOpen) {
//     if (isOpen) {
//       _pauseGame();
//       _controller.forward();
//     } else {
//       _resumeGame();
//       _controller.reverse();
//     }
//   }
//
//   Widget _buildAnimatedTile({required Widget child, required int index}) {
//     final interval = 0.1 * index;
//     final animation = CurvedAnimation(
//       parent: _controller,
//       curve: Interval(interval, 1.0, curve: Curves.easeOut),
//     );
//
//     return FadeTransition(
//       opacity: animation,
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(-0.2, 0),
//           end: Offset.zero,
//         ).animate(animation),
//         child: child,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!mounted) return;
//
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       _pauseGame();
//     } else if (state == AppLifecycleState.resumed) {
//       _resumeGame();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final soundService = SoundService();
//     final _gameBloc = widget.gameBloc;
//
//     final drawerItems = <Widget>[
//       const SizedBox(height: 10),
//       Text(
//         "Level Selection",
//         textAlign: TextAlign.center,
//         style: GoogleFonts.fredoka(
//           fontSize: 16,
//           color: AppColors.textOrange,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       const SizedBox(height: 5),
//       ListTile(
//         leading: Icon(Icons.grid_view, color: AppColors.textOrange),
//         title: Text(
//           'Level Selection',
//           style: GoogleFonts.fredoka(color: AppColors.textOrange),
//         ),
//         onTap: () {
//           _gameBloc.add(PauseTimer());
//           setState(() {
//             _gameOverDialogShown = false;
//             _winDialogShown = false;
//             _gridVisible = true;
//           });
//           navigateWithFadeReplacement(context, LevelSelection());
//           _gameBloc.add(ResumeTimer());
//         },
//       ),
//       const SizedBox(height: 5),
//       Text(
//         "Sound settings",
//         textAlign: TextAlign.center,
//         style: GoogleFonts.fredoka(
//           fontSize: 16,
//           color: AppColors.textOrange,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       const SizedBox(height: 5),
//       Divider(height: 2, color: AppColors.dividerOrange),
//       SoundToggleTile(
//         title: 'Background Music',
//         activeIcon: Icons.music_note,
//         inactiveIcon: Icons.music_off,
//         notifier: soundService.bgEnabledNotifier,
//         onToggle: () async => await soundService.toggleBackground(),
//       ),
//       SoundToggleTile(
//         title: 'Tap Sound',
//         activeIcon: Icons.touch_app,
//         inactiveIcon: Icons.music_off,
//         notifier: soundService.tapEnabledNotifier,
//         onToggle: soundService.toggleTap,
//       ),
//       SoundToggleTile(
//         title: 'Victory Sound',
//         activeIcon: Icons.emoji_events,
//         inactiveIcon: Icons.music_off,
//         notifier: soundService.victoryEnabledNotifier,
//         onToggle: soundService.toggleVictory,
//       ),
//       SoundToggleTile(
//         title: 'Fail Sound',
//         activeIcon: Icons.error,
//         inactiveIcon: Icons.music_off,
//         notifier: soundService.failEnabledNotifier,
//         onToggle: soundService.toggleFail,
//       ),
//       Divider(height: 2, color: AppColors.dividerOrange),
//       const SizedBox(height: 5),
//       Text(
//         "Game reset",
//         textAlign: TextAlign.center,
//         style: GoogleFonts.fredoka(
//           fontSize: 16,
//           color: AppColors.textOrange,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       const SizedBox(height: 5),
//       ListTile(
//         leading: const Icon(Icons.restart_alt, color: AppColors.iconOrange),
//         title: Text(
//           "Reset Game",
//           style: GoogleFonts.fredoka(color: AppColors.textOrange),
//         ),
//         onTap: () async {
//           _gameBloc.add(PauseTimer());
//           final confirm = await showResetGameDialog(context);
//           if (confirm != true) return;
//
//           setState(() {
//             _gameOverDialogShown = false;
//             _winDialogShown = false;
//             _gridVisible = true;
//           });
//
//           _gameBloc.resetFlippedIndices();
//           final box = _gameBloc.box;
//           if (box != null) await box.clear();
//
//           _gameBloc.add(
//             ResetGame(
//               gridSize: widget.gridSize.toInt(),
//               levelType: widget.levelType,
//               level: 1,
//             ),
//           );
//
//           Navigator.pop(context); // close drawer
//           _gameBloc.add(ResumeTimer());
//         },
//       ),
//     ];
//
//     return Drawer(
//       // backgroundColor: Colors.transparent, // make drawer itself transparent
//       elevation: 5,
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               // Header with background image
//               SizedBox(
//                 height: 150,
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     Image.asset('assets/images/menu.webp', fit: BoxFit.cover),
//                     Container(color: Colors.black38),
//                     Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Align(
//                         alignment: Alignment.bottomLeft,
//                         child: Text(
//                           'Menu',
//                           style: GoogleFonts.fredoka(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textWhite,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Animate all drawer items
//               ...drawerItems
//                   .asMap()
//                   .entries
//                   .map((e) => _buildAnimatedTile(child: e.value, index: e.key))
//                   .toList(),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Future<bool?> showResetGameDialog(BuildContext context) {
//     return showGeneralDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       barrierLabel: "ResetGame",
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return const SizedBox.shrink();
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         final curvedAnimation = CurvedAnimation(
//           parent: animation,
//           curve: Curves.easeOutCubic,
//         );
//
//         return FadeTransition(
//           opacity: curvedAnimation,
//           child: ScaleTransition(
//             scale: curvedAnimation,
//             child: AlertDialog(
//               backgroundColor: AppColors.backgroundLight,
//               title: Center(
//                 child: Text(
//                   'Start New Game?',
//                   style: GoogleFonts.fredoka(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: AppColors.textRed,
//                   ),
//                 ),
//               ),
//               content: Text(
//                 'This will delete all saved progress and restart the game from level 1. Are you sure?',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.fredoka(
//                   fontSize: 16,
//                   color: AppColors.textOrange,
//                 ),
//               ),
//               actionsAlignment: MainAxisAlignment.center,
//               actions: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.btnOrange,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   onPressed: () => Navigator.pop(context, false),
//                   child: Text(
//                     "Cancel",
//                     style: GoogleFonts.fredoka(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                       color: AppColors.textWhite,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.btnOrange,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   onPressed: () => Navigator.pop(context, true),
//                   child: Text(
//                     "Restart",
//                     style: GoogleFonts.fredoka(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                       color: AppColors.textWhite,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//       transitionDuration: const Duration(milliseconds: 500),
//     );
//   }
// }

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/game_bloc.dart';
import '../game/game_event.dart';
import '../level_selection/level_selection.dart';
import '../reuse/reuse.dart';
import '../reuse/sound/sound.dart';
import '../theme/myColor.dart';

class AnimatedDrawer extends StatefulWidget {
  final GameBloc gameBloc;
  final double gridSize;
  final String levelType;

  const AnimatedDrawer({
    super.key,
    required this.gameBloc,
    required this.gridSize,
    required this.levelType,
  });

  @override
  State<AnimatedDrawer> createState() => _AnimatedDrawerState();
}

class _AnimatedDrawerState extends State<AnimatedDrawer>
    with WidgetsBindingObserver {
  bool _gridVisible = true;
  bool _gameOverDialogShown = false;
  bool _winDialogShown = false;
  SoundService soundService = SoundService();
  AudioPlayer? bgPlayer; // lazy initialization

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (bgPlayer == null) {
      return;
    } else {
      bgPlayer!.resume();
    }
  }

  void _pauseGame() => widget.gameBloc.add(PauseTimer());
  void _resumeGame() => widget.gameBloc.add(ResumeTimer());

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // soundService.toggleBackground();
      _pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      _resumeGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final soundService = SoundService();
    final _gameBloc = widget.gameBloc;

    final drawerItems = <Widget>[
      const SizedBox(height: 10),
      Text(
        "Level Selection",
        textAlign: TextAlign.center,
        style: GoogleFonts.fredoka(
          fontSize: 16,
          color: AppColors.textOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 5),
      ListTile(
        leading: Icon(Icons.grid_view, color: AppColors.textOrange),
        title: Text(
          'Level Selection',
          style: GoogleFonts.fredoka(color: AppColors.textOrange),
        ),
        onTap: () {
          _gameBloc.add(PauseTimer());
          setState(() {
            _gameOverDialogShown = false;
            _winDialogShown = false;
            _gridVisible = true;
          });
          navigateWithFadeReplacement(context, LevelSelection());
          _gameBloc.add(ResumeTimer());
        },
      ),
      const SizedBox(height: 10),
      Text(
        "Sound settings",
        textAlign: TextAlign.center,
        style: GoogleFonts.fredoka(
          fontSize: 16,
          color: AppColors.textOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 5),
      Divider(height: 2, color: AppColors.dividerOrange),
      SoundToggleTile(
        title: 'Background Music',
        activeIcon: Icons.music_note,
        inactiveIcon: Icons.music_off,
        notifier: soundService.bgEnabledNotifier,
        onToggle: () async => await soundService.toggleBackground(),
      ),
      SoundToggleTile(
        title: 'Tap Sound',
        activeIcon: Icons.touch_app,
        inactiveIcon: Icons.music_off,
        notifier: soundService.tapEnabledNotifier,
        onToggle: soundService.toggleTap,
      ),
      SoundToggleTile(
        title: 'Victory Sound',
        activeIcon: Icons.emoji_events,
        inactiveIcon: Icons.music_off,
        notifier: soundService.victoryEnabledNotifier,
        onToggle: soundService.toggleVictory,
      ),
      SoundToggleTile(
        title: 'Fail Sound',
        activeIcon: Icons.error,
        inactiveIcon: Icons.music_off,
        notifier: soundService.failEnabledNotifier,
        onToggle: soundService.toggleFail,
      ),
      Divider(height: 2, color: AppColors.dividerOrange),
      const SizedBox(height: 10),
      Text(
        "Game reset",
        textAlign: TextAlign.center,
        style: GoogleFonts.fredoka(
          fontSize: 16,
          color: AppColors.textOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 5),
      ListTile(
        leading: const Icon(Icons.restart_alt, color: AppColors.iconOrange),
        title: Text(
          "Reset Game",
          style: GoogleFonts.fredoka(color: AppColors.textOrange),
        ),
        onTap: () async {
          _gameBloc.add(PauseTimer());
          final confirm = await showResetGameDialog(context);
          if (confirm != true) return;

          setState(() {
            _gameOverDialogShown = false;
            _winDialogShown = false;
            _gridVisible = true;
          });

          _gameBloc.resetFlippedIndices();
          final box = _gameBloc.box;
          if (box != null) await box.clear();

          _gameBloc.add(
            ResetGame(
              gridSize: widget.gridSize.toInt(),
              levelType: widget.levelType,
              level: 1,
            ),
          );

          Navigator.pop(context); // close drawer
          _gameBloc.add(ResumeTimer());
        },
      ),
    ];

    return Drawer(
      backgroundColor: AppColors.backgroundLight,
      elevation: 5,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/menu.webp', fit: BoxFit.cover),
                Container(color: Colors.black38),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Menu',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Drawer items
          ...drawerItems,
        ],
      ),
    );
  }

  Future<bool?> showResetGameDialog(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "ResetGame",
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
            child: AlertDialog(
              backgroundColor: AppColors.backgroundLight,
              title: Center(
                child: Text(
                  'Start New Game?',
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textRed,
                  ),
                ),
              ),
              content: Text(
                'This will delete all saved progress and restart the game from level 1. Are you sure?',
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
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "Cancel",
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
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    "Restart",
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
}
