import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chesslib;
import 'package:simple_chess_board/simple_chess_board.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

class HandlingPromotionsBoard extends StatefulWidget {
  const HandlingPromotionsBoard({super.key});

  @override
  State<HandlingPromotionsBoard> createState() =>
      _HandlingPromotionsBoardState();
}

class _HandlingPromotionsBoardState extends State<HandlingPromotionsBoard> {
  final _chess = chesslib.Chess.fromFEN('1k6/p2KP3/1p6/8/4B3/8/8/8 w - - 0 1');
  final _highlightCells = <String, Color>{};

  void tryMakingMove({required ShortMove move}) {
    final success = _chess.move(<String, String?>{
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion?.name,
    });
    if (success) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Handling promotions"),
      ),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: SimpleChessBoard(
            engineThinking: false,
            fen: _chess.fen,
            onMove: ({required ShortMove move}) {
              debugPrint('${move.from}|${move.to}|${move.promotion}');
            },
            blackSideAtBottom: false,
            whitePlayerType: PlayerType.human,
            blackPlayerType: PlayerType.computer,
            lastMoveToHighlight: null,
            onPromote: () {
              return showDialog<PieceType>(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text('Promotion'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          child: _chess.turn == chesslib.Color.WHITE
                              ? WhiteQueen(
                                  size: 60,
                                )
                              : BlackQueen(
                                  size: 60,
                                ),
                          onTap: () =>
                              Navigator.of(context).pop(PieceType.queen),
                        ),
                        InkWell(
                          child: _chess.turn == chesslib.Color.WHITE
                              ? WhiteRook(
                                  size: 60,
                                )
                              : BlackRook(
                                  size: 60,
                                ),
                          onTap: () =>
                              Navigator.of(context).pop(PieceType.rook),
                        ),
                        InkWell(
                          child: _chess.turn == chesslib.Color.WHITE
                              ? WhiteBishop(
                                  size: 60,
                                )
                              : BlackBishop(
                                  size: 60,
                                ),
                          onTap: () =>
                              Navigator.of(context).pop(PieceType.bishop),
                        ),
                        InkWell(
                          child: _chess.turn == chesslib.Color.WHITE
                              ? WhiteKnight(
                                  size: 60,
                                )
                              : BlackKnight(
                                  size: 60,
                                ),
                          onTap: () =>
                              Navigator.of(context).pop(PieceType.knight),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            cellHighlights: _highlightCells,
            chessBoardColors: ChessBoardColors(),
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
      ),
    );
  }
}
