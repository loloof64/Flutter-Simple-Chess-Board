import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:provider/provider.dart';
import '../models/board.dart';
import '../models/board_color.dart';
import '../models/half_move.dart';
import '../models/piece.dart';
import '../widgets/ui_tile.dart';

class UIPiece extends StatelessWidget {
  final String squareName;
  final BoardColor squareColor;
  final Piece piece;
  final double size;

  const UIPiece({
    Key? key,
    required this.squareName,
    required this.squareColor,
    required this.piece,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final board = Provider.of<Board>(context);
    final pieceWidget = board.buildPiece
        .flatMap((f) => Option.fromNullable(f(piece, size)))
        .getOrElse(() => _buildPiece(piece, size));

    return Draggable<HalfMove>(
      data: HalfMove(squareName, Option.of(piece)),
      child: pieceWidget,
      feedback: pieceWidget,
      childWhenDragging: UITile(
        color: squareColor,
        size: size,
      ),
    );
  }

  Widget _buildPiece(Piece piece, double size) {
    if (piece == Piece.whiteRook) {
      return WhiteRook(size: size);
    } else if (piece == Piece.whiteKnight) {
      return WhiteKnight(size: size);
    } else if (piece == Piece.whiteBishop) {
      return WhiteBishop(size: size);
    } else if (piece == Piece.whiteKing) {
      return WhiteKing(size: size);
    } else if (piece == Piece.whiteQueen) {
      return WhiteQueen(size: size);
    } else if (piece == Piece.whitePawn) {
      return WhitePawn(size: size);
    } else if (piece == Piece.blackRook) {
      return BlackRook(size: size);
    } else if (piece == Piece.blackKnight) {
      return BlackKnight(size: size);
    } else if (piece == Piece.blackBishop) {
      return BlackBishop(size: size);
    } else if (piece == Piece.blackKing) {
      return BlackKing(size: size);
    } else if (piece == Piece.blackQueen) {
      return BlackQueen(size: size);
    } else if (piece == Piece.blackPawn) {
      return BlackPawn(size: size);
    } else {
      return const SizedBox();
    }
  }
}
