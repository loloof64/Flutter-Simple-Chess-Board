import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chesslib;
import 'package:simple_chess_board/simple_chess_board.dart';

class BoardWithSound extends StatefulWidget {
  const BoardWithSound({super.key});

  @override
  State<BoardWithSound> createState() => _BoardWithSoundState();
}

class _BoardWithSoundState extends State<BoardWithSound> {
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
    final navigator = Navigator.of(context);
    return showDialog<PieceType>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Promotion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Queen"),
                onTap: () => navigator.pop(PieceType.queen),
              ),
              ListTile(
                title: const Text("Rook"),
                onTap: () => navigator.pop(PieceType.rook),
              ),
              ListTile(
                title: const Text("Bishop"),
                onTap: () => navigator.pop(PieceType.bishop),
              ),
              ListTile(
                title: const Text("Knight"),
                onTap: () => navigator.pop(PieceType.knight),
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
        title: Text("Sound example"),
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
            Expanded(
              child: SimpleChessBoard(
                chessBoardColors: ChessBoardColors()
                  ..lightSquaresColor = Colors.blue.shade200
                  ..darkSquaresColor = Colors.blue.shade600
                  ..coordinatesZoneColor = Colors.redAccent.shade200
                  ..lastMoveArrowColor = Colors.cyan
                  ..startSquareColor = Colors.orange
                  ..endSquareColor = Colors.green
                  ..circularProgressBarColor = Colors.red
                  ..coordinatesColor = Colors.green,
                engineThinking: false,
                fen: _chess.fen,
                onMove: tryMakingMove,
                blackSideAtBottom: _blackAtBottom,
                whitePlayerType: PlayerType.human,
                blackPlayerType: PlayerType.human,
                lastMoveToHighlight: _lastMoveArrowCoordinates,
                cellHighlights: _highlightCells,
                playSounds: true,
                onPromote: () => handlePromotion(context),
                onPromotionCommited: ({
                  required ShortMove moveDone,
                  required PieceType pieceType,
                }) {
                  moveDone.promotion = pieceType;
                  tryMakingMove(move: moveDone);
                },
                onTap: ({required String cellCoordinate}) {
                  if (_highlightCells[cellCoordinate] == null) {
                    _highlightCells[cellCoordinate] = Colors.red.withAlpha(70);
                    setState(() {});
                  } else {
                    _highlightCells.remove(cellCoordinate);
                    setState(() {});
                  }
                },
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
