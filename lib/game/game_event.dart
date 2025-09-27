abstract class GameEvent {}

// class InitializeGame extends GameEvent {
//   final int gridSize;
//   final String levelType;
//   final int level;
//
//   InitializeGame({
//     required this.gridSize,
//     this.levelType = 'numbers',
//     this.level = 1,
//   });
// }
class InitializeGame extends GameEvent {
  final int level;
  final int? gridSize; // optional
  final String? levelType; // optional

  InitializeGame({required this.level, this.gridSize, this.levelType});
}

class FlipCard extends GameEvent {
  final int index;

  FlipCard(this.index);
}

class ResetGame extends GameEvent {
  final int gridSize;
  final String levelType;
  final int level;

  ResetGame({
    required this.gridSize,
    required this.levelType,
    required this.level,
  });
}

// retry playing same round same level
class RetryRound extends GameEvent {
  final String levelType;
  final int gridSize;
  final int level;
  final int round;

  RetryRound({
    required this.levelType,
    required this.gridSize,
    required this.level,
    required this.round,
  });
}

//next button
class NextRound extends GameEvent {
  final String levelType;
  final int gridSize;
  final int level;
  final int currentRound;

  NextRound({
    required this.levelType,
    required this.gridSize,
    required this.level,
    required this.currentRound,
  });
}

class CompleteRound extends GameEvent {
  final int points; // points earned this round

  CompleteRound(this.points);
}

class StartNewRound extends GameEvent {
  final int roundTime; // time per round
  StartNewRound({required this.roundTime});
}

// control the timer on pause or changes
class PauseTimer extends GameEvent {}

class ResumeTimer extends GameEvent {}

class RoundCompleted extends GameEvent {}

// class Tick extends GameEvent {}
