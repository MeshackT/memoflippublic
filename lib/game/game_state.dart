class GameState {
  final List<String> cards;
  final List<bool> flipped;
  final List<bool> matched;
  final int moves;
  final int level;
  final int currentRound;
  final int roundsPerLevel;
  final int seconds;
  final String levelType;
  final bool isCompleted;
  final bool allLevelsCompleted;
  final bool isGameOver;
  final bool isPaused;
  final int gridSize;
  final int totalPoints;
  final bool levelCompleted; // ✅ NEW

  const GameState({
    required this.cards,
    required this.flipped,
    required this.matched,
    required this.moves,
    required this.level,
    required this.currentRound,
    required this.roundsPerLevel,
    required this.seconds,
    required this.levelType,
    required this.isCompleted,
    required this.allLevelsCompleted,
    this.isGameOver = false,
    this.isPaused = false,
    required this.gridSize,
    this.totalPoints = 0,
    this.levelCompleted = false, // ✅ NEW default
  });

  /// ✅ Initial factory
  factory GameState.initial({
    required int gridSize,
    required String levelType,
    int roundsPerLevel = 10,
    List<String>? cards,
  }) {
    final totalCards = gridSize * gridSize;

    return GameState(
      cards: cards ?? List.filled(totalCards, ''),
      flipped: List.filled(totalCards, false),
      matched: List.filled(totalCards, false),
      moves: 0,
      level: 1,
      currentRound: 1,
      roundsPerLevel: roundsPerLevel,
      seconds: _getTimeLimit(gridSize),
      levelType: levelType,
      isCompleted: false,
      allLevelsCompleted: false,
      isGameOver: false,
      isPaused: false,
      gridSize: gridSize,
      totalPoints: 0,
      levelCompleted: false, // ✅ initial always false
    );
  }

  /// helper for initial time
  static int _getTimeLimit(int gridSize) {
    if (gridSize == 4) return 120;
    if (gridSize == 6) return 180;
    if (gridSize == 8) return 240;
    return 180;
  }

  GameState copyWith({
    List<String>? cards,
    List<bool>? flipped,
    List<bool>? matched,
    int? moves,
    int? level,
    int? currentRound,
    int? roundsPerLevel,
    int? seconds,
    String? levelType,
    bool? isCompleted,
    bool? allLevelsCompleted,
    bool? isGameOver,
    bool? isPaused,
    int? gridSize,
    int? totalPoints,
    bool? levelCompleted, // ✅ NEW
  }) {
    return GameState(
      cards: cards ?? this.cards,
      flipped: flipped ?? this.flipped,
      matched: matched ?? this.matched,
      moves: moves ?? this.moves,
      level: level ?? this.level,
      currentRound: currentRound ?? this.currentRound,
      roundsPerLevel: roundsPerLevel ?? this.roundsPerLevel,
      seconds: seconds ?? this.seconds,
      levelType: levelType ?? this.levelType,
      isCompleted: isCompleted ?? this.isCompleted,
      allLevelsCompleted: allLevelsCompleted ?? this.allLevelsCompleted,
      isGameOver: isGameOver ?? this.isGameOver,
      isPaused: isPaused ?? this.isPaused,
      gridSize: gridSize ?? this.gridSize,
      totalPoints: totalPoints ?? this.totalPoints,
      levelCompleted: levelCompleted ?? this.levelCompleted, // ✅ copy forward
    );
  }

  Map<String, dynamic> toJson() => {
    'cards': cards,
    'flipped': flipped,
    'matched': matched,
    'moves': moves,
    'level': level,
    'currentRound': currentRound,
    'roundsPerLevel': roundsPerLevel,
    'seconds': seconds,
    'levelType': levelType,
    'isCompleted': isCompleted,
    'allLevelsCompleted': allLevelsCompleted,
    'isGameOver': isGameOver,
    'isPaused': isPaused,
    'gridSize': gridSize,
    'totalPoints': totalPoints,
    'levelCompleted': levelCompleted, // ✅ NEW
  };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      cards: List<String>.from(json['cards']),
      flipped: List<bool>.from(json['flipped']),
      matched: List<bool>.from(json['matched']),
      moves: json['moves'],
      level: json['level'],
      currentRound: json['currentRound'],
      roundsPerLevel: json['roundsPerLevel'],
      seconds: json['seconds'],
      levelType: json['levelType'],
      isCompleted: json['isCompleted'],
      allLevelsCompleted: json['allLevelsCompleted'],
      isGameOver: json['isGameOver'] ?? false,
      isPaused: json['isPaused'] ?? false,
      gridSize: json['gridSize'],
      totalPoints: json['totalPoints'] ?? 0,
      levelCompleted: json['levelCompleted'] ?? false, // ✅ load safely
    );
  }
}
