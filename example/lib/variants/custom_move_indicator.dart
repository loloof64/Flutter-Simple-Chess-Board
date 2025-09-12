import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chesslib;
import 'package:simple_chess_board/simple_chess_board.dart';

class CustomMoveIndicator extends StatefulWidget {
  const CustomMoveIndicator({super.key});

  @override
  State<CustomMoveIndicator> createState() => _CustomMoveIndicatorState();
}

class _CustomMoveIndicatorState extends State<CustomMoveIndicator> {
  final _chess = chesslib.Chess.fromFEN(chesslib.Chess.DEFAULT_POSITION);
  var _blackAtBottom = false;
  BoardArrow? _lastMoveArrowCoordinates;
  final _highlightCells = <String, Color>{};

  void tryMakingMove({required ShortMove move}) {
    final success = _chess.move(<String, String?>{
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion?.name,
    });
    if (success) {
      setState(() {
        _lastMoveArrowCoordinates = BoardArrow(from: move.from, to: move.to);
      });
    }
  }

  Future<PieceType?> handlePromotion(BuildContext context) {
    return showDialog<PieceType>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Promotion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Queen"),
                onTap: () => Navigator.of(context).pop(PieceType.queen),
              ),
              ListTile(
                title: const Text("Rook"),
                onTap: () => Navigator.of(context).pop(PieceType.rook),
              ),
              ListTile(
                title: const Text("Bishop"),
                onTap: () => Navigator.of(context).pop(PieceType.bishop),
              ),
              ListTile(
                title: const Text("Knight"),
                onTap: () => Navigator.of(context).pop(PieceType.knight),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("With custom move indicator"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _blackAtBottom = !_blackAtBottom;
              });
            },
            icon: const Icon(Icons.swap_vert),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: SimpleChessBoard(
                engineThinking: false,
                fen: _chess.fen,
                onMove: tryMakingMove,
                blackSideAtBottom: _blackAtBottom,
                whitePlayerType: PlayerType.human,
                blackPlayerType: PlayerType.human,
                showPossibleMoves: true,
                // Custom widget for normal moves (empty squares)
                normalMoveIndicatorBuilder: (cellSize) => SizedBox(
                  width: cellSize,
                  height: cellSize,
                  child: Center(
                    child: Container(
                      width: cellSize * 0.3,
                      height: cellSize * 0.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                // Custom widget for capture moves (squares with opponent pieces)
                captureMoveIndicatorBuilder: (cellSize) => Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: cellSize * 0.05,
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: cellSize * 0.5,
                  ),
                ),
                onPromote: () => handlePromotion(context),
                cellHighlights: _highlightCells,
                chessBoardColors: ChessBoardColors(),
                onPromotionCommited: ({required moveDone, required pieceType}) {
                  moveDone.promotion = pieceType;
                  tryMakingMove(move: moveDone);
                },
                onTap: ({required cellCoordinate}) {},
                highlightLastMoveSquares: true,
                lastMoveToHighlight: _lastMoveArrowCoordinates,
                showCoordinatesZone: false,
              ),
            ),
            Text("Click on a cell in order to (un)highlight it."
                " You can also drag and drop pieces")
          ],
        ),
      ),
    );
  }
}
