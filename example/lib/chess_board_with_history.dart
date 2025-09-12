import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'package:simple_chess_board/simple_chess_board.dart';

class ChessBoardWithHistory extends StatefulWidget {
  const ChessBoardWithHistory({super.key});

  @override
  State<ChessBoardWithHistory> createState() => _ChessBoardWithHistoryState();
}

class _ChessBoardWithHistoryState extends State<ChessBoardWithHistory> {
  late chess.Chess _chess;
  late MoveHistory _moveHistory;
  String? _customFen;

  // Example: Start from a custom position (Sicilian Defense)
  static const String _initialFen =
      'rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2';

  @override
  void initState() {
    super.initState();
    _chess = chess.Chess.fromFEN(_initialFen);
    _moveHistory = MoveHistory(initialFen: _initialFen);
  }

  String get _currentFen => _customFen ?? _chess.fen;

  void _onMove(ShortMove move) {
    final chessCopy = chess.Chess.fromFEN(_chess.fen);

    try {
      // Try to make the move
      final success = chessCopy.move({
        'from': move.from,
        'to': move.to,
        'promotion': move.promotion?.name,
      });

      if (success) {
        // Move was successful
        setState(() {
          _chess = chessCopy;
          _customFen = null; // Reset custom FEN since we're at current position
        });

        // Add to history
        _moveHistory.addMove(
          move: '${move.from}${move.to}${move.promotion?.name ?? ''}',
          fen: _chess.fen,
          san: null, // SAN can be computed later if needed
        );
      }
    } catch (e) {
      // Invalid move
      if (kDebugMode) {
        print('Invalid move: $e');
      }
    }
  }

  void _onPromotionCommitted({
    required ShortMove moveDone,
    required PieceType pieceType,
  }) {
    moveDone.promotion = pieceType;
    _onMove(moveDone);
  }

  // Navigation callbacks
  void _goBack() {
    final previousFen = _moveHistory.goBack();
    setState(() {
      _customFen = previousFen;
    });
  }

  void _goForward() {
    final nextFen = _moveHistory.goForward();
    if (nextFen != null) {
      setState(() {
        _customFen = nextFen;
      });
    }
  }

  void _goToStart() {
    setState(() {
      _customFen = _moveHistory.initialFen;
      _moveHistory.goToIndex(-1);
    });
  }

  void _goToEnd() {
    if (_moveHistory.length > 0) {
      setState(() {
        _customFen = null; // Go to current game position
        _moveHistory.goToIndex(_moveHistory.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Board with History'),
      ),
      body: Column(
        children: [
          // Chess Board
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: SimpleChessBoard(
                  fen: _currentFen,
                  whitePlayerType: PlayerType.human,
                  blackPlayerType: PlayerType.human,
                  onMove: ({required ShortMove move}) => _onMove(move),
                  onPromote: () async {
                    // Simple promotion to queen for demo
                    return PieceType.queen;
                  },
                  onPromotionCommited: _onPromotionCommitted,
                  onTap: ({required String cellCoordinate}) {
                    // Handle cell taps if needed
                  },
                  chessBoardColors: ChessBoardColors(),
                  cellHighlights: {},
                  showPossibleMoves: true,
                  // Board is only interactive when we're at the current position
                  isInteractive: _moveHistory.canGoForward == false,
                  // Customize the non-interactive overlay
                  nonInteractiveText: 'ANALYZING POSITION',
                  nonInteractiveTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                  nonInteractiveOverlayColor: Colors.deepPurple,
                ),
              ),
            ),
          ),

          // Navigation Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Move navigation
                MoveNavigationControls(
                  moveHistory: _moveHistory,
                  onGoBack: _goBack,
                  onGoForward: _goForward,
                  onGoToStart: _goToStart,
                  onGoToEnd: _goToEnd,
                  style: NavigationControlsStyle(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Move history info
                if (_moveHistory.length > 0)
                  Text(
                    'Position ${_moveHistory.currentIndex + 2} of ${_moveHistory.length + 1}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
