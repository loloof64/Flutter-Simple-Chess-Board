import 'board_color.dart';
import 'piece_type.dart';

class Piece {
  static Piece whitePawn = const Piece(BoardColor.white, PieceType.pawn);
  static Piece whiteKnight = const Piece(BoardColor.white, PieceType.knight);
  static Piece whiteBishop = const Piece(BoardColor.white, PieceType.bishop);
  static Piece whiteRook = const Piece(BoardColor.white, PieceType.rook);
  static Piece whiteQueen = const Piece(BoardColor.white, PieceType.queen);
  static Piece whiteKing = const Piece(BoardColor.white, PieceType.king);

  static Piece blackPawn = const Piece(BoardColor.black, PieceType.pawn);
  static Piece blackKnight = const Piece(BoardColor.black, PieceType.knight);
  static Piece blackBishop = const Piece(BoardColor.black, PieceType.bishop);
  static Piece blackRook = const Piece(BoardColor.black, PieceType.rook);
  static Piece blackQueen = const Piece(BoardColor.black, PieceType.queen);
  static Piece blackKing = const Piece(BoardColor.black, PieceType.king);

  final BoardColor color;
  final PieceType type;

  const Piece(this.color, this.type);

  String get name => "${color.name}${type.name}";
}
