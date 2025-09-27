import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:memoflip/reuse/sound/sound.dart';

import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  final SoundService _soundService = SoundService();

  int _currentRound = 1;
  final int roundsPerLevel = 10;

  Box? box;
  Timer? _timer;

  final Map<String, int> maxLevelsPerMode = {
    'numbers': 2,
    'icons': 3,
    'images': 4,
  };

  GameBloc() : super(GameState.initial(gridSize: 4, levelType: 'numbers')) {
    on<InitializeGame>(_onInitializeGame);
    on<FlipCard>(_onFlipCard);
    on<ResetGame>(_onResetGame);
    on<RetryRound>(_onRetryRound);
    on<NextRound>(_onNextRound);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<CompleteRound>(_onCompleteRound);
  }

  int getGridSizeForLevel(int level) => 4 + ((level - 1) ~/ 2);

  String getLevelTypeForLevel(int level) {
    if (level % 3 == 1) return 'numbers';
    if (level % 3 == 2) return 'icons';
    return 'images';
  }

  bool get allLevelsCompleted {
    final maxLevel = maxLevelsPerMode[state.levelType] ?? 1;
    return state.level >= maxLevel;
  }

  void resetFlippedIndices() {
    _firstFlippedIndex = null;
    _secondFlippedIndex = null;
  }

  void startTimer({int? totalSeconds}) {
    stopTimer();
    int secondsLeft = totalSeconds ?? state.seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsLeft <= 0) {
        stopTimer();
        emit(state.copyWith(seconds: 0, isGameOver: true));
        return;
      }
      secondsLeft--;
      emit(state.copyWith(seconds: secondsLeft));
      _saveProgress(state.copyWith(seconds: secondsLeft));
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _initHive() async {
    box ??= await Hive.openBox('game_progress');
  }

  String progressKey(String levelType, int gridSize, int level, int round) {
    return '${levelType}_${gridSize}_L${level}_R$round';
  }

  void _saveProgress(GameState state) {
    if (box == null) return;
    final key = progressKey(
      state.levelType,
      state.gridSize,
      state.level,
      state.currentRound,
    );
    box!.put(key, state.toJson());
  }

  GameState? _loadProgress(
    String levelType,
    int gridSize,
    int level,
    int round,
  ) {
    final key = progressKey(levelType, gridSize, level, round);
    final data = box?.get(key);
    if (data == null) return null;
    return GameState.fromJson(Map<String, dynamic>.from(data));
  }

  int _durationForGrid(int gridSize) {
    if (gridSize <= 4) return 120;
    if (gridSize == 6) return 180;
    if (gridSize == 8) return 300;
    return 360;
  }

  Future<void> _onInitializeGame(
    InitializeGame event,
    Emitter<GameState> emit,
  ) async {
    await _initHive();

    _currentRound = 1;

    final gridSize = event.gridSize ?? getGridSizeForLevel(event.level);
    final levelType = event.levelType ?? getLevelTypeForLevel(event.level);

    final points = 0;
    final maxLevel = maxLevelsPerMode[levelType] ?? 1;

    if (event.level > maxLevel) {
      final totalCards = gridSize * gridSize;
      final cards = _generateCardsByLevel(
        totalCards ~/ 2,
        gridSize,
        levelType: levelType,
      );
      final allCards = [...cards, ...cards]..shuffle(Random());

      emit(
        GameState(
          cards: allCards,
          flipped: List.filled(allCards.length, false),
          matched: List.filled(allCards.length, false),
          moves: 0,
          level: maxLevel,
          currentRound: roundsPerLevel,
          roundsPerLevel: roundsPerLevel,
          isCompleted: true,
          allLevelsCompleted: true,
          seconds: 0,
          levelType: levelType,
          isGameOver: true,
          gridSize: gridSize,
          totalPoints: points,
          levelCompleted: false,
        ),
      );
      return;
    }

    final savedState = _loadProgress(
      levelType,
      gridSize,
      event.level,
      _currentRound,
    );
    if (savedState != null) {
      emit(savedState.copyWith(levelCompleted: false));
      if (!savedState.isPaused) startTimer(totalSeconds: savedState.seconds);
      return;
    }

    await _startNewLevel(event.level, levelType, gridSize, emit);
  }

  Future<void> _startNewLevel(
    int level,
    String levelType,
    int gridSize,
    Emitter<GameState> emit,
  ) async {
    final totalCards = gridSize * gridSize;
    final cards = _generateCardsByLevel(
      totalCards ~/ 2,
      gridSize,
      levelType: levelType,
    );
    final allCards = [...cards, ...cards]..shuffle(Random());
    _currentRound = 1;

    final points = await _loadTotalPoints();

    final newState = GameState(
      cards: allCards,
      flipped: List.filled(allCards.length, false),
      matched: List.filled(allCards.length, false),
      moves: 0,
      level: level,
      currentRound: _currentRound,
      roundsPerLevel: roundsPerLevel,
      isCompleted: false,
      allLevelsCompleted: false,
      seconds: _durationForGrid(gridSize),
      levelType: levelType,
      isGameOver: false,
      gridSize: gridSize,
      totalPoints: points,
      levelCompleted: false,
    );

    emit(newState);
    _saveProgress(newState);
    startTimer(totalSeconds: newState.seconds);
  }

  Future<void> _onFlipCard(FlipCard event, Emitter<GameState> emit) async {
    final index = event.index;
    if (index >= state.cards.length) return;
    if (state.flipped[index] || state.matched[index]) return;

    final flipped = [...state.flipped];
    flipped[index] = true;

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
      emit(state.copyWith(flipped: flipped));
      _saveProgress(state.copyWith(flipped: flipped));
      return;
    }

    if (_secondFlippedIndex == null) {
      _secondFlippedIndex = index;
      emit(state.copyWith(flipped: flipped));
      _saveProgress(state.copyWith(flipped: flipped));

      final first = _firstFlippedIndex!;
      final second = _secondFlippedIndex!;

      if (state.cards[first] == state.cards[second]) {
        final matched = [...state.matched];
        matched[first] = true;
        matched[second] = true;

        final updatedPoints = state.totalPoints + 10;
        await _saveTotalPoints(updatedPoints);

        final successState = state.copyWith(
          flipped: flipped,
          matched: matched,
          moves: state.moves + 1,
          totalPoints: updatedPoints,
        );
        emit(successState);
        _saveProgress(successState);

        final isRoundCompleted = matched.every((m) => m);
        if (isRoundCompleted) {
          stopTimer();
          await _soundService.playRoundComplete('sounds.wav');

          final maxLevel = maxLevelsPerMode[state.levelType] ?? 1;
          final lastLevelReached = state.level >= maxLevel;
          final lastRound = _currentRound >= roundsPerLevel;

          if (!lastRound) {
            _currentRound++;
            await _shuffleForNextRoundAsync(emit);
          } else if (!lastLevelReached) {
            final levelCompletedState = successState.copyWith(
              levelCompleted: true,
            );
            emit(levelCompletedState);
            _saveProgress(levelCompletedState);
            await _soundService.playRoundComplete('sounds.wav');

            final nextLevel = state.level + 1;
            add(
              InitializeGame(
                level: nextLevel,
                gridSize: getGridSizeForLevel(nextLevel),
                levelType: state.levelType,
              ),
            );
          } else {
            await _soundService.playVictory('next_level.wav');
            final completedState = successState.copyWith(
              isCompleted: true,
              allLevelsCompleted: true,
              isGameOver: true,
            );
            emit(completedState);
            _saveProgress(completedState);
          }
        }
      } else {
        final penalty = _getPenalty(state.gridSize);
        int updatedPoints = (state.totalPoints - penalty).clamp(
          0,
          state.totalPoints,
        );
        await _saveTotalPoints(updatedPoints);

        await Future.delayed(const Duration(seconds: 1));
        flipped[first] = false;
        flipped[second] = false;

        final failState = state.copyWith(
          flipped: flipped,
          moves: state.moves + 1,
          totalPoints: updatedPoints,
        );
        emit(failState);
        _saveProgress(failState);
      }

      resetFlippedIndices();
    }
  }

  Future<void> _shuffleForNextRoundAsync(Emitter<GameState> emit) async {
    final shuffledCards = [...state.cards]..shuffle(Random());
    final newState = state.copyWith(
      cards: shuffledCards,
      flipped: List.filled(shuffledCards.length, false),
      matched: List.filled(shuffledCards.length, false),
      moves: 0,
      currentRound: _currentRound,
      isCompleted: false,
      isGameOver: false,
      seconds: _durationForGrid(state.gridSize),
    );
    emit(newState);
    _saveProgress(newState);
    startTimer(totalSeconds: newState.seconds);
  }

  Future<void> _onCompleteRound(
    CompleteRound event,
    Emitter<GameState> emit,
  ) async {
    int nextRound = state.currentRound + 1;
    int nextLevel = state.level;
    bool completed = state.isCompleted;
    bool allDone = state.allLevelsCompleted;

    int totalPoints = state.totalPoints + event.points;

    if (nextRound > roundsPerLevel) {
      nextRound = 1;
      nextLevel++;
      completed = true;
    }

    if (nextLevel > (maxLevelsPerMode[state.levelType] ?? 1)) {
      allDone = true;
      nextLevel = maxLevelsPerMode[state.levelType]!;
      nextRound = roundsPerLevel;
    }

    final newState = state.copyWith(
      currentRound: nextRound,
      level: nextLevel,
      totalPoints: totalPoints,
      isCompleted: completed,
      allLevelsCompleted: allDone,
    );
    emit(newState);
    _saveProgress(newState);
  }

  Future<void> _onResetGame(ResetGame event, Emitter<GameState> emit) async {
    stopTimer();
    _currentRound = 1;

    await box?.delete(
      progressKey(event.levelType, event.gridSize, event.level, _currentRound),
    );

    final totalCards = event.gridSize * event.gridSize;
    final cards = _generateCardsByLevel(
      totalCards ~/ 2,
      event.gridSize,
      levelType: event.levelType,
    );
    final allCards = [...cards, ...cards]..shuffle(Random());

    final newState = GameState(
      cards: allCards,
      flipped: List.filled(totalCards, false),
      matched: List.filled(totalCards, false),
      moves: 0,
      level: event.level,
      currentRound: _currentRound,
      roundsPerLevel: roundsPerLevel,
      isCompleted: false,
      allLevelsCompleted: false,
      seconds: _durationForGrid(event.gridSize),
      levelType: event.levelType,
      isGameOver: false,
      gridSize: event.gridSize,
      totalPoints: state.totalPoints,
    );

    emit(newState);
    _saveProgress(newState);
    startTimer(totalSeconds: newState.seconds);
  }

  Future<void> _onNextRound(NextRound event, Emitter<GameState> emit) async {
    stopTimer();
    int nextRound = event.currentRound + 1;
    if (nextRound > roundsPerLevel) {
      emit(state.copyWith(isCompleted: true, isGameOver: true));
      return;
    }

    await box?.delete(
      progressKey(event.levelType, event.gridSize, event.level, nextRound),
    );

    final totalCards = event.gridSize * event.gridSize;
    final cards = _generateCardsByLevel(
      totalCards ~/ 2,
      event.gridSize,
      levelType: event.levelType,
    );
    final allCards = [...cards, ...cards]..shuffle(Random());

    final newState = state.copyWith(
      cards: allCards,
      flipped: List.filled(totalCards, false),
      matched: List.filled(totalCards, false),
      moves: 0,
      currentRound: nextRound,
      seconds: _durationForGrid(event.gridSize),
    );

    emit(newState);
    _saveProgress(newState);
    startTimer(totalSeconds: newState.seconds);
  }

  Future<void> _onRetryRound(RetryRound event, Emitter<GameState> emit) async {
    stopTimer();
    await box?.delete(
      progressKey(
        event.levelType,
        event.gridSize,
        event.level,
        state.currentRound,
      ),
    );

    final totalCards = event.gridSize * event.gridSize;
    final cards = _generateCardsByLevel(
      totalCards ~/ 2,
      event.gridSize,
      levelType: event.levelType,
    );
    final allCards = [...cards, ...cards]..shuffle(Random());

    final newState = state.copyWith(
      cards: allCards,
      flipped: List.filled(totalCards, false),
      matched: List.filled(totalCards, false),
      moves: 0,
      seconds: _durationForGrid(event.gridSize),
    );

    emit(newState);
    _saveProgress(newState);
    startTimer(totalSeconds: newState.seconds);
  }

  void _onPauseTimer(PauseTimer event, Emitter<GameState> emit) {
    stopTimer();
    emit(state.copyWith(isPaused: true));
    _saveProgress(state.copyWith(isPaused: true));
  }

  void _onResumeTimer(ResumeTimer event, Emitter<GameState> emit) {
    if (!state.isPaused) return;
    emit(state.copyWith(isPaused: false));
    _saveProgress(state.copyWith(isPaused: false));
    startTimer(totalSeconds: state.seconds);
  }

  int _getPenalty(int gridSize) {
    switch (gridSize) {
      case 4:
        return 4;
      case 6:
        return 15;
      case 8:
        return 20;
      default:
        return 10;
    }
  }

  Future<int> _loadTotalPoints() async {
    final pointsBox = await Hive.openBox<int>('total_points_box');
    return pointsBox.get('totalPoints', defaultValue: 0) ?? 0;
  }

  Future<void> _saveTotalPoints(int points) async {
    final pointsBox = await Hive.openBox<int>('total_points_box');
    await pointsBox.put('totalPoints', points);
  }

  List<String> _generateCardsByLevel(
    int pairsNeeded,
    int gridSize, {
    String levelType = 'numbers',
  }) {
    final numbers = List.generate(50, (i) => 'num_${i + 1}');
    final icons = [
      'icon_home',
      'icon_star',
      'icon_face',
      'icon_pets',
      'icon_sports',
      'icon_music',
      'icon_camera',
      'icon_pumpkin',
      'icon_list',
      'icon_inion',
      'icon_fire',
      'icon_dragon',
      'icon_coconut',
      'icon_carrot',
      'icon_betrude',
      'icon_zoo',
      'icon_robot',
      'icon_wifi',
      'icon_train',
      'icon_tv',
      'icon_strawberry',
      'icon_river',
      'icon_owl',
      'icon_moon',
      'icon_helicopter',
      'icon_cheetah',
      'icon_bee',
      'img_blue',
    ];
    final images = [
      'img_cat',
      'img_dog',
      'img_tree',
      'img_car',
      'img_rocket',
      'img_bird',
      'img_flower',
      'img_zebra',
      'img_twoCats',
      'img_monkey',
      'img_orange',
      'img_mango',
      'img_listen',
      'img_lion',
      'img_heart',
      'img_gorilla',
      'img_giraff',
      'img_frog',
      'img_elefant',
      'img_cycle',
      'img_banana',
      'img_aple',
      'img_wagon',
      'img_taoste',
      'img_skeleton',
      'img_plane',
      'img_phone',
      'img_laptop',
      'img_hand',
      'img_fires',
      'img_crumbs',
      'img_cold',
      'img_catolic',
      'img_breadFruit',
      'img_brain',
      'img_books',
    ];

    List<String> pool;
    switch (levelType) {
      case 'numbers':
        pool = [...numbers, ...images];
        break;
      case 'icons':
        pool = [...numbers, ...icons];
        break;
      case 'images':
        pool = [...numbers, ...icons, ...images];
        break;
      default:
        pool = gridSize <= 4
            ? numbers
            : gridSize <= 5
            ? [...numbers, ...icons]
            : [...numbers, ...icons, ...images];
    }

    pool.shuffle(Random());
    if (pairsNeeded > pool.length)
      pool.addAll(pool.take(pairsNeeded - pool.length));
    return pool.take(pairsNeeded).toList()..shuffle(Random());
  }

  @override
  Future<void> close() {
    stopTimer();
    return super.close();
  }
}
