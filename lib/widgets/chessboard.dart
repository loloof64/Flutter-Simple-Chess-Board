library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'package:just_audio/just_audio.dart';
import 'package:simple_chess_board/models/piece.dart';
import 'package:simple_chess_board/utils.dart';
import 'package:simple_chess_board/widgets/chess_vectors_definitions.dart';
import '../models/piece_type.dart';
import '../models/board_arrow.dart';
import '../models/board_color.dart';
import '../models/short_move.dart';

final piecesDefinition = {
  "wp": whitePawnDefinition,
  "wn": whiteKnightDefinition,
  "wb": whiteBishopDefinition,
  "wr": whiteRookDefinition,
  "wq": whiteQueenDefinition,
  "wk": whiteKingDefinition,
  "bp": blackPawnDefinition,
  "bn": blackKnightDefinition,
  "bb": blackBishopDefinition,
  "br": blackRookDefinition,
  "bq": blackQueenDefinition,
  "bk": blackKingDefinition,
};

const baseImageSize = 45.0;

/// Colors used by the chess board.
class ChessBoardColors {
  /// The color of the light squares.
  Color lightSquaresColor = const Color.fromRGBO(240, 217, 181, 1);

  /// The color of the dark squares.
  Color darkSquaresColor = const Color.fromRGBO(181, 136, 99, 1);

  /// The color of the coordinates zone.
  Color coordinatesZoneColor = Colors.indigo.shade300;

  /// The color of last move arrow.
  Color lastMoveArrowColor = Colors.greenAccent;

  /// The color of the circular progress bar.
  Color circularProgressBarColor = Colors.teal;

  /// The color of the coordinates.
  Color coordinatesColor = Colors.yellow.shade400;

  /// The color of the start square for drag and drop, or for click then click move.
  Color startSquareColor = Colors.red;

  /// The color of the end square for drag and drop
  Color endSquareColor = Colors.green;

  /// Optional color for the drag and drop indicator's cells.
  Color? dndIndicatorColor;

  /// The color of the possible move indicators (dots).
  Color possibleMovesColor = Colors.grey.withAlpha(128);

  /// Constructor.
  ChessBoardColors();
}

/// Player type (human/computer)
enum PlayerType {
  human,
  computer,
}

/// Simple chess board widget.
class SimpleChessBoard extends StatelessWidget {
  /// Board's position in Forsyth-Edwards Notation.
  final String fen;

  /// Is Black side at bottom of the board, or white side ?
  final bool blackSideAtBottom;

  /// White type (human/cpu).
  final PlayerType whitePlayerType;

  /// Black type (human/cpu).
  final PlayerType blackPlayerType;

  /// Handler for when user tries to make move on board.
  final void Function({required ShortMove move}) onMove;

  /// Handler for when a move is successfully made (for history tracking)
  final void Function({required ShortMove move, required String newFen})?
      onMoveComplete;

  /// Handler for when user wants to make a promotion on board.
  final Future<PieceType?> Function() onPromote;

  /// Handler for when a promotion has been commited on the board.
  final void Function({
    required ShortMove moveDone,
    required PieceType pieceType,
  }) onPromotionCommited;

  /// Handler for when a cell is tapped.
  final void Function({
    required String cellCoordinate,
  }) onTap;

  /// Does the border with coordinates and player turn must be visible ?
  final bool showCoordinatesZone;

  /// Last move arrow.
  final BoardArrow? lastMoveToHighlight;

  /// Should the start and end squares be highlighted when showing last move arrow?
  final bool highlightLastMoveSquares;

  /// Should possible moves be shown as dots when dragging a piece?
  final bool? showPossibleMoves;

  /// Whether the board is interactive (allows moves)
  final bool isInteractive;

  /// Text to show when board is not interactive
  final String nonInteractiveText;

  /// Style for the non-interactive overlay text
  final TextStyle? nonInteractiveTextStyle;

  /// Background color for the non-interactive overlay
  final Color? nonInteractiveOverlayColor;

  /// Custom widget builder for normal move indicators (empty squares)
  final Widget Function(double cellSize)? normalMoveIndicatorBuilder;

  /// Custom widget builder for capture move indicators (squares with opponent pieces)
  final Widget Function(double cellSize)? captureMoveIndicatorBuilder;

  /// Must a circular progress bar be visible above of the board ?
  final bool engineThinking;

  /// Whether to play sound effects when moves are made
  final bool playSounds;

  /// The cell highlighting colors.
  final Map<String, Color> cellHighlights;

  /// Callback for captured pieces information.
  /// Called whenever the board position changes.
  /// Returns lists of piece types captured by each player.
  final void Function({
    required List<PieceType> whiteCapturedPieces,
    required List<PieceType> blackCapturedPieces,
  })? onCapturedPiecesChanged;

  /// Says if the player in turn is human.
  bool currentPlayerIsHuman() {
    final whiteTurn = fen.split(' ')[1] == 'w';
    return (whitePlayerType == PlayerType.human && whiteTurn) ||
        (blackPlayerType == PlayerType.human && !whiteTurn);
  }

  /// Colors used by the chess board.
  final ChessBoardColors chessBoardColors;

  /// Constructor.
  const SimpleChessBoard({
    super.key,
    required this.fen,
    this.blackSideAtBottom = false,
    required this.whitePlayerType,
    required this.blackPlayerType,
    required this.onMove,
    this.onMoveComplete,
    required this.onPromote,
    required this.onPromotionCommited,
    required this.onTap,
    required this.chessBoardColors,
    required this.cellHighlights,
    this.engineThinking = false,
    this.showCoordinatesZone = true,
    this.lastMoveToHighlight,
    this.highlightLastMoveSquares = false,
    this.showPossibleMoves,
    this.isInteractive = true,
    this.nonInteractiveText = 'VIEWING HISTORY',
    this.nonInteractiveTextStyle,
    this.nonInteractiveOverlayColor,
    this.normalMoveIndicatorBuilder,
    this.captureMoveIndicatorBuilder,
    this.playSounds = false,
    this.onCapturedPiecesChanged,
  });

  void _processMove(ShortMove move) {
    if (currentPlayerIsHuman()) {
      onMove(move: move);
    }
  }

  Widget _buildPlayerTurn({required double size}) {
    final isWhiteTurn = fen.split(' ')[1] == 'w';
    return Positioned(
      bottom: size * 0.001,
      right: size * 0.001,
      child: _PlayerTurn(size: size * 0.05, whiteTurn: isWhiteTurn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((ctx, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        var boardSizeProportion = (showCoordinatesZone ? 0.9 : 1.0);
        return Stack(
          alignment: Alignment.center,
          children: [
            showCoordinatesZone
                ? Container(
                    color: chessBoardColors.coordinatesZoneColor,
                    width: size,
                    height: size,
                    child: Stack(
                      children: [
                        ...getFilesCoordinates(
                          boardSize: size,
                          top: true,
                          reversed: blackSideAtBottom,
                          coordinatesColor: chessBoardColors.coordinatesColor,
                        ),
                        ...getFilesCoordinates(
                          boardSize: size,
                          top: false,
                          reversed: blackSideAtBottom,
                          coordinatesColor: chessBoardColors.coordinatesColor,
                        ),
                        ...getRanksCoordinates(
                          boardSize: size,
                          left: true,
                          reversed: blackSideAtBottom,
                          coordinatesColor: chessBoardColors.coordinatesColor,
                        ),
                        ...getRanksCoordinates(
                          boardSize: size,
                          left: false,
                          reversed: blackSideAtBottom,
                          coordinatesColor: chessBoardColors.coordinatesColor,
                        ),
                        _buildPlayerTurn(size: size),
                      ],
                    ),
                  )
                : Container(),
            _Chessboard(
              fen: fen,
              size: size * boardSizeProportion,
              blackSideAtBottom: blackSideAtBottom,
              boardColors: chessBoardColors,
              processMove: _processMove,
              whitePlayerType: whitePlayerType,
              blackPlayerType: blackPlayerType,
              onPromote: onPromote,
              onPromotionCommited: onPromotionCommited,
              onTap: onTap,
              highlightLastMoveSquares: highlightLastMoveSquares,
              showPossibleMoves: showPossibleMoves ?? false,
              isInteractive: isInteractive,
              nonInteractiveText: nonInteractiveText,
              nonInteractiveTextStyle: nonInteractiveTextStyle,
              nonInteractiveOverlayColor: nonInteractiveOverlayColor,
              normalMoveIndicatorBuilder: normalMoveIndicatorBuilder,
              captureMoveIndicatorBuilder: captureMoveIndicatorBuilder,
              arrow: (lastMoveToHighlight != null)
                  ? BoardArrow(
                      from: lastMoveToHighlight!.from,
                      to: lastMoveToHighlight!.to,
                    )
                  : null,
              cellHighlights: cellHighlights,
              onCapturedPiecesChanged: onCapturedPiecesChanged,
              playSounds: playSounds,
            ),
            if (engineThinking)
              SizedBox(
                width: size * boardSizeProportion,
                height: size * boardSizeProportion,
                child: CircularProgressIndicator(
                  backgroundColor: chessBoardColors.circularProgressBarColor,
                  strokeWidth: 8,
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _DragAndDropDetails {
  Piece movedPiece;
  (int, int) startCell;
  (int, int) endCell;
  (double, double) position;

  _DragAndDropDetails({
    required this.movedPiece,
    required this.startCell,
    required this.position,
  }) : endCell = startCell;
}

class _PlayerTurn extends StatelessWidget {
  final double size;
  final bool whiteTurn;

  const _PlayerTurn({required this.size, required this.whiteTurn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(
        left: 10,
      ),
      decoration: BoxDecoration(
        color: whiteTurn ? Colors.white : Colors.black,
        border: Border.all(
          width: 0.7,
          color: Colors.black,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}

Iterable<Widget> getFilesCoordinates({
  required double boardSize,
  required bool top,
  required bool reversed,
  required Color coordinatesColor,
}) {
  final commonTextStyle = TextStyle(
    color: coordinatesColor,
    fontWeight: FontWeight.bold,
    fontSize: boardSize * 0.04,
  );

  return [0, 1, 2, 3, 4, 5, 6, 7].map(
    (file) {
      final letterOffset = !reversed ? file : 7 - file;
      final letter = String.fromCharCode('A'.codeUnitAt(0) + letterOffset);
      return Positioned(
        top: boardSize * (top ? 0.005 : 0.955),
        left: boardSize * (0.09 + 0.113 * file),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    },
  );
}

Iterable<Widget> getRanksCoordinates({
  required double boardSize,
  required bool left,
  required bool reversed,
  required Color coordinatesColor,
}) {
  final commonTextStyle = TextStyle(
    color: coordinatesColor,
    fontWeight: FontWeight.bold,
    fontSize: boardSize * 0.04,
  );

  return [0, 1, 2, 3, 4, 5, 6, 7].map((rank) {
    final letterOffset = reversed ? rank : 7 - rank;
    final letter = String.fromCharCode('1'.codeUnitAt(0) + letterOffset);
    return Positioned(
      left: boardSize * (left ? 0.012 : 0.965),
      top: boardSize * (0.09 + 0.113 * rank),
      child: Text(
        letter,
        style: commonTextStyle,
      ),
    );
  });
}

class _Chessboard extends StatefulWidget {
  final ChessBoardColors boardColors;
  final PlayerType whitePlayerType;
  final PlayerType blackPlayerType;
  final double size;
  final bool blackSideAtBottom;
  final String fen;
  final BoardArrow? arrow;
  final Map<String, Color> cellHighlights;
  final bool highlightLastMoveSquares;
  final bool showPossibleMoves;
  final bool isInteractive;
  final String nonInteractiveText;
  final TextStyle? nonInteractiveTextStyle;
  final Color? nonInteractiveOverlayColor;
  final Widget Function(double cellSize)? normalMoveIndicatorBuilder;
  final Widget Function(double cellSize)? captureMoveIndicatorBuilder;
  final void Function(ShortMove move) processMove;
  final Future<PieceType?> Function() onPromote;
  final void Function({
    required ShortMove moveDone,
    required PieceType pieceType,
  }) onPromotionCommited;
  final void Function({
    required String cellCoordinate,
  }) onTap;
  final void Function({
    required List<PieceType> whiteCapturedPieces,
    required List<PieceType> blackCapturedPieces,
  })? onCapturedPiecesChanged;
  final bool playSounds;

  const _Chessboard({
    required this.fen,
    required this.whitePlayerType,
    required this.blackPlayerType,
    required this.size,
    required this.boardColors,
    required this.blackSideAtBottom,
    required this.processMove,
    required this.arrow,
    required this.cellHighlights,
    required this.highlightLastMoveSquares,
    required this.showPossibleMoves,
    required this.isInteractive,
    required this.nonInteractiveText,
    this.nonInteractiveTextStyle,
    this.nonInteractiveOverlayColor,
    required this.normalMoveIndicatorBuilder,
    required this.captureMoveIndicatorBuilder,
    required this.onPromote,
    required this.onPromotionCommited,
    required this.onTap,
    this.onCapturedPiecesChanged,
    required this.playSounds,
  });

  @override
  State<StatefulWidget> createState() => _ChessboardState();
}

class _ChessboardState extends State<_Chessboard> {
  _DragAndDropDetails? _dndDetails;
  (int, int)? _tapStart;
  Map<String, Piece?> _squares = <String, Piece?>{};
  List<String> _possibleMoves = [];

  // Audio players for each sound type
  final Map<SoundType, AudioPlayer> _audioPlayers = {};

  @override
  void initState() {
    _squares = getSquares(widget.fen);
    super.initState();
    _calculateCapturedPieces();
    _initAudioPlayers();
  }

  Future<void> _initAudioPlayers() async {
    // Initialize audio players for each sound type
    try {
      _audioPlayers[SoundType.move] = AudioPlayer();
      _audioPlayers[SoundType.capture] = AudioPlayer();

      // Pre-load sounds
      await _audioPlayers[SoundType.move]!
          .setAsset('packages/simple_chess_board/sounds/move-self.mp3');
      await _audioPlayers[SoundType.capture]!
          .setAsset('packages/simple_chess_board/sounds/capture.mp3');
    } catch (e) {
      debugPrint('Sound initialization error: $e');
    }
  }

  @override
  void didUpdateWidget(_Chessboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      // Only clear possible moves if the FEN actually changed (indicating a move was made)
      if (oldWidget.fen != widget.fen) {
        final newSquares = getSquares(widget.fen);

        // Determine if it was a capture by checking if a piece disappeared
        final isCapture = _detectCapture(_squares, newSquares);

        _squares = newSquares;
        _possibleMoves = [];
        _tapStart = null;
        _calculateCapturedPieces();

        // Play sound for both human and computer moves
        if (widget.playSounds) {
          _playSound(isCapture ? SoundType.capture : SoundType.move);
        }
      } else {
        _squares = getSquares(widget.fen);
      }
    });
  }

  bool _detectCapture(
      Map<String, Piece?> oldSquares, Map<String, Piece?> newSquares) {
    // Count pieces in both positions
    int oldPieceCount =
        oldSquares.values.where((piece) => piece != null).length;
    int newPieceCount =
        newSquares.values.where((piece) => piece != null).length;

    // If piece count decreased, it was a capture
    return newPieceCount < oldPieceCount;
  }

  Future<void> _playSound(SoundType soundType) async {
    try {
      final player = _audioPlayers[soundType];
      if (player != null) {
        await player.seek(Duration.zero);
        await player.play();
      }
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  @override
  void dispose() {
    // Dispose all audio players
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    super.dispose();
  }

  void _calculateCapturedPieces() {
    if (widget.onCapturedPiecesChanged == null) return;

    // Initial piece counts at starting position
    final initialPieces = {
      BoardColor.white: {
        PieceType.pawn: 8,
        PieceType.knight: 2,
        PieceType.bishop: 2,
        PieceType.rook: 2,
        PieceType.queen: 1,
        PieceType.king: 1,
      },
      BoardColor.black: {
        PieceType.pawn: 8,
        PieceType.knight: 2,
        PieceType.bishop: 2,
        PieceType.rook: 2,
        PieceType.queen: 1,
        PieceType.king: 1,
      },
    };

    // Count pieces currently on the board
    final currentPieces = {
      BoardColor.white: <PieceType, int>{
        PieceType.pawn: 0,
        PieceType.knight: 0,
        PieceType.bishop: 0,
        PieceType.rook: 0,
        PieceType.queen: 0,
        PieceType.king: 0,
      },
      BoardColor.black: <PieceType, int>{
        PieceType.pawn: 0,
        PieceType.knight: 0,
        PieceType.bishop: 0,
        PieceType.rook: 0,
        PieceType.queen: 0,
        PieceType.king: 0,
      },
    };

    for (final piece in _squares.values) {
      if (piece != null) {
        currentPieces[piece.color]![piece.type] =
            (currentPieces[piece.color]![piece.type] ?? 0) + 1;
      }
    }

    // Calculate captured pieces
    final whiteCapturedPieces = <PieceType>[];
    final blackCapturedPieces = <PieceType>[];

    // Black pieces captured by white
    for (final entry in initialPieces[BoardColor.black]!.entries) {
      final pieceType = entry.key;
      final initialCount = entry.value;
      final currentCount = currentPieces[BoardColor.black]![pieceType] ?? 0;
      final captured = initialCount - currentCount;

      for (int i = 0; i < captured; i++) {
        whiteCapturedPieces.add(pieceType);
      }
    }

    // White pieces captured by black
    for (final entry in initialPieces[BoardColor.white]!.entries) {
      final pieceType = entry.key;
      final initialCount = entry.value;
      final currentCount = currentPieces[BoardColor.white]![pieceType] ?? 0;
      final captured = initialCount - currentCount;

      for (int i = 0; i < captured; i++) {
        blackCapturedPieces.add(pieceType);
      }
    }

    // Invoke callback
    widget.onCapturedPiecesChanged!(
      whiteCapturedPieces: whiteCapturedPieces,
      blackCapturedPieces: blackCapturedPieces,
    );
  }

  void _handlePanStart(DragStartDetails details) {
    if (!_isHumanTurn() || !widget.isInteractive) return;
    if (_tapStart != null) return;
    final position = details.localPosition;
    final cellsSize = widget.size / 8;
    final col = position.dx ~/ cellsSize;
    final row = position.dy ~/ cellsSize;

    final file = widget.blackSideAtBottom ? 7 - col : col;
    final rank = widget.blackSideAtBottom ? row : 7 - row;

    final squareName = coordinatesToSquareName(file, rank);
    final piece = _squares[squareName];

    if (piece == null) return;

    final isWhiteTurn = widget.fen.split(" ")[1] == "w";

    final isNotAPieceOfPlayerInTurn = isWhiteTurn
        ? piece.color == BoardColor.black
        : piece.color == BoardColor.white;

    if (isNotAPieceOfPlayerInTurn) return;

    // Calculate possible moves for the selected piece
    if (widget.showPossibleMoves) {
      final chessLogic = chess.Chess.fromFEN(widget.fen);
      _possibleMoves = chessLogic
          .moves({'square': squareName, 'verbose': true})
          .map<String>((move) => move['to'] as String)
          .toList();
    }

    setState(() {
      _dndDetails = _DragAndDropDetails(
        movedPiece: piece,
        startCell: (file, rank),
        position: (details.localPosition.dx, details.localPosition.dy),
      );
      // Clear tap selection when drag starts
      _tapStart = null;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final position = details.localPosition;
    final cellsSize = widget.size / 8;
    final col = position.dx ~/ cellsSize;
    final row = position.dy ~/ cellsSize;

    final file = widget.blackSideAtBottom ? 7 - col : col;
    final rank = widget.blackSideAtBottom ? row : 7 - row;

    setState(() {
      _dndDetails?.endCell = (file, rank);
      _dndDetails?.position =
          (details.localPosition.dx, details.localPosition.dy);
    });
  }

  Future<void> _handlePanEnd(DragEndDetails details) async {
    if (_dndDetails == null) return;
    final from = coordinatesToSquareName(
        _dndDetails!.startCell.$1, _dndDetails!.startCell.$2);
    final to = coordinatesToSquareName(
        _dndDetails!.endCell.$1, _dndDetails!.endCell.$2);
    final move = ShortMove(from: from, to: to);

    if (isPromoting(widget.fen, move)) {
      final selectedPiece = await widget.onPromote();
      if (selectedPiece != null) {
        widget.onPromotionCommited(
          moveDone: move,
          pieceType: selectedPiece,
        );
        Future.delayed(
          const Duration(milliseconds: 35),
          () => setState(
            () => _squares = getSquares(widget.fen),
          ),
        );
      }
      setState(() {
        _dndDetails = null;
        _possibleMoves = [];
      });
      return;
    }

    widget.processMove(move);
    setState(() {
      _dndDetails = null;
      _possibleMoves = [];
    });
    Future.delayed(
      const Duration(milliseconds: 35),
      () => setState(
        () => _squares = getSquares(widget.fen),
      ),
    );
  }

  void _handlePanCancel() {
    if (_dndDetails == null) return;
    setState(() {
      _dndDetails = null;
      _possibleMoves = [];
    });
  }

  void _handleTap(TapUpDetails details) async {
    final eventCoordinates = details.localPosition;

    final eventX = eventCoordinates.dx;
    final eventY = eventCoordinates.dy;

    final cellSize = widget.size / 8;

    final col = (eventX / cellSize).floor();
    final row = (eventY / cellSize).floor();

    final file = (widget.blackSideAtBottom) ? 7 - col : col;
    final rank = (widget.blackSideAtBottom) ? row : 7 - row;

    final cellCoordinate = "${String.fromCharCode('a'.codeUnitAt(0) + file)}"
        "${String.fromCharCode('1'.codeUnitAt(0) + rank)}";

    // Handle possible moves display on tap
    if (widget.showPossibleMoves && _isHumanTurn() && widget.isInteractive) {
      // Check if tapping on a possible move square (to make a move) FIRST
      if (_possibleMoves.contains(cellCoordinate) && _tapStart != null) {
        // Make the move
        final from = coordinatesToSquareName(_tapStart!.$1, _tapStart!.$2);
        final move = ShortMove(from: from, to: cellCoordinate);

        if (isPromoting(widget.fen, move)) {
          // Handle promotion
          final selectedPiece = await widget.onPromote();
          if (selectedPiece != null) {
            widget.onPromotionCommited(
              moveDone: move,
              pieceType: selectedPiece,
            );
          }
        } else {
          widget.processMove(move);
        }

        // Clear selection after move
        setState(() {
          _possibleMoves = [];
          _tapStart = null;
        });

        // Don't call onTap callback when making a move
        return;
      }

      final piece = _squares[cellCoordinate];

      if (piece != null) {
        final isWhiteTurn = widget.fen.split(" ")[1] == "w";
        final isPieceOfPlayerInTurn = isWhiteTurn
            ? piece.color == BoardColor.white
            : piece.color == BoardColor.black;

        if (isPieceOfPlayerInTurn) {
          // Check if this is the same piece that's already selected
          final currentlySelected = _tapStart != null &&
              _tapStart!.$1 == file &&
              _tapStart!.$2 == rank;

          if (currentlySelected) {
            // If same piece clicked again, clear selection
            setState(() {
              _possibleMoves = [];
              _tapStart = null;
            });
          } else {
            // Calculate and show possible moves for tapped piece
            final chessLogic = chess.Chess.fromFEN(widget.fen);
            final moves = chessLogic
                .moves({'square': cellCoordinate, 'verbose': true})
                .map<String>((move) => move['to'] as String)
                .toList();

            setState(() {
              _possibleMoves = moves;
              _tapStart = (file, rank);
            });
          }
        } else {
          // Clear possible moves if tapping on opponent's piece
          setState(() {
            _possibleMoves = [];
            _tapStart = null;
          });
        }
      } else {
        // Clear possible moves if tapping on empty square that's not a valid move
        setState(() {
          _possibleMoves = [];
          _tapStart = null;
        });
      }
    }

    widget.onTap(cellCoordinate: cellCoordinate);
  }

  bool _isHumanTurn() {
    final isWhiteTurn = widget.fen.split(' ')[1] == 'w';
    return (isWhiteTurn && widget.whitePlayerType == PlayerType.human) ||
        (!isWhiteTurn && widget.blackPlayerType == PlayerType.human);
  }

  @override
  Widget build(BuildContext context) {
    final boardWidget = GestureDetector(
      onTapUp: _handleTap,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onPanCancel: _handlePanCancel,
      child: Stack(
        children: [
          CustomPaint(
            painter: _ChessBoardPainter(
              colors: widget.boardColors,
              blackSideAtBottom: widget.blackSideAtBottom,
              squares: _squares,
              dragAndDropDetails: _dndDetails,
              tapStart: _tapStart,
              arrow: widget.arrow,
              cellHighlights: widget.cellHighlights,
              highlightLastMoveSquares: widget.highlightLastMoveSquares,
              possibleMoves: widget.showPossibleMoves ? _possibleMoves : [],
              hasCustomNormalIndicator:
                  widget.normalMoveIndicatorBuilder != null,
              hasCustomCaptureIndicator:
                  widget.captureMoveIndicatorBuilder != null,
            ),
            size: Size.square(widget.size),
          ),
          if (widget.showPossibleMoves) ..._buildPossibleMoveIndicators(),
        ],
      ),
    );

    // If not interactive, wrap with visual feedback
    if (!widget.isInteractive) {
      final overlayColor = widget.nonInteractiveOverlayColor ?? Colors.orange;
      final textStyle = widget.nonInteractiveTextStyle ??
          const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          );

      return Stack(
        children: [
          Opacity(
            opacity: 0.6,
            child: boardWidget,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: overlayColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: overlayColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.nonInteractiveText,
                    style: textStyle,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return boardWidget;
  }

  List<Widget> _buildPossibleMoveIndicators() {
    if (_possibleMoves.isEmpty) return [];

    final cellSize = widget.size / 8;
    final widgets = <Widget>[];

    for (final moveSquare in _possibleMoves) {
      // Parse square name (e.g., "e4" -> file: 4, rank: 3)
      final file = moveSquare.codeUnitAt(0) - 'a'.codeUnitAt(0);
      final rank = int.parse(moveSquare[1]) - 1;

      final col = widget.blackSideAtBottom ? 7 - file : file;
      final row = widget.blackSideAtBottom ? rank : 7 - rank;

      // Check if there's a piece on this square
      final piece = _squares[moveSquare];
      final isCapture = piece != null;

      Widget? indicator;

      if (isCapture && widget.captureMoveIndicatorBuilder != null) {
        indicator = widget.captureMoveIndicatorBuilder!(cellSize);
      } else if (!isCapture && widget.normalMoveIndicatorBuilder != null) {
        indicator = widget.normalMoveIndicatorBuilder!(cellSize);
      }

      if (indicator != null) {
        widgets.add(
          Positioned(
            left: col * cellSize,
            top: row * cellSize,
            width: cellSize,
            height: cellSize,
            child: indicator,
          ),
        );
      }
    }

    return widgets;
  }
}

Map<String, Piece?> getSquares(String fen) {
  final boardLogic = chess.Chess.fromFEN(
    fen,
    check_validity: false,
  );
  final result = <String, Piece?>{};
  for (final squareName in chess.Chess.SQUARES.keys) {
    final tempValue = boardLogic.get(squareName);
    if (tempValue == null) {
      result[squareName] = null;
    } else {
      result[squareName] = Piece(
        tempValue.color == chess.Color.WHITE
            ? BoardColor.white
            : BoardColor.black,
        PieceType.fromString(tempValue.type.toString()),
      );
    }
  }
  return result;
}

String coordinatesToSquareName(int file, int rank) {
  return String.fromCharCode('a'.codeUnitAt(0) + file) +
      String.fromCharCode('1'.codeUnitAt(0) + rank);
}

class _ChessBoardPainter extends CustomPainter {
  final ChessBoardColors colors;
  final bool blackSideAtBottom;
  final Map<String, Piece?> squares;
  final _DragAndDropDetails? dragAndDropDetails;
  final (int, int)? tapStart;
  final BoardArrow? arrow;
  final Map<String, Color> cellHighlights;
  final bool highlightLastMoveSquares;
  final List<String> possibleMoves;
  final bool hasCustomNormalIndicator;
  final bool hasCustomCaptureIndicator;

  _ChessBoardPainter({
    required this.colors,
    required this.blackSideAtBottom,
    required this.squares,
    required this.tapStart,
    required this.dragAndDropDetails,
    required this.arrow,
    required this.cellHighlights,
    required this.highlightLastMoveSquares,
    required this.possibleMoves,
    required this.hasCustomNormalIndicator,
    required this.hasCustomCaptureIndicator,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawCells(canvas, size);
    _drawPossibleMoves(canvas, size);
    _drawPieces(canvas, size);
    _drawLastMoveArrow(canvas, size);
    _drawMovedPiece(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..color = colors.coordinatesZoneColor;
    canvas.drawRect(rect, paint);
  }

  void _drawCells(Canvas canvas, Size size) {
    final cellSize = size.shortestSide / 8;
    for (final row in [0, 1, 2, 3, 4, 5, 6, 7]) {
      for (final col in [0, 1, 2, 3, 4, 5, 6, 7]) {
        final file = blackSideAtBottom ? 7 - col : col;
        final rank = blackSideAtBottom ? row : 7 - row;

        final isWhiteCell = (col + row) % 2 == 0;

        final rect = Rect.fromLTWH(
          cellSize * col,
          cellSize * row,
          cellSize,
          cellSize,
        );

        final cellCoord = "${String.fromCharCode('a'.codeUnitAt(0) + file)}"
            "${String.fromCharCode('1'.codeUnitAt(0) + rank)}";

        final paint = Paint()
          ..color =
              isWhiteCell ? colors.lightSquaresColor : colors.darkSquaresColor;
        final highlightColor = cellHighlights[cellCoord];
        final isStartSquare = dragAndDropDetails != null &&
            dragAndDropDetails?.startCell.$1 == file &&
            dragAndDropDetails?.startCell.$2 == rank;
        final isEndSquare = dragAndDropDetails != null &&
            dragAndDropDetails?.endCell.$1 == file &&
            dragAndDropDetails?.endCell.$2 == rank;
        final isTapStartCell = tapStart?.$1 == file && tapStart?.$2 == rank;

        // Check if this square is the start or end of the last move arrow
        final isLastMoveStartSquare = highlightLastMoveSquares &&
            arrow != null &&
            cellCoord == arrow!.from;
        final isLastMoveEndSquare =
            highlightLastMoveSquares && arrow != null && cellCoord == arrow!.to;

        if (colors.dndIndicatorColor != null) {
          final isDndIndicatorSquare = dragAndDropDetails != null &&
              (dragAndDropDetails?.endCell.$1 == file ||
                  dragAndDropDetails?.endCell.$2 == rank);
          if (isDndIndicatorSquare) paint.color = colors.dndIndicatorColor!;
        }

        if (isStartSquare || isLastMoveStartSquare) {
          paint.color = colors.startSquareColor;
        }
        if (isEndSquare || isLastMoveEndSquare) {
          paint.color = colors.endSquareColor;
        }
        if (isTapStartCell) paint.color = colors.startSquareColor;

        canvas.drawRect(rect, paint);
        if (highlightColor != null) {
          canvas.drawRect(rect, Paint()..color = highlightColor);
        }
      }
    }
  }

  void _drawLastMoveArrow(Canvas canvas, Size size) {
    if (arrow == null) return;

    final blockSize = size.width / 8;
    final halfBlockSize = blockSize / 2;
    final arrowMultiplier = blockSize * 0.1;

    final startFile = files.indexOf(arrow!.from[0]);
    final startRank = int.parse(arrow!.from[1]) - 1;
    final endFile = files.indexOf(arrow!.to[0]);
    final endRank = int.parse(arrow!.to[1]) - 1;

    int effectiveRowStart = 0;
    int effectiveColumnStart = 0;
    int effectiveRowEnd = 0;
    int effectiveColumnEnd = 0;

    if (blackSideAtBottom) {
      effectiveColumnStart = 7 - startFile;
      effectiveColumnEnd = 7 - endFile;
      effectiveRowStart = startRank;
      effectiveRowEnd = endRank;
    } else {
      effectiveColumnStart = startFile;
      effectiveColumnEnd = endFile;
      effectiveRowStart = 7 - startRank;
      effectiveRowEnd = 7 - endRank;
    }

    final startOffset = Offset(
        ((effectiveColumnStart + 1) * blockSize) - halfBlockSize,
        ((effectiveRowStart + 1) * blockSize) - halfBlockSize);
    final endOffset = Offset(
        ((effectiveColumnEnd + 1) * blockSize) - halfBlockSize,
        ((effectiveRowEnd + 1) * blockSize) - halfBlockSize);

    final yDist = endOffset.dy - startOffset.dy;
    final xDist = endOffset.dx - startOffset.dx;

    final paint = Paint()
      ..strokeWidth = halfBlockSize * 0.150
      ..color = colors.lastMoveArrowColor;

    canvas.drawLine(startOffset,
        Offset(startOffset.dx + xDist, startOffset.dy + yDist), paint);

    var arrowPoint = endOffset;
    double arrowLength = sqrt(
      pow((startOffset.dx - endOffset.dx).abs(), 2) +
          pow((startOffset.dy - endOffset.dy).abs(), 2),
    );
    double arrowAngle = atan2(
      (startOffset.dy - endOffset.dy).abs(),
      (startOffset.dx - endOffset.dx).abs(),
    );

    double pointX, pointY;
    if (startOffset.dx > endOffset.dx) {
      pointX = startOffset.dx -
          (cos(arrowAngle) * (arrowLength - (3 * arrowMultiplier)));
    } else {
      pointX = cos(arrowAngle) * (arrowLength - (3 * arrowMultiplier)) +
          startOffset.dx;
    }

    if (startOffset.dy > endOffset.dy) {
      pointY = startOffset.dy -
          (sin(arrowAngle) * (arrowLength - (3 * arrowMultiplier)));
    } else {
      pointY = (sin(arrowAngle) * (arrowLength - (3 * arrowMultiplier))) +
          startOffset.dy;
    }

    Offset arrowPointBack = Offset(pointX, pointY);

    double angleB =
        atan2((3 * arrowMultiplier), (arrowLength - (3 * arrowMultiplier)));

    double angleC =
        pi * (90 - (arrowAngle * (180 / pi)) - (angleB * (180 / pi))) / 180;

    double secondaryLength = (3 * arrowMultiplier) / sin(angleB);

    if (startOffset.dx > endOffset.dx) {
      pointX = startOffset.dx - (sin(angleC) * secondaryLength);
    } else {
      pointX = (sin(angleC) * secondaryLength) + startOffset.dx;
    }

    if (startOffset.dy > endOffset.dy) {
      pointY = startOffset.dy - (cos(angleC) * secondaryLength);
    } else {
      pointY = (cos(angleC) * secondaryLength) + startOffset.dy;
    }

    Offset arrowPointLeft = Offset(pointX, pointY);
    angleC = arrowAngle - angleB;

    if (startOffset.dx > endOffset.dx) {
      pointX = startOffset.dx - (cos(angleC) * secondaryLength);
    } else {
      pointX = (cos(angleC) * secondaryLength) + startOffset.dx;
    }

    if (startOffset.dy > endOffset.dy) {
      pointY = startOffset.dy - (sin(angleC) * secondaryLength);
    } else {
      pointY = (sin(angleC) * secondaryLength) + startOffset.dy;
    }

    Offset arrowPointRight = Offset(pointX, pointY);

    Path path = Path();
    path.moveTo(arrowPoint.dx, arrowPoint.dy);
    path.lineTo(arrowPointLeft.dx, arrowPointLeft.dy);
    path.lineTo(arrowPointBack.dx, arrowPointBack.dy);
    path.lineTo(arrowPointRight.dx, arrowPointRight.dy);

    canvas.drawPath(
      path,
      paint..style = PaintingStyle.fill,
    );
  }

  void _drawPieces(Canvas canvas, Size size) {
    final cellSize = size.shortestSide / 8;

    for (final row in [0, 1, 2, 3, 4, 5, 6, 7]) {
      for (final col in [0, 1, 2, 3, 4, 5, 6, 7]) {
        final file = blackSideAtBottom ? 7 - col : col;
        final rank = blackSideAtBottom ? row : 7 - row;

        final isTheMovedPiece = dragAndDropDetails != null &&
            dragAndDropDetails?.startCell.$1 == file &&
            dragAndDropDetails?.startCell.$2 == rank;
        if (isTheMovedPiece) continue;

        final squareName = coordinatesToSquareName(file, rank);
        final piece = squares[squareName];

        if (piece == null) continue;
        final pieceDefinition = piecesDefinition[piece.name];
        if (pieceDefinition == null) continue;

        final offset = Offset(cellSize * col, cellSize * row);

        canvas.save();

        canvas.translate(offset.dx, offset.dy);
        canvas.scale(cellSize / baseImageSize, cellSize / baseImageSize);

        for (var vectorElement in pieceDefinition) {
          vectorElement.paintIntoCanvas(
              canvas, vectorElement.drawingParameters);
        }

        canvas.restore();
      }
    }
  }

  void _drawMovedPiece(Canvas canvas, Size size) {
    final cellSize = size.shortestSide / 8;

    final pieceDefinition =
        piecesDefinition[dragAndDropDetails?.movedPiece.name];
    if (pieceDefinition == null) return;

    final offset = Offset(
      dragAndDropDetails?.position.$1 ?? -cellSize,
      dragAndDropDetails?.position.$2 ?? -cellSize,
    );

    canvas.save();

    canvas.translate(offset.dx, offset.dy);
    canvas.scale(cellSize / baseImageSize, cellSize / baseImageSize);

    for (var vectorElement in pieceDefinition) {
      vectorElement.paintIntoCanvas(canvas, vectorElement.drawingParameters);
    }

    canvas.restore();
  }

  void _drawPossibleMoves(Canvas canvas, Size size) {
    if (possibleMoves.isEmpty) return;

    final cellSize = size.shortestSide / 8;

    for (final moveSquare in possibleMoves) {
      // Parse square name (e.g., "e4" -> file: 4, rank: 3)
      final file = moveSquare.codeUnitAt(0) - 'a'.codeUnitAt(0);
      final rank = int.parse(moveSquare[1]) - 1;

      final col = blackSideAtBottom ? 7 - file : file;
      final row = blackSideAtBottom ? rank : 7 - rank;

      final centerX = (col + 0.5) * cellSize;
      final centerY = (row + 0.5) * cellSize;

      // Check if there's a piece on this square
      final piece = squares[moveSquare];

      if (piece != null) {
        // Skip capture moves if custom capture indicator is provided
        if (hasCustomCaptureIndicator) continue;

        // If there's a piece (capture move), draw a gradient overlay
        final rect = Rect.fromLTWH(
          col * cellSize,
          row * cellSize,
          cellSize,
          cellSize,
        );

        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.possibleMovesColor.withAlpha(0),
            colors.possibleMovesColor,
          ],
        );

        final gradientPaint = Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.fill;

        canvas.drawRect(rect, gradientPaint);
      } else {
        // Skip normal moves if custom normal indicator is provided
        if (hasCustomNormalIndicator) continue;

        // If no piece (normal move), draw a hollow circle
        final circleRadius = cellSize * 0.15;
        final strokeWidth = cellSize * 0.08;

        final hollowPaint = Paint()
          ..color = colors.possibleMovesColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

        canvas.drawCircle(Offset(centerX, centerY), circleRadius, hollowPaint);
      }
    }
  }
}

/*
Adapted from https://www.codeproject.com/Questions/125049/Draw-an-arrow-with-big-cap */
const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
