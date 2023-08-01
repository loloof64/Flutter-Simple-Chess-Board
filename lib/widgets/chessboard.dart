library flutter_chessboard;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
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

  /// The color of the drag and drop indicator's cells.
  Color dndIndicatorColor = Colors.purple;

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

  /// Handler for when user wants to make a promotion on board.
  final Future<PieceType?> Function() onPromote;

  /// Handler for when a promotion has been commited on the board.
  final void Function({
    required ShortMove moveDone,
    required PieceType pieceType,
  }) onPromotionCommited;

  /// Does the border with coordinates and player turn must be visible ?
  final bool showCoordinatesZone;

  /// Last move arrow.
  final BoardArrow? lastMoveToHighlight;

  /// Must a circular progress bar be visible above of the board ?
  final bool engineThinking;

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
    Key? key,
    required this.fen,
    this.blackSideAtBottom = false,
    required this.whitePlayerType,
    required this.blackPlayerType,
    required this.onMove,
    required this.onPromote,
    required this.onPromotionCommited,
    required this.chessBoardColors,
    this.engineThinking = false,
    this.showCoordinatesZone = true,
    this.lastMoveToHighlight,
  }) : super(key: key);

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
        final isWhiteTurn = fen.split(' ')[1] == 'w';
        final humanTurn =
            (isWhiteTurn && whitePlayerType == PlayerType.human) ||
                (!isWhiteTurn && blackPlayerType == PlayerType.human);
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
              onPromote: onPromote,
              onPromotionCommited: onPromotionCommited,
              arrow: (lastMoveToHighlight != null)
                  ? BoardArrow(
                      from: lastMoveToHighlight!.from,
                      to: lastMoveToHighlight!.to,
                    )
                  : null,
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
            if (!humanTurn)
              SizedBox(
                width: size,
                height: size,
                child: const Text(''),
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

  const _PlayerTurn({Key? key, required this.size, required this.whiteTurn})
      : super(key: key);

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
  final double size;
  final bool blackSideAtBottom;
  final String fen;
  final BoardArrow? arrow;
  final void Function(ShortMove move) processMove;
  final Future<PieceType?> Function() onPromote;
  final void Function({
    required ShortMove moveDone,
    required PieceType pieceType,
  }) onPromotionCommited;

  const _Chessboard({
    required this.fen,
    required this.size,
    required this.boardColors,
    required this.blackSideAtBottom,
    required this.processMove,
    required this.arrow,
    required this.onPromote,
    required this.onPromotionCommited,
  });

  @override
  State<StatefulWidget> createState() => _ChessboardState();
}

class _ChessboardState extends State<_Chessboard> {
  _DragAndDropDetails? _dndDetails;
  (int, int)? _tapStart;
  Map<String, Piece?> _squares = <String, Piece?>{};

  @override
  void initState() {
    _squares = getSquares(widget.fen);
    super.initState();
  }

  @override
  void didUpdateWidget(_Chessboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _squares = getSquares(widget.fen);
    });
  }

  Future<void> _handleTapDown(TapDownDetails details) async {
    final position = details.localPosition;
    final cellsSize = widget.size / 8;
    final col = position.dx ~/ cellsSize;
    final row = position.dy ~/ cellsSize;

    final file = widget.blackSideAtBottom ? 7 - col : col;
    final rank = widget.blackSideAtBottom ? row : 7 - row;

    if (_tapStart == null) {
      final squareName = coordinatesToSquareName(file, rank);
      final piece = _squares[squareName];

      if (piece == null) return;

      final isWhiteTurn = widget.fen.split(" ")[1] == "w";

      final isNotAPieceOfPlayerInTurn = isWhiteTurn
          ? piece.color == BoardColor.black
          : piece.color == BoardColor.white;

      if (isNotAPieceOfPlayerInTurn) return;
      setState(() {
        _tapStart = (file, rank);
      });
    } else {
      final from = coordinatesToSquareName(_tapStart!.$1, _tapStart!.$2);
      final to = coordinatesToSquareName(file, rank);
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
          _tapStart = null;
        });
      } else {
        widget.processMove(move);
        setState(() {
          _tapStart = null;
        });
        Future.delayed(
          const Duration(milliseconds: 35),
          () => setState(
            () => _squares = getSquares(widget.fen),
          ),
        );
      }
    }
  }

  void _handlePanStart(DragStartDetails details) {
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

    setState(() {
      _dndDetails = _DragAndDropDetails(
        movedPiece: piece,
        startCell: (file, rank),
        position: (details.localPosition.dx, details.localPosition.dy),
      );
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
      });
      return;
    }

    widget.processMove(move);
    setState(() {
      _dndDetails = null;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onPanCancel: _handlePanCancel,
      child: CustomPaint(
        painter: _ChessBoardPainter(
          colors: widget.boardColors,
          blackSideAtBottom: widget.blackSideAtBottom,
          squares: _squares,
          dragAndDropDetails: _dndDetails,
          tapStart: _tapStart,
          arrow: widget.arrow,
        ),
        size: Size.square(widget.size),
        isComplex: true,
        willChange: true,
      ),
    );
  }
}

Map<String, Piece?> getSquares(String fen) {
  final boardLogic = chess.Chess.fromFEN(fen);
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

  _ChessBoardPainter({
    required this.colors,
    required this.blackSideAtBottom,
    required this.squares,
    required this.tapStart,
    required this.dragAndDropDetails,
    required this.arrow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawCells(canvas, size);
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

        final paint = Paint()
          ..color =
              isWhiteCell ? colors.lightSquaresColor : colors.darkSquaresColor;
        final isStartSquare = dragAndDropDetails != null &&
            dragAndDropDetails?.startCell.$1 == file &&
            dragAndDropDetails?.startCell.$2 == rank;
        final isEndSquare = dragAndDropDetails != null &&
            dragAndDropDetails?.endCell.$1 == file &&
            dragAndDropDetails?.endCell.$2 == rank;
        final isDndIndicatorSquare = dragAndDropDetails != null &&
                dragAndDropDetails?.endCell.$1 == file ||
            dragAndDropDetails?.endCell.$2 == rank;
        final isTapStartCell = tapStart?.$1 == file && tapStart?.$2 == rank;

        if (isDndIndicatorSquare) paint.color = colors.dndIndicatorColor;
        if (isStartSquare) paint.color = colors.startSquareColor;
        if (isEndSquare) paint.color = colors.endSquareColor;
        if (isTapStartCell) paint.color = colors.startSquareColor;

        canvas.drawRect(rect, paint);
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
}

/*
Adapted from https://www.codeproject.com/Questions/125049/Draw-an-arrow-with-big-cap */
const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
