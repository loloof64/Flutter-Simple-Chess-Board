/// Represents a single move in the game history
class HistoryMove {
  /// The move that was made
  final String move;

  /// The FEN position after this move
  final String fen;

  /// The move in standard algebraic notation (optional)
  final String? san;

  /// Timestamp when the move was made
  final DateTime timestamp;

  const HistoryMove({
    required this.move,
    required this.fen,
    this.san,
    required this.timestamp,
  });

  @override
  String toString() => san ?? move;
}

/// Manages the history of moves in a chess game
class MoveHistory {
  final List<HistoryMove> _history = [];
  int _currentIndex = -1;
  final String _initialFen;

  /// Creates a move history with an optional initial FEN position
  MoveHistory({String? initialFen})
      : _initialFen = initialFen ??
            'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  /// The initial FEN position
  String get initialFen => _initialFen;

  /// All moves in chronological order
  List<HistoryMove> get history => List.unmodifiable(_history);

  /// Current position index in history (-1 means at start)
  int get currentIndex => _currentIndex;

  /// Total number of moves in history
  int get length => _history.length;

  /// Whether we can go back in history
  bool get canGoBack => _currentIndex >= 0;

  /// Whether we can go forward in history
  bool get canGoForward => _currentIndex < _history.length - 1;

  /// Current FEN position
  String get currentFen =>
      _currentIndex >= 0 ? _history[_currentIndex].fen : _initialFen;

  /// Add a new move to history
  void addMove({
    required String move,
    required String fen,
    String? san,
  }) {
    // If we're not at the end of history, truncate future moves
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    final historyMove = HistoryMove(
      move: move,
      fen: fen,
      san: san,
      timestamp: DateTime.now(),
    );

    _history.add(historyMove);
    _currentIndex = _history.length - 1;
  }

  /// Go back one move in history
  String goBack() {
    if (!canGoBack) return _initialFen;

    _currentIndex--;
    return _currentIndex >= 0 ? _history[_currentIndex].fen : _initialFen;
  }

  /// Go forward one move in history
  String? goForward() {
    if (!canGoForward) return null;

    _currentIndex++;
    return _history[_currentIndex].fen;
  }

  /// Go to a specific position in history
  String goToIndex(int index) {
    if (index < -1 || index >= _history.length) {
      return _currentIndex >= 0 ? _history[_currentIndex].fen : _initialFen;
    }

    _currentIndex = index;
    return _currentIndex >= 0 ? _history[_currentIndex].fen : _initialFen;
  }

  /// Clear all history
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }

  /// Get the last move made
  HistoryMove? get lastMove => _history.isNotEmpty ? _history.last : null;

  /// Get move at specific index
  HistoryMove? getMoveAt(int index) {
    if (index < 0 || index >= _history.length) return null;
    return _history[index];
  }
}
