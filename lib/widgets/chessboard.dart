library flutter_chessboard;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Option;
import 'package:provider/provider.dart';
import '../models/piece_type.dart';
import '../models/board.dart';
import '../models/board_arrow.dart';
import '../models/board_color.dart';
import '../models/half_move.dart';
import '../models/piece.dart';
import '../models/short_move.dart';
import '../models/square.dart';
import '../utils.dart';
import '../widgets/ui_square.dart';

enum PlayerType {
  human,
  computer,
}

class SimpleChessBoard extends StatelessWidget {
  final String fen;
  final void Function({required ShortMove move}) onMove;
  final BoardColor orientation;
  final BoardArrow? lastMoveToHighlight;
  final PlayerType whitePlayerType;
  final PlayerType blackPlayerType;
  final Future<PieceType?> Function() onPromote;
  final bool showCoordinatesZone;
  final bool engineThinking;

  bool currentPlayerIsHuman() {
    final whiteTurn = fen.split(' ')[1] == 'w';
    return (whitePlayerType == PlayerType.human && whiteTurn) ||
        (blackPlayerType == PlayerType.human && !whiteTurn);
  }

  const SimpleChessBoard({
    Key? key,
    required this.fen,
    required this.onMove,
    required this.orientation,
    required this.whitePlayerType,
    required this.blackPlayerType,
    required this.onPromote,
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
      child: _PlayerTurn(size: size * 0.05, whiteTurn: isWhiteTurn),
      bottom: size * 0.001,
      right: size * 0.001,
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
                    color: Colors.indigo.shade300,
                    width: size,
                    height: size,
                    child: Stack(
                      children: [
                        ...getFilesCoordinates(
                          boardSize: size,
                          top: true,
                          reversed: orientation == BoardColor.black,
                        ),
                        ...getFilesCoordinates(
                          boardSize: size,
                          top: false,
                          reversed: orientation == BoardColor.black,
                        ),
                        ...getRanksCoordinates(
                          boardSize: size,
                          left: true,
                          reversed: orientation == BoardColor.black,
                        ),
                        ...getRanksCoordinates(
                          boardSize: size,
                          left: false,
                          reversed: orientation == BoardColor.black,
                        ),
                        _buildPlayerTurn(size: size),
                      ],
                    ),
                  )
                : Container(),
            _Chessboard(
              fen: fen,
              size: size * boardSizeProportion,
              onMove: _processMove,
              onPromote: onPromote,
              orientation: orientation,
              lastMoveHighlightColor: Colors.indigoAccent.shade200,
              selectionHighlightColor: Colors.greenAccent,
              arrows: <BoardArrow>[
                if (lastMoveToHighlight != null)
                  BoardArrow(
                      from: lastMoveToHighlight!.from,
                      to: lastMoveToHighlight!.to,
                      color: lastMoveToHighlight!.color)
              ],
            ),
            if (engineThinking)
              SizedBox(
                width: size * boardSizeProportion,
                height: size * boardSizeProportion,
                child: const CircularProgressIndicator(
                  backgroundColor: Colors.teal,
                  strokeWidth: 8,
                ),
              )
          ],
        );
      }),
    );
  }
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
}) {
  final commonTextStyle = TextStyle(
    color: Colors.yellow.shade400,
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
}) {
  final commonTextStyle = TextStyle(
    color: Colors.yellow.shade400,
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
  final Board board;

  _Chessboard({
    required String fen,
    required double size,
    BoardColor orientation = BoardColor.white,
    Color lightSquareColor = const Color.fromRGBO(240, 217, 181, 1),
    Color darkSquareColor = const Color.fromRGBO(181, 136, 99, 1),
    Moved onMove = noop1,
    Promoted onPromote = defaultPromoting,
    BuildPiece? buildPiece,
    BuildSquare? buildSquare,
    BuildCustomPiece? buildCustomPiece,
    Color lastMoveHighlightColor = const Color.fromRGBO(128, 128, 128, .3),
    Color selectionHighlightColor = const Color.fromRGBO(128, 128, 128, .3),
    List<String> lastMove = const [],
    List<BoardArrow> arrows = const [],
  }) : board = Board(
          fen: fen,
          size: size,
          orientation: orientation,
          onMove: onMove,
          lightSquareColor: lightSquareColor,
          darkSquareColor: darkSquareColor,
          onPromote: onPromote,
          buildPiece: buildPiece,
          buildSquare: buildSquare,
          buildCustomPiece: buildCustomPiece,
          lastMove: lastMove,
          lastMoveHighlightColor: lastMoveHighlightColor,
          selectionHighlightColor: selectionHighlightColor,
          arrows: arrows,
        );

  @override
  State<StatefulWidget> createState() => _ChessboardState();
}

class _ChessboardState extends State<_Chessboard> {
  Option<HalfMove> clickMove = Option.none();

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: widget.board,
      child: SizedBox(
        width: widget.board.size,
        height: widget.board.size,
        child: Stack(
            alignment: AlignmentDirectional.topStart,
            textDirection: TextDirection.ltr,
            children: [
              ...widget.board.squares.map((it) {
                return UISquare(
                  square: it,
                  onClick: _handleClick,
                  onDrop: _handleDrop,
                  highlight: _getHighlight(it),
                );
              }).toList(growable: false),
              if (widget.board.arrows.isNotEmpty)
                IgnorePointer(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CustomPaint(
                      child: Container(),
                      painter: _ArrowPainter(
                          widget.board.arrows, widget.board.orientation),
                    ),
                  ),
                ),
            ]),
      ),
    );
  }

  Color? _getHighlight(Square square) {
    return clickMove
        .filter((t) => t.square == square.name)
        .map((_) => widget.board.selectionHighlightColor)
        .alt(() => Option.fromPredicate(
              widget.board.lastMoveHighlightColor,
              (_) => widget.board.lastMove.contains(square.name),
            ))
        .toNullable();
  }

  void _handleDrop(ShortMove move) {
    widget.board.makeMove(move).then((_) {
      _clearClickMove();
    });
  }

  void _handleClick(HalfMove halfMove) {
    clickMove.match(
      (t) {
        final sameSquare = t.square == halfMove.square;
        final sameColorPiece = t.piece
            .map2<Piece, bool>(halfMove.piece, (t, r) => t.color == r.color)
            .getOrElse(() => false);

        if (sameSquare) {
          _clearClickMove();
        } else if (sameColorPiece) {
          _setClickMove(halfMove);
        } else {
          widget.board.makeMove(ShortMove(
            from: t.square,
            to: halfMove.square,
          ));
          _clearClickMove();
        }
      },
      () => _setClickMove(halfMove),
    );
  }

  void _setClickMove(HalfMove halfMove) {
    setState(() {
      clickMove = Option.of(halfMove).flatMap((t) => t.piece.map((_) => t));
    });
  }

  void _clearClickMove() {
    setState(() {
      clickMove = Option.none();
    });
  }
}

/*
Adapted from https://github.com/deven98/flutter_chess_board/blob/97fe52c9a0c706b455b2162df55b050eb92ff70e/lib/src/chess_board.dart
*/
const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

class _ArrowPainter extends CustomPainter {
  List<BoardArrow> arrows;
  BoardColor orientation;

  _ArrowPainter(this.arrows, this.orientation);

  @override
  void paint(Canvas canvas, Size size) {
    var blockSize = size.width / 8;
    var halfBlockSize = size.width / 16;

    const baseArrowLengthProportion = 0.6;

    for (var arrow in arrows) {
      var startFile = files.indexOf(arrow.from[0]);
      var startRank = int.parse(arrow.from[1]) - 1;
      var endFile = files.indexOf(arrow.to[0]);
      var endRank = int.parse(arrow.to[1]) - 1;

      int effectiveRowStart = 0;
      int effectiveColumnStart = 0;
      int effectiveRowEnd = 0;
      int effectiveColumnEnd = 0;

      if (orientation == BoardColor.black) {
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

      var startOffset = Offset(
          ((effectiveColumnStart + 1) * blockSize) - halfBlockSize,
          ((effectiveRowStart + 1) * blockSize) - halfBlockSize);
      var endOffset = Offset(
          ((effectiveColumnEnd + 1) * blockSize) - halfBlockSize,
          ((effectiveRowEnd + 1) * blockSize) - halfBlockSize);

      var yDist = baseArrowLengthProportion * (endOffset.dy - startOffset.dy);
      var xDist = baseArrowLengthProportion * (endOffset.dx - startOffset.dx);

      var paint = Paint()
        ..strokeWidth = halfBlockSize * baseArrowLengthProportion
        ..color = arrow.color;

      canvas.drawLine(startOffset,
          Offset(startOffset.dx + xDist, startOffset.dy + yDist), paint);

      var slope =
          (endOffset.dy - startOffset.dy) / (endOffset.dx - startOffset.dx);

      var newLineSlope = -1 / slope;

      var points = _getNewPoints(
          Offset(startOffset.dx + xDist, startOffset.dy + yDist),
          newLineSlope,
          halfBlockSize);
      var newPoint1 = points[0];
      var newPoint2 = points[1];

      var path = Path();

      path.moveTo(endOffset.dx, endOffset.dy);
      path.lineTo(newPoint1.dx, newPoint1.dy);
      path.lineTo(newPoint2.dx, newPoint2.dy);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  List<Offset> _getNewPoints(Offset start, double slope, double length) {
    if (slope == double.infinity || slope == double.negativeInfinity) {
      return [
        Offset(start.dx, start.dy + length),
        Offset(start.dx, start.dy - length)
      ];
    }

    return [
      Offset(start.dx + (length / sqrt(1 + (slope * slope))),
          start.dy + ((length * slope) / sqrt(1 + (slope * slope)))),
      Offset(start.dx - (length / sqrt(1 + (slope * slope))),
          start.dy - ((length * slope) / sqrt(1 + (slope * slope)))),
    ];
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return arrows != oldDelegate.arrows;
  }
}
