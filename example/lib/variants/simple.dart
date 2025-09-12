import 'package:flutter/material.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

class SimpleBoardVariant extends StatelessWidget {
  const SimpleBoardVariant({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple ininteractive chess board"),
      ),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: SimpleChessBoard(
            engineThinking: false,
            fen: '8/8/8/4p1K1/2k1P3/8/8/8 b - - 0 1',
            onMove: ({required ShortMove move}) {
              debugPrint('${move.from}|${move.to}|${move.promotion}');
            },
            blackSideAtBottom: false,
            whitePlayerType: PlayerType.human,
            blackPlayerType: PlayerType.computer,
            lastMoveToHighlight: BoardArrow(from: 'e2', to: 'e4'),
            onPromote: () async => PieceType.queen,
            onPromotionCommited: ({required moveDone, required pieceType}) =>
                {},
            onTap: ({required cellCoordinate}) {},
            cellHighlights: <String, Color>{},
            chessBoardColors: ChessBoardColors()
              ..lastMoveArrowColor = Colors.redAccent,
            showPossibleMoves: false,
          ),
        ),
      ),
    );
  }
}
