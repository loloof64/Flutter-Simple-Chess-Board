import 'board_color.dart';
import 'piece_type.dart';

class Piece {
  final BoardColor color;
  final PieceType type;

  const Piece(this.color, this.type);

  static const Piece whitePawn = Piece(BoardColor.white, PieceType.pawn);
  static const Piece whiteKnight = Piece(BoardColor.white, PieceType.knight);
  static const Piece whiteBishop = Piece(BoardColor.white, PieceType.bishop);
  static const Piece whiteRook = Piece(BoardColor.white, PieceType.rook);
  static const Piece whiteQueen = Piece(BoardColor.white, PieceType.queen);
  static const Piece whiteKing = Piece(BoardColor.white, PieceType.king);

  static const Piece blackPawn = Piece(BoardColor.black, PieceType.pawn);
  static const Piece blackKnight = Piece(BoardColor.black, PieceType.knight);
  static const Piece blackBishop = Piece(BoardColor.black, PieceType.bishop);
  static const Piece blackRook = Piece(BoardColor.black, PieceType.rook);
  static const Piece blackQueen = Piece(BoardColor.black, PieceType.queen);
  static const Piece blackKing = Piece(BoardColor.black, PieceType.king);

  @override
  String toString() => '$color$type';

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && hashCode == other.hashCode;
  }

  @override
  int get hashCode => Object.hash(color, type);
}
