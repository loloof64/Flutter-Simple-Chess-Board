import 'package:flutter/material.dart';
import '../models/board_arrow.dart';
import '../models/piece.dart';
import '../utils.dart' as utils;
import 'package:fpdart/fpdart.dart';

import 'board_color.dart';
import 'piece_type.dart';
import 'short_move.dart';
import 'square.dart';

typedef Promoted = Future<PieceType?> Function();
typedef Moved = void Function(ShortMove move);
typedef BuildPiece = Widget? Function(Piece piece, double size);
typedef BuildSquare = Widget? Function(BoardColor color, double size);
typedef BuildCustomPiece = Widget? Function(Square square);

class Board {
  final String fen;
  final double size;
  final BoardColor orientation;
  final Color lightSquareColor;
  final Color darkSquareColor;
  final Moved _onMove;
  final Promoted _onPromote;
  final Option<BuildPiece> buildPiece;
  final Option<BuildSquare> buildSquare;
  final Option<BuildCustomPiece> buildCustomPiece;
  final Color selectionHighlightColor;
  final Color lastMoveHighlightColor;
  final List<String> lastMove;
  final List<BoardArrow> arrows;

  Board({
    required this.fen,
    required this.size,
    required this.orientation,
    required this.lightSquareColor,
    required this.darkSquareColor,
    required Moved onMove,
    required Promoted onPromote,
    BuildPiece? buildPiece,
    BuildSquare? buildSquare,
    BuildCustomPiece? buildCustomPiece,
    required this.selectionHighlightColor,
    required this.lastMoveHighlightColor,
    required this.lastMove,
    required this.arrows,
  })  : _onMove = onMove,
        _onPromote = onPromote,
        buildPiece = Option.fromNullable(buildPiece),
        buildSquare = Option.fromNullable(buildSquare),
        buildCustomPiece = Option.fromNullable(buildCustomPiece);

  double get squareSize => size / 8;

  List<Square> get squares => utils.getSquares(this);

  Future<void> makeMove(ShortMove move) async {
    if (utils.isPromoting(fen, move)) {
      final pieceType = await promotion;
      return pieceType.match(
        (t) {
          _onMove(ShortMove(
            from: move.from,
            to: move.to,
            promotion: Option.of(t),
          ));
        },
        () => Future.error("Move cancelled"),
      );
    } else {
      _onMove(move);
    }
  }

  Future<Option<PieceType>> get promotion async {
    return Option.fromNullable(await _onPromote()).map(
      (t) => t == PieceType.king || t == PieceType.pawn ? PieceType.queen : t,
    );
  }
}
