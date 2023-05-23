import 'package:chess/chess.dart' as ch;
import 'package:fpdart/fpdart.dart';

import 'models/board.dart';
import 'models/board_color.dart';
import 'models/piece.dart';
import 'models/piece_type.dart';
import 'models/short_move.dart';
import 'models/square.dart';

List<Square> getSquares(Board board) {
  final chess = ch.Chess.fromFEN(board.fen);
  return ch.Chess.SQUARES.keys.map((squareName) {
    return Square(
      board: board,
      name: squareName,
      piece: Option.fromNullable(chess.get(squareName)).map(
        (t) => Piece(
          t.color == ch.Color.WHITE ? BoardColor.white : BoardColor.black,
          PieceType.fromString(t.type.toString()),
        ),
      ),
    );
  }).toList(growable: false);
}

bool isPromoting(String fen, ShortMove move) {
  final chess = ch.Chess.fromFEN(fen);

  final piece = chess.get(move.from);

  if (piece?.type != ch.PieceType.PAWN) {
    return false;
  }

  if (piece?.color != chess.turn) {
    return false;
  }

  if (!["1", "8"].any((it) => move.to.endsWith(it))) {
    return false;
  }

  return chess
      .moves({"square": move.from, "verbose": true})
      .map((it) => it["to"])
      .contains(move.to);
}

noop1(arg1) {}

Future<PieceType?> defaultPromoting() => Future.value(PieceType.queen);

void defaultPromotionCommitedHandler({required ShortMove moveDone}) => {};
