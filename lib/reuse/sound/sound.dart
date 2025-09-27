import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  // Players
  AudioPlayer? _bgPlayer; // lazy initialization
  final AudioPlayer _tapPlayer = AudioPlayer();
  final AudioPlayer _victoryPlayer = AudioPlayer();
  final AudioPlayer _failPlayer = AudioPlayer();
  final AudioPlayer _roundPlayer = AudioPlayer();

  // Hive box
  Box? _box;

  // Toggles with reactive notifiers
  final ValueNotifier<bool> bgEnabledNotifier = ValueNotifier(true);
  final ValueNotifier<bool> tapEnabledNotifier = ValueNotifier(true);
  final ValueNotifier<bool> victoryEnabledNotifier = ValueNotifier(true);
  final ValueNotifier<bool> failEnabledNotifier = ValueNotifier(true);
  final ValueNotifier<bool> roundEnabledNotifier = ValueNotifier(true);

  bool _bgPlaying = false;

  bool get isBgPlaying => _bgPlaying;

  // -------------------------
  // Initialize Hive and players
  // -------------------------
  Future<void> init() async {
    _box = await Hive.openBox('sound_settings');

    // Load saved settings
    bgEnabledNotifier.value =
        _box?.get('bgEnabled', defaultValue: true) ?? true;
    tapEnabledNotifier.value =
        _box?.get('tapEnabled', defaultValue: true) ?? true;
    victoryEnabledNotifier.value =
        _box?.get('victoryEnabled', defaultValue: true) ?? true;
    failEnabledNotifier.value =
        _box?.get('failEnabled', defaultValue: true) ?? true;

    // Initialize background player
    _bgPlayer ??= AudioPlayer();
    await _bgPlayer!.setReleaseMode(ReleaseMode.loop);

    // Auto-play background if enabled
    if (bgEnabledNotifier.value) {
      await playBackground('background_sound.mp3');
    }
  }

  ///----------------
  /// background sound / music
  /// ----------------
  Future<void> playBackground(String assetName) async {
    if (!bgEnabledNotifier.value) return;

    _bgPlayer ??= AudioPlayer();

    // Set looping for background music
    await _bgPlayer!.setReleaseMode(ReleaseMode.loop);

    // Use mediaPlayer mode so it behaves like background music
    await _bgPlayer!.setPlayerMode(PlayerMode.mediaPlayer);

    // This allows other short sounds to play over it
    await _bgPlayer!.play(AssetSource('sounds/$assetName'));
    _bgPlaying = true;
  }

  Future<void> stopBackground() async {
    if (_bgPlayer == null) return;
    try {
      await _bgPlayer!.stop();
      _bgPlaying = false;
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  Future<void> toggleBackground() async {
    bgEnabledNotifier.value = !bgEnabledNotifier.value;
    await _box?.put('bgEnabled', bgEnabledNotifier.value);

    if (_bgPlayer == null) return;

    if (_bgPlaying && !bgEnabledNotifier.value) {
      await _bgPlayer!.pause();
      _bgPlaying = false;
    } else if (!_bgPlaying && bgEnabledNotifier.value) {
      await _bgPlayer!.resume();
      _bgPlaying = true;
    }
  }

  // -------------------------
  // Tap sound on flipping cards
  // -------------------------
  Future<void> toggleTap() async {
    tapEnabledNotifier.value = !tapEnabledNotifier.value;
    await _box?.put('tapEnabled', tapEnabledNotifier.value);
  }

  Future<void> playTap(String assetName) async {
    if (!tapEnabledNotifier.value) return;
    try {
      await _tapPlayer.play(AssetSource('sounds/$assetName'));
    } catch (e) {
      print('Error playing tap sound: $e');
    }
  }

  // -------------------------
  // Victory sound When level is completed
  // -------------------------
  Future<void> toggleVictory() async {
    victoryEnabledNotifier.value = !victoryEnabledNotifier.value;
    await _box?.put('victoryEnabled', victoryEnabledNotifier.value);
  }

  Future<void> playVictory(String assetName) async {
    if (!victoryEnabledNotifier.value) return;
    try {
      await _victoryPlayer.play(AssetSource('sounds/$assetName'));
    } catch (e) {
      print('Error playing victory sound: $e');
    }
  }

  // -------------------------
  // Fail sound
  // -------------------------
  Future<void> toggleFail() async {
    failEnabledNotifier.value = !failEnabledNotifier.value;
    await _box?.put('failEnabled', failEnabledNotifier.value);
  }

  Future<void> playFail(String assetName) async {
    if (!failEnabledNotifier.value) return;
    try {
      await _failPlayer.play(AssetSource('sounds/$assetName'));
    } catch (e) {
      print('Error playing fail sound: $e');
    }
  }

  /// ------------------
  /// round completed play
  /// ---------------
  Future<void> toggleRoundComplete() async {
    roundEnabledNotifier.value = !roundEnabledNotifier.value;
    await _box?.put('roundEnabled', roundEnabledNotifier.value);
  }

  Future<void> playRoundComplete(String assetName) async {
    if (!roundEnabledNotifier.value) return;
    try {
      await _roundPlayer.play(AssetSource('sounds/$assetName'));
    } catch (e) {
      print('Error playing round complete sound: $e');
    }
  }
}
