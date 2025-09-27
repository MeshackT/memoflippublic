import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:memoflip/home/about.dart';
import 'package:memoflip/home/home.dart';
import 'package:memoflip/level_selection/level_selection.dart';
import 'package:memoflip/reuse/reuse.dart';
import 'package:memoflip/reuse/sound/sound.dart';
import 'package:memoflip/theme/myColor.dart';

import 'firebase_options.dart';
import 'game/game_bloc.dart';
import 'game/ui/game_screen.dart';
import 'game/ui/win_screen.dart';
import 'notifications/local_notifications.dart';
import 'reuse/bouncingBalls.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Hive.initFlutter(); // initialize Hive
  await Hive.openBox('gameBox'); // open your box
  await SoundService().init(); // globally initialize
  LocalNotificationService.initialize();
  await LocalNotificationService.getPermission();

  await LocalNotificationService.subscribeToTopicDevice();
  String? token = await FirebaseMessaging.instance.getToken();
  logger.i("Device token: $token");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.backgroundGreen,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<GameBloc>(create: (_) => GameBloc()),
          // Add other providers here if needed
        ],
        child: MaterialApp(
          title: 'MemoFlip',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.backgroundDark,
            textTheme: GoogleFonts.pressStart2pTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: AppColors.textWhite,
                displayColor: AppColors.textWhite,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimary,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
              ),
            ),
          ),
          home: const SplashScreen(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/splashScreen':
                return MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                );
              case '/home':
                return MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                );
              case '/level_selection':
                return MaterialPageRoute(
                  builder: (context) => const LevelSelection(),
                );
              case '/game_screen':
                final args = settings.arguments as Map<String, dynamic>;
                final gridSize = args['gridSize'] as int;
                final levelType = args['levelType'];
                final level = args['level'] ?? 1;
                return MaterialPageRoute(
                  builder: (context) => GameScreen(
                    level: level,
                    gridSize: gridSize,
                    levelType: levelType,
                  ),
                );
              case '/win_screen':
                return MaterialPageRoute(
                  builder: (context) => const WinScreen(),
                );
              case '/about':
                return MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                );
              default:
                return null;
            }
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

    // Card flip animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Navigate to home screen after 3 seconds
    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flip animation card
                AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * 3.14; // radians
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(angle),
                      child: Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          color: angle < 1.57
                              ? Colors.orange.shade400
                              : Colors.teal.shade400,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(4, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: angle < 1.57
                              ? const Icon(
                                  Icons.question_mark,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : const Icon(
                                  Icons.star,
                                  size: 50,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // App title
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

                const SizedBox(height: 10),
                Text(
                  "Match & Win!",
                  style: GoogleFonts.freckleFace(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textTeal,
                      letterSpacing: 2,
                    ),
                  ),
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
              children: List.generate(
                5, // number of icons
                (index) => BouncingIcon(delay: index * 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
