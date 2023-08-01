import 'package:chess/chess.dart' as ch;

import 'models/short_move.dart';

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
